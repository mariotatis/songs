import SwiftUI

struct ContentView: View {
    @EnvironmentObject var songStore: SongStore
    @State private var showingAddSong = false
    @State private var filterMode: FilterMode = .all
    
    enum FilterMode {
        case all
        case favorites
    }
    
    let guitarQuotes = [
        "Music is the strongest form of magic - Marilyn Manson",
        "If you want to be a rock star or just be famous, then run down the street naked, you'll make the news.",
        "I believe every guitar player inherently has something unique about their playing - Jimmy Page"
    ]
    
    var filteredSongs: [Song] {
        switch filterMode {
        case .all:
            return songStore.savedSongs
        case .favorites:
            return songStore.savedSongs.filter { $0.isFavorite }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(0.4), Color.blue.opacity(0.4)]),
                             startPoint: .topLeading,
                             endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                
                if filteredSongs.isEmpty {
                    VStack {
                        Text(guitarQuotes.randomElement() ?? "")
                            .italic()
                            .padding()
                            .multilineTextAlignment(.center)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredSongs) { song in
                                NavigationLink(destination: SongDetailView(song: song)) {
                                    SongRowView(song: song)
                                }
                            }
                        }
                        .padding()
                    }
                }
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: { showingAddSong = true }) {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.blue)
                                .background(Circle().fill(Color.white))
                                .shadow(radius: 4)
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Guitar Lyrics")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { filterMode = .all }) {
                            Label("All Songs", systemImage: "music.note.list")
                                .foregroundColor(filterMode == .all ? .blue : .primary)
                        }
                        Button(action: { filterMode = .favorites }) {
                            Label("Favorites", systemImage: "heart.fill")
                                .foregroundColor(filterMode == .favorites ? .blue : .primary)
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .foregroundColor(.blue)
                    }
                }
            }
            .sheet(isPresented: $showingAddSong) {
                AddSongView(isPresented: $showingAddSong)
            }
        }
    }
}