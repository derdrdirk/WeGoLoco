//
//  Tinpon.swift
//  Tinpons
//
//  Created by Dirk Hornung on 31/7/17.
//
//

import Foundation

class Tinpon: CustomStringConvertible {
    var tinponId: String?
    var active: Bool?
    var category: String?
    var createdAt: Date?
    var imgUrl: String?
    var latitude: Double?
    var longitude: Double?
    var name: String?
    var price: Double?
    var updatedAt: Date?
    var userId: String?
    var mainImage: UIImage?
    var additionalImages: [UIImage]?

    var description: String {
        return "tinponId: \(tinponId ?? "nil")"
    }
    
    init() {}
    
    init(json: [String:Any]) throws {
        guard let tinponId = json["tinponId"] as? String else {
            throw SerializationError.missing("userId")
        }
        
        guard let active = json["active"] as? Bool else {
            throw SerializationError.missing("active")
        }
        
        guard let category = json["category"] as? String else {
            throw SerializationError.missing("category")
        }
        
        guard let createdAt = (json["createdAt"] as? String)?.dateFromISO8601 else {
            throw SerializationError.missing("createdAt")
        }
        
        guard let imgUrl = json["imgUrl"] as? String else {
            throw SerializationError.missing("imgUrl")
        }
        
        guard let latitude = json["latitude"] as? Double else {
            throw SerializationError.missing("latitude")
        }

        
        guard let longitude = json["longitude"] as? Double else {
            throw SerializationError.missing("longitude")
        }
        
        guard let name = json["name"] as? String else {
            throw SerializationError.missing("name")
        }
        
        guard let price = json["price"] as? Double else {
            throw SerializationError.missing("price")
        }
        
        guard let updatedAt = (json["updatedAt"] as? String)?.dateFromISO8601 else {
            throw SerializationError.missing("updatedAt")
        }
        
        guard let userId = json["userId"] as? String else {
            throw SerializationError.missing("userId")
        }
        
        
        self.tinponId = tinponId
        self.active = active
        self.category = category
        self.createdAt = createdAt
        self.imgUrl = imgUrl
        self.latitude = latitude
        self.longitude = longitude
        self.name = name
        self.price = price
        self.updatedAt = updatedAt
        self.userId = userId
    }
}
