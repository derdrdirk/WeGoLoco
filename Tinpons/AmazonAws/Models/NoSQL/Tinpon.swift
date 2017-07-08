//
//  Tinpon.swift
//  Tinpons
//
//  Created by Dirk Hornung on 7/7/17.
//
//

import Foundation
import UIKit
import AWSDynamoDB
import AWSS3
import AWSMobileHubHelper

class Tinpon : CustomStringConvertible {
    var category: String?
    var createdAt: String?
    var latitude: NSNumber?
    var longitude: NSNumber?
    var name: String?
    var price: NSNumber?
    var tinponId: String?
    var updatedAt: String?
    var userId: String?
    
    var image: UIImage?
    var imageData: Data? {
        if image != nil {
            return UIImagePNGRepresentation(image!)
        } else {
            return nil
        }
    }
    var imgUrl: String {
        return tinponId ?? ""
    }
    var imageS3Path: String {
        return tinponId!
    }

    init() {
        tinponId = UUID().uuidString
        userId = User().userId
    }
    
    var description: String {
        return "Name: \(name ?? "") \nImage: \(imgUrl) \nPrice: \(String(Double(price ?? 0))) \nCategory: \(category ?? "")"
    }
    
    private func dynamoDBTinpon() -> DynamoDBTinpon {
        let tinpon = DynamoDBTinpon()
        tinpon?.category = category
        tinpon?.createdAt = createdAt
        tinpon?.imgUrl = imageS3Path
        tinpon?.latitude = latitude
        tinpon?.longitude = longitude
        tinpon?.name = name
        tinpon?.price = price
        tinpon?.tinponId = tinponId
        tinpon?.updatedAt = updatedAt
        tinpon?.userId = userId
        return tinpon!
    }
    
    func save(_ onComplete: @escaping () -> Void) {
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
        dynamoDBObjectMapper.save(dynamoDBTinpon()).continueOnSuccessWith(block: {[weak self] (task:AWSTask<AnyObject>!) -> Any? in
            guard let strongSelf = self else { print("nil"); return nil }
            // upload S3 image
            let transferManager = AWSS3TransferManager.default()
            
            let fileManager = FileManager.default
            let path = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(strongSelf.tinponId!+".png")
            fileManager.createFile(atPath: path as String, contents: self?.imageData, attributes: nil)
            let fileUrl = NSURL(fileURLWithPath: path)
            
            let uploadRequest = AWSS3TransferManagerUploadRequest()
            
            uploadRequest?.bucket = "tinpons-userfiles-mobilehub-1827971537"
            uploadRequest?.key = strongSelf.tinponId
            uploadRequest?.body = fileUrl as URL!
            
            return transferManager.upload(uploadRequest!)
        }).continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask<AnyObject>) -> Any? in
            if let error = task.error as NSError? {
                if error.domain == AWSS3TransferManagerErrorDomain, let code = AWSS3TransferManagerErrorType(rawValue: error.code) {
                    switch code {
                    case .cancelled, .paused:
                        break
                    default:
                        print("Error uploading:  Error: \(error)")
                    }
                } else {
                    print("Error uploading:  Error: \(error)")
                }
                return nil
            }
            
            // S3 upload complete
            onComplete()
            return nil
        })
    }

}
