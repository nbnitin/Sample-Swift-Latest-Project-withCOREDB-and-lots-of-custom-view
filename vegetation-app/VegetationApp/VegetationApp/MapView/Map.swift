//
//  Map.swift
//  VegetationApp
//
//  Created by Nitin Bhatia on 09/04/19.
//  Copyright © 2019 Nitin Bhatia. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

protocol MapLocationDelegate {
    func doneWithMap(location:CLLocation)
}

class Map: UIViewController,searchCurrentLocation {
    //variables
    var getCurrentLocation : GetUserLocation!
    var location : CLLocation!
    var annotation : MKPointAnnotation = MKPointAnnotation()
    var mapLocationDelegate : MapLocationDelegate!
    
    //outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var lblCurrentAddresse: UILabel!
    
    @IBOutlet weak var navigationBar: Navigation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getCurrentLocation = GetUserLocation()
        getCurrentLocation.delegate = self
        
        let tapGesture = UITapGestureRecognizer()
        tapGesture.addTarget(self, action: #selector(getTappedCoordinates(_:)))
        mapView.addGestureRecognizer(tapGesture)
        mapView.isUserInteractionEnabled = true
        
        navigationBar.btnRight.setTitle("Done", for: .normal)
        navigationBar.btnRight.setImage(nil, for: .normal)
        navigationBar.btnRight.addTarget(self, action: #selector(doneWithLocation(_:)), for: .touchUpInside)
        
        let image = UIImage(named: "ico")
        navigationBar.btnMenu.setImage(image, for: .normal)
        navigationBar.btnMenu.addTarget(self, action: #selector(back(_:)), for: .touchUpInside)
        
        
        
        
        //zooming map
        
        if ( location == nil ) {
            navigationBar.btnRight.isEnabled = false
        } else {
            mapView.setRegion(MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 200, longitudinalMeters: 200), animated: true)
            navigationBar.btnRight.isEnabled = true
        }

        
        
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                self.showAlertWithSettings(message: "Do not have permission to access the location. Please give the permission from Settings to access the location or tap on map to pick the location.",title:"Location Permission")
            case .authorizedAlways, .authorizedWhenInUse:
                print("Access")
            }
        } else {
            self.showAlertWithSettings(message: "Do not have permission to access the location. Please give the permission from Settings to access the location or tap on map to pick the location.",title:"Location Permission")
        }
        
        navigationBar.btnRight.setTitleColor(UIColor.lightGray, for: .disabled)
    }
    
    //Mark:- pop to vc
    @objc func back(_ sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    //Mark:- done with location
    @objc private func doneWithLocation(_ sender:UIButton){
        if(sender.titleLabel?.text == "Done"){
            let location = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
            self.mapLocationDelegate.doneWithMap(location: location)
            self.dismiss(animated: true, completion: nil)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    //Mark:- get user location where user taps
    @objc private func getTappedCoordinates(_ sender:UITapGestureRecognizer){
        
        let point = sender.location(in: mapView)
        let location = self.mapView.convert(point, toCoordinateFrom: self.mapView)
        self.mapView.removeAnnotation(annotation)
        self.annotation.coordinate = location
        self.mapView.addAnnotation(annotation)
        self.navigationBar.btnRight.isEnabled = true
        self.setAddresse()
    }
    
    //Mark:- setting address to label
    func setAddresse(){
        let location = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
        location.geocode { placemark, error in
            if let error = error as? CLError {
                print("CLError:", error)
                return
            } else if let placemark = placemark?.first {
                // you should always update your UI in the main thread
                DispatchQueue.main.async {
                    
                    //  update UI here
                    print("name:", placemark.name ?? "unknown")
                    
                    print("address1:", placemark.thoroughfare ?? "unknown")
                    self.lblCurrentAddresse.text = (placemark.mailingAddress == "" ? "unknown" : placemark.mailingAddress)
                    self.navigationBar.btnRight.isEnabled = true

                    if ( self.lblCurrentAddresse.text == "unknown" ) {
                        self.navigationBar.btnRight.setTitle("Cancel", for: .normal)
                        self.navigationBar.btnRight.titleLabel!.adjustsFontSizeToFitWidth = true
                        self.navigationBar.btnRight.titleLabel!.lineBreakMode = .byClipping
                    } else {
                        self.navigationBar.btnRight.setTitle("Done", for: .normal)
                    }
                    
                }
            }
        }
    }
    
    func getCurrentLocation(location: CLLocation) {
        
        if ( self.location == nil ) {
            annotation.coordinate = location.coordinate
        } else {
            annotation.coordinate = self.location.coordinate
        }
        mapView.removeAnnotation(annotation)
        mapView.addAnnotation(annotation)
        setAddresse()
            
        
    }
    
    

    

}
