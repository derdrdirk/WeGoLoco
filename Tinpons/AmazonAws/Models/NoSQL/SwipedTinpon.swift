//
//  SwipedTinpon.swift
//  Tinpons
//
//  Created by Dirk Hornung on 12/7/17.
//
//

import Foundation
import AWSDynamoDB
import AWSMobileHubHelper

class SwipedTinpon {
    var userId: String?
    var swipedAt: String?
    var like: NSNumber?
    var tinponId: String?
    var favourite: NSNumber?
    
    private func dynamoDBSwipedTinpon() -> DynamoDBSwipedTinpon {
        let dynamoDBSwipedTinpon = DynamoDBSwipedTinpon()
        dynamoDBSwipedTinpon?.userId = userId
        dynamoDBSwipedTinpon?.swipedAt = swipedAt
        dynamoDBSwipedTinpon?.like = like
        dynamoDBSwipedTinpon?.tinponId = tinponId
        dynamoDBSwipedTinpon?.favourite = favourite
        return dynamoDBSwipedTinpon!
    }
    
    static func castDynamoDBSwipedTinponToSwipedTinpon(dynamoDBSwipedTinpon: DynamoDBSwipedTinpon) -> SwipedTinpon {
        let swipedTinpon = SwipedTinpon()
        swipedTinpon.userId = dynamoDBSwipedTinpon.userId
        swipedTinpon.swipedAt = dynamoDBSwipedTinpon.swipedAt
        swipedTinpon.like = dynamoDBSwipedTinpon.like
        swipedTinpon.tinponId = dynamoDBSwipedTinpon.tinponId
        swipedTinpon.favourite = dynamoDBSwipedTinpon.favourite
        return swipedTinpon
    }
    
    func save() {
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
        
        dynamoDBObjectMapper.save(dynamoDBSwipedTinpon()).continueWith(block: { (task:AWSTask<AnyObject>!) -> Void in
            if let error = task.error as NSError? {
                print("The request failed. Error: \(error)")
            } else {
                // succesfully saved
            }
        })
    }
    
    func loadAllSwipedTinponsFor(userId: String, onComplete: @escaping ([SwipedTinpon]) -> ()) {
        UserWrapper.getUserIdAWSTask().continueOnSuccessWith{ task in
            let cognitoId = task.result! as String
            
            let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
            
            let queryExpression = AWSDynamoDBQueryExpression()
            
            queryExpression.keyConditionExpression = "userId = :userId"
            queryExpression.expressionAttributeValues = [":userId" : cognitoId]
            
            return dynamoDBObjectMapper.query(DynamoDBSwipedTinpon.self, expression: queryExpression)
            }.continueWith{ task in
                if let error = task.error as NSError? {
                    print("The request failed. Error: \(error)")
                } else if let paginatedOutput = task.result as? AWSDynamoDBPaginatedOutput {
                    let dynamoDBSwipedTinpons = (paginatedOutput.items as? [DynamoDBSwipedTinpon])!
                    var swipedTinpons: [SwipedTinpon] = []
                    for dynamoDBSwipedTinpon in dynamoDBSwipedTinpons {
                        swipedTinpons.append(SwipedTinpon.castDynamoDBSwipedTinponToSwipedTinpon(dynamoDBSwipedTinpon: dynamoDBSwipedTinpon))
                    }
                    
                    print("swipedTinpon count \(swipedTinpons.count)")
                    onComplete(swipedTinpons)
                }
                return nil
        }
    }
    
    static func loadAllFavouriteTinpons(lastEvaluatedKey: [String: AWSDynamoDBAttributeValue]? = nil,
                                        //swipedTinpons: [DynamoDBSwipedTinpon]?,
                                        _ onComplete: @escaping ([Tinpon]) -> ())
    {
        UserWrapper.getUserIdAWSTask().continueOnSuccessWith{ task in
            let cognitoId = task.result! as String
            let favourite = NSNumber(value: 1)
            let queryExpression = AWSDynamoDBQueryExpression()
            queryExpression.indexName = "favourite-userId-index"
            queryExpression.keyConditionExpression = "favourite = :favourite AND userId = :userId"
            queryExpression.expressionAttributeValues = [":favourite" : favourite, ":userId" : cognitoId]
            if lastEvaluatedKey != nil {
                queryExpression.exclusiveStartKey = lastEvaluatedKey
            }
            let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
            return dynamoDBObjectMapper.query(DynamoDBSwipedTinpon.self, expression: queryExpression)
        }.continueOnSuccessWith{ task -> AWSTask<AnyObject> in
            let paginatedOutput = task.result! as! AWSDynamoDBPaginatedOutput
            let dynamoDBSwipedTinpons = (paginatedOutput.items as? [DynamoDBSwipedTinpon])!
            let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
            
            var tasks = Array<AWSTask<AnyObject>>()
            dynamoDBSwipedTinpons.forEach({
                tasks.append(dynamoDBObjectMapper.load(Tinpon.self, hashKey: $0.tinponId, rangeKey: nil))
            })
            return AWSTask(forCompletionOfAllTasksWithResults: tasks)
        }.continueWith { task in
            if let tinpons = task.result as? [Tinpon] {
             
                onComplete(tinpons)
            } else if let error = task.error {
                print("Fetching Favourites error: \(error.localizedDescription)")
            }
            return nil
        }
    }
}
