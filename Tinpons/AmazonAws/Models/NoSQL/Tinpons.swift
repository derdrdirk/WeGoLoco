//
//  Tinpons.swift
//  MySampleApp
//
//
// Copyright 2017 Amazon.com, Inc. or its affiliates (Amazon). All Rights Reserved.
//
// Code generated by AWS Mobile Hub. Amazon gives unlimited permission to 
// copy, distribute and modify it.
//
// Source code generated from template: aws-my-sample-app-ios-swift v0.16
//

import Foundation
import UIKit
import AWSDynamoDB

class Tinpons: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var _id: String?
    var _created: NSNumber?
    var _img: String?
    var _name: String?
    var _preis: NSNumber?
    var _productType: String?
    var _tags: Set<String>?
    
    class func dynamoDBTableName() -> String {

        return "tinpons-mobilehub-1827971537-Tinpons"
    }
    
    class func hashKeyAttribute() -> String {

        return "_id"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
               "_id" : "Id",
               "_created" : "Created",
               "_img" : "Img",
               "_name" : "Name",
               "_preis" : "Preis",
               "_productType" : "ProductType",
               "_tags" : "Tags",
        ]
    }
}
