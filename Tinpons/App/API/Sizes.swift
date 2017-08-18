//
//  Sizes.swift
//  WeGoLoco
//
//  Created by Dirk Hornung on 18/8/17.
//
//

import Foundation

class Sizes {
    static let 👕 = ["XS", "S", "M", "L", "XL", "XXL"]
    
    static var 👖: [String: [Int]] {
        var result = ["width" : [Int](), "length" : [Int]()]
        for width in 25...44 {
            result["width"]?.append(width)
        }
        for length in 30...36 {
            result["length"]?.append(length)
        }
        return result
    }
    
    static var 👞: [Int] {
        var result = [Int]()
        for size in 35...50 {
            result.append(size)
        }
        return result
    }
    
    static let dictionary: [String: Any] = ["👕" : Sizes.👕, "👖" : Sizes.👖, "👞" : Sizes.👞]
}


