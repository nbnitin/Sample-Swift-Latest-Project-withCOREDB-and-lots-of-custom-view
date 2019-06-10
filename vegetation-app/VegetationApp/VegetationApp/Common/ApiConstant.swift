//
//  ApiConstant.swift
//  VegetationApp
//
//  Created by Nitin Bhatia on 02/04/19.
//  Copyright © 2019 Nitin Bhatia. All rights reserved.
//

import Foundation

let apiUrl = AllUrl()
//192.168.19.10
private let baseUrl = "http://"
//production or local
//private let websiteName = ""

//staging
private let websiteName = ""

//local
//private let hostAt = ""

//staging
private let hostAt = ""

//production
//private let hostAt = ""

private let initial_url = baseUrl + hostAt + websiteName

class AllUrl {
    
    
    //Mark:- Login and all
    var login = initial_url + ""
    var getHazarList = initial_url + ""
    var getCycletrimList = initial_url + ""
    var addHazardTree = initial_url + ""
    var addCycleTrim = initial_url + ""
    var getFeederList = initial_url + ""
    var getRiskLevel = initial_url + ""
    var forgotPassword = initial_url + ""
    var resetPassword = initial_url + ""
    var getWorkOrder = initial_url + ""
    var saveWorkOrderWithCycleTrim = initial_url + ""
    var saveWorkOrderWithHazardTree = initial_url + ""
    var saveWorkOrder = initial_url + ""
    var getUsersList = initial_url + ""
    var addImageToHazardTree = initial_url + ""
    var addImageToCycleTrim = initial_url + ""
    var updateHazardTreeStatus = initial_url + ""
    var updateCycleTrimStatus = initial_url + ""
    var dashboard = initial_url + ""
    var userImage = baseUrl + hostAt + ""
    var getHotSpotList = initial_url + ""
    var addHotSpot = initial_url + ""
    var addHotSpotImage = initial_url + ""
    var updateHotSpotStatus = initial_url + ""
    var editWorkOrder = initial_url + ""
    var getContractorsAndLineManList = initial_url + ""
    var updateNotificationToken = initial_url + ""
    var getWorkOrderSearch = initial_url + ""
    var getHazardTreeSearch = initial_url + ""
    var getCycleTrimSearch = initial_url + ""
    var getHotSpotSearch = initial_url + ""

    //Master Data url
    var getTreeSpeciesList = initial_url + ""
    var getHazardTreeCondition = initial_url + ""
    var getCycleTrimCondition = initial_url + ""
    var getPrescription = initial_url + ""
    var getAccessToTree = initial_url + ""
    var getAccessToLine = initial_url + ""
    var getDiameterAtBreastHeight = initial_url + ""
    var getLineConstruction = initial_url + ""
    var getTreeDensity = initial_url + ""
    var getStatus = initial_url + ""
    var getUserRole = initial_url + ""
    var getPoles = initial_url + ""

}
