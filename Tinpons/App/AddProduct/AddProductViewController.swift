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
import AWSDynamoDB

class AddProductViewController: FormViewController {
    
    var table = TinponsTable()
    var product: Product?
    
    struct Product {
        var name: String
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        form +++ Section("Producto")
            <<< TextRow(){ row in
                row.title = "Nombre"
                row.placeholder = "Zapados de Nike"
                row.tag = "name"
            }
            <<< ImageRow() {
                $0.title = "Image"
                $0.sourceTypes = [.PhotoLibrary]
                $0.clearAction = .yes(style: .default)
                $0.tag = "image"
            }
            <<< ButtonRow(){
                $0.title = "Guardar"
                }.onCellSelection { [weak self] (_, _) in
                    if let nameRow: TextRow = self?.form.rowBy(tag: "name"),
                        let name = nameRow.value {
                        self?.product = Product(name: name)
                    }
                    let imageRow: ImageRow? = self?.form.rowBy(tag: "image")
                
                    self?.insertDataWithCompletionHandler({(errors: [NSError]?) -> Void in
                        //self.activityIndicator.stopAnimating()
                        var message: String = "Data inserted."
                        if errors != nil {
                            message = "Failed to insert sample items to your table."
                        }
                        let alartController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
                        alartController.addAction(dismissAction)
                        self?.present(alartController, animated: true, completion: nil)
                    })

            }
    }
    
    func insertDataWithCompletionHandler(_ completionHandler: @escaping (_ errors: [NSError]?) -> Void) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        var errors: [NSError] = []
        let group: DispatchGroup = DispatchGroup()
        
            
        let item: Tinpons = Tinpons()
        item._id = NoSQLSampleDataGenerator.randomSampleStringWithAttributeName("Id")
        item._name = product!.name
        
        group.enter()
        
        objectMapper.save(item, completionHandler: {(error: Error?) -> Void in
            if error != nil {
                DispatchQueue.main.async(execute: {
                    errors.append(error! as NSError)
                })
            }
            group.leave()
        })
        
        group.notify(queue: DispatchQueue.main, execute: {
            if errors.count > 0 {
                completionHandler(errors)
            }
            else {
                completionHandler(nil)
            }
        })
    }
}
