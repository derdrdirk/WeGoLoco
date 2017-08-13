//
//  Tinpon.swift
//  Tinpons
//
//  Created by Dirk Hornung on 31/7/17.
//
//

import Foundation

struct ColorVariation {
    var sizeVariations = [SizeVariation]()
    var images = [UIImage]()
    
    // Sequence Protocol
    //var iterattionsCount = 0
    
   
}

struct SizeVariation {
    var size: String
    var quantity: Int
}

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
    var images = [UIImage]()
    var productVariations = [Color : ColorVariation]()
    
    var description: String {
        return "tinponId: \(tinponId ?? "nil")"
    }
    
    init() {}
    
    init(testing: Bool) {
        if testing {
            self.name = "Name"
            self.category = "👕"
            self.price = 49.99
            
            let blackColor = Color(spanishName: "negro")
            let redColor = Color(spanishName: "rojo")
            let sizeVariation = SizeVariation(size: "M", quantity: 1000)
            let sizeVariations = [sizeVariation, sizeVariation]
            let colorVariation = ColorVariation(sizeVariations: sizeVariations, images: [])
            self.productVariations = [blackColor : colorVariation, redColor : colorVariation]
            
            print(self.toJSON()!)
        }
    }
    
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
    //                                                      color  : [  sizeVariation : [ [ size : "M" ] , [ quantity : 1000 ] ]
    fileprivate func makeProductVariationsJSONCompatible() -> [ String : [ String : [ [ String : Any ] ] ] ] {
        // example: ["Red" : [["M" : 1000], ["XL" : 100]], "Black" :["S" : 500]]]
        var result = [ String : [ String : [ [ String : Any ] ] ] ]()
        for productVariation in self.productVariations {
            let color = productVariation.key.name!
            result[color] = ["sizeVariation" : [ [ String : Any ] ]() ]
            for sizeVariation in productVariation.value.sizeVariations {
                let size = sizeVariation.size
                let quantity = sizeVariation.quantity
                let jsonSizeVariation = ["size" : size, "quantity" : quantity] as [String : Any]
                result[color]?["sizeVariation"]?.append(jsonSizeVariation)
            }
        }
        return result
    }
    
    open func toJSON() -> String? {
        let jsonObject: [String: Any] = ["name": self.name, "category_id" : self.category, "price" : self.price, "productVariations" : makeProductVariationsJSONCompatible(), "main_image" : "imageKey"]
//        let jsonObject: [String: Any] = ["id": self.id, "email" : self.email, "birthdate" : birthdate?.iso8601, "gender" : gender, "categories" : Array(categories) ]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: jsonObject,
                                                      options: .prettyPrinted)
            return String(data: jsonData, encoding: String.Encoding.utf8)
        } catch let error {
            print("User: error converting to json: \(error)")
            return nil
        }
    }
}
