//
//  MediaListWithVideoTests.swift
//  MediaListWithVideoTests
//
//  Created by adm on 7/07/22.
//

import XCTest
import Combine
@testable import MediaListWithVideo

class MediaListWithVideoTests: XCTestCase {
    
    func testViewModelDataFetch() {
        let sut = ViewModel()
        var disposables = Set<AnyCancellable>()
        
        sut.fetchMovies()
        
        let expectation = expectation(description: "fetchData")
        sut.$dataLoaded.sink { isDataLoaded in
            if isDataLoaded {
                XCTAssertGreaterThan(sut.thumbs.count, 0)
                XCTAssertGreaterThan(sut.posters.count, 0)
            }
            expectation.fulfill()
        }.store(in: &disposables)
        
        waitForExpectations(timeout: 2)
    }
    
    func testAPIClientToken() {
        let sut = APIClient()
        let expectation = expectation(description: "fetchToken")
        
        sut.fetchSessionToken()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            XCTAssertFalse(sut.sessionToken.isEmpty)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }
}
