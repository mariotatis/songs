import Foundation

struct SearchResponse: Codable {
    let data: [Song]
    let total: Int
    let next: String?
}

struct LyricsResponse: Codable {
    let lyrics: String
}