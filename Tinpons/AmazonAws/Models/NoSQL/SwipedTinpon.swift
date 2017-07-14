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
                    swipedTinpons.append(SwipedTinpon.castDynamoDBSwipedTinponToSwipedTinpon(dynamoDBSwipedTinpon: dynamoDBSwipedTinpon))
                }
                
                onComplete(swipedTinpons)
            }
            return nil
        })
    }
    
    static func loadAllFavouriteTinpons(lastEvaluatedKey: [String: AWSDynamoDBAttributeValue]? = nil,
                                        //swipedTinpons: [DynamoDBSwipedTinpon]?,
                                        _ onComplete: @escaping ([Tinpon]) -> ())
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
            dynamoDBObjectMapper.query(DynamoDBSwipedTinpon.self, expression: queryExpression).continueOnSuccessWith(block: { (task:AWSTask<AWSDynamoDBPaginatedOutput>!) -> AWSTask<AnyObject>? in
                
                if let paginatedOutput = task.result {
                    let dynamoDBSwipedTinpons = (paginatedOutput.items as? [DynamoDBSwipedTinpon])!
                    
                    var tasks = Array<AWSTask<AnyObject>>()
                    dynamoDBSwipedTinpons.forEach({
                        tasks.append(dynamoDBObjectMapper.load(DynamoDBTinpon.self, hashKey: $0.tinponId, rangeKey: nil))
                    })
                    return AWSTask(forCompletionOfAllTasksWithResults: tasks)
                }
                return nil
            }).continueWith { task in
                if let dynamoDBTinpons = task.result as? [DynamoDBTinpon] {
                    var tinpons = Array<Tinpon>()
                    dynamoDBTinpons.forEach{
                        tinpons.append(Tinpon.castDynamoDBTinponToTinpon(dynamoDBTinpon: $0))
                    }
                    onComplete(tinpons)
                } else if let error = task.error {
                    print("Fetching Favourites error: \(error.localizedDescription)")
                }
                return nil
            }
        
        } else {
            onComplete([])
        }
    }
}
