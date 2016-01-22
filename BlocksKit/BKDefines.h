//
//  BKDefines.h
//  BlocksKit

#pragma once

#import <Foundation/NSObjCRuntime.h>

#ifndef __has_builtin
#define __has_builtin(x) 0
#endif
#ifndef __has_include
#define __has_include(x) 0
#endif
#ifndef __has_feature
#define __has_feature(x) 0
#endif
#ifndef __has_attribute
#define __has_attribute(x) 0
#endif
#ifndef __has_extension
#define __has_extension(x) 0
#endif

#if !defined(NS_ASSUME_NONNULL_BEGIN)
# if  __has_feature(assume_nonnull)
#  define NS_ASSUME_NONNULL_BEGIN _Pragma("clang assume_nonnull begin")
#  define NS_ASSUME_NONNULL_END   _Pragma("clang assume_nonnull end")
# else
#  define NS_ASSUME_NONNULL_BEGIN
#  define NS_ASSUME_NONNULL_END
# endif
#endif

#if !__has_feature(nullability)
# define nonnull
# define nullable
# define null_unspecified
# define __nonnull
# define __nullable
# define __null_unspecified
#endif

#if __has_feature(objc_generics)
#   define __GENERICS(class, ...)      class<__VA_ARGS__>
#   define __GENERICS_TYPE(type)       type
#else
#   define __GENERICS(class, ...)      class
#   define __GENERICS_TYPE(type)       id
#endif

#if !defined(BK_INITIALIZER)
# if __has_attribute(objc_method_family)
#  define BK_INITIALIZER __attribute__((objc_method_family(init)))
# else
#  define BK_INITIALIZER
# endif
#endif

#if !defined(BK_ALERT_CONTROLLER_DEPRECATED)
# define BK_ALERT_CONTROLLER_DEPRECATED(intro) NS_DEPRECATED_IOS(intro, 8_0, "The BlocksKit extensions for UIAlertView and UIActionSheet are deprecated. Use UIAlertController instead.");
#endif

#if !defined(BK_URL_CONNECTION_DEPRECATED)
# define BK_URL_CONNECTION_DEPRECATED NS_DEPRECATED(10_5, 10_11, 2_0, 9_0, "The BlocksKit extensions for NSURLConnection are deprecated. Use NSURLSession instead.");
#endif
