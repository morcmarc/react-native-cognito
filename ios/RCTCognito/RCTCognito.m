//
//  RCTCognito.m
//  RCTCognito
//
//  Created by Marcell Jusztin on 21/11/2015.
//  Copyright © 2015 Marcell Jusztin. All rights reserved.
//

#import "RCTBridge.h"
#import "RCTConvert.h"
#import "RCTCognito.h"

#import <AWSCognito/AWSCognito.h>
#import <AWSCore/AWSCore.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <AWSS3/AWSS3.h>

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

 NSString *identityPoolId = @"";
 NSString *region = @"";


- (AWSCognitoCredentialsProvider *) StartCognito: (NSString *)token {
    AWSCognitoCredentialsProvider *credentialsProvider =
    [[AWSCognitoCredentialsProvider alloc]
     initWithRegionType:[self getRegionFromString:region]
     identityPoolId:identityPoolId];


    if([token length] != 0) {

        credentialsProvider.logins = @{
                                       @"graph.facebook.com" : token
                                       };
    }

    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc]
                                              initWithRegion:[self getRegionFromString:region]
                                              credentialsProvider:credentialsProvider];

    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration =
    configuration;

    return credentialsProvider;
}

RCT_REMAP_METHOD(UploadFileToS3,
                      : (NSString*) fileUrl
                      : (NSString*) bucket
                      : (NSString*) key
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)

{
    AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
    uploadRequest.bucket = bucket;
    uploadRequest.key = key;
     NSURL *url = [NSURL URLWithString:fileUrl];
    uploadRequest.body = url;
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    [[transferManager upload:uploadRequest] continueWithBlock:^id
                                                       (AWSTask *task) {
                                                           if (task.error) {
                                                               if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
                                                                   switch (task.error.code) {
                                                                       case AWSS3TransferManagerErrorCancelled:
                                                                       case AWSS3TransferManagerErrorPaused:
                                                                           break;

                                                                       default:
                                                                           NSLog(@"Error: %@", task.error);
                                                                           reject(@"Error", @"Failed upload file", task.error);
                                                                           break;
                                                                   }
                                                               } else {
                                                                   // Unknown error.
                                                                   NSLog(@"Error: %@", task.error);
                                                                   reject(@"Error", @"Failed upload file", task.error);
                                                               }
                                                           }

                                                           if (task.result) {
                                                               AWSS3TransferManagerUploadOutput *uploadOutput = task.result;
                                                               // The file uploaded successfully.
                                                               NSLog(@"Successfully uploaded file to S3", task.result);
                                                               resolve(@ {@"success": @"done"});
                                                           }
                                                           return nil;
                                                       }];

}




RCT_EXPORT_METHOD(initCredentialsProvider: (NSString *)identityPoolIdInput
                  : (NSString *)tokenInput
                  : (NSString *)regionInput
                  ) {

    identityPoolId =identityPoolIdInput;
    region = regionInput;
    [self StartCognito: tokenInput];

}

RCT_EXPORT_METHOD(clearCognitoCredentialsProvider)
{
    AWSCognitoCredentialsProvider *credentialsProvider = [[[AWSCognito defaultCognito] configuration] credentialsProvider];
    [credentialsProvider clearCredentials];
    //[credentialsProvider clearKeychain];
}

RCT_EXPORT_METHOD(setVariables: (NSString *)identityPoolIdInput
                  :(NSString *)regionInput
                  )
{
    identityPoolId = identityPoolIdInput;
    region = regionInput;
}


RCT_REMAP_METHOD(getCognitoCredentials,
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    AWSCognitoCredentialsProvider *credentialsProvider = [[[AWSCognito defaultCognito] configuration] credentialsProvider];

    NSString *token = [FBSDKAccessToken currentAccessToken].tokenString;
    Boolean isAuthenticated = [token length] != 0;


    if(credentialsProvider == nil){
        [self StartCognito:token];
        credentialsProvider = [[[AWSCognito defaultCognito] configuration] credentialsProvider];
    }
    else{
       // if(isAuthenticated)

            NSMutableDictionary *merge = [NSMutableDictionary dictionaryWithDictionary:credentialsProvider.logins];
            NSString *currentToken = [merge valueForKey: @"graph.facebook.com"];




        if([currentToken length] != 0 && !isAuthenticated){
            //If User Logged Out from Facebook and Currently Logged In to Cognito
            [merge removeObjectForKey:@"graph.facebook.com"];
            [[AWSCognito defaultCognito] wipe];
            [credentialsProvider clearKeychain];

            //Re Initialize Credentials Provider so we get UnAuthenticated User Credentials
            [self StartCognito:nil];
            credentialsProvider = [[[AWSCognito defaultCognito] configuration] credentialsProvider];


        }


        else if( isAuthenticated && ([currentToken length] == 0 || ![currentToken isEqualToString: token])){
            //Un Authenticated User Logged In or Token is Changed
            [self StartCognito:token];
            credentialsProvider = [[[AWSCognito defaultCognito] configuration] credentialsProvider];

        }
    }

    [[credentialsProvider refresh] continueWithBlock:^id(AWSTask *task) {

        if (task.error) {
            NSString *errorType = [task.error.userInfo valueForKey: @"__type"];
            if([errorType isEqualToString: @"NotAuthorizedException"]){
                [[AWSCognito defaultCognito] wipe];
                [credentialsProvider clearKeychain];
            }
            NSLog(@"Error in Cognito credentialsprovider.refresh", task.error);
            reject(@"Error", @"Failed to get Cognito", task.error);
        }
        else {
            NSInteger timeStamp = round(credentialsProvider.expiration.timeIntervalSince1970);
            resolve( @{@"accessKey": credentialsProvider.accessKey, @"secretKey": credentialsProvider.secretKey, @"sessionKey":credentialsProvider.sessionKey, @"expiration":[NSNumber numberWithInt:timeStamp],
                       @"cognitoId":credentialsProvider.identityId, @"isAuthenticated":[NSNumber numberWithBool: isAuthenticated]});
        }
        return nil;
    }];

}


RCT_EXPORT_METHOD(syncData: (NSString *)datasetName
                  : (NSString *)key
                  : (NSString *)value
                  : (RCTResponseSenderBlock)callback) {
    AWSCognito *syncClient = [AWSCognito defaultCognito];
    AWSCognitoDataset *dataset = [syncClient openOrCreateDataset:datasetName];

    [dataset setString:value forKey:key];
    [[dataset synchronize] continueWithBlock:^id(AWSTask *task) {
        if (task.error) {
            callback(@[ @{@"code":[NSNumber numberWithLong:task.error.code], @"domain":task.error.domain, @"userInfo":task.error.userInfo, @"localizedDescription":task.error.localizedDescription} ]);
        } else {
            callback(@[ [NSNull null] ]);
        }
        return nil;
    }];
}

RCT_EXPORT_METHOD(subscribe: (NSString *)datasetName
                  : (RCTResponseSenderBlock)callback) {
    AWSCognito *syncClient = [AWSCognito defaultCognito];
    AWSCognitoDataset *dataset = [syncClient openOrCreateDataset:datasetName];

    [[dataset subscribe] continueWithBlock:^id(AWSTask *task) {
        if (task.error) {
            NSLog(@"Unable to subscribe to dataset");
            callback(@[ [task.error localizedDescription] ]);
        } else {
            NSLog(@"Subscribed to dataset");
            callback(@[ [NSNull null] ]);
        }
        return nil;
    }];
}

@end
