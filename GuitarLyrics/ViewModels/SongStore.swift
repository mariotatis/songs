import Foundation
import AVFoundation

class SongStore: ObservableObject {
    @Published var savedSongs: [Song] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentlyPlayingSongId: Int?
    private var audioPlayer: AVPlayer?
    private let userDefaultsKey = "savedSongs"
    
    init() {
        loadSongs()
    }
    
    func loadSongs() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey) {
            do {
                savedSongs = try JSONDecoder().decode([Song].self, from: data)
            } catch {
                print("Error loading songs: \(error)")
                errorMessage = "Failed to load saved songs"
            }
        }
    }
    
    func saveSongs() {
        do {
            let data = try JSONEncoder().encode(savedSongs)
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
            UserDefaults.standard.synchronize()
        } catch {
            print("Error saving songs: \(error)")
            errorMessage = "Failed to save songs"
        }
    }
    
    func toggleFavorite(_ song: Song) {
        if let index = savedSongs.firstIndex(where: { $0.id == song.id }) {
            savedSongs[index].isFavorite.toggle()
            saveSongs()
        }
    }
    
    func addSong(_ song: Song) {
        if !savedSongs.contains(where: { $0.id == song.id }) {
            var newSong = song
            newSong.isFavorite = false
            savedSongs.append(newSong)
            saveSongs()
        }
    }
    
    func removeSong(_ song: Song) {
        if currentlyPlayingSongId == song.id {
            stopPreview()
        }
        savedSongs.removeAll { $0.id == song.id }
        saveSongs()
    }
    
    func updateLyrics(for songId: Int, lyrics: String) {
        if let index = savedSongs.firstIndex(where: { $0.id == songId }) {
            savedSongs[index].lyrics = lyrics
            saveSongs()
        }
    }
    
    func playPreview(song: Song) {
        if currentlyPlayingSongId == song.id {
            stopPreview()
            return
        }
        
        stopPreview() // Stop any currently playing song
        
        guard let url = URL(string: song.previewUrl) else { return }
        let playerItem = AVPlayerItem(url: url)
        audioPlayer = AVPlayer(playerItem: playerItem)
        audioPlayer?.play()
        currentlyPlayingSongId = song.id
        
        // Add observer for when song finishes playing
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime,
                                            object: playerItem,
                                            queue: .main) { [weak self] _ in
            self?.currentlyPlayingSongId = nil
        }
    }
    
    func stopPreview() {
        audioPlayer?.pause()
        audioPlayer = nil
        currentlyPlayingSongId = nil
    }
    
    func fetchSongs(query: String) async throws -> [Song] {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://api.deezer.com/search?q=\(encodedQuery)") else {
            throw AppError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(SearchResponse.self, from: data)
        return response.data
    }
    
    func fetchLyrics(for song: Song) async throws -> String {
        // Check if lyrics are already stored
        if let storedLyrics = song.lyrics {
            return storedLyrics
        }
        
        // If not, fetch from API
        guard let encodedArtist = song.artist.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let encodedTitle = song.title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://api.lyrics.ovh/v1/\(encodedArtist)/\(encodedTitle)") else {
            throw AppError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(LyricsResponse.self, from: data)
        
        // Store the lyrics
        updateLyrics(for: song.id, lyrics: response.lyrics)
        
        return response.lyrics
    }
}