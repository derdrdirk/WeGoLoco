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

class Users: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    var _userId: String?
    var _createdAt: String?
    var _birthdate: String?
    var _gender: String?
    var _height: NSNumber?
    var _tinponCategories: Set<String>?
    var _updatedAt: String?
    
    class func dynamoDBTableName() -> String {
        return"tinpons-mobilehub-1827971537-Users"
    }
    
    class func hashKeyAttribute() -> String {
        return "_userId"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
            "_userId" : "userId",
            "_createdAt" : "createdAt",
            "_birthdate" : "birthdate",
            "_gender" : "gender",
            "_height" : "height",
            "_tinponCategories" : "tinponCategories",
            "_updatedAt" : "updatedAt",
        ]
    }
}
