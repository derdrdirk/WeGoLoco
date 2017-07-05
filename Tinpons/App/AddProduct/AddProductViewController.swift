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
import AWSS3

class AddProductViewController: FormViewController {
    
    @IBOutlet weak var progressBar: UIProgressView!
    
    var table = TinponsTable()
    var product = Product()
    
    struct Product {
        let uuid = UUID().uuidString
        var name: String?
        var image: UIImage?
        var imageData: Data? {
            if image != nil {
                return UIImagePNGRepresentation(image!)
            } else {
                return nil
            }
        }
        let s3Prefix = ""
        var imageS3Path: String {
            return "\(s3Prefix)\(uuid)"
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
        
        insertDataWithCompletionHandler({(errors: [NSError]?) -> Void in
            //self.activityIndicator.stopAnimating()
            self.uploadWithData(data: self.product.imageData!, forKey: self.product.imageS3Path)
        })

    }
    
    
    // MARK: AWS DynamoDB
    private func insertDataWithCompletionHandler(_ completionHandler: @escaping (_ errors: [NSError]?) -> Void) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        var errors: [NSError] = []
        let group: DispatchGroup = DispatchGroup()
        
        let item: Tinpons = Tinpons()
        item._id = product.uuid
        item._name = product.name
        item._imgUrl = product.imageS3Path
        item._createdAt = Date().iso8601.dateFromISO8601?.iso8601 // "2017-03-22T13:22:13.933Z"
        item._category = "Shoe"
        
        
        
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
    
    // MARK: AWS S3
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
                    // image upload failed
                    // => delete DynamoDB entry
                    let objectMapper = AWSDynamoDBObjectMapper.default()
                    let itemToDelete: Tinpons = Tinpons()
                    itemToDelete._id = self?.product.uuid
                    objectMapper.remove(itemToDelete)
                    
                    let message = "Uups something went wrong"
                    let alartController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                    let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
                    alartController.addAction(dismissAction)
                    self?.present(alartController, animated: true, completion: nil)
                } else {
                    // image sucessfully uploaded
                    self?.presentingViewController?.dismiss(animated: true)
                }
        })
    }
}

extension Formatter {
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "es_ES_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        return formatter
    }()
}
extension Date {
    var iso8601: String {
        return Formatter.iso8601.string(from: self)
    }
}

extension String {
    var dateFromISO8601: Date? {
        return Formatter.iso8601.date(from: self)   // "Mar 22, 2017, 10:22 AM"
    }
}
