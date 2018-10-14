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

//50.473976, 30.448605
//50.440011, 30.472238

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
    
    fileprivate var trasportType: MKDirectionsTransportType = .automobile
    fileprivate var isBestRoute: Bool = true
    fileprivate var didDrawRoute: Bool = false
    
    fileprivate var startAnnonation: CustomAnnotation?
    fileprivate var destinationAnnotation: CustomAnnotation?
    
    fileprivate var locationStart: CLLocation? //CLLocation(latitude: 50.473976, longitude: 30.448605)
    fileprivate var locationDestination: CLLocation? //CLLocation(latitude: 50.440011, longitude: 30.472238)
    
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
    
    //function for create a marker pin on map
    private func createMarker(forLocation locaiton: Location, titleMarker title: String, subTitle: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        switch locaiton {
        case .start:
            startAnnonation = CustomAnnotation(title: title, subtitle: subTitle, coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
            startAnnonation!.color = UIColor.blue
            mapView.addAnnotation(startAnnonation!)
        case .destination:
            destinationAnnotation = CustomAnnotation(title: title, subtitle: subTitle, coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
            destinationAnnotation!.color = UIColor.red
            mapView.addAnnotation(destinationAnnotation!)
        }
    }
    
    //this is function for create direction path, from start location to desination location
    private func drawPath() {
        guard let startLatitude = locationStart?.coordinate.latitude, let startlLongitude = locationStart?.coordinate.longitude else { return }
        guard let destinatioLatitude = locationDestination?.coordinate.latitude, let destinatioLongitude = locationDestination?.coordinate.longitude else { return }
        
        let sourcePlacemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: startLatitude, longitude: startlLongitude))
        let destinationPlacemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: destinatioLatitude, longitude: destinatioLongitude))

        let directionRequest = MKDirectionsRequest()
        directionRequest.source = MKMapItem(placemark: sourcePlacemark)
        directionRequest.destination = MKMapItem(placemark: destinationPlacemark)
        directionRequest.transportType = trasportType
        directionRequest.requestsAlternateRoutes = true
        
        let direcation = MKDirections(request: directionRequest)
        direcation.calculate { [weak self] response, error in
//            self?.didDrawRoute = true
            guard let `self` = self else { return }
            if let error = error {
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction.init(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true, completion:nil)
                return
            }
            if let response = response {
                print(response.routes.count)
                
                for route in response.routes {
                    self.mapView.add(route.polyline, level: .aboveLabels)
                    let rect = route.polyline.boundingMapRect
                    self.mapView.setRegion(MKCoordinateRegionForMapRect(rect), animated: true)
                }
                self.isBestRoute = true
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

// MARK: - MapView Delegate
extension GeneralViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let rendered = MKPolylineRenderer(overlay: overlay)
        if isBestRoute {
            isBestRoute = false
            rendered.strokeColor = UIColor(red: 17.0/255.0, green: 147.0/255.0, blue: 255.0/255.0, alpha: 1)
        } else {
            rendered.strokeColor = UIColor.lightGray.withAlphaComponent(0.7)
        }
        rendered.lineWidth = 4
        return rendered
    }
}


// MARK: Actions
extension GeneralViewController {
    @IBAction func myLocationPressed(_ sender: UIButton) {
        guard let region = selfLocation else { return }
        mapView.setRegion(region, animated: true)
    }
    
    @IBAction func openStartLocation(_ sender: UIButton) {
        let autoCompleteController = GMSAutocompleteViewController()
        autoCompleteController.delegate = self
        
        locationSelected = .start
        UISearchBar.appearance().setTextColor(color: UIColor.black)
        present(autoCompleteController, animated: true, completion: nil)
    }
    
    @IBAction func openDestinationLocation(_ sender: UIButton) {
        let autoCompleteController = GMSAutocompleteViewController()
        autoCompleteController.delegate = self
        
        locationSelected = .destination
        UISearchBar.appearance().setTextColor(color: UIColor.black)
        present(autoCompleteController, animated: true, completion: nil)
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
        
        let address = place.formattedAddress ?? ""
        let longitude = place.coordinate.longitude
        let latitude = place.coordinate.latitude
        
        zoomIn(toLocaction: CLLocation(latitude: latitude, longitude: longitude))
        
        if locationSelected == .start {
            if let start = startAnnonation { mapView.removeAnnotation(start) }
            createMarker(forLocation: .start, titleMarker: "Start Location", subTitle: address, latitude: latitude, longitude: longitude)
            locationStart = CLLocation(latitude: latitude, longitude: longitude) // TODO: remove
        } else {
            if let destination = destinationAnnotation { mapView.removeAnnotation(destination) }
            createMarker(forLocation: .destination, titleMarker: "Destination Location", subTitle: address, latitude: latitude, longitude: longitude)
            locationDestination = CLLocation(latitude: latitude, longitude: longitude)  // TODO: remove
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
