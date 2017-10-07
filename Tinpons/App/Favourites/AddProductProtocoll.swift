//
//  AddProductProtocoll.swift
//  WeGoLoco
//
//  Created by Dirk Hornung on 7/10/17.
//
//

import Foundation

protocol AddProductProtocol {
    // MARK: - Model
    var tinpon: Tinpon! { get set }
    
    func guardTinpon() -> Void

}
