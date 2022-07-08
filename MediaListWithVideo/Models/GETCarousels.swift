//
//  GETCarousels.swift
//  MediaListWithVideo
//
//  Created by adm on 8/07/22.
//

import Foundation

struct GETCarousels: Codable {
    var title: String
    var type: String
    var items: [Movie]
}

enum CarouselType: String {
    case thumb
    case poster
}
