//
//  ReactNativePackageManager.m
//  testApp
//
//  Created by atrl on 16/4/7.
//  Copyright © 2016年 Facebook. All rights reserved.
//
#import "ReactNativePackageManager.h"
#import "RCTBridge.h"
#import "RCTUtils.h"
#import "RCTPerformanceLogger.h"
#import "RCTBridgeDelegate.h"


@implementation ReactNativePackageManager{}

RCT_EXPORT_MODULE();

@synthesize bridge = _bridge;

static NSMutableDictionary *modules;
static NSString *url = @"http://localhost:8081/%@.ios.bundle?platform=ios&dev=false&withoutSource=true";

+(void) load:(NSString *)module withBlock:(RCTSourceLoadBlock)onComplete
{
  if (!modules) {
    modules =[NSMutableDictionary new];
  }
  
  if ([modules objectForKey:module]) {
    onComplete(nil, modules[module]);
  }else{
    NSURL *scriptURL = [NSURL URLWithString:[NSString stringWithFormat:url, module]];
    // Load remote script file
    NSURLSessionDataTask *task =
    [[NSURLSession sharedSession] dataTaskWithURL:scriptURL
                                completionHandler:
     ^(NSData *data, NSURLResponse *response, NSError *error) {
       // Handle general request errors
       if (error) {
         onComplete(error, nil);
         return;
       }
       
       // Parse response as text
       NSStringEncoding encoding = NSUTF8StringEncoding;
       if (response.textEncodingName != nil) {
         CFStringEncoding cfEncoding = CFStringConvertIANACharSetNameToEncoding((CFStringRef)response.textEncodingName);
         if (cfEncoding != kCFStringEncodingInvalidId) {
           encoding = CFStringConvertEncodingToNSStringEncoding(cfEncoding);
         }
       }
       // Handle HTTP errors
       if ([response isKindOfClass:[NSHTTPURLResponse class]] && ((NSHTTPURLResponse *)response).statusCode != 200) {
         NSString *rawText = [[NSString alloc] initWithData:data encoding:encoding];
         NSDictionary *userInfo;
         NSDictionary *errorDetails = RCTJSONParse(rawText, nil);
         if ([errorDetails isKindOfClass:[NSDictionary class]] &&
             [errorDetails[@"errors"] isKindOfClass:[NSArray class]]) {
           NSMutableArray<NSDictionary *> *fakeStack = [NSMutableArray new];
           for (NSDictionary *err in errorDetails[@"errors"]) {
             [fakeStack addObject: @{
                                     @"methodName": err[@"description"] ?: @"",
                                     @"file": err[@"filename"] ?: @"",
                                     @"lineNumber": err[@"lineNumber"] ?: @0
                                     }];
           }
           userInfo = @{
                        NSLocalizedDescriptionKey: errorDetails[@"message"] ?: @"No message provided",
                        @"stack": fakeStack,
                        };
         } else {
           userInfo = @{NSLocalizedDescriptionKey: rawText};
         }
         error = [NSError errorWithDomain:@"JSServer"
                                     code:((NSHTTPURLResponse *)response).statusCode
                                 userInfo:userInfo];
         onComplete(error, data);
         return;
       }
       
       [modules setObject:data forKey:module];
       onComplete(nil, data);
     }];
    
    [task resume];
  }
};

-(void) runModule:(NSString *)moduleName
{
    NSDictionary *appParameters = @
    {
      @"rootTag": @1,
      @"initialProps": @{},
    };
    
    [_bridge enqueueJSCall:@"AppRegistry.runApplication"
                      args:@[moduleName, appParameters]];
}

RCT_EXPORT_METHOD(loadModule:(NSString *) moduleName)
{
  if ([modules objectForKey:moduleName]) {
    [self runModule:moduleName];
  }else{
    [ReactNativePackageManager load:moduleName withBlock:^(NSError *error, NSData* data){
      [_bridge enqueueApplicationScript:data url:[_bridge bundleURL] onComplete:^(NSError *scriptLoadError) {
        [self runModule:moduleName];
      }];
    }];
  }
}

@end