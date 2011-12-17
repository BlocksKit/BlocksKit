//
//  A2BlockDelegate.m
//  A2DynamicDelegate
//
//  Created by Alexsander Akers on 12/6//11.
//  Copyright (c) 2011 Pandamonia LLC. All rights reserved.
//

#import <objc/runtime.h>
#import <pthread.h>

#import "A2BlockDelegate.h"
#import "A2DynamicDelegate.h"

#if __has_attribute(objc_arc)
	#error "At present, 'A2BlockDelegate.m' may not be compiled with ARC. This is a limitation of the Obj-C runtime library. See here: http://j.mp/tJsoOV"
#endif

#ifndef NSAlwaysAssert
	#define NSAlwaysAssert(condition, desc, ...) \
		do { if (!(condition)) { [NSException raise: NSInternalInconsistencyException format: [NSString stringWithFormat: @"%s: %@", __PRETTY_FUNCTION__, (desc)], ## __VA_ARGS__]; } } while(0)
#endif

static void *A2BlockDelegateProtocolsKey;
static void *A2BlockDelegateMapKey;
static void *A2BlockDelegateMapMutexDataKey;

static char *a2_property_copyAttributeValue(objc_property_t property, const char *attributeName);
static void *a2_blockPropertyGetter(id self, SEL _cmd);
static void a2_blockPropertySetter(id self, SEL _cmd, id block);

@interface NSObject ()

+ (BOOL) a2_resolveInstanceMethod: (SEL) selector;
+ (BOOL) a2_getProtocol: (Protocol **) _protocol representedSelector: (SEL *) _representedSelector forPropertyAccessor: (SEL) selector __attribute((nonnull));

+ (int) a2_lockMapMutex;
+ (int) a2_unlockMapMutex;

+ (NSDictionary *) a2_mapForProtocol: (Protocol *) protocol;

+ (NSMutableDictionary *) a2_propertyMapForProtocol: (Protocol *) protocol;
+ (NSMutableDictionary *) a2_selectorCacheForProtocol: (Protocol *) protocol;

+ (NSMutableSet *) a2_protocols;

+ (Protocol *) a2_dataSourceProtocol;
+ (Protocol *) a2_delegateProtocol;

+ (pthread_mutex_t *) a2_mapMutex;

@end

@implementation NSObject (A2BlockDelegate)

#pragma mark - Helpers

+ (BOOL) a2_resolveInstanceMethod: (SEL) selector
{
	Protocol *protocol;
	SEL representedSelector;
	
	NSUInteger argc = [[NSStringFromSelector(selector) componentsSeparatedByString: @":"] count] - 1;
	if (argc <= 1 && [self a2_getProtocol: &protocol representedSelector: &representedSelector forPropertyAccessor: selector])
	{
		IMP implementation;
		const char *types;
		
		if (argc == 1)
		{
			if (&imp_implementationWithBlock)
			{
				implementation = imp_implementationWithBlock(^(NSObject *obj, id block) {
					[[obj dynamicDelegateForProtocol: protocol] implementMethod: representedSelector withBlock: block];
				});
			}
			else
			{
				implementation = (IMP) a2_blockPropertySetter;
			}
			
			types = "v@:@?";
		}
		else
		{
			if (&imp_implementationWithBlock)
			{
				implementation = imp_implementationWithBlock(^id(NSObject *obj) {
					return [[obj dynamicDelegateForProtocol: protocol] blockImplementationForMethod: representedSelector];
				});
			}
			else
			{
				implementation = (IMP) a2_blockPropertyGetter;
			}
			
			types = "@?@:";
		}
		
		if (class_addMethod(self, selector, implementation, types)) return YES;
	}
	
	return [self a2_resolveInstanceMethod: selector];
}
+ (BOOL) a2_getProtocol: (Protocol **) _protocol representedSelector: (SEL *) _representedSelector forPropertyAccessor: (SEL) selector
{
	__block BOOL found = NO;
	
	[[self a2_protocols] enumerateObjectsUsingBlock: ^(Protocol *protocol, BOOL *stop) {
		[self a2_lockMapMutex];
		NSString *representedName = [[self a2_selectorCacheForProtocol: protocol] objectForKey: NSStringFromSelector(selector)];
		[self a2_unlockMapMutex];
		
		if (representedName)
		{
			*_representedSelector = NSSelectorFromString(representedName);
			*_protocol = protocol;
			found = *stop = YES;
		}
	}];
	
	if (found) return YES;
	
	NSString *propertyName = NSStringFromSelector(selector);
	if ([propertyName hasPrefix: @"set"])
	{
		unichar firstChar = [propertyName characterAtIndex: 3];
		NSString *coda = [propertyName substringWithRange: NSMakeRange(4, propertyName.length - 5)]; // -5 to remove trailing ':'
		propertyName = [NSString stringWithFormat: @"%c%@", tolower(firstChar), coda];
	}
	
	if (!class_getProperty(self, propertyName.UTF8String))
	{
		// It's not a simple -xBlock/setXBlock: pair
		propertyName = nil;
		
		const char *selectorName = sel_getName(selector);
		char lastChar = selectorName[strlen(selectorName) - 1];
		
		// If the selector's last character is a ':', it's a setter.
		const BOOL isSetter = (lastChar == ':');
	
		unsigned int i, count;
		objc_property_t *properties = class_copyPropertyList(self, &count);
		
		for (i = 0; i < count; ++i)
		{
			objc_property_t property = properties[i];
			
			const char *key = (isSetter ? "S" : "G");
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
	
	if (!propertyName) return NO;

	[[self a2_protocols] enumerateObjectsUsingBlock: ^(Protocol *protocol, BOOL *stop) {
		[self a2_lockMapMutex];
		NSString *selectorName = [[self a2_propertyMapForProtocol: protocol] objectForKey: propertyName];
		
		if (!selectorName) 
		{
			[self a2_unlockMapMutex];
			return;
		}
		
		[[self a2_selectorCacheForProtocol: protocol] setObject: selectorName forKey: NSStringFromSelector(selector)];
		[self a2_unlockMapMutex];
		
		*_representedSelector = NSSelectorFromString(selectorName);
		*_protocol = protocol;
		found = *stop = YES;
	}];
	
	return found;
;}

+ (NSDictionary *) a2_mapForProtocol: (Protocol *) protocol
{
	[[self a2_protocols] addObject: protocol];
	
	NSMutableDictionary *map = objc_getAssociatedObject(self, &A2BlockDelegateMapKey);
	if (!map)
	{
		map = [NSMutableDictionary dictionary];
		objc_setAssociatedObject(self, &A2BlockDelegateMapKey, map, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
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
	NSMutableSet *protocols = objc_getAssociatedObject(self, &A2BlockDelegateProtocolsKey);
	if (!protocols)
	{
		protocols = [NSMutableSet set];
		objc_setAssociatedObject(self, &A2BlockDelegateProtocolsKey, protocols, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	
	return protocols;
}

#pragma mark - Map Mutex

+ (int) a2_unlockMapMutex
{
	return pthread_mutex_unlock([self a2_mapMutex]);
}
+ (int) a2_lockMapMutex
{
	return pthread_mutex_lock([self a2_mapMutex]);
}

+ (pthread_mutex_t *) a2_mapMutex
{
	NSData *mutexData = objc_getAssociatedObject(self, &A2BlockDelegateMapMutexDataKey);
	if (mutexData)
	{
		return (pthread_mutex_t *) mutexData.bytes;
	}
	
	pthread_mutex_t *mutex = malloc(sizeof(pthread_mutex_t));
	pthread_mutex_init(mutex, NULL);
	mutexData = [NSData dataWithBytesNoCopy: mutex length: sizeof(pthread_mutex_t)];
	objc_setAssociatedObject(self, &A2BlockDelegateMapMutexDataKey, mutexData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	return mutex;
}

#pragma mark - Data Source

+ (void) linkCategoryBlockProperty: (NSString *) propertyName withDataSourceMethod: (SEL) selector
{
	NSDictionary *dictionary = [NSDictionary dictionaryWithObject: NSStringFromSelector(selector) forKey: propertyName];
	[self linkProtocol: [self a2_dataSourceProtocol] methods: dictionary];
}
+ (void) linkDataSourceMethods: (NSDictionary *) dictionary
{
	[self linkProtocol: [self a2_dataSourceProtocol] methods: dictionary];
}

#pragma mark - Delegate

+ (void) linkCategoryBlockProperty: (NSString *) propertyName withDelegateMethod: (SEL) selector
{
	NSDictionary *dictionary = [NSDictionary dictionaryWithObject: NSStringFromSelector(selector) forKey: propertyName];
	[self linkProtocol: [self a2_delegateProtocol] methods: dictionary];
}
+ (void) linkDelegateMethods: (NSDictionary *) dictionary
{
	[self linkProtocol: [self a2_delegateProtocol] methods: dictionary];
}

#pragma mark - Other Protocol

+ (void) linkCategoryBlockProperty: (NSString *) propertyName withProtocol: (Protocol *) protocol method: (SEL) selector
{
	NSDictionary *dictionary = [NSDictionary dictionaryWithObject: NSStringFromSelector(selector) forKey: propertyName];
	[self linkProtocol: protocol methods: dictionary];
}
+ (void) linkProtocol: (Protocol *) protocol methods: (NSDictionary *) dictionary
{
	[dictionary enumerateKeysAndObjectsUsingBlock: ^(NSString *propertyName, NSString *selectorName, __unused BOOL *stop) {
		objc_property_t property = class_getProperty(self, propertyName.UTF8String);
		NSAlwaysAssert(property, @"Property \"%@\" does not exist on class %s", propertyName, class_getName(self));
		
		char *dynamic = a2_property_copyAttributeValue(property, "D");
		NSAlwaysAssert(dynamic, @"Property \"%@\" on class %s must be backed with \"@dynamic\"", propertyName, class_getName(self));
		free(dynamic);
		
		char *copy = a2_property_copyAttributeValue(property, "C");
		NSAlwaysAssert(copy, @"Property \"%@\" on class %s must be defined with the \"copy\" attribute", propertyName, class_getName(self));
		free(copy);
		
		SEL selector = NSSelectorFromString(selectorName);
		struct objc_method_description methodDescription = protocol_getMethodDescription(protocol, selector, YES, YES);
		if (!methodDescription.name) methodDescription = protocol_getMethodDescription(protocol, selector, NO, YES);
		NSAlwaysAssert(methodDescription.name, @"Instance method %@ not found in protocol <%s>", selectorName, protocol_getName(protocol));
	}];
	
	static void *didSwizzleKey;
	if (!objc_getAssociatedObject(self, &didSwizzleKey))
	{
		Class metaClass = object_getClass(self);
		SEL origSel = @selector(resolveInstanceMethod:);
		SEL newSel = @selector(a2_resolveInstanceMethod:);
		
		Method origMethod = class_getClassMethod(self, origSel);
		Method newMethod = class_getClassMethod(self, newSel);
		
		if (class_addMethod(metaClass, origSel, method_getImplementation(newMethod), method_getTypeEncoding(newMethod)))
			class_replaceMethod(metaClass, newSel, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
		else
			method_exchangeImplementations(origMethod, newMethod);

		objc_setAssociatedObject(self, &didSwizzleKey, (void *) kCFBooleanTrue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	
	[self a2_lockMapMutex];
	[[self a2_propertyMapForProtocol: protocol] addEntriesFromDictionary: dictionary];
	[self a2_unlockMapMutex];
}

@end

static void *a2_blockPropertyGetter(NSObject *self, SEL _cmd)
{
	Protocol *protocol;
	SEL representedSelector;
	if (![self.class a2_getProtocol: &protocol representedSelector: &representedSelector forPropertyAccessor: _cmd])
		return nil;

	return [[self dynamicDelegateForProtocol: protocol] blockImplementationForMethod: representedSelector];
}
static void a2_blockPropertySetter(NSObject *self, SEL _cmd, id block)
{
	Protocol *protocol;
	SEL representedSelector;
	if (![self.class a2_getProtocol: &protocol representedSelector: &representedSelector forPropertyAccessor: _cmd])
		return;
	
	[[self dynamicDelegateForProtocol: protocol] implementMethod: representedSelector withBlock: block];
}

/*
 * Copyright (c) 1999-2007 Apple Inc.  All Rights Reserved.
 * 
 * @APPLE_LICENSE_HEADER_START@
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
 * @APPLE_LICENSE_HEADER_END@
 */

/*
 * Changelog:
 * - 12/7/11 - Wrote wrapper for `property_copyAttributeValue` if it is not defined (Alexsander Akers)
 */

static unsigned int a2_iteratePropertyAttributes(const char *attrs, BOOL (*fn)(unsigned int index, void *ctx1, void *ctx2, const char *name, size_t nlen, const char *value, size_t vlen), void *ctx1, void *ctx2)
{
	/*
	 Property attribute string format:
	 - Comma-separated name-value pairs. 
	 - Name and value may not contain ,
	 - Name may not contain "
	 - Value may be empty
	 - Name is single char, value follows
	 - OR Name is double-quoted string of 2+ chars, value follows
	 */
	
    if (!attrs) return 0;
	
    const char *attrsend = attrs + strlen(attrs);
    unsigned int attrcount = 0;
	
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
		
        BOOL more = (*fn)(attrcount, ctx1, ctx2, 
                          nameStart, nameEnd-nameStart, 
                          valueStart, valueEnd-valueStart);
        attrcount++;
        if (!more) break;
    }
	
    return attrcount;
}
static BOOL a2_findOneAttribute(__unused unsigned int index, void *ctxa, void *ctxs, const char *name, size_t nlen, const char *value, size_t vlen)
{
	const char *query = (char *)ctxa;
    char **resultp = (char **)ctxs;
	
    if (strlen(query) == nlen  &&  0 == strncmp(name, query, nlen)) {
        char *result = calloc(vlen+1, 1);
        memcpy(result, value, vlen);
        result[vlen] = '\0';
        *resultp = result;
        return NO;
    }
	
    return YES;
}
static char *a2_property_copyAttributeValue(objc_property_t property, const char *name)
{
	if (&property_copyAttributeValue)
	{
		return property_copyAttributeValue(property, name);
	}
	
	if (!property || !name || *name == '\0') return NULL;
	
    char *result = NULL;
	const char *attributes = property_getAttributes(property);
	a2_iteratePropertyAttributes(attributes, &a2_findOneAttribute, (void *) name, &result);
    return result;
}
