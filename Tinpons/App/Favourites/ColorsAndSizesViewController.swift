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

class ColorsAndSizesViewController: FormViewController, LoadingAnimationProtocol {
    
    // MARK: Setup
    var category: String!
    
    // MARK: LoadingAnimationProtocol
    var loadingAnimationView: UIView!
    var loadingAnimationOverlay: UIView!
    var loadingAnimationIndicator: UIActivityIndicatorView!
    
    var tinpon: Tinpon!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingAnimationView = navigationController?.view
    
        tableView.isEditing = false
        
        // Sizes
        sizeSection(category: category)
        
        // Colors
        form +++ SelectableSection<ListCheckRow<String>>("Colores", selectionType: .multipleSelection) { $0.tag = "colorSection" }
        let colors = Color.spanishColors
        for option in colors {
            form.last! <<< ListCheckRow<String>(option){ listRow in
                listRow.title = option
                listRow.selectableValue = Color(spanishName: option).name
                listRow.value = nil
                }.cellUpdate { cell, row in
                    let color = Color.colorDictionary[row.selectableValue!]
                    cell.tintColor = color
                    cell.textLabel?.textColor = color
                    
                    // text outline for better visibility
//                    if row.title == "blanco" || row.title == "amarillo" || row.title == "gris" {
//                        let strokeTextAttributes = [
//                            NSStrokeColorAttributeName : UIColor.black,
//                            NSForegroundColorAttributeName : color,
//                            NSStrokeWidthAttributeName : -2.0,
//                            ] as [String : Any]
//                        
//                        cell.textLabel?.attributedText = NSAttributedString(string: row.title!, attributes: strokeTextAttributes)
//                    }
            }
        }

        
        form +++ Section("") {
            $0.tag = "Continuar"
            }
            <<< ButtonRow() {
                $0.title = "Continuar"
                }.cellSetup { buttonCell, _ in
                    buttonCell.tintColor = #colorLiteral(red: 0, green: 0.8166723847, blue: 0.9823040366, alpha: 1)
                }.onCellSelection{[weak self] buttonCell, row in
                    guard let strongSelf = self else { return }
                    if strongSelf.isValidColor() && strongSelf.isValidSize() {
//                        strongSelf.addSizesAndColorsToTinpon(selectedSizes, colors: selectedColors)
//                        strongSelf.performSegue(withIdentifier: "segueToQuantities", sender: self)
                        print("segue")
                    }
        }
    }
    
    
    // MARK: - Helper
    private func validateSizes() {

    }
    
    private func isValidSize() -> Bool {
        let colorSection = form.sectionBy(tag: "colorSection")! as! SelectableSection<ListCheckRow<String>>
        if colorSection.selectedRows().count > 0 {
            return true
        } else {
            let message = Message(title: "Hay que seleccionar un color.", backgroundColor: .red)
            Whisper.show(whisper: message, to: navigationController!, action: .show)
            return false
        }
    }
    
    private func isValidColor() -> Bool {
        let section = form.sectionBy(tag: "sizeSection")
        switch tinpon.category! {
        case "👕":
            let sizeSection = section as! SelectableSection<ListCheckRow<String>>
            if sizeSection.selectedRows().count > 0 {
                return true
            } else {
                let message = Message(title: "Hay que seleccionar un tamaño.", backgroundColor: .red)
                Whisper.show(whisper: message, to: navigationController!, action: .show)
                return false
            }
        case "👖":
            for row in section! {
                let multipleSelectorRow = row as! MultipleSelectorRow<Int>
                if multipleSelectorRow.value != nil && !multipleSelectorRow.value!.isEmpty {
                    return true
                }
            }
            // "else"
            let message = Message(title: "Hay que seleccionar un tamaño.", backgroundColor: .red)
            Whisper.show(whisper: message, to: navigationController!, action: .show)
            return false
        case "👞":
            let sizeSection = section as! SelectableSection<ListCheckRow<Int>>
            if sizeSection.selectedRows().count > 0 {
                return true
            } else {
                let message = Message(title: "Hay que seleccionar un tamaño.", backgroundColor: .red)
                Whisper.show(whisper: message, to: navigationController!, action: .show)
                return false
            }
        default :
            return false
        }
    }

    
    private func addSizesAndColorsToTinpon(_ sizes: [ListCheckRow<String>], colors: [ListCheckRow<String>]) {
        for colorRow in colors {
            let color = Color(spanishName: colorRow.selectableValue!)
            var sizeVariations = Array<SizeVariation>()
            for sizeRow in sizes {
                let sizeVariation = SizeVariation(size: sizeRow.selectableValue!, quantity: 0)
                sizeVariations.append(sizeVariation)
            }
            let colorVariation = ColorVariation(sizeVariations: sizeVariations, images: [TinponImage]())
            tinpon.productVariations[color] = colorVariation
        }
    }
    
    private func sizeSection(category: String) {
//        switch category {
//        case "👕":
//            let sizes = Sizes.dictionary[category] as! [String]
//            form +++ SelectableSection<ListCheckRow<String>>("\(category) Tamaños", selectionType: .multipleSelection) { $0.tag = "sizeSection" }
//            for option in sizes {
//                form.last! <<< ListCheckRow<String>(option){ listRow in
//                    listRow.title = option
//                    listRow.selectableValue = option
//                    listRow.value = nil
//                }
//            }
//        case "👖":
//            let sizes = Sizes.dictionary[category] as! [String : [Int]]
//            form +++ Section("\(category) Tamaños") { $0.tag = "sizeSection" }
//            for size in sizes["width"]! {
//                form.last! <<< MultipleSelectorRow<Int>() {
//                    $0.title = "\(size) x "
//                    $0.options = sizes["length"]!
//                    }
//                    .onPresent { from, to in
//                        to.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: from, action: #selector(ColorsAndSizesViewController.multipleSelectorDone(_:)))
//                }
//            }
//        case "👞":
//            let sizes = Sizes.dictionary[category] as! [Int]
//            form +++ SelectableSection<ListCheckRow<Int>>("\(category) Tamaños", selectionType: .multipleSelection) { $0.tag = "sizeSection" }
//            for option in sizes {
//                form.last! <<< ListCheckRow<Int>{ listRow in
//                    listRow.title = "\(option)"
//                    listRow.selectableValue = option
//                    listRow.value = nil
//                }
//            }
//        default: ()
//        }
    }
    
    func multipleSelectorDone(_ item:UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let quantitiesViewController = segue.destination as! QuantitiesViewController
        quantitiesViewController.tinpon = self.tinpon
    }
}
