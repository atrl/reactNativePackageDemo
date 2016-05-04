//
//  ReactDownload.h
//  testApp
//
//  Created by atrl on 16/4/14.
//  Copyright © 2016年 Facebook. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "RCTBridgeDelegate.h"

@interface ReactDownload : NSObject
+(void) module:(NSString *)module withBlock:(RCTSourceLoadBlock)onComplete;
@end

