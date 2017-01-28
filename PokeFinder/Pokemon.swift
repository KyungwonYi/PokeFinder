//
//  Pokemon.swift
//  PokeFinder
//
//  Created by Abdurrahman on 1/28/17.
//  Copyright © 2017 AR Ehsan. All rights reserved.
//

import Foundation

class Pokemon {

	private var _name: String!
	private var _pokedexId: Int!
	
	var name: String {
		if _name == nil {
			_name = ""
		}
		
		return _name
	}
	
	var pokedexId: Int {
		return _pokedexId
	}
	
	init(name: String, pokedexId: Int) {
		self._name = name
		self._pokedexId = pokedexId
	}
}
