//
//  SwipedTinpon.swift
//  Tinpons
//
//  Created by Dirk Hornung on 12/7/17.
//
//

import Foundation
import AWSDynamoDB

class SwipedTinpon {
    var userId: String?
    var swipedAt: String?
    var like: NSNumber?
    var tinponId: String?
    
    private func dynamoDBSwipedTinpon() -> DynamoDBSwipedTinpon {
        let swipedTinpon = DynamoDBSwipedTinpon()
        swipedTinpon?.userId = userId
        return swipedTinpon!
    }
    
    private static func castDynamoDBTinponToTinpon(dynamoDBTinpon: DynamoDBSwipedTinpon) -> SwipedTinpon {
        let swipedTinpon = SwipedTinpon()
        swipedTinpon.userId = dynamoDBTinpon.userId
        swipedTinpon.swipedAt = dynamoDBTinpon.swipedAt
        swipedTinpon.like = dynamoDBTinpon.like
        swipedTinpon.tinponId = dynamoDBTinpon.tinponId
        return swipedTinpon
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
            print("jojo")
            //guard let strongSelf = self else {return nil}
            
            print("JO")
            
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
}
