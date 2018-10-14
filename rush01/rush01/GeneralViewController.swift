//
//  ViewController.swift
//  rush01
//
//  Created by Vitalii Poltavets on 10/13/18.
//  Copyright © 2018 Vitalii Poltavets. All rights reserved.
//

import UIKit
import MapKit
import GooglePlaces
import GoogleMaps


/*
 
 let allAnnotations = self.mapView.annotations
 self.mapView.removeAnnotations(allAnnotations)
 
 */

fileprivate enum Location {
    case start
    case destination
}

class GeneralViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var startLocation: UIButton!
    @IBOutlet weak var destinationLocation: UIButton!
    
    
    fileprivate var selfLocation: MKCoordinateRegion?
    fileprivate var locationManager: CLLocationManager!
    fileprivate var locationSelected = Location.start
    
    fileprivate var locationStart = CLLocation()
    fileprivate var locationDestination = CLLocation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initLocationManager()
        mapView.showsUserLocation = true
    }
    
    private func initLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    // MARK: function for create a marker pin on map
    private func createMarker(titleMarker title: String, subTitle: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let samplePoint = CustomAnnotation(title: title, subtitle: subTitle, coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
        samplePoint.color = UIColor.red
        mapView.addAnnotation(samplePoint)
    }
    
    //MARK: - this is function for create direction path, from start location to desination location
    private func drawPath() {

        let sourcePlacemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: locationStart.coordinate.latitude, longitude: locationStart.coordinate.longitude))
        let destinationPlacemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: locationDestination.coordinate.latitude, longitude: locationDestination.coordinate.longitude))
        
        let directionRequest = MKDirectionsRequest()
        directionRequest.source = MKMapItem(placemark: sourcePlacemark)
        directionRequest.destination = MKMapItem(placemark: destinationPlacemark)
        directionRequest.transportType = .automobile
        
        let direcation = MKDirections(request: directionRequest)
        direcation.calculate { response, error in
            if let error = error { print(error); return }
            if let response = response {
                guard let route = response.routes.first else { return }
                self.mapView.add(route.polyline, level: .aboveRoads)
                
                let rect = route.polyline.boundingMapRect
                self.mapView.setRegion(MKCoordinateRegionForMapRect(rect), animated: true)
            }
        }
    }
    
    private func zoomIn(toLocaction locaction: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: locaction.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    
}

//MARK: - Location Manager delegates
extension GeneralViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        debugPrint("Error to get location : \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            selfLocation = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
        }
    }
}


extension GeneralViewController: MKMapViewDelegate {
 
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let rendered = MKPolylineRenderer(overlay: overlay)
        rendered.strokeColor = UIColor.blue
        rendered.lineWidth = 3
        return rendered
    }
    
}


// MARK: Actions
extension GeneralViewController {
    @IBAction func openStartLocation(_ sender: UIButton) {
        
        let autoCompleteController = GMSAutocompleteViewController()
        autoCompleteController.delegate = self
        
        locationSelected = .start
        
        UISearchBar.appearance().setTextColor(color: UIColor.black)
        self.locationManager.stopUpdatingLocation()
        
        self.present(autoCompleteController, animated: true, completion: nil)
    }
    
    @IBAction func openDestinationLocation(_ sender: UIButton) {
        
        let autoCompleteController = GMSAutocompleteViewController()
        autoCompleteController.delegate = self
        
        locationSelected = .destination
        
        UISearchBar.appearance().setTextColor(color: UIColor.black)
        self.locationManager.stopUpdatingLocation()
        
        self.present(autoCompleteController, animated: true, completion: nil)
    }
    
    @IBAction func showDirection(_ sender: UIButton) {
        self.drawPath()
    }
}

// MARK: - GMS Auto Complete Delegate, for autocomplete search location
extension GeneralViewController: GMSAutocompleteViewControllerDelegate {
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error \(error)")
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        print(place.formattedAddress)
        
        let longitude = place.coordinate.longitude
        let latitude = place.coordinate.latitude
        
        zoomIn(toLocaction: CLLocation(latitude: latitude, longitude: longitude))
        
        if locationSelected == .start {
            locationStart = CLLocation()
            createMarker(titleMarker: "Start Location", subTitle: "", latitude: latitude, longitude: longitude)
            locationStart = CLLocation(latitude: latitude, longitude: longitude)
        } else {
            locationDestination = CLLocation()
            createMarker(titleMarker: "Destination Location", subTitle: "", latitude: latitude, longitude: longitude)
            locationDestination = CLLocation(latitude: latitude, longitude: longitude)
        }
        dismiss(animated: true, completion: nil)
    }

    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
}

public extension UISearchBar {
    
    public func setTextColor(color: UIColor) {
        let svs = subviews.flatMap { $0.subviews }
        guard let tf = (svs.filter { $0 is UITextField }).first as? UITextField else { return }
        tf.textColor = color
    }
    
}
