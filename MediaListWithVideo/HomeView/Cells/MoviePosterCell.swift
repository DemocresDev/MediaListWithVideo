//
//  MoviePosterCell.swift
//  MediaListWithVideo
//
//  Created by adm on 8/07/22.
//

import UIKit
import Kingfisher

class MoviePosterCell: UICollectionViewCell {

    @IBOutlet weak var posterImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setupCell(movie: Movie){
        if let url = URL(string: movie.imageUrl ?? "") {
            posterImage.kf.setImage(with: url)
        }
        titleLabel.text = movie.title ?? ""
    }
}
