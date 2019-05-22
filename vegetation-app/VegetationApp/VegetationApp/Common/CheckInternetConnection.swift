//
//  CheckInternetConnection.swift
//  VegetationApp
//
//  Created by Nitin Bhatia on 26/03/19.
//  Copyright © 2019 Nitin Bhatia. All rights reserved.
//

import Foundation
import Alamofire

class Connectivity {
    class func isConnectedToInternet() -> Bool {
        return NetworkReachabilityManager()?.isReachable ?? false
    }
}


//Usage

/*if Connectivity.isConnectedToInternet() {
 print("Yes! internet is available.")
 // do some tasks..
 } else {
 print("No! internet is not available.")
 }*/

