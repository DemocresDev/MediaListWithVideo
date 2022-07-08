//
//  RequestType.swift
//  MediaListWithVideo
//
//  Created by David Figueroa on 7/07/22.
//

import Foundation

enum RequestType {
    case getMovies
    case getToken
}

extension RequestType: APIRequest {
    
    var customHeaders: [String : String]? {
        switch self {
        case .getMovies:
            return ["Content-Type": "application/json",
             "accept" : "application/json",
             "Authorization": APIClient.shared.tokeyType + " " + APIClient.shared.sessionToken]
        default:
            return ["Content-Type": "application/json", "accept" : "application/json"]
        }
    }
    
    var scheme: String {
        switch self {
        default:
            return "https"
        }
    }
    
    var baseURL: String {
        switch self {
        default:
            return "echo-serv.tbxnet.com"
        }
    }
    
    var path: String {
        switch self {
        case .getMovies:
            return "/v1/mobile/data"
        case .getToken:
            return "/v1/mobile/auth"
        }
    }
    
    var parameters: [URLQueryItem]? {
        switch self {
        default:
            return nil
        }
    }
    
    var requestBody: [String : Any]? {
        switch self {
        case .getToken:
            return ["sub": "ToolboxMobileTest"]
        default:
            return nil
        }
    }
    
    var method: String {
        switch self {
        case .getToken:
            return "POST"
        default:
            return "GET"
        }
    }
    
    var absoluteString: String {
        switch self {
        default:
            return self.scheme + "://" + self.baseURL + self.path
        }
    }
}
