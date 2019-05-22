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
