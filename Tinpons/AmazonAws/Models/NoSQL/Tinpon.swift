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
    var imgUrl: String?
    
    let s3BucketName = "tinpons-userfiles-mobilehub-1827971537"
    var image: UIImage?
    var imageData: Data? {
        if image != nil {
            return UIImagePNGRepresentation(image!)
        } else {
            return nil
        }
    }
    var s3ImagePath: String {
        return tinponId!
    }
    var noMoreTinponsToLoad = false
    var lastEvaluatedKey: [String: AWSDynamoDBAttributeValue]?

    init() {
        tinponId = UUID().uuidString
        userId = User().userId
    }
    
    var description: String {
        return "Name: \(name ?? "") \nImage: \(String(describing: imgUrl)) \nPrice: \(String(Double(price ?? 0))) \nCategory: \(category ?? "")"
    }
    
    private func dynamoDBTinpon() -> DynamoDBTinpon {
        let tinpon = DynamoDBTinpon()
        tinpon?.category = category
        tinpon?.createdAt = createdAt
        tinpon?.imgUrl = s3ImagePath
        tinpon?.latitude = latitude
        tinpon?.longitude = longitude
        tinpon?.name = name
        tinpon?.price = price
        tinpon?.tinponId = tinponId
        tinpon?.updatedAt = updatedAt
        tinpon?.userId = userId
        return tinpon!
    }
    
    private func castDynamoDBTinponToTinpon(dynamoDBTinpon: DynamoDBTinpon) -> Tinpon {
        let tinpon = Tinpon()
        tinpon.category = dynamoDBTinpon.category
        tinpon.createdAt = dynamoDBTinpon.createdAt
        tinpon.imgUrl = dynamoDBTinpon.imgUrl
        tinpon.latitude = dynamoDBTinpon.latitude
        tinpon.longitude = dynamoDBTinpon.longitude
        tinpon.name = dynamoDBTinpon.name
        tinpon.price = dynamoDBTinpon.price
        tinpon.tinponId = dynamoDBTinpon.tinponId
        tinpon.updatedAt = dynamoDBTinpon.updatedAt
        tinpon.userId = dynamoDBTinpon.userId
        return tinpon
    }
    
    func save(_ onComplete: @escaping () -> Void, _ progressView: UIProgressView?) {
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
            uploadRequest?.uploadProgress = { (bytesSent, totalBytesSent, totalBytesExpectedToSend) -> Void in
                DispatchQueue.main.async(execute: {
                    let sent = Float(totalBytesSent)
                    let total = Float(totalBytesExpectedToSend)
                    progressView?.progress = sent/total
                })
            }
            
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
    
    // load x=limit Items
    // 1. query x tinpons
    // 2. filter with SwipedTinponsCore
    // 3. if x >= limit: done! | else repeat
    // update lastEvaluated key to dont query same objects
    func loadNotSwipedItems(limit: Int, onComplete: @escaping ([Tinpon])->Void) {
        if noMoreTinponsToLoad {
            onComplete([])
        } else {
            let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
            
            let queryExpression = AWSDynamoDBQueryExpression()
            queryExpression.indexName = "category-tinponId-index"
            
            queryExpression.limit = limit as NSNumber
            queryExpression.keyConditionExpression = "category = :category"
            queryExpression.expressionAttributeValues = [":category" : "👕"]
            if lastEvaluatedKey != nil {
                queryExpression.exclusiveStartKey = lastEvaluatedKey
            }
            
            //        queryExpression.filterExpression = "tinponId <> :tinponId"
            //        queryExpression.keyConditionExpression = "#name = :category"
            //        queryExpression.expressionAttributeNames = [ "#name" : "name" ]
            //        queryExpression.expressionAttributeValues = [":category" : "Asdf" ]
            
            dynamoDBObjectMapper.query(DynamoDBTinpon.self, expression: queryExpression).continueWith(block: { [weak self] (task:AWSTask<AWSDynamoDBPaginatedOutput>!) -> Any? in
                guard let strongSelf = self else {return nil}
                
                if let error = task.error as NSError? {
                    print("The request failed. Error: \(error)")
                } else if let paginatedOutput = task.result {
                    var tinpons = [Tinpon]()
                    for dynamoDBTinpon in (paginatedOutput.items as? [DynamoDBTinpon])! {
                        tinpons.append(strongSelf.castDynamoDBTinponToTinpon(dynamoDBTinpon: dynamoDBTinpon))
                    }
                    
                    // filter already swiped Tinpons
                    tinpons = strongSelf.filterAlreadySwipedTinpons(tinpons: tinpons)
                    print("filtered Tinpons : \(tinpons.count) name: \(tinpons.count == 1 ? tinpons[0].name : ""), lastEvaluatedKey \(strongSelf.lastEvaluatedKey)")
                    
                    // check if more tinpons available
                    if let lastEvaluatedKey = task.result?.lastEvaluatedKey {
                        if tinpons.count >= limit {
                            onComplete(tinpons)
                            return nil
                        } else {
                            onComplete(tinpons)
                            strongSelf.lastEvaluatedKey = lastEvaluatedKey
                            strongSelf.loadNotSwipedItems(limit: limit, onComplete: onComplete)
                        }
                    } else {
                        // no more Tinpons in Database
                        strongSelf.noMoreTinponsToLoad = true
                        onComplete(tinpons)
                        return nil
                    }
                }
                return nil
            })
        }
    }
    
    public func filterAlreadySwipedTinpons(tinpons: [Tinpon]) -> [Tinpon] {
        var filteredTinpons: [Tinpon] = []
        let context = AppDelegate.viewContext
        
        for tinpon in tinpons {
            var fetchSwipedTinpons : [SwipedTinponsCore] = []
            do {
                let fetchRequest : NSFetchRequest<SwipedTinponsCore> = SwipedTinponsCore.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "(tinponId == %@)", tinpon.tinponId!)
                fetchSwipedTinpons = try context.fetch(fetchRequest)
                if fetchSwipedTinpons.count < 1 {
                    filteredTinpons.append(tinpon)
                }
            } catch {
                print("filterTinpons: Fetching Failed")
            }
        }
        return filteredTinpons
    }
}
