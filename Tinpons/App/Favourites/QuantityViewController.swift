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

class QuantityViewController: FormViewController, LoadingAnimationProtocol {
    
    // MARK: LoadingAnimationProtocol
    var loadingAnimationView: UIView!
    var loadingAnimationOverlay: UIView!
    var loadingAnimationIndicator: UIActivityIndicatorView!
    
    var tinpon: Tinpon!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingAnimationView = navigationController?.view
        
        tableView.isEditing = false
        
        
        form +++ SelectableSection<ListCheckRow<String>>("Where do you live", selectionType: .singleSelection(enableDeselection: true))
        
        let continents = ["Africa", "Antarctica", "Asia", "Australia", "Europe", "North America", "South America"]
        for option in continents {
            form.last! <<< ListCheckRow<String>(option){ listRow in
                listRow.title = option
                listRow.selectableValue = option
                listRow.value = nil
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
                    
                    if strongSelf.form.validate().isEmpty {
                        strongSelf.performSegue(withIdentifier: "segueToQuantities", sender: self)
                    } else {
                        let message = Message(title: "El formulario no es valido.", backgroundColor: .red)
                        Whisper.show(whisper: message, to: strongSelf.navigationController!, action: .show)
                    }
        }
    }
    
    
    // MARK: Rows
    
    //    private func productVariationSection() -> Section {
    //        var section = MultivaluedSection(multivaluedOptions: [.Insert, .Delete]) {
    //            $0.header = {
    //                var header = HeaderFooterView<UIView>(.callback({
    //                    let view = UIView(frame: CGRect(x: 0, y: 0, width: super.view.bounds.width, height: 40))
    //                    let textField = UITextField(frame: CGRect(x: 15, y: 0, width: super.view.bounds.width, height: 40))
    //                    textField.text = "Rojo"
    //                    textField.textColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
    //                    //self.colorTextFields.append(textField)
    //                    view.addSubview(textField)
    //                    return view
    //                }))
    //                return header
    //            }()
    //            $0.footer = {
    //                var footer = HeaderFooterView<UIView>(.callback({
    //                    let view = UIView(frame: CGRect(x: 0, y: 0, width: super.view.bounds.width, height: 0))
    //                    return view
    //                }))
    //                return footer
    //            }()
    //            $0.addButtonProvider = { section in
    //                return ButtonRow(){
    //                    $0.title = "Añadir Tamaño"
    //                    }.cellSetup { buttonCell, _ in
    //                        buttonCell.tintColor = #colorLiteral(red: 0, green: 0.8166723847, blue: 0.9823040366, alpha: 1)
    //                }
    //            }
    //            $0.multivaluedRowToInsertAt = { index in
    //                return ProductVariationRow()
    //            }
    //            $0 <<< ProductVariationRow()
    //        }
    //
    //        section.insert(recursiveImageRow(), at: 0)
    //
    //        return section
    //    }
    
    //    private func recursiveImageRow() -> ImageRow {
    //        let imageRow = ImageRow() {
    //            $0.title = "Imagen"
    //            $0.sourceTypes = [.PhotoLibrary]
    //            $0.clearAction = .yes(style: .default)
    //            }.onChange {
    //                let index = $0.indexPath!.row
    //                if let image = $0.value {
    //                    // add (wOw one line arrray initelizer!)
    //                    (self.tinpon.additionalImages?.append(image)) ?? (self.tinpon.additionalImages = [image])
    //                    $0.section?.insert(self.recursiveImageRow(), at: index+1)
    //                } else {
    //                    // delete (only if not last)
    //                    if self.tinpon.additionalImages?.count ?? 0 > 1 {
    //                        $0.section?.remove(at: index)
    //                    }
    //                    self.tinpon.additionalImages?.remove(at: index-1)
    //                }
    //                print("additional images count \(self.tinpon.additionalImages?.count)")
    //        }
    //        
    //        return imageRow
    //    }
}
