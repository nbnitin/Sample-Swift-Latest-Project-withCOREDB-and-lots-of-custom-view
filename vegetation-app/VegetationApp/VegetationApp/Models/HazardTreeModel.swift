//
//  HazardTree.swift
//  VegetationApp
//
//  Created by Nitin Bhatia on 02/04/19.
//  Copyright © 2019 Nitin Bhatia. All rights reserved.
//

import Foundation

class HazardTreeModel:Decodable {
    let HazardTreeID: Int
    let WorkOrderID: Int
    let FeederId: Int
    let Prescription: Int
    let TreeSpeciesId: Int
    let DistLine: Double
    let RiskLevel: Int
    let DistBrush: Int
    let Comments: String?
    let GeoLat: Double
    let GeoLong: Double
    let WeatherData: String?
    let Status: Int
    let AssignedTo: Int
    let CreatedBy: Int
    let UpdatedBy: Int
    let CreatedAt: String?
    let UpdatedAt: String?
    let HoursSpend: Int
    let Condition: Int
    let OCAssigned: Int
    let FeederSubstation: String?
    let FeederCustomerCount: Int
    let Diameter: Int
    let AccessToTree: Int
    let EnvCondition: String?
    let CreatedByName: String?
    let AssignedToName: String?
    let Identifier: String?
    let SpeciesName: String?
    let RiskLavelValue: String?
    let StatusName: String?
    let HzTreeImages : [HazardTreeImages]?
    let InSideRow : Bool?
    let AuditList : [AuditList]?
    let PoleId : Int?
    
    init(HazardTreeID: Int,WorkOrderID: Int,FeederId: Int,Prescription: Int,TreeSpeciesId:Int,DistLine: Double,RiskLevel: Int,DistBrush: Int,Comments: String, GeoLat: Double,GeoLong: Double,WeatherData: String,Status: Int,AssignedTo: Int, CreatedBy: Int,UpdatedBy: Int,CreatedAt: String,UpdatedAt: String,HoursSpend: Int, Condition: Int,OCAssigned: Int,FeederSubstation: String,FeederCustomerCount: Int,
         Diameter: Int,AccessToTree: Int,EnvCondition: String,CreatedByName: String,AssignedToName: String,Identifier: String,SpeciesName: String, RiskLavelValue: String,StatusName: String,HzTreeImages : [HazardTreeImages]?,InSideRow:Bool?,AuditList:[AuditList],PoleId:Int?)
    {
        self.InSideRow = InSideRow
        self.HazardTreeID = HazardTreeID
        self.WorkOrderID = WorkOrderID
        self.FeederId = FeederId
        self.Prescription = Prescription
        self.TreeSpeciesId = TreeSpeciesId
        self.DistLine = DistLine
        self.RiskLevel = RiskLevel
        self.DistBrush = DistBrush
        self.Comments = Comments
        self.GeoLat = GeoLat
        self.GeoLong = GeoLong
        self.WeatherData = WeatherData
        self.AssignedTo = AssignedTo
        self.CreatedBy = CreatedBy
        self.UpdatedBy = UpdatedBy
        self.CreatedAt = CreatedAt
        self.UpdatedAt = UpdatedAt
        self.HoursSpend = HoursSpend
        self.Condition = Condition
        self.OCAssigned = OCAssigned
        self.FeederSubstation = FeederSubstation
        self.FeederCustomerCount = FeederCustomerCount
        self.Diameter = Diameter
        self.AccessToTree = AccessToTree
        self.EnvCondition = EnvCondition
        self.CreatedByName = CreatedByName
        self.AssignedToName = AssignedToName
        self.Identifier = Identifier
        self.SpeciesName = SpeciesName
        self.RiskLavelValue = RiskLavelValue
        self.StatusName = StatusName
        self.Status = Status
        self.HzTreeImages = HzTreeImages
        self.AuditList = AuditList
        self.PoleId = PoleId
    }
}

class HazardTreeImages:Decodable,Encodable{
    let hazardTreeImageId: Int
    let uerId: Int
    let rowId: Int?
    let hazardTreeId: Int
    let status: Int
    let description: String?
    let geo_Lat: Double
    let geo_Long: Double
    let weather_Data: String?
    let createdAt: String?
    let createdBy: Int
    let seqNo: Int
    let refGeoLat: Double
    let refGeoLong: Double
    let imageFullPath: String?
    let imageFullPathOriginal : String?
    let imageName : String?
    
    enum CodingKeys: String, CodingKey {
        case HazardTreeImageId = "HazardTreeImageId"
        case UerId = "UerId"
        case RowId = "RowId"
        case HazardTreeId = "HazardTreeId"
        case Status = "Status"
        case Description = "Description"
        case Geo_Lat = "Geo_Lat"
        case Geo_Long = "Geo_Long"
        case Weather_Data = "Weather_Data"
        case CreatedAt = "CreatedAt"
        case CreatedBy = "CreatedBy"
        case SeqNo = "SeqNo"
        case RefGeoLat = "RefGeoLat"
        case RefGeoLong = "RefGeoLong"
        case ImageFullPath = "ImageFullPath"
        case ImageFullPathOriginal = "ImageFullPathOriginal"
        case ImageName = "ImageName"


    }
    
    enum encodingKeys : String,CodingKey {
        case hazardTreeImageId = "hazardTreeImageId"
        case uerId = "uerId"
        case rowId = "rowId"
        case hazardTreeId = "hazardTreeId"
        case geo_Lat = "geo_Lat"
        case geo_Long = "geo_Long"
        case weather_Data = "weather_Data"
        case status = "status"
        case description = "description"
        case createdAt = "createdAt"
        case createdBy = "createdBy"
        case seqNo = "seqNo"
        case refGeoLat = "refGeoLat"
        case refGeoLong = "refGeoLong"
        case imageFullPath = "imageFullPath"
        case imageFullPathOriginal = "imageFullPathOriginal"
        case imageName = "imageName"


    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: encodingKeys.self)
        
        try container.encode(hazardTreeId, forKey: .hazardTreeId)
        try container.encode(uerId, forKey: .uerId)
        try container.encode(rowId, forKey: .rowId)
        try container.encode(hazardTreeImageId, forKey: .hazardTreeImageId)
        try container.encode(geo_Lat, forKey: .geo_Lat)
        try container.encode(geo_Long, forKey: .geo_Long)
        try container.encode(weather_Data, forKey: .weather_Data)
        try container.encode(createdAt,forKey: .createdAt)
        try container.encode(createdBy, forKey: .createdBy)
        try container.encode(seqNo ,forKey:  .seqNo)
        try container.encode(refGeoLat,forKey:  .refGeoLat)
        try container.encode(refGeoLong,forKey: .refGeoLong)
        try container.encode(imageFullPath ,forKey:  .imageFullPath)
        try container.encode(imageFullPathOriginal,forKey: .imageFullPathOriginal)
        try container.encode(imageName,forKey: .imageName)
        try container.encode(status, forKey: .status)
        
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        hazardTreeImageId = try values.decode(Int.self, forKey: .HazardTreeImageId)
        hazardTreeId = try values.decode(Int?.self, forKey: .HazardTreeId)!
        rowId = try values.decode(Int?.self, forKey: .RowId)
        uerId = try values.decode(Int.self, forKey: .UerId)
        description = try values.decode(String?.self, forKey: .Description)
        geo_Lat = try values.decode(Double.self, forKey: .Geo_Lat)
        geo_Long = try values.decode(Double.self, forKey: .Geo_Long)
        weather_Data = try values.decode(String?.self, forKey: .Weather_Data)
        status = try values.decode(Int.self, forKey: .Status)
        createdAt = try values.decode(String.self, forKey: .CreatedAt)
        createdBy = try values.decode(Int.self, forKey: .CreatedBy)
        seqNo = try values.decode(Int.self, forKey: .SeqNo)
        refGeoLat = try values.decode(Double.self, forKey: .RefGeoLat)
        refGeoLong = try values.decode(Double.self, forKey: .RefGeoLong)
        imageFullPath = try values.decode(String?.self, forKey: .ImageFullPath)
        imageFullPathOriginal = try values.decode(String?.self, forKey: .ImageFullPathOriginal)
        imageName = try values.decode(String?.self, forKey: .ImageName)

    }
}
