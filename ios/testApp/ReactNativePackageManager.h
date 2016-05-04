//
//  ReactNativePackageManager.h
//  testApp
//
//  Created by atrl on 16/4/7.
//  Copyright © 2016年 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCTBridge.h"
#import "RCTBridgeModule.h"
#import "RCTBridgeDelegate.h"

@interface ReactNativePackageManager : NSObject <RCTBridgeModule>
+(void) load:(NSString *)module withBlock:(RCTSourceLoadBlock)onComplete;
@end