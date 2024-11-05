import Foundation

struct Album: Codable {
    let id: Int
    let title: String
    let coverMedium: String
    
    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case coverMedium = "cover_medium"
    }
}