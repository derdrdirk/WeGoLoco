//
//  AddProductViewController.swift
//  Tinpons
//
//  Created by Dirk Hornung on 10/6/17.
//
//

import UIKit
import Eureka
import ImageRow

class AddProductViewController: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        form +++ Section("Producto")
            <<< TextRow(){ row in
                row.title = "Nombre"
                row.placeholder = "Zapados de Nike"
            }
            <<< ImageRow() {
                $0.title = "Image"
                $0.sourceTypes = [.PhotoLibrary]
                $0.clearAction = .yes(style: .default)
            }
            <<< ButtonRow(){
                $0.title = "Guardar"
            }
        }
}
