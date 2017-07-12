//
//  Users.swift
//  Tinpons
//
//  Created by Dirk Hornung on 5/7/17.
//
//

import Foundation
import UIKit
import AWSDynamoDB

class User: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    var userId: String?
    var createdAt: String?
    var birthdate: String?
    var gender: String?
    var height: NSNumber?
    var role: String?
    var stores: Set<String>?
    var tinponCategories: Set<String>?
    var updatedAt: String?
    
    class func dynamoDBTableName() -> String {
        return"tinpons-mobilehub-1827971537-Users"
    }
    
    class func hashKeyAttribute() -> String {
        return "userId"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
            "userId" : "userId",
            "createdAt" : "createdAt",
            "birthdate" : "birthdate",
            "gender" : "gender",
            "height" : "height",
            "role" : "role",
            "stores" : "stores",
            "tinponCategories" : "tinponCategories",
            "updatedAt" : "updatedAt",
        ]
    }
    
    convenience init(new: Bool) {
        self.init()
        getUserId(onComplete: { [weak self] in self?.userId = $0 })
    }

    
    public func getUserId(onComplete: @escaping (String) -> Void) {
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: .EUWest1, identityPoolId: "eu-west-1:8088e7da-a496-4ae3-818c-2b9025180888")
        let configuration = AWSServiceConfiguration(region: .EUWest1, credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        // Retrieve your Amazon Cognito ID
        credentialsProvider.getIdentityId().continueWith(block: { (task) -> AnyObject? in
            if (task.error != nil) {
                print("Error: " + task.error!.localizedDescription)
            }
            else {
                // the task result will contain the identity id
                let cognitoId = task.result!
                onComplete(cognitoId as String)
                return cognitoId
            }
            return nil
        })
    }
    
    public func load() {
    
    }
}
