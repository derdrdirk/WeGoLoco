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
    case userEmailAvailable = "/users/is-email-available"
    case tinpons = "/tinpons"
    case notSwipedTinpons = "/tinpons/notSwiped"
    case favouriteTinpons = "/tinpons/favourite"
}

protocol APIGatewayProtocol: class {}

extension APIGatewayProtocol {
    
    static func restAPITask(_ httpMethod: HttpdMethod, endPoint: APIEndPoint, queryStringParameters: [String:String] = [:], httpBody: String? = nil) -> AWSTask<AWSAPIGatewayResponse>  {
        
        let httpMethodName = httpMethod.rawValue
        let URLString = endPoint.rawValue
        let queryStringParameters: [String:String] = queryStringParameters
        let headerParameters = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
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

