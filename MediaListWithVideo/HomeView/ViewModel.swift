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
    let apiClient = APIClient.shared
    
    var thumbs = [Movie]()
    var posters = [Movie]()
    private var disposables = Set<AnyCancellable>()
    
    func fetchMovies() {
        if let request = apiClient.createRequestWithURLComponents(requestType: .getMovies) {
            
            apiClient.sendRequest(model: [GETCarousels].self, request: request).sink { [weak self] completion in
                switch completion {
                case .finished:
                    self?.dataLoaded = true
                    break
                case .failure(let error):
                    self?.dataLoaded = false
                    print("HANDLE ERROR:" + error.localizedDescription)
                    // RUDIMENTARY RETRY
                    let queue = DispatchQueue(label: "mediaList", qos: .userInteractive)
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
}
