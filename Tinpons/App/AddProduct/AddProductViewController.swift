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
import AWSMobileHubHelper

class AddProductViewController: FormViewController {
    
    var table = TinponsTable()
    var product = Product()
    
    
    struct Product {
        var name: String?
        var image: UIImage?
        var imageData: Data? {
            if image != nil {
                return UIImagePNGRepresentation(image!)
            } else {
                return nil
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        form +++ Section("Product")
            <<< TextRow(){ row in
                row.title = "Name"
                row.placeholder = "Shoes"
                row.tag = "name"
                }.onChange{ [weak self] in
                    self?.product.name = $0.value
            }
            <<< ImageRow() {
                $0.title = "Image"
                $0.sourceTypes = [.PhotoLibrary]
                $0.clearAction = .yes(style: .default)
                $0.tag = "image"
                }.onChange{ [weak self] in
                    self?.product.image = $0.value
            }
    }
    
    // MARK: Actions
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        presentingViewController?.dismiss(animated: true)
    }
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        print("Name: \(product.name), Image: \(product.image)")
//        if let nameRow: TextRow = form.rowBy(tag: "name"),
//            let name = nameRow.value {
//            product = Product(name: name)
//        }
//        if let imageRow: ImageRow? = form.rowBy(tag: "image"),
//            let image = imageRow?.value as? UIImage {
//            product.image = image
//        }
        
//        insertDataWithCompletionHandler({(errors: [NSError]?) -> Void in
//            //self.activityIndicator.stopAnimating()
//            var message: String = "Data inserted."
//            if errors != nil {
//                message = "Failed to insert sample items to your table."
//            }
//            let alartController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
//            let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
//            alartController.addAction(dismissAction)
//            self.present(alartController, animated: true, completion: nil)
//        })

    }
    
    
    // MARK: AWS Saver
    
//    func insertDataWithCompletionHandler(_ completionHandler: @escaping (_ errors: [NSError]?) -> Void) {
//        let objectMapper = AWSDynamoDBObjectMapper.default()
//        var errors: [NSError] = []
//        let group: DispatchGroup = DispatchGroup()
//        
//        
//        let item: Tinpons = Tinpons()
//        item._id = NoSQLSampleDataGenerator.randomSampleStringWithAttributeName("Id")
//        item._name = product!.name
//        
//        group.enter()
//        
//        objectMapper.save(item, completionHandler: {(error: Error?) -> Void in
//            if error != nil {
//                DispatchQueue.main.async(execute: {
//                    errors.append(error! as NSError)
//                })
//            }
//            group.leave()
//        })
//        
//        group.notify(queue: DispatchQueue.main, execute: {
//            if errors.count > 0 {
//                completionHandler(errors)
//            }
//            else {
//                completionHandler(nil)
//            }
//        })
//    }
    
    private func uploadWithData(data: NSData, forKey key: String) {
        let manager = AWSUserFileManager.defaultUserFileManager()
        let localContent = manager.localContent(with: data as Data, key: key)
        localContent.uploadWithPin(
            onCompletion: false,
            progressBlock: {[weak self](content: AWSLocalContent, progress: Progress) -> Void in
                guard let strongSelf = self else { return }
                /* Show progress in UI. */
            },
            completionHandler: {[weak self](content: AWSLocalContent?, error: Error?) -> Void in
                guard let strongSelf = self else { return }
                if let error = error {
                    print("Failed to upload an object. \(error)")
                } else {
                    print("Object upload complete. \(error)")
                }
        })
    }


}
