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
    
    @IBOutlet weak var progressBar: UIProgressView!
    
    var table = TinponsTable()
    var product = Product()
    var s3Prefix = "public/"
    
    
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
        
        // Set up progress bar (right under the navigationController tob bar)
        let navBar = self.navigationController?.navigationBar
        let navBarHeight = navBar?.frame.height
        let progressFrame = progressBar.frame
        let pSetX = CGFloat(0)
        let pSetY = CGFloat(navBarHeight!)
        let pSetWidth = view.frame.size.width
        let pSetHeight = progressFrame.height
        progressBar.frame = CGRect(x: pSetX, y: pSetY, width: pSetWidth, height: pSetHeight)
        self.navigationController?.navigationBar.addSubview(progressBar)
        
        // Set up Eureka form
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
        
        let imageId = product.name!
        let s3UploadUrl = "\(s3Prefix)\(imageId)"
        uploadWithData(data: product.imageData!, forKey: s3UploadUrl)
        
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
    
    func insertDataWithCompletionHandler(_ completionHandler: @escaping (_ errors: [NSError]?) -> Void) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        var errors: [NSError] = []
        let group: DispatchGroup = DispatchGroup()
        
        
        let item: Tinpons = Tinpons()
        item._id = NoSQLSampleDataGenerator.randomSampleStringWithAttributeName("Id")
        item._name = product.name
        
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
    
    private func uploadWithData(data: Data, forKey key: String) {
        let manager = AWSUserFileManager.defaultUserFileManager()
        let localContent = manager.localContent(with: data as Data, key: key)
        localContent.uploadWithPin(
            onCompletion: false,
            progressBlock: {[weak self](content: AWSLocalContent, progress: Progress) -> Void in
                guard let strongSelf = self else { return }
                /* Show progress in UI. */
                self?.progressBar.progress = Float(progress.fractionCompleted)
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
