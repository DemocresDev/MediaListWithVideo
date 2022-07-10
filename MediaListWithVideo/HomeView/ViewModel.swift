//
//  ViewModel.swift
//  MediaListWithVideo
//
//  Created by adm on 7/07/22.
//

import Foundation
import Combine

class ViewModel {
    
    @Published var dataLoaded: Bool = false
    
    var thumbs = [Movie]()
    var posters = [Movie]()
    var apiClient: APIClientProtocol
    
    private var disposables = Set<AnyCancellable>()
    
    init(apiClient: APIClientProtocol = APIClient.shared) {
        self.apiClient = apiClient
    }
    
    func fetchMovies() {
        apiClient.createRequest(responseModel: [Carousels].self, requestType: .getMovies).sink { [weak self] completion in
            switch completion {
            case .finished:
                self?.dataLoaded = true
                break
            case .failure(let error):
                self?.dataLoaded = false
                print("HANDLE ERROR:" + error.localizedDescription)
                // RUDIMENTARY RETRY
                let queue = DispatchQueue(label: "mediaListFetchRetry", qos: .userInteractive)
                queue.asyncAfter(deadline: .now() + 1, execute: {
                    self?.fetchMovies()
                })
            }
        } receiveValue: { [weak self]  carousels in
            carousels.filter({ $0.type == CarouselType.thumb.rawValue }).forEach { [weak self] carousel in
                self?.thumbs.append(contentsOf: carousel.items)
            }
            carousels.filter({ $0.type == CarouselType.poster.rawValue }).forEach { [weak self] carousel in
                self?.posters.append(contentsOf: carousel.items)
            }
        }.store(in: &disposables)
    }
}
