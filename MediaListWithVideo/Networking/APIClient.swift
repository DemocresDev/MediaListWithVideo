//
//  APIClient.swift
//  MediaListWithVideo
//
//  Created by David Figueroa on 3/06/22.
//

import Foundation
import SwiftKeychainWrapper
import Combine

class APIClient {
    
    static var shared: APIClient = {
        let instance = APIClient()
        KeychainWrapper.standard.remove(forKey: "sessionKey")
        KeychainWrapper.standard.remove(forKey: "tokeyType")
        instance.sessionToken = KeychainWrapper.standard.string(forKey: "sessionKey") ?? ""
        instance.tokeyType = KeychainWrapper.standard.string(forKey: "tokeyType") ?? ""
        return instance
    }()
    
    var sessionToken = ""
    var tokeyType = ""
    private var request: URLRequest?
    private var disposables = Set<AnyCancellable>()
    
    func createRequestWithURLComponents(requestType: RequestType) -> URLRequest? {
        
        var components = URLComponents(string: requestType.absoluteString)!

        components.queryItems = requestType.parameters
        request = URLRequest(url: components.url!)
        request?.httpMethod = requestType.method
        if let requestBody = requestType.requestBody,
           let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) {
            request?.httpBody = jsonData
        }
        if let customHeaders = requestType.customHeaders {
            for (value, header) in customHeaders {
                request?.addValue(header, forHTTPHeaderField: value)
            }
        }
        return request
    }
    
    func sendRequest<T:Codable>(model: T.Type, request: URLRequest) -> AnyPublisher<T, Error> {
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap({ data, response -> T in
                if let response = response as? HTTPURLResponse {
                    print(response.statusCode)
                }
                return try JSONDecoder().decode(T.self, from: data)
            })
            .eraseToAnyPublisher()
    }
    
    public func refreshSessionToken() {
        
        let emptyToken = POSTTokenResponse(sub: "", token: "", type: "")
        guard let request = createRequestWithURLComponents(requestType: .getToken) else { return }
        
        sendRequest(model: POSTTokenResponse.self, request: request)
            .catch({ error -> AnyPublisher<POSTTokenResponse, Never> in
                print("Handle Error: " + error.localizedDescription)
                return Just(emptyToken).eraseToAnyPublisher()
            }).sink { [weak self] tokenResponse in
                KeychainWrapper.standard.remove(forKey: "sessionKey")
                KeychainWrapper.standard.set(tokenResponse.token, forKey: "sessionKey")

                KeychainWrapper.standard.remove(forKey: "tokeyType")
                KeychainWrapper.standard.set(tokenResponse.type, forKey: "tokeyType")
                
                self?.sessionToken = tokenResponse.token
                self?.tokeyType = tokenResponse.type
            }.store(in: &disposables)
    }
}
