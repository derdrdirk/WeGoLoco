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
//        gender = .male
//        category = .sweaters
        
        // add Next button
        addNextBarButtonItem()
        
        form +++ Section("\(category!) Sizes")

        addSizesRows()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let colorVC = segue.destination as? ColorsViewController {
           
        }
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
                }.cellUpdate { _,_ in
                    self.validate()
                }
            }

        }

    }
    
    private func getSelectedSizes() -> Sizes.Size {
        let sizes = Sizes.getSizesFor(gender: gender, category: category)

        switch sizes {
        case .StringSize(_):
            var result = [String]()
            if let formRows = form.allRows as? [CheckRow] {
                for row in formRows {
                    if row.value! {
                        result.append(row.title!)
                    }
                }
            }
            return Sizes.Size.StringSize(result)
        case .DoubleSize(_):
            var result = [Double]()
            if let formRows = form.allRows as? [CheckRow] {
                for row in formRows {
                    if row.value! {
                        result.append(Double(row.title!)!)
                    }
                }
            }
            return Sizes.Size.DoubleSize(result)
        case .DoubleDoubleSize(_):
            var result = [Double:[Double]]()
            if let formRows = form.allRows as? [MultipleSelectorRow<Double>] {
                for row in formRows {
                    if let selectedLengths = row.value, row.value!.count > 0 {
                        result[Double(row.title!)!] = Array(selectedLengths)
                    }
                }
            }
            return Sizes.Size.DoubleDoubleSize(result)
        }
    }
    
    private func isValid() -> Bool {
        let sizes = getSelectedSizes()
        
        switch sizes {
        case .StringSize( let stringSizes):
            if stringSizes.count > 0 {
                return true
            } else {
                return false
            }
        case .DoubleSize( let doubleSizes ):
            if doubleSizes.count > 0 {
                return true
            } else {
                return false
            }
        case .DoubleDoubleSize( let doubleDoubleSizes ):
            if doubleDoubleSizes.count > 0 {
                return true
            } else {
                return false
            }
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
        let barButtonItem = UIBarButtonItem.init(title: "Next", style: .plain, target: self, action: #selector(self.segueToColors))
        barButtonItem.isEnabled = false
        self.navigationItem.rightBarButtonItem = barButtonItem
    }
    
    @objc private func segueToColors() {
        self.performSegue(withIdentifier: "segueToColors", sender: self)
    }
    
    @objc private func multipleSelectorDone(_ item:UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
    }
    
}
