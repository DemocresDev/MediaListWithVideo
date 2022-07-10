//
//  APIClientMock.swift
//  MediaListWithVideoTests
//
//  Created by adm on 9/07/22.
//

@testable import MediaListWithVideo
import Combine
import Foundation

class APIClientMock: APIClientProtocol {
    var sessionToken: String = ""
    
    var tokeyType: String = ""
    
    func createRequest<T>(responseModel: T.Type, requestType: RequestType) -> AnyPublisher<T, Error> where T : Decodable, T : Encodable {
        return PassthroughSubject().eraseToAnyPublisher()
    }
    
    func sendRequest<T>(model: T.Type, request: URLRequest) -> AnyPublisher<T, Error> where T : Decodable, T : Encodable {
        return PassthroughSubject().eraseToAnyPublisher()
    }
}
