//
//  TinponsAPI.swift
//  Tinpons
//
//  Created by Dirk Hornung on 1/8/17.
//
//

import Foundation
import AWSAPIGateway
import PromiseKit
import AWSS3

class TinponsAPI: APIGatewayProtocol {
    // MARK: - TinponDetail    
    static func getTinpon(fromId tinponId: Int, completion: @escaping (Tinpon?, Error?)->() ) {
        restAPITask(.GET, endPoint: .tinpons, queryStringParameters: ["tinponId":"\(tinponId)"]).continueWith { task -> () in
            if let error = task.error {
                print("TinponsAPI.getTinpon \(error)")
                completion(nil, error)
            } else if let error = statusCodeValidation(statusCode: task.result!.statusCode) {
                print("TinponsAPI.getTinpon \(error)")
                completion(nil, error)
            } else {
                let tinpon = taskToTinpon(task: task)
                print(tinpon)
                completion(tinpon, nil)
            }
        }
    }
    static func getTinpon(fromId tinponId: Int) -> Promise<Tinpon> {
        return PromiseKit.wrap { getTinpon(fromId: tinponId, completion: $0) }
    }
    
    static func getImage(fromS3Key s3Key: String, completion: @escaping (UIImage?, Error?)->()) {
        let transferManager = AWSS3TransferManager.default()
        let downloadingFileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        let downloadRequest = AWSS3TransferManagerDownloadRequest()!
        downloadRequest.bucket = "wegoloco"
        downloadRequest.key = s3Key
        downloadRequest.downloadingFileURL = downloadingFileURL
        transferManager.download(downloadRequest).continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask<AnyObject>) -> Any? in
            if let error = task.error as? NSError {
                if error.domain == AWSS3TransferManagerErrorDomain, let code = AWSS3TransferManagerErrorType(rawValue: error.code) {
                    switch code {
                    case .cancelled, .paused:
                        completion(nil, APIError.cancelled)
                        break
                    default:
                        print("Error downloading: \(downloadRequest.key) Error: \(error)")
                        completion(nil, APIError.serverError)
                    }
                } else {
                    print("Error downloading: \(downloadRequest.key) Error: \(error)")
                    completion(nil, APIError.serverError)
                }
                return nil
            }
            print("Download complete for: \(downloadRequest.key)")
            let downloadOutput = task.result
            completion(UIImage(contentsOfFile: downloadingFileURL.path), nil)
            return nil
        })
    }
    static func getImage(fromS3Key s3Key: String) -> Promise<UIImage> {
        return PromiseKit.wrap { getImage(fromS3Key: s3Key, completion: $0 ) }
    }
    
    
    // MARK: GET Not Swiped Tinpons
    static public func getNotSwipedTinpons(completion: @escaping ([Tinpon]?, Error?)->()) {
        var tmpTinpons = [Tinpon]()
        firstly {
            TinponsAPI.getNotSwipedTinponsFromRDS()
        }.then { tinpons -> () in
            var getSwiperImagePromises = [Promise<UIImage>]()
            for tinpon in tinpons {
                tmpTinpons.append(tinpon)
                getSwiperImagePromises.append(TinponsAPI.getSwiperImage(for: tinpon))
            }
            when(fulfilled: getSwiperImagePromises).then { images -> () in
                for index in 0..<tinpons.count {
                    tmpTinpons[index].images.append(images[index])
                }
                completion(tmpTinpons, nil)
            }
        }.catch { error in
            completion(nil, error)
        }
    }
    static func getNotSwipedTinpons() -> Promise<[Tinpon]> {
        return PromiseKit.wrap { getNotSwipedTinpons(completion: $0) }
    }
    
    /**
     gets not swiped tinpons from RDS
     */
    static private func getNotSwipedTinponsFromRDS(completion: @escaping ([Tinpon]?, Error?) -> ()) {
        restAPITask(.GET, endPoint: .swipedTinpons).continueWith { (task: AWSTask<AWSAPIGatewayResponse>) -> () in
            if let error = task.error {
                completion(nil, APIError.serverError)
                return
            } else if let result = task.result {
                switch result.statusCode {
                case 200:
                    let responseString = String(data: result.responseData!, encoding: .utf8)
                    let json = responseString?.toJSON
                    var tinpons = Array<Tinpon>()
                    if let tinponDictionary = json as? [Any] {
                        for tinponJson in tinponDictionary {
                            do {
                                let tinpon = try Tinpon(json: tinponJson as! [String : Any])
                                tinpons.append(tinpon)
                            } catch {
                                print("TinponsAPI.getNotSwipedTinpons error: \(error)")
                                completion(nil, APIError.unknown)
                            }
                        }
                    }

                    completion(tinpons, nil)
                case 502:
                    completion(nil, APIError.serverError)
                default:
                    completion(nil, APIError.unknown)
                }

            }
        }
    }
    static func getNotSwipedTinponsFromRDS() -> Promise<[Tinpon]> {
        return PromiseKit.wrap { getNotSwipedTinponsFromRDS(completion: $0) }
    }
    
    /**
     gets swiper image for tinpon
     */
    static private func getSwiperImage(for tinpon: Tinpon, completion: @escaping (UIImage?, Error?) -> ()) {
        let transferManager = AWSS3TransferManager.default()
        
        
        let swiperImageKey = "Tinpons/\(tinpon.id!)/main/1.png"
        let downloadingFileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(tinpon.id!)+.png")
        
        let downloadRequest = AWSS3TransferManagerDownloadRequest()!
        
        downloadRequest.bucket = "wegoloco"
        downloadRequest.key = swiperImageKey
        downloadRequest.downloadingFileURL = downloadingFileURL
        
        transferManager.download(downloadRequest).continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask<AnyObject>) -> Any? in
            
            if let error = task.error as? NSError {
                if error.domain == AWSS3TransferManagerErrorDomain, let code = AWSS3TransferManagerErrorType(rawValue: error.code) {
                    switch code {
                    case .cancelled, .paused:
                        completion(nil, APIError.cancelled)
                        break
                    default:
                        print("Error downloading: \(downloadRequest.key) Error: \(error)")
                        completion(nil, APIError.serverError)
                    }
                } else {
                    print("Error downloading: \(downloadRequest.key) Error: \(error)")
                    completion(nil, APIError.serverError)
                }
                return nil
            }
            print("Download complete for: \(downloadRequest.key)")
            let downloadOutput = task.result
            completion(UIImage(contentsOfFile: downloadingFileURL.path), nil)
            return nil
        })
    }
    static private func getSwiperImage(for tinpon: Tinpon) -> Promise<UIImage> {
        return PromiseKit.wrap { getSwiperImage(for: tinpon, completion: $0) }
    }
    
    
    /**
     save Tinpon in RDS
     */
    static func save(_ tinpon: Tinpon, completion: @escaping (Int?, Error?)->()) {
        restAPITask(.POST, endPoint: .tinpons, httpBody: tinpon.toJSON()).continueWith {  (task: AWSTask<AWSAPIGatewayResponse>) -> () in
            if let error = task.error {
                completion(nil, APIError.serverError)
                return
            } else if let result = task.result {
                switch result.statusCode {
                case 200:
                    let json = (String(data: result.responseData!, encoding: .utf8))?.toJSON as! [String: Any]
                    let tinponId = json["tinponId"] as! Int
                    completion(tinponId, nil)
                case 502:
                    completion(nil, APIError.serverError)
                default:
                    completion(nil, APIError.unknown)
                }
            }
        }
    }
    static func save(_ tinpon: Tinpon) -> Promise<Int> {
        return PromiseKit.wrap{ save(tinpon, completion: $0) }
    }
    
    /**
    upload Image
    */
    static func uploadMainImages(from tinpon: Tinpon, completion: @escaping (Error?)->()) {
        loopThroughMainImages(for: tinpon) { image, i in
            let imagePath = "Tinpons/\(tinpon.id!)/main/\(i)"
            uploadImage(image: image, path: imagePath) { error in
                completion(error)
            }
        }
    }
    static func uploadMainImages(from tinpon: Tinpon) -> Promise<Void> {
        return PromiseKit.wrap { uploadMainImages(from: tinpon, completion: $0) }
    }
    
    static func uploadImage(image: UIImage, path: String, completion: @escaping (Error?)->()) {
        
        // upload S3 image
        let imageData: NSData = UIImagePNGRepresentation(image)! as NSData
        let transferManager = AWSS3TransferManager.default()
        
        let fileManager = FileManager.default
        let filePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(UUID().uuidString)
        fileManager.createFile(atPath: filePath as String, contents: imageData as Data, attributes: nil)
        let fileUrl = NSURL(fileURLWithPath: filePath)
        
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        
        uploadRequest?.bucket = "wegoloco"
        uploadRequest?.key = path+".png"
        uploadRequest?.body = fileUrl as URL!
        uploadRequest?.uploadProgress = { (bytesSent, totalBytesSent, totalBytesExpectedToSend) -> Void in
            DispatchQueue.main.async(execute: {
                let sent = Float(totalBytesSent)
                let total = Float(totalBytesExpectedToSend)
                //progressView?.progress = sent/total
            })
        }
        
        transferManager.upload(uploadRequest!).continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask<AnyObject>) -> Any? in
            
            if let error = task.error as NSError? {
                if error.domain == AWSS3TransferManagerErrorDomain, let code = AWSS3TransferManagerErrorType(rawValue: error.code) {
                    switch code {
                    case .cancelled, .paused:
                        completion(APIError.cancelled)
                        break
                    default:
                        print("Error uploading: \(uploadRequest?.key) Error: \(error)")
                        completion(error)
                    }
                } else {
                    print("Error uploading: \(uploadRequest?.key) Error: \(error)")
                    completion(error)
                }
                return nil
            }

            // SUCCESS: Image uploaded
            // save ImageId to RDS
//            let uploadOutput = task.result
//            print("Upload complete for: \(uploadRequest?.key ?? "")")
            completion(nil)
            return nil
        })
    }
    static func uploadImage(image: UIImage, path: String) -> Promise<Void> {
        return PromiseKit.wrap{ uploadImage(image: image, path: path, completion: $0) }
    }
    
    private static func loopThroughMainImages(for tinpon: Tinpon, handle: (UIImage, Int) -> () ) {
        var i = 0
        for image in tinpon.images {
            i += 1
            handle(image, i)
        }
    }
    
    // MARK: Swipe Tinpon
    /**
     Save Swipe
     */
    static func saveSwipe(for tinpon: Tinpon, liked: Int, completion: @escaping (Error?)->()) {
        var jsonObject = ["tinpon_id" : tinpon.id, "liked": liked]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: jsonObject,
                                                      options: .prettyPrinted)
            let jsonString = String(data: jsonData, encoding: String.Encoding.utf8)
            restAPITask(.POST, endPoint: .swipedTinpons, httpBody: jsonString).continueWith { task -> () in
                if let error = task.error {
                    print("ERROR - TinponsAPI.saveSwipe: \(error)")
                    completion(APIError.serverError)
                } else if let result = task.result {
                    switch result.statusCode {
                    case 200:
                        print("SUCCESS - TinponsAPI.saveSwipe : swiped tinpon saved")
                        completion(nil)
                    default:
                        print("Error - TinponsAPI.saveSwipe : \(result.statusCode)")
                        completion(APIError.serverError)
                    }
                }
            }
        } catch let error {
            print("SwipedTinpon: error converting to json: \(error)")
            completion(APIError.clientError)
        }
    }
    static func saveSwipe(for tinpon: Tinpon, liked: Int) -> Promise<Void> {
        return PromiseKit.wrap { saveSwipe(for: tinpon, liked: liked, completion: $0) }
    }
    
    // MARK: - Favourite
    static func getFavouriteTinponsFromRDS(completion: @escaping ([Tinpon]?, Error?)->() ) {
        restAPITask(.GET, endPoint: .favouriteTinpons).continueWith { task -> () in
            if let error = task.error {
                completion(nil, error)
            } else if let result = task.result {
                switch result.statusCode {
                case 200:
                    print("SUCCESS - TinponsAPI.getFavouriteTinponsFromRDS")
                    let tinpons = taskToTinpons(task: task)
                    completion(tinpons, nil)
                default:
                    print("Error - TinponsAPI.saveSwipe : \(result.statusCode)")
                    completion(nil, APIError.serverError)
                }
            }
        }
    }
    static func getFavouriteTinponsFromRDS() -> Promise<[Tinpon]> {
        return PromiseKit.wrap { getFavouriteTinponsFromRDS(completion: $0) }
    }
    
    
    
    // MARK: - Helper
    fileprivate static func statusCodeValidation(statusCode: Int) -> Error? {
        switch statusCode {
        case 200..<300: return nil
        case 400..<500: return APIError.forbidden
        case 500..<600: return APIError.serverError
        default: return APIError.unknown
        }
    }
    
    fileprivate static func taskToTinpon(task: AWSTask<AWSAPIGatewayResponse>) -> Tinpon {
        let result = task.result!
        let responseString = String(data: result.responseData!, encoding: .utf8)
        let json = responseString?.toJSON
        return try! Tinpon(json: json as! [String: Any])
    }
    
    fileprivate static func taskToTinpons(task: AWSTask<AWSAPIGatewayResponse>) -> [Tinpon] {
        let result = task.result!
        var tmpTinpons = [Tinpon]()
        let responseString = String(data: result.responseData!, encoding: .utf8)
        let json = responseString?.toJSON
        let tinponDictionary = json as! [Any]
        for tinponJson in tinponDictionary {
            let tinpon = try! Tinpon(json: tinponJson as! [String : Any])
            tmpTinpons.append(tinpon)
        }
        return tmpTinpons
    }
}
