import Foundation

struct Song: Identifiable, Codable {
    let id: Int
    let title: String
    let artist: String
    let pictureUrl: String
    let previewUrl: String
    let duration: Int
    var isFavorite: Bool
    var lyrics: String?
    
    var formattedDuration: String {
        let minutes = duration / 60
        let seconds = duration % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case artist
        case album
        case duration
        case previewUrl = "preview"
        case isFavorite
        case lyrics
    }
    
    private enum ArtistKeys: String, CodingKey {
        case name
    }
    
    private enum AlbumKeys: String, CodingKey {
        case coverMedium = "cover_medium"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        duration = try container.decode(Int.self, forKey: .duration)
        previewUrl = try container.decode(String.self, forKey: .previewUrl)
        
        // Try to decode nested objects first (API response)
        if let artistContainer = try? container.nestedContainer(keyedBy: ArtistKeys.self, forKey: .artist),
           let albumContainer = try? container.nestedContainer(keyedBy: AlbumKeys.self, forKey: .album) {
            artist = try artistContainer.decode(String.self, forKey: .name)
            pictureUrl = try albumContainer.decode(String.self, forKey: .coverMedium)
        } else {
            // If that fails, try to decode as stored format
            artist = try container.decode(String.self, forKey: .artist)
            pictureUrl = try container.decode(String.self, forKey: .album)
        }
        
        isFavorite = try container.decodeIfPresent(Bool.self, forKey: .isFavorite) ?? false
        lyrics = try container.decodeIfPresent(String.self, forKey: .lyrics)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(artist, forKey: .artist)
        try container.encode(previewUrl, forKey: .previewUrl)
        try container.encode(duration, forKey: .duration)
        try container.encode(isFavorite, forKey: .isFavorite)
        try container.encodeIfPresent(lyrics, forKey: .lyrics)
        // Store the album cover URL
        try container.encode(pictureUrl, forKey: .album)
    }
}