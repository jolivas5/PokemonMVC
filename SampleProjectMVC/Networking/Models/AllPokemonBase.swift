//
//

import Foundation

struct AllPokemonBase: Codable {
    let count : Int
    let next : String?
    let previous : String?
    let results : [Pokemon]
}
