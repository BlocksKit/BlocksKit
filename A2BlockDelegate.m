//
//  A2BlockDelegate.m
//  A2DynamicDelegate
//
//  Created by Alexsander Akers on 11/30/11.
//  Copyright (c) 2011 Pandamonia LLC. All rights reserved.
//

#import "A2BlockDelegate.h"
#import "A2DynamicDelegate.h"
#import <objc/runtime.h>

#if __has_attribute(objc_arc)
	#error "At present, 'A2BlockDelegate.m' may not be compiled with ARC. This is a limitation of the Obj-C runtime library. See here: http://j.mp/tJsoOV"
#endif

#ifndef NSAlwaysAssert
	#define NSAlwaysAssert(condition, desc, ...) \
		do { if (!(condition)) { [NSException raise: NSInternalInconsistencyException format: [NSString stringWithFormat: @"%s: %@", __PRETTY_FUNCTION__, (desc)], ## __VA_ARGS__]; } } while(0)
#endif

// Function Declarations
extern Protocol *a2_dataSourceProtocol(Class cls);
extern Protocol *a2_delegateProtocol(Class cls);
extern char *property_copyAttributeValue(objc_property_t property, const char *attributeName) WEAK_IMPORT_ATTRIBUTE;

SEL a2_getterForProperty(Class cls, NSString *propertyName);
SEL a2_setterForProperty(Class cls, NSString *propertyName);
NSString *a2_nameForPropertyAccessor(Class cls, SEL selector);
static char *a2_property_copyAttributeValue(objc_property_t property, const char *query);

// Block Property Accessors
static id a2_blockPropertyGetter(NSObject *self, SEL _cmd);
static void a2_blockPropertySetter(NSObject *self, SEL _cmd, id block);

#pragma mark -

@interface NSObject (A2BlockDelegatePrivate)

- (void) a2_checkRegisteredProtocol:(Protocol *)protocol;

+ (NSDictionary *) a2_mapForProtocol: (Protocol *) protocol;

+ (NSMutableDictionary *) a2_propertyMapForProtocol: (Protocol *) protocol;
+ (NSMutableDictionary *) a2_selectorCacheForProtocol: (Protocol *) protocol;

+ (NSMutableSet *) a2_protocols;

@end

#pragma mark -

@implementation NSObject (A2BlockDelegate)

#pragma mark Helpers

+ (NSDictionary *) a2_mapForProtocol: (Protocol *) protocol
{
	[[self a2_protocols] addObject: protocol];
	
	NSMutableDictionary *map = objc_getAssociatedObject(self, _cmd);
	if (!map)
	{
		map = [NSMutableDictionary dictionary];
		objc_setAssociatedObject(self, _cmd, map, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	
	NSDictionary *protocolMap = [map objectForKey: NSStringFromProtocol(protocol)];
	if (!protocolMap)
	{
		protocolMap = [NSDictionary dictionaryWithObjectsAndKeys:
					   [NSMutableDictionary dictionary], @"properties",
					   [NSMutableDictionary dictionary], @"cache", nil];
		[map setObject: protocolMap forKey: NSStringFromProtocol(protocol)];
	}
	
	return protocolMap;
}

+ (NSMutableDictionary *) a2_propertyMapForProtocol: (Protocol *) protocol
{
	return [[self a2_mapForProtocol: protocol] objectForKey: @"properties"];
}
+ (NSMutableDictionary *) a2_selectorCacheForProtocol: (Protocol *) protocol
{
	return [[self a2_mapForProtocol: protocol] objectForKey: @"cache"];
}

+ (NSMutableSet *) a2_protocols
{
	NSMutableSet *protocols = objc_getAssociatedObject(self, _cmd);
	if (!protocols)
	{
		protocols = [NSMutableSet set];
		objc_setAssociatedObject(self, _cmd, protocols, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	
	return protocols;
}

#pragma mark Data Source

+ (void) linkCategoryBlockProperty: (NSString *) propertyName withDataSourceMethod: (SEL) selector
{
	NSDictionary *dictionary = [NSDictionary dictionaryWithObject: NSStringFromSelector(selector) forKey: propertyName];
	[self linkProtocol: a2_dataSourceProtocol(self) methods: dictionary];
}
+ (void) linkDataSourceMethods: (NSDictionary *) dictionary
{
	[self linkProtocol: a2_dataSourceProtocol(self) methods: dictionary];
}

#pragma mark Delegate

+ (void) linkCategoryBlockProperty: (NSString *) propertyName withDelegateMethod: (SEL) selector
{
	NSDictionary *dictionary = [NSDictionary dictionaryWithObject: NSStringFromSelector(selector) forKey: propertyName];
	[self linkProtocol: a2_delegateProtocol(self) methods: dictionary];
}
+ (void) linkDelegateMethods: (NSDictionary *) dictionary
{
	[self linkProtocol: a2_delegateProtocol(self) methods: dictionary];
}

#pragma mark Other Protocol

+ (void) linkCategoryBlockProperty: (NSString *) propertyName withProtocol: (Protocol *) protocol method: (SEL) selector
{
	NSDictionary *dictionary = [NSDictionary dictionaryWithObject: NSStringFromSelector(selector) forKey: propertyName];
	[self linkProtocol: protocol methods: dictionary];
}
+ (void) linkProtocol: (Protocol *) protocol methods: (NSDictionary *) dictionary
{
	NSMutableDictionary *propertyMap = [self a2_propertyMapForProtocol: protocol];
    
    [dictionary.allKeys enumerateObjectsUsingBlock:^(NSString *propertyName, __unused NSUInteger idx, __unused BOOL *stop) {
        objc_property_t property = class_getProperty(self, propertyName.UTF8String);
		NSAlwaysAssert(property, @"Property \"%@\" does not exist on class %s", propertyName, class_getName(self));
        
		char *dynamic = a2_property_copyAttributeValue(property, "D");
		NSAlwaysAssert(dynamic, @"Property \"%@\" on class %s must be backed with \"@dynamic\"", propertyName, class_getName(self));
		free(dynamic);
		
		char *copy = a2_property_copyAttributeValue(property, "C");
		NSAlwaysAssert(copy, @"Property \"%@\" on class %s must be defined with the \"copy\" attribute", propertyName, class_getName(self));
		free(copy);
		
		NSAlwaysAssert(![propertyMap objectForKey:propertyMap], @"Class \"%s\" already implements a \"%@\" property.", class_getName(self), propertyName);
		
		SEL getter = a2_getterForProperty(self, propertyName);
        IMP getterImplementation = (IMP) a2_blockPropertyGetter;
		const char *getterTypes = "@@:";
		BOOL success = class_addMethod(self, getter, getterImplementation, getterTypes);
		NSAlwaysAssert(success, @"Could not implement getter for \"%@\" property.", propertyName);
		
		SEL setter = a2_setterForProperty(self, propertyName);
        IMP setterImplementation  = (IMP) a2_blockPropertySetter;
		const char *setterTypes = "v@:@";
		success = class_addMethod(self, setter, setterImplementation, setterTypes);
		NSAlwaysAssert(success, @"Could not implement setter for \"%@\" property.", propertyName);
    }];
	
	[propertyMap addEntriesFromDictionary: dictionary];
}

@end

#pragma mark - Functions

SEL a2_getterForProperty(Class cls, NSString *propertyName)
{
	SEL getter = NULL;
    
	objc_property_t property = class_getProperty(cls, propertyName.UTF8String);
	if (property)
	{
		char *getterName = a2_property_copyAttributeValue(property, "G");
		if (getterName) getter = sel_getUid(getterName);
		free(getterName);
	}
	
	if (!getter)
	{
		getter = NSSelectorFromString(propertyName);
	}
	
	return getter;
}
SEL a2_setterForProperty(Class cls, NSString *propertyName)
{
	SEL setter = NULL;
    
	objc_property_t property = class_getProperty(cls, propertyName.UTF8String);
	if (property)
	{
		char *setterName = a2_property_copyAttributeValue(property, "S");
		if (setterName) setter = sel_getUid(setterName);
		free(setterName);
	}
	
	if (!setter)
	{
		unichar firstChar = [propertyName characterAtIndex: 0];
		NSString *coda = [propertyName substringFromIndex: 1];
		
		setter = NSSelectorFromString([NSString stringWithFormat: @"set%c%@:", toupper(firstChar), coda]);
	}
	
	return setter;
}

NSString *a2_nameForPropertyAccessor(Class cls, SEL selector) {
    if (!cls || !selector)
        return nil;
    
    NSString *propertyName = NSStringFromSelector(selector);
    if ([propertyName hasPrefix: @"set"])
    {
        unichar firstChar = [propertyName characterAtIndex: 3];
        NSString *coda = [propertyName substringWithRange: NSMakeRange(4, propertyName.length - 5)]; // -5 to remove trailing ':'
        propertyName = [NSString stringWithFormat: @"%c%@", tolower(firstChar), coda];
    }
    
    if (!class_getProperty(cls, propertyName.UTF8String))
    {
        // It's not a simple -xBlock/setXBlock: pair
        
        // If selector ends in ':', it's a setter.
        const BOOL isSetter = [NSStringFromSelector(selector) hasSuffix: @":"];
        const char *key = (isSetter ? "S" : "G");
        
        unsigned int i, count;
        objc_property_t *properties = class_copyPropertyList(cls, &count);
        
        for (i = 0; i < count; ++i)
        {
            objc_property_t property = properties[i];
            
            char *accessorName = a2_property_copyAttributeValue(property, key);
            SEL accessor = sel_getUid(accessorName);
            if (sel_isEqual(selector, accessor))
            {
                propertyName = [NSString stringWithUTF8String: property_getName(property)];
                break; // from for-loop
            }
            
            free(accessorName);
        }
        
        free(properties);
    }
    
    return propertyName;
}

/*
 * Copyright (c) 1999-2007 Apple Inc.  All Rights Reserved.
 * 
 * This file contains Original Code and/or Modifications of Original Code
 * as defined in and that are subject to the Apple Public Source License
 * Version 2.0 (the 'License'). You may not use this file except in
 * compliance with the License. Please obtain a copy of the License at
 * http://www.opensource.apple.com/apsl/ and read it before using this
 * file.
 * 
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER
 * EXPRESS OR IMPLIED, AND APPLE HEREBY DISCLAIMS ALL SUCH WARRANTIES,
 * INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT.
 * Please see the License for the specific language governing rights and
 * limitations under the License.
 * 
 */
static char *a2_property_copyAttributeValue(objc_property_t property, const char *query)
{
	if (&property_copyAttributeValue != NULL)
		return property_copyAttributeValue(property, query);
	
	if (!property || !query || *query == '\0') return NULL;
	
    __block char *result = NULL;
	const char *attrs = property_getAttributes(property);
    
    BOOL(^fn)(const char *, size_t, const char *, size_t) = ^BOOL(const char *name, size_t nlen, const char *value, size_t vlen) {
        if (strlen(query) == nlen && !strncmp(name, query, nlen)) {
            result = calloc(vlen+1, 1);
            memcpy(result, value, vlen);
            result[vlen] = '\0';
            return NO;
        }
        
        return YES;
    };
    
    /*
	 Property attribute string format:
	 - Comma-separated name-value pairs. 
	 - Name and value may not contain ,
	 - Name may not contain "
	 - Value may be empty
	 - Name is single char, value follows
	 - OR Name is double-quoted string of 2+ chars, value follows
	 */
    const char *attrsend = attrs + strlen(attrs);
    while (*attrs) {
        // Find the next comma-separated attribute
        const char *start = attrs;
        const char *end = start + strcspn(attrs, ",");
		
        // Move attrs past this attribute and the comma (if any)
        attrs = *end ? end+1 : end;
		
        assert(attrs <= attrsend);
        assert(start <= attrsend);
        assert(end <= attrsend);
        
        // Skip empty attribute
        if (start == end) continue;
		
        // Process one non-empty comma-free attribute [start,end)
        const char *nameStart;
        const char *nameEnd;
		
        assert(start < end);
        assert(*start);
        if (*start != '\"') {
            // single-char short name
            nameStart = start;
            nameEnd = start+1;
            start++;
        }
        else {
            // double-quoted long name
            nameStart = start+1;
            nameEnd = nameStart + strcspn(nameStart, "\",");
            start++;                       // leading quote
            start += nameEnd - nameStart;  // name
            if (*start == '\"') start++;   // trailing quote, if any
        }
		
        // Process one possibly-empty comma-free attribute value [start,end)
        const char *valueStart;
        const char *valueEnd;
		
        assert(start <= end);
		
        valueStart = start;
        valueEnd = end;
		
        BOOL more = fn(nameStart, nameEnd-nameStart, valueStart, valueEnd-valueStart);
        if (!more) break;
    }
    
    return result;
}

static BOOL a2_informationForBlockProperty(Class cls, SEL selector, Protocol **outProtocol, SEL *outSelector) {
    __block BOOL found = NO;
    
    NSString *key = NSStringFromSelector(selector);
    
    [[cls a2_protocols] enumerateObjectsUsingBlock: ^(Protocol *protocol, BOOL *stop) {
        NSString *representedName = [[cls a2_selectorCacheForProtocol: protocol] objectForKey: key];
        
        if (representedName)
        {
            *outSelector = NSSelectorFromString(representedName);
            *outProtocol = protocol;
            found = *stop = YES;
        }
    }];
    
    if (found) return YES;
    
    NSString *propertyName = a2_nameForPropertyAccessor(cls, selector);
    
    if (!propertyName.length) return NO;
    
    [[cls a2_protocols] enumerateObjectsUsingBlock: ^(Protocol *protocol, BOOL *stop) {
        NSString *selectorName = [[cls a2_propertyMapForProtocol: protocol] objectForKey: propertyName];
        if (!selectorName) return;
        
        [[cls a2_selectorCacheForProtocol: protocol] setObject: selectorName forKey: key];
        
        *outSelector = NSSelectorFromString(selectorName);
        *outProtocol = protocol;
        found = *stop = YES;
    }];
    
    return found;
}

static id a2_blockPropertyGetter(NSObject *self, SEL _cmd)
{
	Protocol *protocol = NULL;
	SEL selector = NULL;
	if (!a2_informationForBlockProperty(self.class, _cmd, &protocol, &selector))
        return nil;
    
	return [[self dynamicDelegateForProtocol: protocol] blockImplementationForMethod: selector];
}
static void a2_blockPropertySetter(NSObject *self, SEL _cmd, id block)
{
	Protocol *protocol = NULL;
	SEL selector = NULL;
	if (!a2_informationForBlockProperty(self.class, _cmd, &protocol, &selector))
        return;
	
	if ([self respondsToSelector:@selector(a2_checkRegisteredProtocol:)])
		[self performSelector:@selector(a2_checkRegisteredProtocol:) withObject:protocol];
    
	[[self dynamicDelegateForProtocol: protocol] implementMethod: selector withBlock: block];
}