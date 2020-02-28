//
//  NetResponseParser.m
//  EHDNetwork
//
//  Created by luohs on 2020/2/28.
//

#import "NetResponseParser.h"
#import "NetResponseError.h"
#import <MJExtension/MJExtension.h>
//@implementation NetResponseParser
//+ (instancetype)errorWithUserInfo:(id)userInfo context:(id)context
//{
//    if (![userInfo isKindOfClass:[NSDictionary class]]) {
//        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
//        dictionary[@"object"] = userInfo;
//        userInfo = dictionary;
//    }
//
//    NetResponseError *error = ({
//        [NetResponseError errorWithDomain:NSURLErrorDomain
//                                       code:NSURLErrorCannotParseResponse
//                                   userInfo:userInfo];
//    });
//
//    error->_context = context;
//
//    return error;
//}
//
//@end

@implementation NetResponseParser

+ (NSString *)stringWithObject:(id)object
{
    if ([object isKindOfClass:[NSString class]]) {
        return object;
    }
    if ([object respondsToSelector:@selector(stringValue)]) {
        return [object stringValue];
    }
    return nil;
}

+ (id)objectWithRawValue:(id)value dataClass:(Class)dataClass
{
    if ([value isKindOfClass:[NSNull class]]) {
        return nil;
    }
    
    if (!dataClass) {
        return value;
    }
    
    if (dataClass == [NSString class]) {
        if ([value isKindOfClass:[NSString class]]) {
            return value;
        } else if ([value respondsToSelector:@selector(stringValue)]) {
            return [value stringValue];
        }
        return nil;
    } else if (dataClass == [NSNumber class]) {
        if ([value isKindOfClass:[NSNumber class]]) {
            return value;
        } else if ([value respondsToSelector:@selector(doubleValue)]) {
            return @([value doubleValue]);
        }
        return nil;
    } else if (dataClass == [NSDictionary class]) {
        if ([value isKindOfClass:[NSDictionary class]]) {
            return [value copy];
        }
        return nil;
    } else if (dataClass == [NSArray class]) {
        if ([value isKindOfClass:[NSArray class]]) {
            return [value copy];
        }
        return nil;
    }
    
    if ([value isKindOfClass:[NSDictionary class]]) {
        return [dataClass mj_objectWithKeyValues:value];
    }
    
    if ([value isKindOfClass:[NSArray class]]) {
        NSMutableArray *array = [NSMutableArray array];
        for (id one in value) {
            id object = [self objectWithRawValue:one dataClass:dataClass];
            if (object) {
                [array addObject:object];
            }
        }
        return [array copy];
    }
    
    return value;
}

+ (NSDictionary *)dictionaryWithObject:(id)object error:(NSError **)error
{
    if ([object isKindOfClass:[NSDictionary class]]) {
        if (error) {
            *error = nil;
        }
        return object;
    }
    
    NSData *data = [object isKindOfClass:[NSData class]] ? object : nil;
    if (!data) {
        if (error) {
            *error = [NetResponseError errorWithUserInfo:object context:nil];
        }
        return nil;
    }
    
    NSError *e = nil;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data
                                                               options:NSJSONReadingMutableContainers
                                                                 error:&e];
    if (e) {
        if (error) {
            *error = e;
        }
        return nil;
    }
    
    if (!dictionary) {
        if (error) {
            *error = [NetResponseError errorWithUserInfo:object context:nil];
        }
        return nil;
    }
    
    if (error) {
        *error = nil;
    }
    return dictionary;
}
@end
