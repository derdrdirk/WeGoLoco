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
    
    // MARK: - Model
    public var gender: Gender!
    public var category: Categories.Category!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // testing
        gender = .male
        category = .jeans
        
        // add Next button
        addNextBarButtonItem()
        
        form +++ Section("\(category!) Sizes")

        addSizesRows()
    }
    
    // MARK: - Helpers
    private func addSizesRows() {
        let sizes = Sizes.getSizesFor(gender: gender, category: category)
        
        switch sizes {
        case .StringSize(let sizes):
            for size in sizes {
                form.last! <<< CheckRow() {
                    $0.title = size
                    $0.value = false
                    }.cellUpdate { _,_ in
                        self.validate()
                }
            }
        case .DoubleSize(let sizes):
            for size in sizes {
                form.last! <<< CheckRow() {
                    $0.title = size.description
                    $0.value = false
                    }.cellUpdate { _,_ in
                        self.validate()
                }
            }
        case .DoubleDoubleSize(let sizes):
            // dictionary normaly not sorted
            let sortedWidths = Array(sizes.keys).sorted()
            
            for width in sortedWidths {
                let lengths = sizes[width]
                form.last! <<< MultipleSelectorRow<Double>() {
                    $0.title = width.description
                    $0.options = lengths!
                    }.onPresent { from, to in
                        to.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: from, action: #selector(self.multipleSelectorDone(_:)))
                }
            }

        }

    }
    
    private func getSelectedSizes() -> [String] {
        
        var sizes = [String]()
        if let formRows = form.allRows as? [CheckRow] {
            for row in formRows {
                if row.value! {
                    sizes.append(row.title!)
                }
            }
        }
        return sizes
    }
    
    private func isValid() -> Bool {
        if getSelectedSizes().count > 0 {
            return true
        } else {
            return false
        }
    }
    private func validate() {
        if isValid() {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
           self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    private func addNextBarButtonItem() {
        let barButtonItem = UIBarButtonItem()
        barButtonItem.title = "Next"
        barButtonItem.isEnabled = false
        self.navigationItem.rightBarButtonItem = barButtonItem
    }
    
    func multipleSelectorDone(_ item:UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
    }
    
}
