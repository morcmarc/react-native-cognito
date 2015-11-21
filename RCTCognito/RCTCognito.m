//
//  RCTCognito.m
//  RCTCognito
//
//  Created by Marcell Jusztin on 21/11/2015.
//  Copyright © 2015 Marcell Jusztin. All rights reserved.
//

#import "RCTCognito.h"
#import "RCTBridge.h"

#import <AWSCore/AWSCore.h>
#import <AWSCognito/AWSCognito.h>

@implementation RCTCognito

@synthesize bridge = _bridge;
RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(initCredentialsProvider:(NSString *) identityPoolId)
{
    AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc]
                                                          initWithRegionType:AWSRegionEUWest1
                                                          identityPoolId:identityPoolId];
    
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:credentialsProvider];
    
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
}

RCT_EXPORT_METHOD(syncData:(NSString*) key:(NSString*) value)
{
    AWSCognito *syncClient = [AWSCognito defaultCognito];
    AWSCognitoDataset *dataset = [syncClient openOrCreateDataset:@"testDataset"];
    
    [dataset setString:value forKey:key];
    
    [[dataset synchronize] continueWithBlock:^id(AWSTask *task) {
        NSLog(@"callback %@", task);
        return nil;
    }];
}

@end
