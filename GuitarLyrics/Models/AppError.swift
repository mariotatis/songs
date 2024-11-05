import Foundation

enum AppError: LocalizedError {
    case networkError(Error)
    case decodingError(Error)
    case invalidURL
    case noLyrics
    
    var errorDescription: String? {
        switch self {
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Data error: \(error.localizedDescription)"
        case .invalidURL:
            return "Invalid URL"
        case .noLyrics:
            return "No lyrics found for this song"
        }
    }
}