//
//  UserWrapper.swift
//  Tinpons
//
//  Created by Dirk Hornung on 18/7/17.
//
//

import Foundation
import AWSDynamoDB

class UserWrapper {
    
    // MARK: load
    
    static func getSignedInUser(onCompletionClosure onComplete: @escaping (User)->Void) {
        getUserIdAWSTask().continueOnSuccessWith{ task in
            let cognitoId = task.result! as String
            
            return getUserAWSTask(cognitoId: cognitoId)
        }.continueWith{ task in
            if let error = task.error {
                print("ERROR---UserWrapper-getSignedInUser: \(error)")
            } else {
                let user = task.result! as! User
                onComplete(user)
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
        
        return dynamoDBObjectMapper.load(User.self, hashKey: cognitoId, rangeKey:nil)
    }

}
