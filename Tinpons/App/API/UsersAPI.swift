//
//  UsersAPI.swift
//  Tinpons
//
//  Created by Dirk Hornung on 23/7/17.
//
//

import Foundation
import AWSAPIGateway

class UserAPI {
    static func getSignedInUser(onCompletionClosure onComplete: @escaping (User)->()) {
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
        AWSAPI_DOMG701VNC_TinponsMobileHubClient(forKey: AWSCloudLogicDefaultConfigurationKey).invoke(apiRequest).continueWith {  (task: AWSTask<AWSAPIGatewayResponse>) -> Any? in
            
            if let error = task.error {
                print("Error occurred: \(error)")
                // Handle error here
                return nil
            }
            
            // Handle successful result here
            let result = task.result!
            let responseString = String(data: result.responseData!, encoding: .utf8)
            
            if let json = responseString?.toJSON {
                let user = User(json: json as! [String : Any])
                onComplete(user!)
            } else {
                print("UserAPI.getSignedInUser Error: HTTP status code: \(result.statusCode)")
            }
            
            return nil
        }
    }
    
    static func save(preparedObject user: User, onCompletionClosure onComplete: @escaping ()->()) {
        let httpMethodName = "POST"
        let URLString = "/users"
        let queryStringParameters: [String:String] = [:]
        let headerParameters = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        let httpBody = user.toJSON()
        
        // Construct the request object
        let apiRequest = AWSAPIGatewayRequest(httpMethod: httpMethodName,
                                              urlString: URLString,
                                              queryParameters: queryStringParameters,
                                              headerParameters: headerParameters,
                                              httpBody: httpBody)
        
        // Fetch the Cloud Logic client to be used for invocation
        // Change the `AWSAPI_XE21FG_MyCloudLogicClient` class name to the client class for your generated SDK
        AWSAPI_DOMG701VNC_TinponsMobileHubClient(forKey: AWSCloudLogicDefaultConfigurationKey).invoke(apiRequest).continueWith {  (task: AWSTask<AWSAPIGatewayResponse>) -> Any? in
            
            if let error = task.error {
                print("Error occurred: \(error)")
                // Handle error here
                return nil
            } else if let result = task.result {
                if result.statusCode == 200 {
                    onComplete()
                } else {
                    print("UserAPI.save Error: HTTP status code: \(result.statusCode)")
                }
            }
            
            return nil
        }

    }
}
