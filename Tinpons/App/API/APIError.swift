//
//  APIErrors.swift
//  Tinpons
//
//  Created by Dirk Hornung on 6/8/17.
//
//

import Foundation

enum APIError: Error {
    case serverError
    case nonExisting
    case alreadyExisting
}
