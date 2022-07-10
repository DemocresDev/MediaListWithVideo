//
//  ViewController.swift
//  MediaListWithVideo
//
//  Created by adm on 7/07/22.
//

import UIKit
import Combine
import AVKit

class ViewController: UIViewController {

    @IBOutlet weak var thumbsCollectionView: UICollectionView!
    @IBOutlet weak var postersCollectionView: UICollectionView!
    
    var viewModel = ViewModel()
    private var disposables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        bindData()
        setupCollectionViews()
        viewModel.fetchMovies()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func bindData() {
        viewModel.$dataLoaded.receive(on: DispatchQueue.main).sink { [weak self] dataLoaded in
            if dataLoaded {
                self?.thumbsCollectionView.reloadData()
                self?.postersCollectionView.reloadData()
            }
        }.store(in: &disposables)
    }
    
    private func setupCollectionViews() {
        
        let thumbsConfig = UICollectionLayoutListConfiguration(appearance: .grouped)
        thumbsCollectionView.collectionViewLayout =
          UICollectionViewCompositionalLayout.list(using: thumbsConfig)
        thumbsCollectionView.register(UINib(nibName: "MovieThumbCell",
                                            bundle: nil), forCellWithReuseIdentifier: "MovieThumbCell")

        postersCollectionView.isPagingEnabled = true
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        postersCollectionView.collectionViewLayout = layout
        postersCollectionView.register(UINib(nibName: "MoviePosterCell", bundle: nil), forCellWithReuseIdentifier: "MoviePosterCell")
    }
    
    private func presentVideoPlayer(videoUrlString: String) {
        let videoURL = URL(string: videoUrlString)
        let player = AVPlayer(url: videoURL!)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        DispatchQueue.main.async {
            self.present(playerViewController, animated: true) {
                playerViewController.player!.play()
            }
        }
    }
}

extension ViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == thumbsCollectionView {
            return viewModel.thumbs.count
        } else if collectionView == postersCollectionView {
            return viewModel.posters.count
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == thumbsCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieThumbCell", for: indexPath) as! MovieThumbCell
            cell.setupCell(movie: viewModel.thumbs[indexPath.row])
            return cell
            
        } else if collectionView == postersCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MoviePosterCell", for: indexPath) as! MoviePosterCell
            cell.setupCell(movie: viewModel.posters[indexPath.row])
            return cell
        }
        
        return UICollectionViewCell()
    }
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var videoUrlString = ""
        if collectionView == thumbsCollectionView {
            videoUrlString = viewModel.thumbs[indexPath.row].videoUrl ?? ""
        } else if collectionView == postersCollectionView {
            videoUrlString = viewModel.posters[indexPath.row].videoUrl ?? ""
        }
        presentVideoPlayer(videoUrlString: videoUrlString)
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width - 50, height: 300.0)
    }
}
