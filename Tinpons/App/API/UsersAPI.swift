//
//  UsersAPI.swift
//  Tinpons
//
//  Created by Dirk Hornung on 23/7/17.
//
//

import Foundation
import AWSAPIGateway
import PromiseKit

class UserAPI: APIGatewayProtocol {
    static func getCognitoIdTask() -> AWSTask<NSString> {
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: .EUWest1, identityPoolId: "eu-west-1:64a9de95-136c-4ba3-b366-6aa4079fef8b")
        return credentialsProvider.getIdentityId()
    }
    
    /**
     return user by cognitoId, if existing
    */
    static func getSignedInUser(completion: @escaping (User?, Error?)->() ) {
        restAPITask(httpMethod: .GET, endPoint: .users).continueWith(block: {  (task: AWSTask<AWSAPIGatewayResponse>) -> () in
            if let error = task.error {
                completion(nil, error)
            } else if let result = task.result {
                let responseString = String(data: result.responseData!, encoding: .utf8)
                
                if let json = responseString?.toJSON {
                    let user = try? User(json: json as! [String : Any])
                    completion(user, nil)
                } else {
                    // User MOST PROBABLY does not exist
                    completion(nil, APIError.nonExisting)
                }
            }
        })
    }
    static func getSignedInUser() -> Promise<User> {
        return PromiseKit.wrap(getSignedInUser)
    }
    
    /**
     save user in RDS
    */
    static func save(user: User, completion: @escaping (Error?)->()) {
        restAPITask(httpMethod: .POST, endPoint: .users, httpBody: user.toJSON()).continueWith {  (task: AWSTask<AWSAPIGatewayResponse>) -> () in
            if let error = task.error {
                completion(APIError.serverError)
                return
            } else if let result = task.result {
                if result.statusCode == 200 {
                    completion(nil)
                } else {
                   completion(APIError.alreadyExisting)
                }
            }
        }
    }
    static func save(user: User) -> Promise<Void> {
        return PromiseKit.wrap{ save(user: user, completion: $0) }
    }
    
    /**
     update user in RDS
     */
    static func update(user: User, completion: @escaping (Error?)->()) {
        restAPITask(httpMethod: .PUT, endPoint: .users, httpBody: user.toJSON()).continueWith {  (task: AWSTask<AWSAPIGatewayResponse>) -> () in
            if let error = task.error {
                completion(APIError.serverError)
                return
            } else if let result = task.result {
                if result.statusCode == 200 {
                    completion(nil)
                } else {
                    completion(APIError.nonExisting)
                    //print("UserAPI.update Error: HTTP status code: \(result.statusCode) \n and body: \(String(data: result.responseData!, encoding: .utf8))")
                }
            }
        }
    }
    static func update(user: User) -> Promise<Void> {
        return PromiseKit.wrap{ update(user: user, completion: $0 ) }
    }
    
    
    /**
     returns Bool if email is already taken in RDS
    */
    static func isEmailAvailable(email: String, completion: @escaping (Bool?, Error?) -> Void) {
        let jsonObject: [String: Any] = ["email": email]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: jsonObject,
                                                      options: .prettyPrinted)
            let json = String(data: jsonData, encoding: String.Encoding.utf8)
            
            restAPITask(httpMethod: .POST, endPoint: .userEmailAvailable, httpBody: json).continueWith {  (task: AWSTask<AWSAPIGatewayResponse>) -> () in
                if let error = task.error {
                    completion(nil, error)
                    return
                } else if let result = task.result {
                    let responseString = String(data: result.responseData!, encoding: .utf8)
                    var isEmailAvailable = false
                    if responseString == "true" {
                        isEmailAvailable = true
                    }
                    
                    if result.statusCode == 200 {
                        completion(isEmailAvailable, nil)
                    } else {
                        completion(nil, APIError.serverError)
                       //print("UserAPI.isEmailAvailable Error: HTTP status code: \(result.statusCode) \n and body: \(String(data: result.responseData!, encoding: .utf8))")
                    }
                } else {
                    completion(nil, APIError.serverError)
                }
            }
        } catch let error {
            completion(nil, error)
        }

    }
    static func isEmailAvailable(email: String) -> Promise<Bool> {
        return PromiseKit.wrap { isEmailAvailable(email: email, completion: $0) }
    }
    
    static func isEmailAvailable(_ email: String, onComlete: @escaping (Bool)->()) {
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
