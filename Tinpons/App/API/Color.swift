//
//  Color.swift
//  WeGoLoco
//
//  Created by Dirk Hornung on 11/8/17.
//
//

import Foundation

class Color : Hashable, Equatable {
    var name: String!
    var spanishName: String!
    var color: UIColor!
    
    static let spanishDictionary = ["azul" : "blue", "negro" : "black", "rojo" : "red"]
    static let colorDictionary = ["black" : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), "blue" : #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1), "red" : #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)]
    
    init(spanishName: String) {
        self.spanishName = spanishName
        self.name = Color.spanishDictionary[spanishName]
        self.color = Color.colorDictionary[self.name]
    }
    
    
    // MARK: Dictionary Protocols
    
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    static func ==(lhs: Color, rhs: Color) -> Bool {
        return lhs.name == rhs.name
    }
    
    /// The hash value.
    ///
    /// Hash values are not guaranteed to be equal across different executions of
    /// your program. Do not save hash values to use during a future execution.
    var hashValue: Int {
        return name.hashValue
    }
}
