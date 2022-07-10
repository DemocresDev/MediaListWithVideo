//
//  APIClient.swift
//  MediaListWithVideo
//
//  Created by David Figueroa on 3/06/22.
//

import Foundation
import SwiftKeychainWrapper
import Combine
import JWTDecode

protocol APIClientProtocol: AnyObject {
    var sessionToken: String { get set }
    var tokeyType: String { get set }
    func createRequest<T:Codable>(responseModel: T.Type, requestType: RequestType) -> AnyPublisher<T, Error> 
    func sendRequest<T:Codable>(model: T.Type, request: URLRequest) -> AnyPublisher<T, Error>
}

final class APIClient: APIClientProtocol {
    
    static var shared: APIClient = {
        let instance = APIClient()
        instance.sessionToken = KeychainWrapper.standard.string(forKey: "sessionKey") ?? ""
        instance.tokeyType = KeychainWrapper.standard.string(forKey: "tokeyType") ?? ""
        instance.refreshSessionToken()
        return instance
    }()
    
    var sessionToken = ""
    var tokeyType = ""
    private var request: URLRequest?
    private var disposables = Set<AnyCancellable>()
    
    func createRequest<T:Codable>(responseModel: T.Type, requestType: RequestType) -> AnyPublisher<T, Error> {
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
        if let request = request {
            return sendRequest(model: responseModel, request: request)
        }
        
        return Fail(error: NSError(domain: "Error Creating Request", code: -1)).eraseToAnyPublisher()
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
    
    public func fetchSessionToken() {
        
        createRequest(responseModel: SessionTokenResponse.self, requestType: .getToken)
        .catch({ error -> AnyPublisher<SessionTokenResponse, Never> in
            print("Handle Error: " + error.localizedDescription)
            return Just(SessionTokenResponse(sub: "", token: "", type: "")).eraseToAnyPublisher()
        }).sink { [weak self] tokenResponse in
            KeychainWrapper.standard.remove(forKey: "sessionKey")
            KeychainWrapper.standard.set(tokenResponse.token, forKey: "sessionKey")

            KeychainWrapper.standard.remove(forKey: "tokeyType")
            KeychainWrapper.standard.set(tokenResponse.type, forKey: "tokeyType")
            
            self?.sessionToken = tokenResponse.token
            self?.tokeyType = tokenResponse.type
        }.store(in: &disposables)
    }
    
    private func refreshSessionToken() {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        guard let jwt = try? decode(jwt: sessionToken),
              let expDateString = jwt.body["expireDate"] as? String,
              let expDate = dateFormatter.date(from: expDateString),
              expDate > Date() else {
            self.fetchSessionToken()
            return
        }
    }
}
