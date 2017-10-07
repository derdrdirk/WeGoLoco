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
    
    static var spanishColors: [String] {
        return spanishDictionary.map { key, value in return key }
    }
    static let spanishDictionary = ["mulitcolor" : "multicolor", "amarillo" : "yellow", "azul" : "blue", "blanco" : "white", "cian" : "cyan", "fucisa" : "magenta", "gris" : "grey", "lila" : "purple", "naranja" : "orange", "negro" : "black", "marrón" : "brown", "rojo" : "red", "verde" : "green"]
    static let colorDictionary = ["multicolor" : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), "black" : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), "blue" : #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1), "brown" : #colorLiteral(red: 0.6679978967, green: 0.4751212597, blue: 0.2586010993, alpha: 1), "cyan" : #colorLiteral(red: 0, green: 0.9914394021, blue: 1, alpha: 1), "green" : #colorLiteral(red: 0, green: 0.9768045545, blue: 0, alpha: 1), "grey" : #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1), "magenta" : #colorLiteral(red: 1, green: 0.2527923882, blue: 1, alpha: 1), "orange" : #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1), "purple" : #colorLiteral(red: 0.5791940689, green: 0.1280144453, blue: 0.5726861358, alpha: 1), "red" : #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1), "yellow" : #colorLiteral(red: 0.9994240403, green: 0.9855536819, blue: 0, alpha: 1), "white": #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1)]
    
    init(name: String) {
        self.name = name
        self.color = Color.colorDictionary[self.name]
    }
    
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
