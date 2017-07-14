//
//  SwipedTinpons.swift
//  Tinpons
//
//  Created by Dirk Hornung on 5/7/17.
//
//

import Foundation
import UIKit
import AWSDynamoDB

class DynamoDBSwipedTinpon: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    var userId: String?
    var swipedAt: String?
    var like: NSNumber?
    var tinponId: String?
    var favourite: NSNumber?
    
    class func dynamoDBTableName() -> String {
        return "tinpons-mobilehub-1827971537-SwipedTinpons"
    }
    
    class func hashKeyAttribute() -> String {
        return "userId"
    }
    
    class func rangeKeyAttribute() -> String {
        return "tinponId"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
            "userId" : "userId",
            "swipedAt" : "swipedAt",
            "like" : "like",
            "tinponId" : "tinponId",
        ]
    }
}
