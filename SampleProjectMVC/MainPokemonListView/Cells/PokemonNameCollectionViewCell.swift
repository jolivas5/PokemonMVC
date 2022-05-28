//
//  PokemonNameCollectionViewCell.swift
//  WW-Exercise-01
//
//  Created by administrator on 5/26/22.
//  Copyright © 2022 Weight Watchers. All rights reserved.
//

import UIKit

final class PokemonNameCollectionViewCell: UICollectionViewCell, NibLoadable {
    
    @IBOutlet var pokemonNameLabel: UILabel!
    
    var cellTapped: (() -> Void)? {
        didSet {
            contentView.isUserInteractionEnabled = true
            contentView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                  action: #selector(contentViewTapped)))
        }
    }

    @objc private func contentViewTapped() {
        cellTapped?()
    }
}
