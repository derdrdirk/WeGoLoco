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

class SwipedTinpons: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    var _userId: String?
    var _swipedAt: String?
    var _like: NSNumber?
    var _tinponId: String?
    
    class func dynamoDBTableName() -> String {
        return "tinpons-mobilehub-1827971537-SwipedTinpons"
    }
    
    class func hashKeyAttribute() -> String {
        return "_userId"
    }
    
    class func rangeKeyAttribute() -> String {
        return "_swipedAt"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
            "_userId" : "userId",
            "_swipedAt" : "swipedAt",
            "_like" : "like",
            "_tinponId" : "tinponId",
        ]
    }
}
