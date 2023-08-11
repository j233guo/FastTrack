//
//  ContentView.swift
//  FastTrack
//
//  Created by Jiaming Guo on 2023-08-05.
//

import AVKit
import SwiftUI

enum SearchState {
    case none, searching, success, error
}

struct ContentView: View {
    @AppStorage("searchText") var searchText = ""
    @State private var tracks = [Track]()
    @State private var audioPlayer: AVPlayer?
    @State private var searchState: SearchState = .none
    @State private var previousSearches = [String]()
    
    let gridItems: [GridItem] = [
        GridItem(.adaptive(minimum: 150, maximum: 200)),
    ]
    
    func performSearch() async throws {
        guard let sanitizedSearchText = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        guard let url = URL(string: "https://itunes.apple.com/search?term=\(sanitizedSearchText)&limit=100&entity=song") else { return }
        let (data, _) = try await URLSession.shared.data(from: url)
        let searchResults = try JSONDecoder().decode(SearchResult.self, from: data)
        tracks = searchResults.results
        if !previousSearches.contains(searchText) {
            previousSearches.append(searchText)
        }
    }
    
    func startSearch() {
        Task {
            do {
                searchState = .searching
                try await performSearch()
                searchState = .success
            } catch {
                searchState = .error
            }
        }
    }
    
    func play(_ track: Track) {
        audioPlayer?.pause()
        audioPlayer = AVPlayer(url: track.previewUrl)
        audioPlayer?.play()
    }
    
    func delete(_ text: String) {
        guard let index = previousSearches.firstIndex(of: text) else { return }
        previousSearches.remove(at: index)
    }
    
    var body: some View {
        NavigationSplitView {
            List {
                Section("Previous Searches") {
                    ForEach(previousSearches, id: \.self) { item in
                        Button {
                            searchText = item
                            startSearch()
                        } label: {
                            Text(item)
                        }
                        .buttonStyle(.borderless)
                        .contextMenu {
                            Button("Delete", role: .destructive) {
                                delete(item)
                            }
                        }
                    }
                }
            }
        } detail: {
            VStack {
                switch searchState {
                case .none:
                    Text("Enter a search keyword to begin")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .frame(maxHeight: .infinity)
                case .searching:
                    ProgressView()
                        .frame(maxHeight: .infinity)
                case .success:
                    HStack {
                        Text("\(tracks.count) search results")
                            .foregroundColor(.secondary)
                            .padding([.top, .leading])
                        Spacer()
                    }
                    ScrollView {
                        LazyVGrid(columns: gridItems) {
                            ForEach(tracks) { track in
                                TrackView(track: track, onSelected: play)
                            }
                        }
                        .padding([.horizontal, .bottom])
                    }
                case .error:
                    Text("Search failed. Please check your connection.")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .frame(maxHeight: .infinity)
                }
            }
        }
        .searchable(text: $searchText, placement: .automatic)
        .onSubmit(of: .search, startSearch)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
