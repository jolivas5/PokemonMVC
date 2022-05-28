//
//  MainViewController.swift
//  SampleProjectMVC
//
//  Created by administrator on 5/28/22.
//

import Foundation

/*
 
So not going to use combine here. Going to use delegation for letting the viewcontroller know when something
has changed and should update. we could do a delegation for closure callback or a protocol type delegation
 I think going to use a protocol style delegation to make it easier to follow. I think you already know how to do
 closure style delegation callback

 so going to show protocol

 in the api to controller going to use closure style call back so you can see
 
 closure callback style delegation
 
 from api class --> controller
 
 and protocol style delegation
 
 from controller --> view (viewcontroller)
 
 */

protocol MainViewControllerDelegate: AnyObject {
    func didLoad(pokemon: [Pokemon])
    func didError(error: Failure)
    func showDetailView(for pokemon: Pokemon)
}


// Would be cool to also make an interface also for the controller - that way it's more encapsulated and easier to test
// the viewcontroller if we ever need to do that

protocol PokemonListController {
    var delegate: MainViewControllerDelegate? { get set }
    func loadData()
    func didTapItem(model: Pokemon)
    func searchPokemon(with query: String?)
    func prefetchData(for indexPaths: [IndexPath])
}

final class PokemonListMainController: PokemonListController {

    // has to be weak to avoid a retain cycle or memory leak
    weak var delegate: MainViewControllerDelegate?
    
    // this is called a store pattern - it's a black box - you dont know if the object is going to fetch the data from a local
    // cache or if its going to fetch from an api call - you just know you get the data back
    private let store: PokemonListStore
    private var fetchedPokemon: [Pokemon] = []

    init(store: PokemonListStore = APIManager()) {
        self.store = store
    }
    
    func loadData() {
        
        // Btw you can pass in blocks of code too
        // like here you could have done
        
        store.readPokemonList(offset: fetchedPokemon.count) { [unowned self] result in
            switch result {
                    
                    // we can use `self` here directly without making weak self or using [unwoned self] or [weak self]
                    // since the delegate is already weak
                    // when you use unowned self you can remove the self call in async methods
                case .success(let pokemonBase):
                    fetchedPokemon.append(contentsOf: pokemonBase.results)
                    delegate?.didLoad(pokemon: fetchedPokemon)
                    
                case .failure(let error):
                    delegate?.didError(error: error)
            }
        }
    }
    
    func searchPokemon(with query: String?) {

        if let query = query, !query.isEmpty {
            let lowerCaseQuery = query.lowercased()
            let filteredPokemonList = fetchedPokemon.filter { $0.name.lowercased().contains(lowerCaseQuery) }
            delegate?.didLoad(pokemon: filteredPokemonList)
        } else {
            delegate?.didLoad(pokemon: fetchedPokemon)
        }
    }
    
    func didTapItem(model: Pokemon) {
        delegate?.showDetailView(for: model)
    }
    
    func prefetchData(for indexPaths: [IndexPath]) {

        guard let index = indexPaths.last?.row else { return }
        
        let pokemonAlreadyLoaded = fetchedPokemon.count
        if index > pokemonAlreadyLoaded - 10 {
            loadData()
        }
    }
}
