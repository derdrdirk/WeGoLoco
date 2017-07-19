//
//  Tinpon.swift
//  Tinpons
//
//  Created by Dirk Hornung on 7/7/17.
//
//

import Foundation
import UIKit
import AWSDynamoDB
import AWSS3
import AWSMobileHubHelper

class TinponOld : CustomStringConvertible {
    var category: String?
    var createdAt: String?
    var latitude: NSNumber?
    var longitude: NSNumber?
    var name: String?
    var price: NSNumber?
    var tinponId: String?
    var updatedAt: String?
    var userId: String?
    var imgUrl: String?
    var active: NSNumber?
    
    let s3BucketName = "tinpons-userfiles-mobilehub-1827971537"
    var image: UIImage?
    var imageData: Data? {
        if image != nil {
            return UIImagePNGRepresentation(image!)
        } else {
            return nil
        }
    }
    var s3ImagePath: String {
        return tinponId!
    }
    var noMoreTinponsToLoad = false
    var lastEvaluatedKey: [String: AWSDynamoDBAttributeValue]?

    init() {
        tinponId = UUID().uuidString
        userId = AWSMobileClient.cognitoId
        createdAt = Date().iso8601
        active = NSNumber(value: 1)
    }
    
    var description: String {
        return "Name: \(name ?? "") \nImage: \(String(describing: imgUrl)) \nPrice: \(String(Double(price ?? 0))) \nCategory: \(category ?? "") \nActive: \(active)"
    }
    
//    private func dynamoDBTinpon() -> DynamoDBTinpon {
//        let tinpon = DynamoDBTinpon()
//        tinpon?.category = category
//        tinpon?.createdAt = createdAt
//        tinpon?.imgUrl = s3ImagePath
//        tinpon?.latitude = latitude
//        tinpon?.longitude = longitude
//        tinpon?.name = name
//        tinpon?.price = price
//        tinpon?.tinponId = tinponId
//        tinpon?.updatedAt = updatedAt
//        tinpon?.userId = userId
//        tinpon?.active = active
//        return tinpon!
//    }
    
//    static func castDynamoDBTinponToTinpon(dynamoDBTinpon: DynamoDBTinpon) -> Tinpon {
//        let tinpon = Tinpon()
//        tinpon.category = dynamoDBTinpon.category
//        tinpon.createdAt = dynamoDBTinpon.createdAt
//        tinpon.imgUrl = dynamoDBTinpon.imgUrl
//        tinpon.latitude = dynamoDBTinpon.latitude
//        tinpon.longitude = dynamoDBTinpon.longitude
//        tinpon.name = dynamoDBTinpon.name
//        tinpon.price = dynamoDBTinpon.price
//        tinpon.tinponId = dynamoDBTinpon.tinponId
//        tinpon.updatedAt = dynamoDBTinpon.updatedAt
//        tinpon.userId = dynamoDBTinpon.userId
//        tinpon.active = dynamoDBTinpon.active
//        return tinpon
//    }
    
    
    

    
}
