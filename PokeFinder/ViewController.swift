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

	@IBOutlet weak var bgView: UIView!
	@IBOutlet weak var mapView: MKMapView!
	
	let locationManager = CLLocationManager()
	var mapHasCenteredOnce = false
	
	var geoFire: GeoFire!
	var geoFireRef: FIRDatabaseReference!
	
	var pokeSelected = 1
	var pokeArray = [Int]()
	
	@IBOutlet weak var pickerView: UIPickerView!
	override func viewDidLoad() {
		super.viewDidLoad()
		
		bgView.alpha = 0
		
		mapView.delegate = self
		mapView.userTrackingMode = MKUserTrackingMode.follow
		self.pickerView.delegate = self
		self.pickerView.dataSource = self
		
		for pokeNum in 1..<152 {
			pokeArray.append(pokeNum)
		}
		
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
		var annoId = "Pokemon"
		var annotationView: MKAnnotationView?
		
		if annotation.isKind(of: MKUserLocation.self) {
			annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "user")
			annotationView?.image = UIImage(named: "player")
		} else if let deqAnno = mapView.dequeueReusableAnnotationView(withIdentifier: annoId) {
			annotationView = deqAnno
			annotationView?.annotation = annotation
		} else {
			let av = MKAnnotationView(annotation: annotation, reuseIdentifier: annoId)
			av.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
			annotationView = av
		}
		
		if let annotationView = annotationView, let anno = annotation as? PokeAnnotation {
			annotationView.canShowCallout = true
			annotationView.image = UIImage(named: "\(anno.pokemonNumber)")
			let btn = UIButton()
			btn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
			btn.setImage(UIImage(named: "map"), for: .normal)
			annotationView.rightCalloutAccessoryView = btn
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
	
	func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
		
		let loc = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
		showSightingsOnMap(location: loc)
	}
	
	func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
		
		if let anno = view.annotation as? PokeAnnotation {
			let place = MKPlacemark(coordinate: anno.coordinate)
			let destination = MKMapItem(placemark: place)
			destination.name = "Pokemon Sighting"
			let regionDistance: CLLocationDistance = 1000
			let regionSpan = MKCoordinateRegionMakeWithDistance(anno.coordinate, regionDistance, regionDistance)
			
			let options = [MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center), MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span), MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving] as [String : Any]
			MKMapItem.openMaps(with: [destination], launchOptions: options)
		}
	}

	@IBAction func spotRandomPokemon(_ sender: UIButton) {
		
		let loc = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
		
		//let rand = arc4random_uniform(151) + 1
		createSighting(forLocation: loc, withPokemon: pokeSelected)
	}

	@IBAction func showPokemonPickerView(_ sender: Any) {
		UIView.animate(withDuration: 0.5, animations: {
			self.bgView.alpha = 1
		})
	}
	
	@IBAction func closePicker(_ sender: Any) {
		UIView.animate(withDuration: 0.5, animations: {
			self.bgView.alpha = 0
		})
	}
}

extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		return "\(pokeArray[row])"
	}
	
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}
	
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return pokemon.count
	}
	
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		pokeSelected = pokeArray[row]
	}

	func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
		let title = NSAttributedString(string: "\(pokeArray[row])", attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 18.0),NSForegroundColorAttributeName:UIColor.white])
		return title
	}
}






