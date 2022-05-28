//
//  PokemonDetailController.swift
//  SampleProjectMVC
//
//  Created by administrator on 5/28/22.
//

import Foundation

protocol Pokedex {
    var delegate: PokedexDelegate? { get set }
    func loadData()
}

protocol PokedexDelegate: AnyObject {
    func didLoad(pokemonDetail: PokemonDetailBase)
    func didError(error: Failure)
}

final class PokemonDetailController: Pokedex {
    
    weak var delegate: PokedexDelegate?
    
    private let pokemon: Pokemon
    private let store: PokemonDetailStore
    
    init(pokemon: Pokemon, store: PokemonDetailStore = APIManager()) {
        self.pokemon = pokemon
        self.store = store
    }
    
    func loadData() {
        
        store.readPokemonDetails(for: pokemon) { [unowned self] result in
            
            switch result {
                case .success(let pokemonDetail):
                    delegate?.didLoad(pokemonDetail: pokemonDetail)
                case .failure(let error):
                    delegate?.didError(error: error)
            }
        }
    }
}
