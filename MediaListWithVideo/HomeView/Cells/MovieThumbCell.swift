//
//  MovieThumbCell.swift
//  MediaListWithVideo
//
//  Created by adm on 8/07/22.
//

import UIKit
import Kingfisher

class MovieThumbCell: UICollectionViewCell {

    @IBOutlet weak var thumbImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setupCell(movie: Movie){
        if let url = URL(string: movie.imageUrl ?? "") {
            thumbImage.kf.setImage(with: url)
        }
        titleLabel.text = movie.title ?? ""
        descriptionLabel.text = movie.description ?? ""
    }
}
