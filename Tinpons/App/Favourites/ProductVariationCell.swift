//
//  productVariationCell.swift
//  WeGoLoco
//
//  Created by Dirk Hornung on 9/8/17.
//
//

import Foundation
import Eureka

struct ProductVariation: Equatable {
    var size: String
    var color: UIColor
    var quantity: Int
}

func ==(lhs: ProductVariation, rhs: ProductVariation) -> Bool {
    return lhs.size == rhs.size && lhs.color == rhs.color
}

final class ProductVariationCell: Cell<ProductVariation>, CellType, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet weak var sizeTextField: UITextField!
    @IBOutlet weak var colorTextField: UITextField!
    @IBOutlet weak var quantityTextField: UITextField!
    
    // Pickers
    var sizePickerView = UIPickerView()
    var 👕Sizes = ["XS", "S", "M", "L", "XL"]
    var colorPickerView = UIPickerView()
    var colors : [[String: UIColor]] = [["Negro" : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)],["Azul" : #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)],["Rojo" : #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)]]
    
    
    required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Setup Pickers
    private func setupPickers() {
        sizePickerView.dataSource = self
        sizePickerView.delegate = self
        sizePickerView.showsSelectionIndicator = true
        sizePickerView.backgroundColor = #colorLiteral(red: 0, green: 0.03529411765, blue: 0.0862745098, alpha: 1)
        self.sizeTextField.inputView = sizePickerView
        
        colorPickerView.dataSource = self
        colorPickerView.delegate = self
        colorPickerView.showsSelectionIndicator = true
//        colorPickerView.backgroundColor = #colorLiteral(red: 0, green: 0.03529411765, blue: 0.0862745098, alpha: 1)
        self.colorTextField.inputView = colorPickerView

    }
    
    // DataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case sizePickerView:
            return 👕Sizes.count
        case colorPickerView:
            return colors.count
        default:
            return 0
        }
    }
    
    // Delegate
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        label.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        label.textAlignment = .center
        
        switch pickerView {
        case sizePickerView:
            label.text = 👕Sizes[row]
        case colorPickerView:
            label.textColor = colors[row].values.first
            label.text = colors[row].keys.first
        default:
            label.text = ""
        }
        
        return label
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
        case sizePickerView:
            sizeTextField.text = 👕Sizes[row]
        case colorPickerView:
            colorTextField.textColor = colors[row].values.first
            colorTextField.text = colors[row].keys.first
        default:
            return
        }
    }
 
    
    override func setup() {
        super.setup()
        
        setupPickers()

        selectionStyle = .none
    }
    
    
}

