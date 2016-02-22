//
//  RCTCognito.h
//  RCTCognito
//
//  Created by Marcell Jusztin on 21/11/2015.
//  Copyright © 2015 Marcell Jusztin. All rights reserved.
//

#import "RCTBridgeModule.h"
#import "RCTLog.h"
#import <AWSCognito/AWSCognito.h>
#import <AWSCore/AWSCore.h>

@interface RCTCognito : NSObject <RCTBridgeModule>

- (AWSRegionType)getRegionFromString:(NSString *)region;

@end
