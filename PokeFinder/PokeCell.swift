//
//  PokeCell.swift
//  PokeFinder
//
//  Created by Abdurrahman on 1/28/17.
//  Copyright © 2017 AR Ehsan. All rights reserved.
//

import UIKit

class PokeCell: UICollectionViewCell {
	@IBOutlet weak var thumbImg: UIImageView!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var idLabel: UILabel!
	
	var pokemon: Pokemon!
	
	func configureCell(_ pokemon: Pokemon) {
		self.pokemon = pokemon
		
		nameLabel.text = self.pokemon.name.capitalized
		thumbImg.image = UIImage(named: "\(self.pokemon.pokedexId)")
		idLabel.text = "\(self.pokemon.pokedexId)"
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		layer.cornerRadius = 5
	}

}
