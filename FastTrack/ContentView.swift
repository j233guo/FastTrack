//
//  ContentView.swift
//  FastTrack
//
//  Created by Jiaming Guo on 2023-08-05.
//

import AVKit
import SwiftUI

struct ContentView: View {
    @AppStorage("searchText") var searchText = ""
    @State private var tracks = [Track]()
    @State private var audioPlayer: AVPlayer?
    
    let gridItems: [GridItem] = [
        GridItem(.adaptive(minimum: 150, maximum: 200)),
    ]
    
    func performSearch() async throws {
        guard let url = URL(string: "https://itunes.apple.com/search?term=\(searchText)&limit=100&entity=song") else { return }
        let (data, _) = try await URLSession.shared.data(from: url)
        let searchResults = try JSONDecoder().decode(SearchResult.self, from: data)
        tracks = searchResults.results
    }
    
    func startSearch() {
        Task {
            try await performSearch()
        }
    }
    
    func play(_ track: Track) {
        audioPlayer?.pause()
        audioPlayer = AVPlayer(url: track.previewUrl)
        audioPlayer?.play()
    }
    
    var body: some View {
        VStack {
            HStack {
                TextField("Search for a song", text: $searchText)
                    .onSubmit(startSearch)
                Button("Search", action: startSearch)
            }
            .padding([.top, .horizontal])
            
            ScrollView {
                LazyVGrid(columns: gridItems) {
                    ForEach(tracks) { track in
                        TrackView(track: track, onSelected: play)
                    }
                }
                .padding()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
