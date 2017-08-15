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
    static func getNotSwipedTinpons(_ onComplete: @escaping ([Tinpon]?) -> ()) {
        restAPITask(.GET, endPoint: .notSwipedTinpons).continueWith {  (task: AWSTask<AWSAPIGatewayResponse>) -> () in
            if let error = task.error {
                print("Error occurred: \(error)")
                // Handle error here
                return
            } else if let result = task.result {
                let responseString = String(data: result.responseData!, encoding: .utf8)
                if let json = responseString?.toJSON {
                    var tinpons = Array<Tinpon>()
                    if let tinponDictionary = json as? [Any] {
                        for tinponJson in tinponDictionary {
                            do {
                                let tinpon = try Tinpon(json: tinponJson as! [String : Any])
                                tinpons.append(tinpon)
                            } catch {
                                print("TinponAPI error: \(error)")
                            }
                        }
                    }
                    
                    onComplete(tinpons)
                } else {
                    // Tinpons MOST PROBABLY do not exist
                    onComplete(nil)
                }
            }
        }
    }
    
    static func getFavouriteTinpons(_ onComplete: @escaping ([Tinpon]?) -> ()) {
        restAPITask(.GET, endPoint: .favouriteTinpons).continueWith{ (task: AWSTask<AWSAPIGatewayResponse>) -> () in
            if let error = task.error {
                print("Error occurred: \(error)")
                // Handle error here
                return
            } else if let result = task.result {
                let responseString = String(data: result.responseData!, encoding: .utf8)
                if let json = responseString?.toJSON {
                    var tinpons = Array<Tinpon>()
                    if let tinponDictionary = json as? [Any] {
                        for tinponJson in tinponDictionary {
                            do {
                                let tinpon = try Tinpon(json: tinponJson as! [String : Any])
                                tinpons.append(tinpon)
                            } catch {
                                print("TinponAPI error: \(error)")
                            }
                        }
                    }
                    
                    onComplete(tinpons)
                } else {
                    // Tinpons MOST PROBABLY do not exist
                    onComplete(nil)
                }
            }
        }
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
        loopThroughMainImages(for: tinpon) { tinponImage, i in
            let imagePath = "Tinpons/\(tinpon.id!)/main/\(i)"
            uploadImage(tinponImage: tinponImage, path: imagePath) { error in
                completion(error)
            }
        }
    }
    static func uploadMainImages(from tinpon: Tinpon) -> Promise<Void> {
        return PromiseKit.wrap { uploadMainImages(from: tinpon, completion: $0) }
    }
    
    static func uploadImage(tinponImage: TinponImage, path: String, completion: @escaping (Error?)->()) {
        
        // upload S3 image
        let imageData: NSData = UIImagePNGRepresentation(tinponImage.image)! as NSData
        let transferManager = AWSS3TransferManager.default()
        
        let fileManager = FileManager.default
        let filePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(tinponImage.id)
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
    static func uploadImage(tinponImage: TinponImage, path: String) -> Promise<Void> {
        return PromiseKit.wrap{ uploadImage(tinponImage: tinponImage, path: path, completion: $0) }
    }
    
    private static func loopThroughMainImages(for tinpon: Tinpon, handle: (TinponImage, Int) -> () ) {
        var i = 0
        for tinponImage in tinpon.images {
            i += 1
            handle(tinponImage, i)
        }
    }
}
