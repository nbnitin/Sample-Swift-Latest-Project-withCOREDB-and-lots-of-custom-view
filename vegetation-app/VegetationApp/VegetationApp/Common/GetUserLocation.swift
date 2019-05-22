//
//  GetUserLocation.swift
//  VegetationApp
//
//  Created by Nitin Bhatia on 09/04/19.
//  Copyright © 2019 Nitin Bhatia. All rights reserved.
//

import Foundation
import CoreLocation
import Contacts

protocol searchCurrentLocation {
    func getCurrentLocation(location:CLLocation)
}

class GetUserLocation:NSObject,CLLocationManagerDelegate{
    
    //variables
    let locationManager = CLLocationManager()
    var location : CLLocation!
    var delegate : searchCurrentLocation!

    override init() {
        super.init()
        
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
    }
    
    
    //Mark:- location delegates function
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        self.location = manager.location
        locationManager.stopUpdatingLocation()
        delegate.getCurrentLocation(location: self.location)
       // self.getAddresseFromCoordinates(loc: locValue)
        print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
    
    func getAddresseFromCoordinates(loc:CLLocationCoordinate2D!){
        let location = CLLocation(latitude: loc.latitude, longitude: loc.latitude)
        
        
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
                    print("address2:", placemark.subThoroughfare ?? "unknown")
                    print("neighborhood:", placemark.subLocality ?? "unknown")
                    print("city:", placemark.locality ?? "unknown")
                    
                    print("state:", placemark.administrativeArea ?? "unknown")
                    print("subAdministrativeArea:", placemark.subAdministrativeArea ?? "unknown")
                    print("zip code:", placemark.postalCode ?? "unknown")
                    print("country:", placemark.country ?? "unknown", terminator: "\n\n")
                    
                    print("isoCountryCode:", placemark.isoCountryCode ?? "unknown")
                    print("region identifier:", placemark.region?.identifier ?? "unknown")
                    
                    print("timezone:", placemark.timeZone ?? "unknown", terminator:"\n\n")
                    
                    // Mailind Address
                    print(placemark.mailingAddress ?? "unknown")
                }
            }
        }
        
    }

    
}

extension CLLocation {
    func geocode(completion: @escaping (_ placemark: [CLPlacemark]?, _ error: Error?) -> Void)  {
        CLGeocoder().reverseGeocodeLocation(self, completionHandler: completion)
    }
    
    
}
//To format your place mark as a mailing address you can use Contacts framework CNPostalAddressFormatter:

extension Formatter {
    static let mailingAddress: CNPostalAddressFormatter = {
        let formatter = CNPostalAddressFormatter()
        formatter.style = .mailingAddress
        return formatter
    }()
}

extension CLPlacemark {
    var mailingAddress: String? {
        if #available(iOS 11.0, *) {
            return postalAddress?.mailingAddress
        } else {
            return ""
        }
    }
}

extension CNPostalAddress {
    var mailingAddress: String {
        return Formatter.mailingAddress.string(from: self)
    }
}



