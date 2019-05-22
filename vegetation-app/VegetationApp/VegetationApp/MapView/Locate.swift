//
//  Locate.swift
//  VegetationApp
//
//  Created by Nitin Bhatia on 09/04/19.
//  Copyright © 2019 Nitin Bhatia. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit



class Locate: UIViewController,searchCurrentLocation,MKMapViewDelegate {
    //variables
    var getCurrentLocation : GetUserLocation!
    var location : CLLocationCoordinate2D!
    var annotation : MKPointAnnotation = MKPointAnnotation()
    var mapLocationDelegate : MapLocationDelegate!
    var objectLocation : CLLocation!
    var objectLocationLat : Double!
    var objectLocationLong : Double!
    var objectType : String = ""
    
    //outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var lblCurrentAddresse: UILabel!
    
    @IBOutlet weak var navigationBar: Navigation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getCurrentLocation = GetUserLocation()
        getCurrentLocation.delegate = self
        mapView.delegate = self

//        let tapGesture = UITapGestureRecognizer()
//        tapGesture.addTarget(self, action: #selector(getTappedCoordinates(_:)))
//        mapView.addGestureRecognizer(tapGesture)
//        mapView.isUserInteractionEnabled = true
        
//        navigationBar.btnRight.setTitle("Done", for: .normal)
//        navigationBar.btnRight.setImage(nil, for: .normal)
//        navigationBar.btnRight.addTarget(self, action: #selector(doneWithLocation(_:)), for: .touchUpInside)
        
        let image = UIImage(named: "ico")
        navigationBar.btnMenu.setImage(image, for: .normal)
        navigationBar.btnMenu.addTarget(self, action: #selector(back(_:)), for: .touchUpInside)
        
        
        //zooming map
        
        
        objectLocation = CLLocation(latitude: objectLocationLat as! CLLocationDegrees, longitude: objectLocationLong as! CLLocationDegrees)
        
        let objectAnnotation = MKPointAnnotation()
        objectAnnotation.coordinate = objectLocation.coordinate
        mapView.addAnnotation(objectAnnotation)
        
        
        self.mapView.showAnnotations(self.mapView.annotations, animated: true)
    }
    
    //Mark:- pop to vc
    @objc func back(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    func navigateMe(){
        var navigateLat = 0.0
        var navigateLong = 0.0
        
        if ( location == nil ) {
            navigateLat = objectLocationLat
            navigateLong = objectLocationLong
        } else {
            navigateLat = location.latitude
            navigateLong = location.longitude
        }
        
        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!))
        {
            //let  url = "comgooglemaps://?saddr=\(navigateLat),\(navigateLong)" //&directionsmode=driving &daddr=
            //let url = "comgooglemaps://?center=\(navigateLat),\(navigateLong)&saddr=\(navigateLat),\(navigateLong)&zoom=14&views=traffic"
            let url = "comgooglemaps://?q=\(navigateLat),\(navigateLong)"
            let finalURL = URL(string: url)!
            UIApplication.shared.open(finalURL, options: [:], completionHandler: nil)
        } else {
            // Navigate from one coordinate to another
          //  let url = "http://maps.apple.com/maps?saddr=&daddr=\(navigateLat),\(navigateLong)"
            let url = "http://maps.apple.com/maps?q=\(navigateLat),\(navigateLong)"
            let finalURL = URL(string: url)!
            UIApplication.shared.open(finalURL, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func navigateAction(_ sender: Any) {
       navigateMe()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        if !(annotation is MKPointAnnotation) {
            return nil
        }
        
        let annotationIdentifier = "AnnotationIdentifier"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView!.canShowCallout = true
        }
        else {
            annotationView!.annotation = annotation
        }
        
        if (objectType == "hzt") {
            let pinImage = UIImage(named: "location-pin-512")
            annotationView!.image = pinImage
        } else {
            let pinImage = UIImage(named: "location-1")
            annotationView!.image = pinImage
        }
        
        return annotationView
    }
    
    
    //Mark:- get user location where user taps
    @objc private func getTappedCoordinates(_ sender:UITapGestureRecognizer){
        
        let alert = UIAlertController(title: "Confirm ?", message: "Do you want to navigate here ?", preferredStyle: .alert)
        
        let point = sender.location(in: self.mapView)
        self.location = self.mapView.convert(point, toCoordinateFrom: self.mapView)
        self.mapView.removeAnnotation(self.annotation)
        self.annotation.coordinate = self.location
        self.mapView.addAnnotation(self.annotation)
        self.setAddresse()
        
        let alertOk = UIAlertAction(title: "Yes", style: .default, handler:{ (UIAlertAction) in
            self.mapView.removeAnnotation(self.annotation)
            self.navigateMe()
        })
        
        let alertCancel = UIAlertAction(title: "No", style: .destructive, handler:{(UIAlertAction) in self.location = nil
            
            
            self.mapView.removeAnnotation(self.annotation)
        })
        
        alert.addAction(alertOk)
        alert.addAction(alertCancel)
        
        self.present(alert, animated: true, completion: nil)
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
                    
                    if ( self.lblCurrentAddresse.text == "unknown" ) {
                        self.navigationBar.btnRight.setTitle("Cancel", for: .normal)
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
            annotation.coordinate = self.location
        }
        mapView.removeAnnotation(annotation)
        mapView.addAnnotation(annotation)
        setAddresse()
        mapView.showAnnotations(mapView.annotations, animated: true)
        mapView.removeAnnotation(annotation)
    }
    
    
    
    
    
}
