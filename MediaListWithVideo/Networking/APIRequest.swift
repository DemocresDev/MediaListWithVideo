//
//  APIRequest.swift
//  MediaListWithVideo
//
//  Created by David Figueroa on 3/06/22.
//

import Foundation

protocol APIRequest {
    var scheme: String { get }
    var baseURL: String { get }
    var path: String { get }
    var parameters: [URLQueryItem]? { get }
    var method: String { get }
    var absoluteString: String { get }
    var requestBody: [String: Any]? { get }
    var customHeaders: [String: String]? { get }
}
