//
//  APIManager.swift

import Foundation

protocol PokemonListStore {
    func readPokemonList(offset: Int, completion: @escaping (Result<AllPokemonBase, Failure>) -> Void)
}

protocol PokemonDetailStore {
    func readPokemonDetails(for pokemon: Pokemon, completion: @escaping (Result<PokemonDetailBase, Failure>) -> Void)
}

final class APIManager {
    
}

extension APIManager: PokemonListStore {
        
    // As you can see the `Result` enum structure makes it very easy to convert cases from Future combine structure
    
    // This is because they have the same cases insid the enums the same name.
    
    // LOL forgot where you add escaping - been a while - this is older way - but also there is an even older way
    // that you do with closure and optional - but use this way - if they ask why just say its the new way and apple recommends it
    
    func readPokemonList(offset: Int, completion: @escaping (Result<AllPokemonBase, Failure>) -> Void) {
        
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=50&offset=\(offset)") else {
            completion(.failure(.urlConstructError))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, _, error) in

            guard let data = data, case .none = error else {
                completion(.failure(.urlConstructError));
                return
            }

            do {

                let decoder = JSONDecoder()
                let allPokemonBase = try decoder.decode(AllPokemonBase.self, from: data)
                completion(.success(allPokemonBase))

            } catch {
                completion(.failure(.APIError(error)))
            }

        }

        task.resume()
    }
}

extension APIManager: PokemonDetailStore {
    
    func readPokemonDetails(for pokemon: Pokemon, completion: @escaping (Result<PokemonDetailBase, Failure>) -> Void) {
        
        guard let url = URL(string: pokemon.url) else {
            completion(.failure(.urlConstructError))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, _, error) in

            guard let data = data, case .none = error else { completion(.failure(.urlConstructError)); return }

            do {

                let decoder = JSONDecoder()
                let pokemonDetailBase = try decoder.decode(PokemonDetailBase.self, from: data)
                completion(.success(pokemonDetailBase))

            } catch {
                completion(.failure(.APIError(error)))
            }

        }

        task.resume()
    }
}
