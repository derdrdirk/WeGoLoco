//
//  UsersAPI.swift
//  Tinpons
//
//  Created by Dirk Hornung on 23/7/17.
//
//

import Foundation

class User: CustomStringConvertible {
    let userId: String
    let createdAt: Date?
    var birthdate: Date?
    var email: String?
    var gender: String?
    var tinponCategories: Set<String>?
    var updatedAt: Date?
    
    var description: String {
        updatedAt?.iso8601
        return "userId: \(userId) \n email: \(email ?? "nil") \n birthdate: \(birthdate?.iso8601 ?? "nil") \n gender: \(gender ?? "nil") \n updatedAt: \(updatedAt?.iso8601 ?? "nil") \n createdAt: \(createdAt?.iso8601 ?? "nil")"
    }

    init() {
        self.userId = UUID().uuidString
        self.createdAt = Date()
        self.tinponCategories = Set<String>()
        self.birthdate = Date()
        self.email = ""
        self.gender = ""
        self.updatedAt = self.createdAt
    }
    
    init(json: [String: Any]) throws {
        guard let userId = json["id"] as? String else {
            throw SerializationError.missing("UserId")
        }
        self.userId = userId
        
        self.createdAt = (json["createdAt"] as? String)?.dateFromISO8601
        self.tinponCategories = nil
        self.birthdate = (json["birthdate"] as? String)?.dateFromISO8601
        self.email = json["email"] as? String
        self.gender = json["gender"] as? String
        self.updatedAt = (json["updatedAt"] as? String)?.dateFromISO8601
    }

    func toJSON() -> String? {
        let jsonObject: [String: Any] = ["userId": self.userId, "createdAt" : self.createdAt!.iso8601, "birthdate" : self.birthdate!.iso8601, "email" : self.email, "gender" : self.gender, "tinponCategories": Array(tinponCategories!), "updatedAt" : updatedAt!.iso8601]
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
