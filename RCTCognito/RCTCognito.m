//
//  RCTCognito.m
//  RCTCognito
//
//  Created by Marcell Jusztin on 21/11/2015.
//  Copyright © 2015 Marcell Jusztin. All rights reserved.
//

#import "RCTCognito.h"
#import <AWSCore/AWSCore.h>

@implementation RCTCognito

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(setupCredentials:(NSString *)region identityPoolId:(NSString *) identityPoolId)
{
    AWSCognitoCredentialsProvider *credentialsProvider =
        [[AWSCognitoCredentialsProvider alloc] initWithRegionType:AWSRegionUSEast1
           identityPoolId:identityPoolId];
    
    AWSServiceConfiguration *configuration =
        [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1
            credentialsProvider:credentialsProvider];
    
    AWSServiceManager.defaultServiceManager.defaultServiceConfiguration = configuration;
}

@end
