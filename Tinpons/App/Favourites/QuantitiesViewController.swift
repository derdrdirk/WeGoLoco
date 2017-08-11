//
//  ColorsAndSizesViewController.swift
//  WeGoLoco
//
//  Created by Dirk Hornung on 10/8/17.
//
//

import UIKit
import Eureka
import Whisper
import ImageRow

class QuantitiesViewController: FormViewController, LoadingAnimationProtocol {
    
    // MARK: LoadingAnimationProtocol
    var loadingAnimationView: UIView!
    var loadingAnimationOverlay: UIView!
    var loadingAnimationIndicator: UIActivityIndicatorView!
    
    var tinpon: Tinpon!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingAnimationView = navigationController?.view
        
        tableView.isEditing = false
        
        productSections()
    }
    
    
    // MARK: Sections
    
    private func productSections() {
        for productVariation in tinpon.productVariations {
            let color = productVariation.key
            form +++ colorSection(color: color)
        }
    }
    
    private func colorSection(color: Color) -> Section {
        let section = Section(color.spanishName)
        let colorVariation = tinpon.productVariations[color]!
        
        for sizeVariation in colorVariation.sizeVariations {
            section <<< IntRow() {
                $0.title = "Cuantidad - "+sizeVariation.size
            }
        }
        
        section <<< recursiveImageRow(color: color)
        
        return section
    }
    
    
    // MARK: Rows
    
    private func recursiveImageRow(color: Color) -> ImageRow {
        let imageRow = ImageRow() {
            $0.title = "Imagen"
            $0.sourceTypes = [.PhotoLibrary]
            $0.clearAction = .yes(style: .default)
            }.onChange {
                var productVariation = self.tinpon.productVariations[color]!
                let rowIndex = $0.indexPath!.row
                let imageIndex = rowIndex - productVariation.sizeVariations.count
                if let image = $0.value {
                    // add row
                    self.tinpon.productVariations[color]!.images.append(image)
                    $0.section?.insert(self.recursiveImageRow(color: color), at: rowIndex+1)
                } else {
                    // delete row
                    $0.section?.remove(at: rowIndex)
                    self.tinpon.productVariations[color]!.images.remove(at: imageIndex)
                }
        }
        
        return imageRow
    }
}
