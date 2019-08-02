
import Foundation

// MARK: - Ornament
struct Ornament: Codable {
    let name: String
    let subCategory: [SubCategory]
    
    enum CodingKeys: String, CodingKey {
        case name
        case subCategory = "sub_category"
    }
}

// MARK: - SubCategory
struct SubCategory: Codable {
    let name, displayName: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case displayName = "display_name"
    }
}

typealias Ornaments = [Ornament]
