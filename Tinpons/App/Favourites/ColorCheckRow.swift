//
//  productVariationCell.swift
//  WeGoLoco
//
//  Created by Dirk Hornung on 9/8/17.
//
//

import Foundation
import Eureka

public final class ColorCheckRow<T: Equatable>: Row<ColorCheckCell<T>>, SelectableRowType, RowType {
    public var selectableValue: T?
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
    }
}

open class ColorCheckCell<T: Equatable> : Cell<T>, CellType {
    
    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var circleView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
    var circleColor: UIColor!
    
    open override func setup() {
        super.setup()
        print("setup \(row.title)")
        accessoryType = .none
        
        circleColor = colorDictionary[row.title!]
        
        circleView.layer.borderColor = circleColor.cgColor
        circleView.layer.borderWidth = 1
        
        accessoryView = circleView
        accessoryView?.sizeToFit()
        
    }

    open override func update() {
        super.update()
        print("update \(row.title)")
        print("row value \(row.value)")
        
        if row.value != nil {
            circleView.backgroundColor = circleColor
        } else {
            circleView.backgroundColor = nil
        }
    }
    
    open override func didSelect() {
        row.select()
        row.deselect()
    }
    
}






