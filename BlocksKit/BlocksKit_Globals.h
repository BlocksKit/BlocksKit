//
//  BlocksKit_Globals.h
//  BlocksKit
//

#pragma once

typedef void(^BKBlock)();
typedef void(^BKSenderBlock)(id sender);
typedef void(^BKWithObjectBlock)(id obj, id arg);

typedef void(^BKObservationBlock)(id obj, NSDictionary *change);
typedef void(^BKKeyValueBlock)(id key, id obj);

typedef BOOL(^BKValidationBlock)(id obj);

typedef id(^BKTransformBlock)(id obj);
typedef id(^BKKeyValueTransformBlock)(id key, id obj);

typedef id(^BKAccumulationBlock)(id sum, id obj);