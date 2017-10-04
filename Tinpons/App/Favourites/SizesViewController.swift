//
//  SizesViewController.swift
//  WeGoLoco
//
//  Created by Dirk Hornung on 2/10/17.
//
//

import Foundation
import Eureka

class SizesViewController : FormViewController {
    
    // MARK: Model
    public var gender: Gender!
    public var category: Categories.Category!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // testing
//        gender = .male
//        category = .sweaters
        
        form +++ Section("\(category!) Sizes")
        
        addSizesRows()
    }
    
    // MARK: Helpers
    private func addSizesRows() {
        let sizes = Sizes.getSizesFor(gender: gender, category: category)
        switch sizes {
        case is [String]:
            for size in sizes as! [String] {
                form.last! <<< CheckRow() {
                    $0.title = size
                    $0.value = false
                }
            }
        case is [Double]:
            return
        case is ([Double], [Double]):
            return
        default:
            return
        }
    }
    
}
