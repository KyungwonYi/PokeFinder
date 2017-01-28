//
//  ViewController.swift
//  PokeFinder
//
//  Created by Abdurrahman on 1/24/17.
//  Copyright © 2017 AR Ehsan. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

	@IBOutlet weak var mapView: MKMapView!
	
	let locationManager = CLLocationManager()
	var mapHasCenteredOnce = false
	
	var geoFire: GeoFire!
	var geoFireRef: FIRDatabaseReference!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		mapView.delegate = self
		mapView.userTrackingMode = MKUserTrackingMode.follow
		
		geoFireRef = FIRDatabase.database().reference()
		geoFire = GeoFire(firebaseRef: geoFireRef)
	}
	
	func locationAuthStatus() {
		if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
			mapView.showsUserLocation = true
		} else {
			locationManager.requestWhenInUseAuthorization()
		}
	}

	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		
		if status == .authorizedWhenInUse {
			mapView.showsUserLocation = true
		}
	}

	func centerMapLocation(location: CLLocation) {
		let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 2000, 2000)
		
		mapView.setRegion(coordinateRegion, animated: true)
	}

	func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
		
		if let location = userLocation.location {
			
			if !mapHasCenteredOnce {
				centerMapLocation(location: location)
				mapHasCenteredOnce = true
			}
		}
	}

	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		var annotationView: MKAnnotationView?
		
		if annotation.isKind(of: MKUserLocation.self) {
			annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "user")
			annotationView?.image = UIImage(named: "player")
		}
		
		return annotationView
	}
	
	func createSighting(forLocation location: CLLocation, withPokemon pokeId: Int) {
		
		geoFire.setLocation(location, forKey: "\(pokeId)")
	}
	
	func showSightingsOnMap(location: CLLocation) {
		let circleQuery = geoFire!.query(at: location, withRadius: 2.5)
		_ = circleQuery?.observe(GFEventType.keyEntered, with: { (key, location) in
			
			if let key = key, let location = location {
				let anno = PokeAnnotation(coordinate: location.coordinate, pokemonNumber: Int(key)!)
				self.mapView.addAnnotation(anno)
			}
		})
	}

	@IBAction func spotRandomPokemon(_ sender: UIButton) {
		
		let loc = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
		
		let rand = arc4random_uniform(151) + 1
		createSighting(forLocation: loc, withPokemon: Int(rand))
	}

}

