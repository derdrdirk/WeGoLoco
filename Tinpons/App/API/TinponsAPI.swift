//
//  TinponsAPI.swift
//  Tinpons
//
//  Created by Dirk Hornung on 1/8/17.
//
//

import Foundation
import AWSAPIGateway

class TinponsAPI: APIGatewayProtocol {
    static func getNotSwipedTinpons(onComplete: @escaping ([Tinpon]?) -> ()) {
        restAPITask(httpMethod: .GET, endPoint: .notSwipedTinpons).continueWith {  (task: AWSTask<AWSAPIGatewayResponse>) -> () in
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
    
    static func getFavouriteTinpons(onComplete: @escaping ([Tinpon]?) -> ()) {
        restAPITask(httpMethod: .GET, endPoint: .favouriteTinpons).continueWith{ (task: AWSTask<AWSAPIGatewayResponse>) -> () in
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

}
