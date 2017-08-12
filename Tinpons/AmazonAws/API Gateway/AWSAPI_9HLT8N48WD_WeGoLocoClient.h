/*
 Copyright 2010-2016 Amazon.com, Inc. or its affiliates. All Rights Reserved.

 Licensed under the Apache License, Version 2.0 (the "License").
 You may not use this file except in compliance with the License.
 A copy of the License is located at

 http://aws.amazon.com/apache2.0

 or in the "license" file accompanying this file. This file is distributed
 on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
 express or implied. See the License for the specific language governing
 permissions and limitations under the License.
 */
 

#import <Foundation/Foundation.h>
#import <AWSAPIGateway/AWSAPIGateway.h>

#import "AWSAPI_9HLT8N48WD_RequestSchema.h"
#import "AWSAPI_9HLT8N48WD_ResponseSchema.h"
#import "AWSAPI_9HLT8N48WD_Empty.h"


NS_ASSUME_NONNULL_BEGIN

/**
 The service client object.
 */
@interface AWSAPI_9HLT8N48WD_WeGoLocoClient: AWSAPIGatewayClient

/**
 Returns the singleton service client. If the singleton object does not exist, the SDK instantiates the default service client with `defaultServiceConfiguration` from `[AWSServiceManager defaultServiceManager]`. The reference to this object is maintained by the SDK, and you do not need to retain it manually.

 If you want to enable AWS Signature, set the default service configuration in `- application:didFinishLaunchingWithOptions:`
 
 *Swift*

     func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
         let credentialProvider = AWSCognitoCredentialsProvider(regionType: .USEast1, identityPoolId: "YourIdentityPoolId")
         let configuration = AWSServiceConfiguration(region: .USEast1, credentialsProvider: credentialProvider)
         AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = configuration

         return true
     }

 *Objective-C*

     - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
          AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:AWSRegionUSEast1
                                                                                                          identityPoolId:@"YourIdentityPoolId"];
          AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1
                                                                               credentialsProvider:credentialsProvider];
          [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;

          return YES;
      }

 Then call the following to get the default service client:

 *Swift*

     let serviceClient = AWSAPI_9HLT8N48WD_WeGoLocoClient.defaultClient()

 *Objective-C*

     AWSAPI_9HLT8N48WD_WeGoLocoClient *serviceClient = [AWSAPI_9HLT8N48WD_WeGoLocoClient defaultClient];

 Alternatively, this configuration could also be set in the `info.plist` file of your app under `AWS` dictionary with a configuration dictionary by name `AWSAPI_9HLT8N48WD_WeGoLocoClient`.

 @return The default service client.
 */
+ (instancetype)defaultClient;

/**
 Creates a service client with the given service configuration and registers it for the key.

 If you want to enable AWS Signature, set the default service configuration in `- application:didFinishLaunchingWithOptions:`

 *Swift*

     func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
         let credentialProvider = AWSCognitoCredentialsProvider(regionType: .USEast1, identityPoolId: "YourIdentityPoolId")
         let configuration = AWSServiceConfiguration(region: .USWest2, credentialsProvider: credentialProvider)
         AWSAPI_9HLT8N48WD_WeGoLocoClient.registerClientWithConfiguration(configuration, forKey: "USWest2AWSAPI_9HLT8N48WD_WeGoLocoClient")

         return true
     }

 *Objective-C*

     - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
         AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:AWSRegionUSEast1
                                                                                                         identityPoolId:@"YourIdentityPoolId"];
         AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSWest2
                                                                              credentialsProvider:credentialsProvider];

         [AWSAPI_9HLT8N48WD_WeGoLocoClient registerClientWithConfiguration:configuration forKey:@"USWest2AWSAPI_9HLT8N48WD_WeGoLocoClient"];

         return YES;
     }

 Then call the following to get the service client:

 *Swift*

     let serviceClient = AWSAPI_9HLT8N48WD_WeGoLocoClient(forKey: "USWest2AWSAPI_9HLT8N48WD_WeGoLocoClient")

 *Objective-C*

     AWSAPI_9HLT8N48WD_WeGoLocoClient *serviceClient = [AWSAPI_9HLT8N48WD_WeGoLocoClient clientForKey:@"USWest2AWSAPI_9HLT8N48WD_WeGoLocoClient"];

 @warning After calling this method, do not modify the configuration object. It may cause unspecified behaviors.

 @param configuration A service configuration object.
 @param key           A string to identify the service client.
 */
+ (void)registerClientWithConfiguration:(AWSServiceConfiguration *)configuration forKey:(NSString *)key;

/**
 Retrieves the service client associated with the key. You need to call `+ registerClientWithConfiguration:forKey:` before invoking this method or alternatively, set the configuration in your application's `info.plist` file. If `+ registerClientWithConfiguration:forKey:` has not been called in advance or if a configuration is not present in the `info.plist` file of the app, this method returns `nil`.

 For example, set the default service configuration in `- application:didFinishLaunchingWithOptions:`

 *Swift*

     func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
         let credentialProvider = AWSCognitoCredentialsProvider(regionType: .USEast1, identityPoolId: "YourIdentityPoolId")
         let configuration = AWSServiceConfiguration(region: .USWest2, credentialsProvider: credentialProvider)
         AWSAPI_9HLT8N48WD_WeGoLocoClient.registerClientWithConfiguration(configuration, forKey: "USWest2AWSAPI_9HLT8N48WD_WeGoLocoClient")

         return true
     }

 *Objective-C*

     - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
         AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:AWSRegionUSEast1
                                                                                                         identityPoolId:@"YourIdentityPoolId"];
         AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSWest2
                                                                              credentialsProvider:credentialsProvider];

         [AWSAPI_9HLT8N48WD_WeGoLocoClient registerClientWithConfiguration:configuration forKey:@"USWest2AWSAPI_9HLT8N48WD_WeGoLocoClient"];

         return YES;
     }

 Then call the following to get the service client:

 *Swift*

     let serviceClient = AWSAPI_9HLT8N48WD_WeGoLocoClient(forKey: "USWest2AWSAPI_9HLT8N48WD_WeGoLocoClient")

 *Objective-C*

     AWSAPI_9HLT8N48WD_WeGoLocoClient *serviceClient = [AWSAPI_9HLT8N48WD_WeGoLocoClient clientForKey:@"USWest2AWSAPI_9HLT8N48WD_WeGoLocoClient"];

 @param key A string to identify the service client.

 @return An instance of the service client.
 */
+ (instancetype)clientForKey:(NSString *)key;

/**
 Removes the service client associated with the key and release it.
 
 @warning Before calling this method, make sure no method is running on this client.
 
 @param key A string to identify the service client.
 */
+ (void)removeClientForKey:(NSString *)key;

/**
 
 
 @param body 
 
 return type: AWSAPI_9HLT8N48WD_ResponseSchema *
 */
- (AWSTask *)tinponsPost:( AWSAPI_9HLT8N48WD_RequestSchema *)body;

/**
 
 
 @param body 
 
 return type: AWSAPI_9HLT8N48WD_ResponseSchema *
 */
- (AWSTask *)usersGet:( AWSAPI_9HLT8N48WD_RequestSchema *)body;

/**
 
 
 
 return type: AWSAPI_9HLT8N48WD_Empty *
 */
- (AWSTask *)usersPut;

/**
 
 
 
 return type: AWSAPI_9HLT8N48WD_Empty *
 */
- (AWSTask *)usersPost;

/**
 
 
 @param body 
 
 return type: AWSAPI_9HLT8N48WD_ResponseSchema *
 */
- (AWSTask *)usersIsEmailAvailablePost:( AWSAPI_9HLT8N48WD_RequestSchema *)body;

@end

NS_ASSUME_NONNULL_END
