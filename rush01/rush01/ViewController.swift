//
//  ViewController.swift
//  rush01
//
//  Created by Vitalii Poltavets on 10/13/18.
//  Copyright © 2018 Vitalii Poltavets. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps
import Alamofire
import SwiftyJSON

// AIzaSyAiEHdYXS8WoFucBCRuTEA5t_Krs0Ppgcs


enum Location {
    case startLocation
    case destinationLocation
}

class ViewController: UIViewController {
    
    @IBOutlet weak var startLocation: UIButton!
    @IBOutlet weak var destinationLocation: UIButton!
    
    
    var locationManager = CLLocationManager()
    var locationSelected = Location.startLocation
    
    var locationStart = CLLocation()
    var locationEnd = CLLocation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    // MARK: function for create a marker pin on map
    func createMarker(titleMarker: String, iconMarker: UIImage, latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        
        
//        let marker = GMSMarker()
//        marker.position = CLLocationCoordinate2DMake(latitude, longitude)
//        marker.title = titleMarker
//        marker.icon = iconMarker
//        marker.map = googleMaps
    }
    

    
    
    //MARK: - this is function for create direction path, from start location to desination location
    func drawPath(startLocation: CLLocation, endLocation: CLLocation) {
        let origin = "\(startLocation.coordinate.latitude),\(startLocation.coordinate.longitude)"
        let destination = "\(endLocation.coordinate.latitude),\(endLocation.coordinate.longitude)"
        
        print(origin)
        print(destination)
    }

    

}

//MARK: - Location Manager delegates
extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error to get location : \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

    }
}


// MARK: Actions
extension ViewController {
    
    @IBAction func openStartLocation(_ sender: UIButton) {
        
        let autoCompleteController = GMSAutocompleteViewController()
        autoCompleteController.delegate = self
    
        locationSelected = .startLocation
        
        UISearchBar.appearance().setTextColor(color: UIColor.black)
        self.locationManager.stopUpdatingLocation()
        
        self.present(autoCompleteController, animated: true, completion: nil)
    }
    
    @IBAction func openDestinationLocation(_ sender: UIButton) {
        
        let autoCompleteController = GMSAutocompleteViewController()
        autoCompleteController.delegate = self
        
        locationSelected = .destinationLocation
        
        UISearchBar.appearance().setTextColor(color: UIColor.black)
        self.locationManager.stopUpdatingLocation()
        
        self.present(autoCompleteController, animated: true, completion: nil)
    }
    
    @IBAction func showDirection(_ sender: UIButton) {
        self.drawPath(startLocation: locationStart, endLocation: locationEnd)
    }
}

// MARK: - GMS Auto Complete Delegate, for autocomplete search location
extension ViewController: GMSAutocompleteViewControllerDelegate {
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error \(error)")
    }

    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
//
//        // Change map location
//        let camera = GMSCameraPosition.camera(withLatitude: place.coordinate.latitude, longitude: place.coordinate.longitude, zoom: 16.0)
//
//        // set coordinate to text
//        if locationSelected == .startLocation {
//            startLocation.titleLabel!.text = "\(place.coordinate.latitude), \(place.coordinate.longitude)"
//            locationStart = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
//            createMarker(titleMarker: "Start Location", iconMarker: #imageLiteral(resourceName: "marker"), latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
//        } else {
//            destinationLocation.titleLabel!.text = "\(place.coordinate.latitude), \(place.coordinate.longitude)"
//            locationEnd = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
//            createMarker(titleMarker: "End Location", iconMarker: #imageLiteral(resourceName: "marker"), latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
//        }
//        self.googleMaps.camera = camera
        self.dismiss(animated: true, completion: nil)
    }
//
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        self.dismiss(animated: true, completion: nil)
    }

}

public extension UISearchBar {
    
    public func setTextColor(color: UIColor) {
        let svs = subviews.flatMap { $0.subviews }
        guard let tf = (svs.filter { $0 is UITextField }).first as? UITextField else { return }
        tf.textColor = color
    }
    
}
