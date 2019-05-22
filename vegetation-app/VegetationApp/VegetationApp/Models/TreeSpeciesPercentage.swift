//
//  TreeSpeciesPercentage.swift
//  VegetationApp
//
//  Created by Nitin Bhatia on 08/04/19.
//  Copyright © 2019 Nitin Bhatia. All rights reserved.
//

import Foundation

class TreeSpeciesPercentage {
    let id : Int
    var percentage : Int
    var name : String
    
    init(id: Int, name: String, percentage: Int){
        self.id = id
        self.name = name
        self.percentage = percentage
    }
}
