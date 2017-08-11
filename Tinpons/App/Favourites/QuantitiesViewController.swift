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
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
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
        let section = MultivaluedSection(multivaluedOptions: [.Reorder, .Delete],
                               header: color.spanishName,
                               footer: "Swipe a la izquierda para borrar fillas.")

        let colorVariation = tinpon.productVariations[color]!
        
        for sizeVariation in colorVariation.sizeVariations {
            section <<< IntRow() {
                $0.title = "Cuantidad - "+sizeVariation.size
                $0.add(rule: RuleRequired())
            }.cellUpdate { cell, row in
                if !row.isValid {
                    cell.titleLabel?.textColor = .red
                }
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
    
    // MARK : Actions
    
    @IBAction func saveButton(_ sender: UIBarButtonItem) {
        if form.validate().isEmpty {
            print("nice continue")
        } else {
            let message = Message(title: "Faltan cuantidades.", backgroundColor: .red)
            Whisper.show(whisper: message, to: navigationController!, action: .show)
        }
    }
    
    
    // MARK : Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("segue")
    }
}
