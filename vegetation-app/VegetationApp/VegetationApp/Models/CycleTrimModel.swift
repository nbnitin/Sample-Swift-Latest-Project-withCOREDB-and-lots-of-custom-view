//
//  CycleTrimModel.swift
//  VegetationApp
//
//  Created by Nitin Bhatia on 02/04/19.
//  Copyright © 2019 Nitin Bhatia. All rights reserved.
//

import Foundation

class CycleTrimModel:Decodable,Encodable{
    let title : String?
    let rowId: Int
    let workOrderId: Int?
    var feederId: Int
    let comments: String?
    let geoLat: Double
    let geoLong: Double
    let weatherData: String?
    let status: Int
    let assignedTo: Int
    let createdBy: Int
    let updatedBy: Int
    let createdAt: String?
    let updatedAt: String?
    let segamentMiles: Int
    let localOffice: String?
    let substation: String?
    let ocAssigned: Int
    let lastTrimAt: String?
    let nextTrimAt: String?
    let lastTrimHeight: Int
    let treeDensity: Int
    let growth : Int
    let hoursSpent: Int
    let feederSubstation: String?
    let feederCustomerCount: Int
    let clearance: Double
    let lineContruction: Int?
    let accessToLine: Int
    let createdByName: String?
    let assignedToName: String?
    let identifier: String?
    let statusName: String?
    let ocAssignedToName: String?
    let currentCondition: Int
    var rowTreeList : [RowTreeList]?
    let rwTreeImages : [CycleTrimImages]?
    let speciesName : String?
    let auditList : [AuditList]?
    let poleId : Int?
    
    enum CodingKeys: String, CodingKey {
        case title = "Title"
        case rowId = "ROWDId"
        case workOrderId = "WorkOrderId"
        case feederId = "FeederId"
        case comments = "Comments"
        case geoLat = "GeoLat"
        case geoLong = "GeoLong"
        case weatherData = "WeatherData"
        
        case status = "Status"
        case assignedTo = "AssignedTo"
        case createdBy = "CreatedBy"
        case localOffice = "LocalOffice"
        case substation = "Substation"
        case ocAssigned = "OCAssigned"
        
        
        case lastTrimAt = "LastTrimAt"
        case nextTrimAt = "NextTrimAt"
        case lastTrimHeight = "LastTrimHeight"
        case treeDensity = "TreeDensity"
        case growth = "Growth"
        case hoursSpent = "HoursSpent"
        case feederSubstation = "FeederSubstation"
        
        case feederCustomerCount = "FeederCustomerCount"
        case clearance = "Clearance"
        case lineContruction = "LineContruction"
        case accessToLine = "AccessToLine"
        case createdByName = "CreatedByName"
        case assignedToName = "AssignedToName"
        case identifier = "Identifier"
        
        
        case statusName = "StatusName"
        case ocAssignedToName = "OCAssignedToName"
        case currentCondition = "CurrentCondition"
        case rowTreeList = "RowTreeList"
        
        case updatedBy = "UpdatedBy"
        case createdAt = "CreatedAt"
        case updatedAt = "UpdatedAt"
        case segamentMiles = "SegamentMiles"
        case rwTreeImages = "RwTreeImages"
        case speciesName = "SpeciesName"
        case auditList = "AuditList"
        
        case poleId = "PoleId"
    }
    
    
    enum encodingKeys : String,CodingKey {
        case title = "title"
        case rowId = "rowId"
        case workOrderId = "workOrderId"
        case feederId = "feederId"
        case comments = "comments"
        case geoLat = "geoLat"
        case geoLong = "geoLong"
        case weatherData = "weatherData"
        
        case status = "status"
        case assignedTo = "assignedTo"
        case createdBy = "createdBy"
        case localOffice = "localOffice"
        case substation = "substation"
        case ocAssigned = "ocAssigned"
        
        
        case lastTrimAt = "lastTrimAt"
        case nextTrimAt = "nextTrimAt"
        case lastTrimHeight = "lastTrimHeight"
        case treeDensity = "treeDensity"
        case growth = "growth"
        case hoursSpent = "hoursSpent"
        case feederSubstation = "feederSubstation"
        
        case feederCustomerCount = "feederCustomerCount"
        case clearance = "clearance"
        case lineContruction = "lineContruction"
        case accessToLine = "accessToLine"
        case createdByName = "createdByName"
        case assignedToName = "assignedToName"
        case identifier = "identifier"
        
        
        case statusName = "statusName"
        case ocAssignedToName = "ocAssignedToName"
        case currentCondition = "currentCondition"
        case rowTreeList = "rowTreeList"
        
        case updatedBy = "updatedBy"
        case createdAt = "createdAt"
        case updatedAt = "updatedAt"
        case segamentMiles = "segamentMiles"
        case rwTreeImages = "rwTreeImages"
        case speciesName = "speciesName"
        case auditList = "auditList"
        
        case poleId = "poleId"
    }
    
    
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: encodingKeys.self)
        try container.encode(title, forKey: .title)

        try container.encode(rowId, forKey: .rowId)
        try container.encode(workOrderId, forKey: .workOrderId)
        try container.encode(feederId, forKey: .feederId)
        try container.encode(comments, forKey: .comments)
        try container.encode(geoLat, forKey: .geoLat)
        try container.encode(geoLong, forKey: .geoLong)
        try container.encode(weatherData, forKey: .weatherData)
        
        try container.encode(status, forKey: .status)
        try container.encode(assignedTo, forKey: .assignedTo)
        try container.encode(createdBy, forKey: .createdBy)
        try container.encode(localOffice, forKey: .localOffice)
        try container.encode(substation, forKey: .substation)
        try container.encode(ocAssigned, forKey: .ocAssigned)
        
        try container.encode(lastTrimAt, forKey: .lastTrimAt)
        try container.encode(nextTrimAt, forKey: .nextTrimAt)
        try container.encode(lastTrimHeight, forKey: .lastTrimHeight)
        try container.encode(treeDensity, forKey: .treeDensity)
        try container.encode(growth, forKey: .growth)
        try container.encode(hoursSpent, forKey: .hoursSpent)
        try container.encode(feederSubstation, forKey: .feederSubstation)
        try container.encode(feederCustomerCount, forKey: .feederCustomerCount)
        try container.encode(clearance, forKey: .clearance)
        try container.encode(lineContruction, forKey: .lineContruction)
        try container.encode(accessToLine, forKey: .accessToLine)
        try container.encode(createdByName, forKey: .createdByName)
        try container.encode(assignedToName, forKey: .assignedToName)
        try container.encode(identifier, forKey: .identifier)
        
        try container.encode(statusName, forKey: .statusName)
        try container.encode(ocAssignedToName, forKey: .ocAssignedToName)
        try container.encode(currentCondition, forKey: .currentCondition)
        try container.encode(speciesName, forKey: .speciesName)
        try container.encode(updatedBy, forKey: .updatedBy)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
        try container.encode(segamentMiles, forKey: .segamentMiles)
        try container.encode(rwTreeImages, forKey: .rwTreeImages)
        try container.encode(auditList, forKey: .auditList)
        
        try container.encode(poleId, forKey: .poleId)

        
    }

    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        title =  try values.decode(String?.self, forKey: .title)

        rowId = try values.decode(Int.self, forKey: .rowId)
        workOrderId = try values.decode(Int?.self, forKey: .workOrderId)
        feederId = try values.decode(Int.self, forKey: .feederId)
        comments = try values.decode(String?.self, forKey: .comments)
        geoLat = try values.decode(Double.self, forKey: .geoLat)
        geoLong = try values.decode(Double.self, forKey: .geoLong)
        weatherData = try values.decode(String?.self, forKey: .weatherData)
        
        status = try values.decode(Int.self, forKey: .status)
        assignedTo = try values.decode(Int.self, forKey: .assignedTo)
        createdBy = try values.decode(Int.self, forKey: .createdBy)
        localOffice = try values.decode(String?.self, forKey: .localOffice)
        substation = try values.decode(String?.self, forKey: .substation)
        ocAssigned = try values.decode(Int.self, forKey: .ocAssigned)
        
        lastTrimAt = try values.decode(String?.self, forKey: .lastTrimAt)
        nextTrimAt = try values.decode(String?.self, forKey: .nextTrimAt)
        lastTrimHeight = try values.decode(Int.self, forKey: .lastTrimHeight)
        treeDensity = try values.decode(Int.self, forKey: .treeDensity)
        growth = try values.decode(Int.self, forKey: .growth)
        hoursSpent = try values.decode(Int.self, forKey: .hoursSpent)
        feederSubstation = try values.decode(String?.self, forKey: .feederSubstation)
        
        feederCustomerCount = try values.decode(Int.self, forKey: .feederCustomerCount)
        clearance = try values.decode(Double.self, forKey: .clearance)
        lineContruction = try values.decode(Int.self, forKey: .lineContruction)
        accessToLine = try values.decode(Int.self, forKey: .accessToLine)
        createdByName = try values.decode(String?.self, forKey: .createdByName)
        assignedToName = try values.decode(String?.self, forKey: .assignedToName)
        identifier = try values.decode(String.self, forKey: .identifier)
        
        statusName = try values.decode(String?.self, forKey: .statusName)
        ocAssignedToName = try values.decode(String?.self, forKey: .ocAssignedToName)
        currentCondition = try values.decode(Int.self, forKey: .currentCondition)
        rowTreeList = try values.decode([RowTreeList]?.self, forKey: .rowTreeList)
        updatedBy = try values.decode(Int.self, forKey: .updatedBy)
        createdAt = try values.decode(String?.self, forKey: .createdAt)
        updatedAt = try values.decode(String?.self, forKey: .updatedAt)
        segamentMiles = try values.decode(Int.self, forKey: .segamentMiles)
        rwTreeImages = try values.decode([CycleTrimImages]?.self, forKey: .rwTreeImages)
        speciesName = try values.decode(String?.self, forKey: .speciesName)
        auditList = try values.decode([AuditList]?.self, forKey: .auditList)
        
        poleId = try values.decode(Int?.self, forKey: .poleId)

    }
    
        
        
    
    
//    init(ROWDId: Int,WorkOrderId: Int?,FeederId: Int,Comments: String?,GeoLat: Double,GeoLong: Double,WeatherData: String?,Status: Int,AssignedTo: Int,CreatedBy: Int,UpdatedBy: Int,CreatedAt: String?,UpdatedAt: String?,SegamentMiles: Int,LocalOffice: String?,Substation: String?,OCAssigned: Int,LastTrimAt: String?,NextTrimAt: String?,LastTrimHeight: Int,TreeDensity: Int,Growth : Int,HoursSpent: Int,FeederSubstation: String?,FeederCustomerCount: Int,Clearance: Int,LineContruction: Int?,AccessToLine: Int,CreatedByName: String?,AssignedToName: String?,Identifier: String?,StatusName: String?,OCAssignedToName: String,CurrentCondition:Int,RowTreeList:[RowTreeList]){
//        self.ROWDId = ROWDId
//        self.WorkOrderId = WorkOrderId
//        self.FeederId = FeederId
//        self.Comments = Comments
//        self.GeoLong = GeoLong
//        self.GeoLat = GeoLat
//        self.WeatherData = WeatherData
//        self.Status = Status
//        self.AssignedTo = AssignedTo
//        self.CreatedBy = CreatedBy
//        self.UpdatedBy = UpdatedBy
//        self.CreatedAt = CreatedAt
//        self.UpdatedAt = UpdatedAt
//        self.SegamentMiles = SegamentMiles
//        self.LocalOffice = LocalOffice
//        self.Substation = Substation
//        self.OCAssigned = OCAssigned
//        self.LastTrimAt = LastTrimAt
//        self.NextTrimAt = NextTrimAt
//        self.LastTrimHeight = LastTrimHeight
//        self.TreeDensity = TreeDensity
//        self.Growth = Growth
//        self.HoursSpent = HoursSpent
//        self.FeederSubstation = FeederSubstation
//        self.FeederCustomerCount = FeederCustomerCount
//        self.Clearance = Clearance
//        self.LineContruction = LineContruction
//        self.AccessToLine = AccessToLine
//        self.CreatedByName = CreatedByName
//        self.AssignedToName = AssignedToName
//        self.Identifier = Identifier
//        self.StatusName = StatusName
//        self.OCAssignedToName = OCAssignedToName
//        self.CurrentCondition = CurrentCondition
//        self.RowTreeList = RowTreeList
//    }
}

class RowTreeList : Decodable,Encodable{
    
        let rowTreeId : Int
        let rowId : Int
        let speciesId : Int
        let percentage : Int
        let createdBy : Int
        let createdAt : String?
        let createdByName : String?
        let speciesName : String?
    
    enum CodingKeys: String, CodingKey {
        case rowTreeId = "RowTreeId"
        case roWID = "RoWID"
        case speciesID = "SpeciesID"
        case percentage = "Percentage"
        case createdBy = "CreatedBy"
        case createdAt = "CreatedAt"
        case createdByName = "CreatedByName"
        case speciesName = "SpeciesName"
    }
    
    
    enum encodingKeys : String,CodingKey {
        case rowTreeId = "rowTreeId"
        case rowID = "rowId"
        case speciesID = "speciesId"
        case percentage = "percentage"
        case createdBy = "createdBy"
        case createdAt = "createdAt"
        case createdByName = "createdByName"
        case speciesName = "speciesName"
    }
    
    
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: encodingKeys.self)
        
        try container.encode(rowTreeId, forKey: .rowTreeId)
        try container.encode(rowId, forKey: .rowID)
        try container.encode(speciesId, forKey: .speciesID)
        try container.encode(percentage, forKey: .percentage)
        try container.encode(createdBy, forKey: .createdBy)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(createdByName, forKey: .createdByName)
        try container.encode(speciesName, forKey: .speciesName)
    }
    
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        rowTreeId = try values.decode(Int.self, forKey: .rowTreeId)
        rowId = try values.decode(Int.self, forKey: .roWID)
        speciesId = try values.decode(Int.self, forKey: .speciesID)
        percentage = try values.decode(Int.self, forKey: .percentage)
        createdBy = try values.decode(Int.self, forKey: .createdBy)
        createdAt = try values.decode(String?.self, forKey: .createdAt)
        createdByName = try values.decode(String?.self, forKey: .createdByName)
        speciesName = try values.decode(String?.self, forKey: .speciesName)
    }
    
        
//        init(RowTreeId: Int, RoWID: Int, SpeciesID: Int,Percentage:Int,CreatedBy:Int,CreatedAt:String,CreatedByName:String,SpeciesName:String){
//            self.RowTreeId = RowTreeId
//            self.RoWID = RoWID
//            self.SpeciesID = SpeciesID
//            self.Percentage = Percentage
//            self.CreatedBy = CreatedBy
//            self.CreatedAt = CreatedAt
//            self.SpeciesName = SpeciesName
//            self.CreatedByName = CreatedByName
//        }
    

}

class CycleTrimImages:Decodable,Encodable{
    let rowTreeImageId: Int?
   // let uerId: Int?
    let rowdId: Int?
//    let status: Int?
    let description: String?
//    let geo_Lat: Double?
//    let geo_Long: Double?
//    let weather_Data: String?
    let createdAt: String?
//    let createdBy: Int?
//    let seqNo: Int?
//    let refGeoLat: Double?
//    let refGeoLong: Double?
    let imageFullPath: String?
    let imageFullPathOriginal: String?

    
    enum CodingKeys: String, CodingKey {
        case rowTreeImageId = "RowTreeImageID"
        //case UerId = "UerId"
        case RowdId = "RowdId"
//        case Status = "Status"
       case Description = "Description"
//        case Geo_Lat = "Geo_Lat"
//        case Geo_Long = "Geo_Long"
//        case Weather_Data = "Weather_Data"
        case CreatedAt = "CreatedAt"
//        case CreatedBy = "CreatedBy"
//        case SeqNo = "SeqNo"
//        case RefGeoLat = "RefGeoLat"
//        case RefGeoLong = "RefGeoLong"
        case ImageFullPath = "ImageFullPath"
        case ImageFullPathOriginal = "ImageFullPathOriginal"

    }
    
    enum encodingKeys : String,CodingKey {
        case rowTreeImageId = "rowTreeImageId"
       // case uerId = "uerId"
        case rowdId = "rowdId"
//        case geo_Lat = "geo_Lat"
//        case geo_Long = "geo_Long"
//        case weather_Data = "weather_Data"
//        case status = "status"
       case description = "description"
        case createdAt = "createdAt"
//        case createdBy = "createdBy"
//        case seqNo = "seqNo"
//        case refGeoLat = "refGeoLat"
//        case refGeoLong = "refGeoLong"
        case imageFullPath = "imageFullPath"
        case imageFullPathOriginal = "imageFullPathOriginal"

    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: encodingKeys.self)
        
      //  try container.encode(uerId, forKey: .uerId)
        try container.encode(rowdId, forKey: .rowdId)
        try container.encode(rowTreeImageId, forKey: .rowTreeImageId)
//        try container.encode(geo_Lat, forKey: .geo_Lat)
//        try container.encode(geo_Long, forKey: .geo_Long)
//        try container.encode(weather_Data, forKey: .weather_Data)
        try container.encode(createdAt,forKey: .createdAt)
        try container.encode(description, forKey: .description)
//        try container.encode(seqNo ,forKey:  .seqNo)
//        try container.encode(refGeoLat,forKey:  .refGeoLat)
//        try container.encode(refGeoLong,forKey: .refGeoLong)
        try container.encode(imageFullPath ,forKey:  .imageFullPath)
        try container.encode(imageFullPathOriginal ,forKey:  .imageFullPathOriginal)

       // try container.encode(status, forKey: .status)
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        rowTreeImageId = try values.decode(Int?.self, forKey: .rowTreeImageId)
        rowdId = try values.decode(Int?.self, forKey: .RowdId)
       // uerId = try values.decode(Int?.self, forKey: .UerId)
        description = try values.decode(String?.self, forKey: .Description)
//        geo_Lat = try values.decode(Double?.self, forKey: .Geo_Lat)
//        geo_Long = try values.decode(Double?.self, forKey: .Geo_Long)
//        weather_Data = try values.decode(String?.self, forKey: .Weather_Data)
//        status = try values.decode(Int?.self, forKey: .Status)
        createdAt = try values.decode(String?.self, forKey: .CreatedAt)
//        createdBy = try values.decode(Int?.self, forKey: .CreatedBy)
//        seqNo = try values.decode(Int?.self, forKey: .SeqNo)
//        refGeoLat = try values.decode(Double?.self, forKey: .RefGeoLat)
//        refGeoLong = try values.decode(Double?.self, forKey: .RefGeoLong)
        imageFullPath = try values.decode(String?.self, forKey: .ImageFullPath)
        imageFullPathOriginal = try values.decode(String?.self, forKey: .ImageFullPathOriginal)

    }
}


extension Encodable {
    var dictionary: [String: Any]! {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
}
