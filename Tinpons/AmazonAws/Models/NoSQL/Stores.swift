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

class Stores: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    var _userId: String?
    var _storeId: String?
    var _latitude: NSNumber?
    var _longitude: NSNumber?
    var _name: String?
    
    class func dynamoDBTableName() -> String {
        return "tinpons-mobilehub-1827971537-Stores"
    }
    
    class func hashKeyAttribute() -> String {
        return "_userId"
    }
    
    class func rangeKeyAttribute() -> String {
        return "_storeId"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
            "_userId" : "userId",
            "_storeId" : "storeId",
            "_latitude" : "latitude",
            "_longitude" : "longitude",
            "_name" : "name",
        ]
    }
}
