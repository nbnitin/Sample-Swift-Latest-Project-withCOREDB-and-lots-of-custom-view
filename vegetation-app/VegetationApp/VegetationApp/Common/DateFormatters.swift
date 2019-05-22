//
//  DateFormatters.swift
//  VegetationApp
//
//  Created by Nitin Bhatia on 29/04/19.
//  Copyright © 2019 Nitin Bhatia. All rights reserved.
//

import Foundation

class DateFormatters{
    
    static let shared = DateFormatters()
    
    lazy var dateFormatterNormal : DateFormatter =  {
        [unowned self] in
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        df.locale = Locale(identifier: "en_US_POSIX")
        df.timeZone = TimeZone(secondsFromGMT:0)
        return df
        }()
    
    lazy var dateFormatter2 : DateFormatter =  {
        [unowned self] in
        let df = DateFormatter()
        df.dateFormat = "MMMM dd, yyyy"
        df.locale = Locale(identifier: "en_US_POSIX")
        df.timeZone = TimeZone(secondsFromGMT:0)
        return df
        }()
}
