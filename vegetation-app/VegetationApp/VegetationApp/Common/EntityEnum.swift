//
//  EntityEnum.swift
//  VegetationApp
//
//  Created by Nitin Bhatia on 04/04/19.
//  Copyright © 2019 Nitin Bhatia. All rights reserved.
//

import Foundation

enum EntityName:String,CaseIterable {
    
    case AccessToTree = "AccessToTree"
    case AccessToLine = "AccessToLine"
    case CurrentConditionCycleTrim = "CurrentConditionCycleTrim"
    case CurrentConditionHazardTree = "CurrentConditionHazardTree"
    case DiameterAtBreastHeight = "DiameterAtBreastHeight"
    case FeederList = "FeederList"
    case LineConstruction = "LineConstruction"
    case Prescription = "Prescription"
    case RiskLevel = "RiskLevel"
    case TreeDensity = "TreeDensity"
    case TreeSpecies = "TreeSpecies"
    case Status = "Status"
    case UserRole = "UserRole"
    case Poles = "Poles"
}

enum WorkType: Int{
    case HOTSPOT = 1
    case SKYLINE = 2
    case TREEREMOVAL = 3
}

enum filterTypePrescription: String{
    case SkyLine = "Skyline"
    case TreeRemoval = "Tree Removal"
}

enum ModuleType : Int {
    case HAZARDTREE = 1
    case CYCLETRIM = 2
    case HOTSPOT = 3
    case WORKORDER = 4
}


let workTypeString : [Int:String] = [1:"Hot Spot",2:"Skyline",3:"Tree Removal"]
let workTypeValue : [Int] = [1,2,3]
