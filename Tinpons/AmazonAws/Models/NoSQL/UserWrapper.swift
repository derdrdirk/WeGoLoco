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
    
    static func getSignedInUser() {
        
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
