//
//  UserWrapper.swift
//  Tinpons
//
//  Created by Dirk Hornung on 18/7/17.
//
//

import Foundation
import AWSDynamoDB
import AWSAPIGateway

class UserWrapper {
    
    // MARK: load
    
    static func getSignedInUser(onCompletionClosure onComplete: @escaping (DynamoDBUser)->Void) {
        getUserIdAWSTask().continueOnSuccessWith{ task in
            let cognitoId = task.result! as String
            
            return getUserAWSTask(cognitoId: cognitoId)
        }.continueWith{ task in
            if let error = task.error {
                print("ERROR---UserWrapper-getSignedInUser: \(error)")
            } else {
                let user = task.result! as! DynamoDBUser
                onComplete(user)
            }
            return nil
        }
    }
    
    // MARK: API
    
    func doInvoke() {
        let httpMethodName = "GET"
        let URLString = "/users"
        let queryStringParameters: [String:String] = [:]
        let headerParameters = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        let httpBody: String? = nil
        
        // Construct the request object
        let apiRequest = AWSAPIGatewayRequest(httpMethod: httpMethodName,
                                              urlString: URLString,
                                              queryParameters: queryStringParameters,
                                              headerParameters: headerParameters,
                                              httpBody: httpBody)
        
        // Fetch the Cloud Logic client to be used for invocation
        // Change the `AWSAPI_XE21FG_MyCloudLogicClient` class name to the client class for your generated SDK
        print(AWSAPI_DOMG701VNC_TinponsMobileHubClient(forKey: AWSCloudLogicDefaultConfigurationKey))
        AWSAPI_DOMG701VNC_TinponsMobileHubClient(forKey: AWSCloudLogicDefaultConfigurationKey).invoke(apiRequest).continueWith { [weak self] (task: AWSTask<AWSAPIGatewayResponse>) -> Any? in
            guard let strongSelf = self else { return nil }
            
            if let error = task.error {
                print("Error occurred: \(error)")
                // Handle error here
                return nil
            }
            
            // Handle successful result here
            let result = task.result!
            let responseString = String(data: result.responseData!, encoding: .utf8)
            
            print(responseString?.toJSON)
            print(result.statusCode)
            
            if let responseString = responseString?.toJSON as? [String:Any] {
                if let item = responseString["Item"] {
                    print(item)
                }
            }
            
            return nil
        }
    }
    
    // MARK: Tasks
    
    static func getUserIdAWSTask() -> AWSTask<NSString> {
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: .EUWest1, identityPoolId: "eu-west-1:8088e7da-a496-4ae3-818c-2b9025180888")
        let configuration = AWSServiceConfiguration(region: .EUWest1, credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        return credentialsProvider.getIdentityId()
    }
    
    static func getUserAWSTask(cognitoId: String) -> AWSTask<AnyObject> {
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
        
        return dynamoDBObjectMapper.load(DynamoDBUser.self, hashKey: cognitoId, rangeKey:nil)
    }

}
