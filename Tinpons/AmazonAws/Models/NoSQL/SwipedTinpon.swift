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
    
    private static func castDynamoDBTinponToTinpon(dynamoDBTinpon: DynamoDBSwipedTinpon) -> SwipedTinpon {
        let swipedTinpon = SwipedTinpon()
        swipedTinpon.userId = dynamoDBTinpon.userId
        swipedTinpon.swipedAt = dynamoDBTinpon.swipedAt
        swipedTinpon.like = dynamoDBTinpon.like
        swipedTinpon.tinponId = dynamoDBTinpon.tinponId
        swipedTinpon.favourite = dynamoDBTinpon.favourite
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
        self.userId = userId
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
        
        let queryExpression = AWSDynamoDBQueryExpression()
        
        queryExpression.keyConditionExpression = "userId = :userId"
        queryExpression.expressionAttributeValues = [":userId" : userId]
        //        if lastEvaluatedKey != nil {
        //            queryExpression.exclusiveStartKey = lastEvaluatedKey
        //        }
        
        dynamoDBObjectMapper.query(DynamoDBSwipedTinpon.self, expression: queryExpression).continueWith(block: { (task:AWSTask<AWSDynamoDBPaginatedOutput>!) -> Any? in

            if let error = task.error as NSError? {
                print("The request failed. Error: \(error)")
            } else if let paginatedOutput = task.result {
                let dynamoDBSwipedTinpons = (paginatedOutput.items as? [DynamoDBSwipedTinpon])!
                var swipedTinpons: [SwipedTinpon] = []
                for dynamoDBSwipedTinpon in dynamoDBSwipedTinpons {
                    swipedTinpons.append(SwipedTinpon.castDynamoDBTinponToTinpon(dynamoDBTinpon: dynamoDBSwipedTinpon))
                }
                
                onComplete(swipedTinpons)
            }
            return nil
        })
    }
    
    static func loadAllFavouriteTinpons(onComplete: @escaping ([SwipedTinpon]) -> (),
                                        //swipedTinpons: [DynamoDBSwipedTinpon]?,
                                        lastEvaluatedKey: [String: AWSDynamoDBAttributeValue]? = nil)
    {
        let favourite = NSNumber(value: 1)
        if let cognitoId = AWSMobileClient.cognitoId {
            let queryExpression = AWSDynamoDBQueryExpression()
            queryExpression.indexName = "favourite-userId-index"
            queryExpression.keyConditionExpression = "favourite = :favourite AND userId = :userId"
            queryExpression.expressionAttributeValues = [":favourite" : favourite, ":userId" : cognitoId]
            if lastEvaluatedKey != nil {
                queryExpression.exclusiveStartKey = lastEvaluatedKey
            }
            let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
            dynamoDBObjectMapper.query(DynamoDBSwipedTinpon.self, expression: queryExpression).continueWith(block: { (task:AWSTask<AWSDynamoDBPaginatedOutput>!) -> Any? in

                if let error = task.error as NSError? {
                    print("The request failed. Error: \(error)")
                } else if let paginatedOutput = task.result {
                    let dynamoDBSwipedTinpons = (paginatedOutput.items as? [DynamoDBSwipedTinpon])!
                    
                    // if more Items queryable, repeat
//                    if let lastEvaluatedKey = task.result?.lastEvaluatedKey {
//                        loadAllFavouriteTinpons(onComplete: onComplete, lastEvaluatedKey: lastEvaluatedKey)
//                    } else {
                        var swipedTinpons: [SwipedTinpon] = []
                        for dynamoDBSwipedTinpon in dynamoDBSwipedTinpons {
                            swipedTinpons.append(castDynamoDBTinponToTinpon(dynamoDBTinpon: dynamoDBSwipedTinpon))
                        }
                        onComplete(swipedTinpons)
//                    }
                }
                return nil
            })
        } else {
            onComplete([])
        }
    }
}
