//
//  ReactView.m
//  testApp
//
//  Created by atrl on 16/4/12.
//  Copyright © 2016年 Facebook. All rights reserved.
//

#import "ReactView.h"
#import "RCTRootView.h"
#import "ReactNativePackageManager.h"


@interface ReactView()<RCTBridgeDelegate>
@property(nonatomic, strong) NSString *moduleName;
@property(nonatomic, strong) RCTRootView *rootView;
@end

@implementation ReactView

- (instancetype)initWithFrame:(CGRect)frame
                       module:(NSString*)module
{
  self = [super initWithFrame:frame];
  if (self)
  {
    _moduleName = module;
    RCTBridge *bridge = [[RCTBridge alloc] initWithDelegate:self launchOptions:nil];
    _rootView = [[RCTRootView alloc] initWithBridge:bridge moduleName:module initialProperties:nil];
  }
  
  [self addSubview:_rootView];
  _rootView.frame = self.bounds;
  return self;
}

#pragma mark -- RCTBridgeDelegate --

- (NSURL *)sourceURLForBridge:(RCTBridge *)bridge
{
  return [NSURL URLWithString:@"http://localhost:8081/index.ios.bundle?platform=ios&dev=true&withoutSource=true"];
}

- (void)loadSourceForBridge:(RCTBridge *)bridge withBlock:(RCTSourceLoadBlock)onComplete
{
  NSURL *jsCodeLocation;
  
  jsCodeLocation = [[NSBundle mainBundle] URLForResource:@"main" withExtension:@"jsbundle"];
  
  NSString *filePath = jsCodeLocation.path;
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSError *error = nil;
    NSData *source = [NSData dataWithContentsOfFile:filePath
                                            options:NSDataReadingMappedIfSafe
                                              error:&error];

    [ReactNativePackageManager load:_moduleName withBlock:^(NSError *error, NSData* data){
    
      NSMutableData *concatData =[[NSMutableData alloc]init];
      [concatData appendData:(NSData*)source];
      [concatData appendData:[@"\n\r" dataUsingEncoding:NSUTF8StringEncoding]];
      [concatData appendData:(NSData*)data];

      onComplete(nil, concatData);
    }];
  });
}
@end