//
//  Helper.swift
//  Tinpons
//
//  Created by Dirk Hornung on 18/7/17.
//
//

import Foundation

extension String {
    
    var toJSON: Any? {
        
        let data = self.data(using: String.Encoding.utf8, allowLossyConversion: false)
        
        if let jsonData = data {
            // Will return an object or nil if JSON decoding fails
            return try? JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers)
        } else {
            // Lossless conversion of the string was not possible
            return nil
        }
    }
}
