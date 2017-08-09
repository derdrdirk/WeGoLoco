//
//  ProductVariationRow.swift
//  WeGoLoco
//
//  Created by Dirk Hornung on 9/8/17.
//
//

import Foundation
import Eureka

final class ProductVariationRow: Row<ProductVariationCell>, RowType {
    required init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<ProductVariationCell>(nibName: "ProductVariationCell")
    }
}
