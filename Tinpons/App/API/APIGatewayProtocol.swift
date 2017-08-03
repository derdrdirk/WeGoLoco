//
//  APIGatewayProtocol.swift
//  Tinpons
//
//  Created by Dirk Hornung on 24/7/17.
//
//

import Foundation

enum HttpdMethod:String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
}

enum APIEndPoint:String {
    case users = "/users"
    case tinpons = "/tinpons"
    case notSwipedTinpons = "/tinpons/notSwiped"
    case favouriteTinpons = "/tinpons/favourite"
}

protocol APIGatewayProtocol: class {}

extension APIGatewayProtocol {
    
    static func restAPITask(httpMethod: HttpdMethod, endPoint: APIEndPoint, httpBody: String? = nil) -> AWSTask<AWSAPIGatewayResponse>  {
        
        let httpMethodName = httpMethod.rawValue
        let URLString = endPoint.rawValue
        let queryStringParameters: [String:String] = [:]
        let headerParameters = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        //let httpBody = user.toJSON()
        
        // Construct the request object
        let apiRequest = AWSAPIGatewayRequest(httpMethod: httpMethodName,
                                              urlString: URLString,
                                              queryParameters: queryStringParameters,
                                              headerParameters: headerParameters,
                                              httpBody: httpBody)
        
        // Fetch the Cloud Logic client to be used for invocation
        // Change the `AWSAPI_XE21FG_MyCloudLogicClient` class name to the client class for your generated SDK
        return  AWSAPI_9HLT8N48WD_WeGoLocoClient(forKey: AWSCloudLogicDefaultConfigurationKey).invoke(apiRequest)
    }
}

