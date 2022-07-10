//
//  POSTToken.swift
//  MediaListWithVideo
//
//  Created by adm on 7/07/22.
//

import Foundation

struct SessionTokenResponse: Codable {
    var sub: String
    var token: String
    var type: String
}
