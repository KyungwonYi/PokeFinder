//
//  PokemonListViewController.swift
//  PokeFinder
//
//  Created by Abdurrahman on 1/28/17.
//  Copyright © 2017 AR Ehsan. All rights reserved.
//

import UIKit

class PokemonListViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {

	@IBOutlet weak var searchBar: UISearchBar!
	@IBOutlet weak var collectionView: UICollectionView!

	var pokemon = [Pokemon]()
	var filteredPokemon = [Pokemon]()
	var inSearchMode = false

    override func viewDidLoad() {
        super.viewDidLoad()
		searchBar.backgroundImage = UIImage()
		
		searchBar.delegate = self
		collectionView.delegate = self
		collectionView.dataSource = self
		
		parsePokemonCSV()
	}
	
	func parsePokemonCSV() {
		let path = Bundle.main.path(forResource: "pokemon", ofType: "csv")!
		
		do {
			let csv = try CSV(contentsOfURL: path)
			let rows = csv.rows
			//print(rows)
			
			for row in rows {
				let pokeId = Int(row["id"]!)!
				let name = row["identifier"]!
				
				let poke = Pokemon(name: name, pokedexId: pokeId)
				pokemon.append(poke)
				
				//print(pokeId, name)
			}
		} catch let err as NSError {
			print(err)
		}
	}

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if inSearchMode {
			return filteredPokemon.count
		}
		return pokemon.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? PokeCell {
			let poke: Pokemon!
			
			if inSearchMode {
				poke = filteredPokemon[indexPath.row]
				cell.configureCell(poke)
			} else {
				poke = pokemon[indexPath.row]
				cell.configureCell(poke)
			}
			
			return cell
		} else {
			return UICollectionViewCell()
		}
	}

	@IBAction func back(_ sender: Any) {
		dismiss(animated: true, completion: nil)
	}
}

extension PokemonListViewController {
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		
		if searchBar.text == nil || searchBar.text == "" {
			inSearchMode = false
			collectionView.reloadData()
			view.endEditing(true)
		} else {
			inSearchMode = true
			
			let lower = searchBar.text!.lowercased()
			
			filteredPokemon = pokemon.filter({
				$0.name.range(of: lower) != nil
			})
			
			collectionView.reloadData()
		}
	}
	
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		view.endEditing(true)
	}
}

