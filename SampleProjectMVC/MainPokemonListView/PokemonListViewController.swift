//
//  PokemonListViewController.swift
//  SampleProjectMVC
//
//  Created by administrator on 5/28/22.
//

import UIKit

final class PokemonListViewController: UICollectionViewController {
    
    private var controller: PokemonListController = PokemonListMainController()
    private var searchController = UISearchController(searchResultsController: nil)
    
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, Pokemon>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Pokemon>

    private enum Section: CaseIterable {
        case main
    }
    
    private lazy var dataSource: DataSource = {
        let dataSource = DataSource(collectionView: collectionView) { (collectionView, indexPath, pokemon) -> UICollectionViewCell in
            
            let cell: PokemonNameCollectionViewCell = collectionView.dequeueCell(for: indexPath)
            
            cell.pokemonNameLabel.text = pokemon.name

            // like here honestly it's a loop - because in this case - this goes to controller --> which would then tell
            // the view to process the transition - view --> controller --> view
            // because here the view is also working as a router - which is dirty - and one of the probelms with mvc
            // the router logic exist here and we will use the presenter logic to show the next screen
            // this app using storyboard - so it will use that in the future. in abit when i write that code.
            
            cell.cellTapped = { [unowned self] in
                controller.didTapItem(model: pokemon)
            }

            return cell
        }

        return dataSource
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let pokemon = sender as? Pokemon, segue.identifier == Segue.showPokemonDetails.rawValue else {
            presentAlert(with: .decodingError)
            return
        }
        
        let pokemonDetailView = segue.destination as? PokemonDetailViewController
        pokemonDetailView?.pokedex = PokemonDetailController(pokemon: pokemon)
    }
    
    private func setUI() {
        collectionView.setCollectionViewLayout(PokemonListViewController.generateLayout(), animated: false)
        collectionView.register(PokemonNameCollectionViewCell.self)
        collectionView.dataSource = dataSource
        collectionView.backgroundColor = .white
        configureSearchController()
        collectionView.prefetchDataSource = self
        controller.delegate = self
        controller.loadData()
    }
    
    private func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = NSLocalizedString("Search LTK", comment: "Placeholder text in searchbar homescreen")
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    private func applySnapshot(items: [Pokemon], animatingDifferences: Bool = true) {
        var snapshot = Snapshot()
        snapshot.appendSections(Section.allCases)
        Section.allCases.forEach { snapshot.appendItems(items, toSection: $0) }
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
    
    static private func generateLayout() -> UICollectionViewLayout {

        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))

        let fullPhotoItem = NSCollectionLayoutItem(layoutSize: itemSize)

        fullPhotoItem.contentInsets = NSDirectionalEdgeInsets(top: 4,
                                                              leading: 4,
                                                              bottom: 4,
                                                              trailing: 4)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: fullPhotoItem, count: 1)

        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
}

extension PokemonListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        controller.searchPokemon(with: searchController.searchBar.text)
    }
}

extension PokemonListViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        controller.prefetchData(for: indexPaths)
    }
}

extension PokemonListViewController: MainViewControllerDelegate {
    
    func didLoad(pokemon: [Pokemon]) {
        applySnapshot(items: pokemon)
    }
    
    func didError(error: Failure) {
        presentAlert(with: error)
    }
    
    func showDetailView(for pokemon: Pokemon) {
        // THIS IS WHERE I'M RUSTY WILL NEED TO LOOK TO SEE HOW TO PRESENT THE OTHER VIEW AND PASS THE DATA
        // I just need to the code - i know you create the storybaord reference - prepare for segue and cast and pass data etc.
        
        performSegue(withIdentifier: Segue.showPokemonDetails.rawValue, sender: pokemon)
    }
}
