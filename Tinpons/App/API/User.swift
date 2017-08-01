//
//  UsersAPI.swift
//  Tinpons
//
//  Created by Dirk Hornung on 23/7/17.
//
//

import Foundation

struct User: CustomStringConvertible {
    let userId: String
    let createdAt: Date
    var birthdate: Date
    var email: String
    var gender: String
    var tinponCategories: Set<String>
    var updatedAt: Date
    
    var description: String {
        return "userId: \(userId) \n createdAt: \(createdAt) \n birthdate: \(birthdate) \n gender: \(gender)"
    }
}

extension User {
    init() {
        self.userId = UUID().uuidString
        self.createdAt = Date()
        self.tinponCategories = Set<String>()
        self.birthdate = Date()
        self.email = ""
        self.gender = ""
        self.updatedAt = self.createdAt
    }
    
    init?(json: [String: Any]) {
        guard let userId = json["userId"] as? String,
            let createdAt = (json["createdAt"] as? String)?.dateFromISO8601,
            let birthdate = (json["birthdate"] as? String)?.dateFromISO8601,
            let email = json["email"] as? String,
            let gender = json["gender"] as? String,
            // JSON set: { "tinponCategories" : { "values" : [ ... ] } }
            let tinponCategories = (json["tinponCategories"] as? [String:Any])?["values"] as? [String],
            let updatedAt = (json["updatedAt"] as? String)?.dateFromISO8601
        else { return nil }

        self.userId = userId
        self.createdAt = createdAt
        self.tinponCategories = Set(tinponCategories)
        self.birthdate = birthdate
        self.email = email
        self.gender = gender
        self.updatedAt = updatedAt
    }

    func toJSON() -> String? {
        let jsonObject: [String: Any] = ["userId": self.userId, "createdAt" : self.createdAt.iso8601, "birthdate" : self.birthdate.iso8601, "email" : self.email, "gender" : self.gender, "tinponCategories": Array(tinponCategories), "updatedAt" : updatedAt.iso8601]
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
