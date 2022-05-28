//
//  PokemonDetailViewController.swift

import UIKit
import Combine
import SDWebImage

final class PokemonDetailViewController: UIViewController {
    
    var pokedex: Pokedex?
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var collectionDetailView: UICollectionView!
    
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, URL>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, URL>
    
    private enum Section: CaseIterable {
        case main
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    
    private lazy var dataSource: DataSource = {
        let dataSource = DataSource(collectionView: collectionDetailView) { (collectionView, indexPath, pokeAvatarURL) -> UICollectionViewCell in
            let cell: PokemonDetailCollectionViewCell = collectionView.dequeueCell(for: indexPath)
            cell.imageView.contentMode = .scaleAspectFill
            
            cell.imageView.sd_setImage(with: pokeAvatarURL,
                                       placeholderImage: #imageLiteral(resourceName: "Placeholder-image"),
                                       options: .retryFailed,
                                       context: nil)

            return cell
        }

        return dataSource
    }()

    private func setUI() {
        
        collectionDetailView.register(PokemonDetailCollectionViewCell.self)
        setCollectionViewUI()
        
        pokedex?.delegate = self
        collectionDetailView.collectionViewLayout = PokemonDetailViewController.generateLayout()
        pokedex?.loadData()
    }
    
    private func setCollectionViewUI() {
        collectionDetailView.register(PokemonDetailCollectionViewCell.self)
        collectionDetailView.dataSource = dataSource
        collectionDetailView.backgroundColor = .white
    }
    
    private func applySnapshot(pokemonDetails: PokemonDetailBase?, animatingDifferences: Bool = true) {
        
        guard let pokemonDetailSprites = pokemonDetails?.sprites else { return }
        
        if
            let imageURL = pokemonDetailSprites.other?.officialArtwork?.front_default,
            let url = URL(string: imageURL) {
            
            imageView.sd_setImage(with: url,
                                  placeholderImage: #imageLiteral(resourceName: "Placeholder-image"),
                                  options: .retryFailed,
                                  context: nil)
        }
        
        let imageURLs: [URL] = [pokemonDetailSprites.back_default,
                                pokemonDetailSprites.back_female,
                                pokemonDetailSprites.back_shiny,
                                pokemonDetailSprites.back_shiny_female,
                                pokemonDetailSprites.front_default,
                                pokemonDetailSprites.front_female,
                                pokemonDetailSprites.front_shiny,
                                pokemonDetailSprites.front_shiny_female].lazy.compactMap { $0 }.compactMap { URL(string: $0) }
        
        var snapshot = Snapshot()
        snapshot.appendSections(Section.allCases)
        Section.allCases.forEach { snapshot.appendItems(imageURLs, toSection: $0) }
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

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(250))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: fullPhotoItem, count: 2)

        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
}

extension PokemonDetailViewController: PokedexDelegate {
    func didLoad(pokemonDetail: PokemonDetailBase) {
        applySnapshot(pokemonDetails: pokemonDetail)
    }
    
    func didError(error: Failure) {
        presentAlert(with: error)
    }
}
