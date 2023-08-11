//
//  TrackView.swift
//  FastTrack
//
//  Created by Jiaming Guo on 2023-08-08.
//

import SwiftUI

struct TrackView: View {
    @State private var isOnHover = false
    
    let track: Track
    
    let onSelected: (Track) -> Void
    
    var body: some View {
        Button {
            onSelected(track)
        } label: {
            ZStack(alignment: .bottom) {
                AsyncImage(url: track.artworkUrl) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable()
                    case .failure(_):
                        Image(systemName: "questionmark")
                            .symbolVariant(.circle)
                            .font(.largeTitle)
                    default:
                        ProgressView()
                    }
                }
                .frame(width: 150, height: 150)
                .scaleEffect(isOnHover ? 1.2 : 1)
                
                VStack {
                    Text(track.trackName)
                        .lineLimit(2)
                        .font(.headline)
                    Text(track.artistName)
                        .lineLimit(2)
                        .foregroundStyle(.secondary)
                }
                .padding(5)
                .frame(width: 150)
                .background(.regularMaterial)
            }
        }
        .buttonStyle(.borderless)
        .border(.blue, width: isOnHover ? 2 : 0)
        .onHover { hover in
            withAnimation {
                isOnHover = hover
            }
        }
    }
}

struct TrackView_Previews: PreviewProvider {
    static var previews: some View {
        TrackView(track: Track(trackId: 1, artistName: "Nirvana", trackName: "Smells Like Teen Spirit", previewUrl: URL(string: "abc")!, artworkUrl100: "https://bit.ly/teen-spirit")) { track in
            
        }
    }
}
