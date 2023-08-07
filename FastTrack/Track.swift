//
//  Track.swift
//  FastTrack
//
//  Created by Jiaming Guo on 2023-08-06.
//

import Foundation

struct Track: Identifiable, Codable {
    let trackId: Int
    let artistName: String
    let trackName: String
    let previewUrl: URL
    let artworkUrl100: String
    
    var id: Int { trackId }
    
    var artworkUrl: URL? {
        let replacedString = artworkUrl100.replacingOccurrences(of: "100x100", with: "300x300")
        return URL(string: replacedString)
    }
}

struct SearchResult: Decodable {
    let results: [Track]
}
