//
//  AWSHelper.swift
//  Tinpons
//
//  Created by Dirk Hornung on 6/7/17.
//
//

import Foundation
import AWSDynamoDB

func getUser(onCompletion: @escaping (DynamoDBUser) -> Void) {
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
            print(cognitoId)
            let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
            return dynamoDBObjectMapper.load(DynamoDBUser.self, hashKey: cognitoId, rangeKey:nil)
        }
        return nil
    }).continueWith(block: { (task:AWSTask<AnyObject>!) -> Any? in
        if let error = task.error {
            print("The request failed. Error: \(error)")
        } else if let user = task.result as? DynamoDBUser {
            // Do something with task.result
            let dynamoDBOBjectMapper = AWSDynamoDBObjectMapper.default()
            let queryExpression = AWSDynamoDBQueryExpression()
            //queryExpression.indexName = "userId"
            queryExpression.keyConditionExpression = "userId = :userId"
            //queryExpression.expressionAttributeNames = [ "#name" : "name" ]
            queryExpression.expressionAttributeValues = [":userId" : user.userId! ]

            onCompletion(user)
        }
        return nil
    })
}





