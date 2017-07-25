//
//  UsersAPI.swift
//  Tinpons
//
//  Created by Dirk Hornung on 23/7/17.
//
//

import Foundation
import AWSAPIGateway

class UserAPI: APIGatewayProtocol {
    static func getSignedInUser(onCompletionClosure onComplete: @escaping (User)->()) {
        restAPITask(httpMethod: .GET, endPoint: .users).continueWith {  (task: AWSTask<AWSAPIGatewayResponse>) -> () in
            if let error = task.error {
                print("Error occurred: \(error)")
                // Handle error here
                return
            } else if let result = task.result {
                let responseString = String(data: result.responseData!, encoding: .utf8)
                
                if let json = responseString?.toJSON {
                    let user = User(json: json as! [String : Any])
                    onComplete(user!)
                } else {
                    print("UserAPI.getSignedInUser Error: HTTP status code: \(result.statusCode)")
                }
            }
        }
    }
    
    static func save(preparedObject user: User, onCompletionClosure onComplete: @escaping ()->()) {        
        restAPITask(httpMethod: .POST, endPoint: .users, httpBody: user.toJSON()).continueWith {  (task: AWSTask<AWSAPIGatewayResponse>) -> () in
            if let error = task.error {
                print("Error occurred: \(error)")
                // Handle error here
                return
            } else if let result = task.result {
                if result.statusCode == 200 {
                    onComplete()
                } else {
                    print("UserAPI.save Error: HTTP status code: \(result.statusCode)")
                }
            }
        }
    }
    
    static func update(preparedObject user: User, onCompletionClosure onComplete: @escaping ()->()) {
        restAPITask(httpMethod: .PUT, endPoint: .users, httpBody: user.toJSON()).continueWith {  (task: AWSTask<AWSAPIGatewayResponse>) -> () in
            if let error = task.error {
                print("Error occurred: \(error)")
                // Handle error here
                return
            } else if let result = task.result {
                if result.statusCode == 200 {
                    onComplete()
                } else {
                    print("UserAPI.save Error: HTTP status code: \(result.statusCode) \n and body: \(String(data: result.responseData!, encoding: .utf8))")
                }
            }
        }
    }
}
