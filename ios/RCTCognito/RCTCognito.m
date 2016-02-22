//
//  RCTCognito.m
//  RCTCognito
//
//  Created by Marcell Jusztin on 21/11/2015.
//  Copyright © 2015 Marcell Jusztin. All rights reserved.
//

#import "RCTBridge.h"
#import "RCTCognito.h"

#import <AWSCognito/AWSCognito.h>
#import <AWSCore/AWSCore.h>

typedef AWSRegionType (^CaseBlock)();

@implementation RCTCognito

@synthesize bridge = _bridge;
RCT_EXPORT_MODULE();

- (AWSRegionType)getRegionFromString:(NSString *)region {
  NSDictionary *regions = @{
    @"eu-west-1" : ^{
      return AWSRegionEUWest1;
    },
    @"us-east-1" : ^{
      return AWSRegionUSEast1;
    },
    @"ap-northeast-1" : ^{
      return AWSRegionAPNortheast1;
    },
  };
  return ((CaseBlock)regions[region])();
}

RCT_EXPORT_METHOD(initCredentialsProvider
                  : (NSString *)identityPoolId token
                  : (NSString *)token region
                  : (NSString *)region) {

  AWSCognitoCredentialsProvider *credentialsProvider =
      [[AWSCognitoCredentialsProvider alloc]
          initWithRegionType:[self getRegionFromString:region]
              identityPoolId:identityPoolId];

  credentialsProvider.logins = @{
    @(AWSCognitoLoginProviderKeyFacebook) : token
  };

  AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc]
           initWithRegion:[self getRegionFromString:region]
      credentialsProvider:credentialsProvider];

  [AWSServiceManager defaultServiceManager].defaultServiceConfiguration =
      configuration;
}

RCT_EXPORT_METHOD(syncData
                  : (NSString *)datasetName key
                  : (NSString *)key value
                  : (NSString *)value) {
  AWSCognito *syncClient = [AWSCognito defaultCognito];
  AWSCognitoDataset *dataset = [syncClient openOrCreateDataset:datasetName];

  [dataset setString:value forKey:key];

  [[dataset synchronize] continueWithBlock:^id(AWSTask *task) {
    return nil;
  }];
}

@end
