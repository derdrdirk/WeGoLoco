//
//  UsersAPI.swift
//  Tinpons
//
//  Created by Dirk Hornung on 23/7/17.
//
//

import Foundation

class User: CustomStringConvertible {
    var id: String
    var createdAt: Date?
    var birthdate: Date?
    var email: String?
    var password: String?
    var gender: String?
    var categories: Set<String>
    var updatedAt: Date?
    
    var description: String {
        return "id: \(id) \n email: \(email ?? "nil") \n birthdate: \(birthdate?.iso8601 ?? "nil") \n gender: \(gender ?? "nil") \n updatedAt: \(updatedAt?.iso8601 ?? "nil") \n createdAt: \(createdAt?.iso8601 ?? "nil")"
    }

    init() {
        self.id = ""
        self.categories = Set<String>()
    }
    
    init(json: [String: Any]) throws {
        guard let id = json["id"] as? String else {
            throw SerializationError.missing("UserId")
        }
        self.id = id
        self.categories = Set(json["categories"] as! [String])
        self.createdAt = (json["createdAt"] as? String)?.dateFromISO8601
        self.birthdate = (json["birthdate"] as? String)?.dateFromISO8601
        self.email = json["email"] as? String
        self.gender = json["gender"] as? String
        self.updatedAt = (json["updatedAt"] as? String)?.dateFromISO8601
    }

    func toJSON() -> String? {
        let jsonObject: [String: Any] = ["id": self.id, "email" : self.email, "birthdate" : birthdate?.iso8601, "gender" : gender, "categories" : Array(categories) ]
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
