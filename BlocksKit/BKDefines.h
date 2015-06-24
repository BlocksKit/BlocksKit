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