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
                print(responseString)
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
    static func save(_ tinpon: Tinpon, completion: @escaping (Error?)->()) {
        restAPITask(.POST, endPoint: .tinpons, httpBody: tinpon.toJSON()).continueWith {  (task: AWSTask<AWSAPIGatewayResponse>) -> () in
            if let error = task.error {
                completion(APIError.serverError)
                return
            } else if let result = task.result {
                if result.statusCode == 200 {
                    completion(nil)
                } else {
                    completion(APIError.alreadyExisting)
                }
            }
        }
    }
    static func save(_ tinpon: Tinpon) -> Promise<Void> {
        return PromiseKit.wrap{ save(tinpon, completion: $0) }
    }
    
    /**
    upload Image
    */
    static func uploadImage(image: UIImage, name: String, path: String, completion: @escaping (Error?)->()) {
        print("Name: \(name), path: \(path)")
        
        // upload S3 image
        let imageData: NSData = UIImagePNGRepresentation(image)! as NSData
        let transferManager = AWSS3TransferManager.default()
        
        let fileManager = FileManager.default
        let filePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(name)
        fileManager.createFile(atPath: filePath as String, contents: imageData as Data, attributes: nil)
        let fileUrl = NSURL(fileURLWithPath: filePath)
        
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        
        uploadRequest?.bucket = "wegoloco"
        uploadRequest?.key = path+name
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
            
            let uploadOutput = task.result
            print("Upload complete for: \(uploadRequest?.key ?? "")")
            completion(nil)
            return nil
        })
    }
    static func uploadImage(image: UIImage, name: String, path: String) -> Promise<Void> {
        return PromiseKit.wrap{ uploadImage(image: image, name: name, path: path, completion: $0) }
    }
}
