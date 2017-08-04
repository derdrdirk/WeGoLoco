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
    static func getSignedInUser(onCompletionClosure onComplete: @escaping (User?)->()) {
        restAPITask(httpMethod: .GET, endPoint: .users).continueWith {  (task: AWSTask<AWSAPIGatewayResponse>) -> () in
            if let error = task.error {
                print("Error occurred: \(error)")
                // Handle error here
                return
            } else if let result = task.result {
                let responseString = String(data: result.responseData!, encoding: .utf8)
                
                if let json = responseString?.toJSON {
                    print("get damn json")
                    print(json)
                    let user = try? User(json: json as! [String : Any])
                    onComplete(user)
                } else {
                    // User MOST PROBABLY does not exist
                    onComplete(nil)
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
                    print(user.toJSON())
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
    
    static func isEmailAvailable(_ email: String, onComlete: @escaping (Bool)->()) {
        print("is email start")
        let jsonObject: [String: Any] = ["email": email]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: jsonObject,
                                                      options: .prettyPrinted)
            let json = String(data: jsonData, encoding: String.Encoding.utf8)
            
            restAPITask(httpMethod: .POST, endPoint: .userEmailAvailable, httpBody: json).continueWith {  (task: AWSTask<AWSAPIGatewayResponse>) -> () in
                if let error = task.error {
                    print("UserAPI.isEmailAvailable Error occurred: \(error)")
                    // Handle error here
                    return
                } else if let result = task.result {
                    let responseString = String(data: result.responseData!, encoding: .utf8)
                    var isEmailAvailable = false
                    if responseString == "true" {
                        isEmailAvailable = true
                    }
                    
                    if result.statusCode == 200 {
                        onComlete(isEmailAvailable)
                    } else {
                        print("UserAPI.isEmailAvailable Error: HTTP status code: \(result.statusCode) \n and body: \(String(data: result.responseData!, encoding: .utf8))")
                    }
                }
            }

        } catch let error {
            print("UserEmail: error converting to json: \(error)")
        }
    }
}
