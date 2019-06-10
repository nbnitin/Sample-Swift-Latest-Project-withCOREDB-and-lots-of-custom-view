//
//  HotSpot.swift
//  VegetationApp
//
//  Created by Nitin Bhatia on 24/05/19.
//  Copyright © 2019 Nitin Bhatia. All rights reserved.
//

import Foundation

class HotSpotModel:Decodable {
    let Title : String?
    let HotSpotID: Int
    let WorkOrderID: Int
    let FeederId: Int
    var HotSpotTreeList : [HotSpotTreeList]?

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
    
    let OCAssigned: Int
    let FeederSubstation: String?
    let FeederCustomerCount: Int
    
    let AccessToTree: Int
    let EnvCondition: String?

    let CreatedByName: String?
    let AssignedToName: String?
    let Identifier: String?
    let SpeciesName: String?
    
    let StatusName: String?
    let HotSpotImages : [HotSpotImages]?
    let AuditList : [AuditList]?
    
    init(Title:String?,HotSpotID: Int,WorkOrderID: Int,FeederId: Int,TreeSpeciesId:String,Comments: String, GeoLat: Double,GeoLong: Double,WeatherData: String,Status: Int,AssignedTo: Int, CreatedBy: Int,UpdatedBy: Int,CreatedAt: String,UpdatedAt: String, Condition: Int,OCAssigned: Int,FeederSubstation: String,FeederCustomerCount: Int,AccessToTree: Int,CreatedByName: String,AssignedToName: String,Identifier: String,SpeciesName: String, StatusName: String,HotSpotImages:[HotSpotImages]?,AuditList:[AuditList],HotSpotTreeList : [HotSpotTreeList],EnvCondition:String)
    {
        self.Title = Title
        self.HotSpotID = HotSpotID
        self.WorkOrderID = WorkOrderID
        self.FeederId = FeederId
        self.HotSpotTreeList = HotSpotTreeList
       
        self.Comments = Comments
        self.GeoLat = GeoLat
        self.GeoLong = GeoLong
        self.WeatherData = WeatherData
        self.AssignedTo = AssignedTo
        self.CreatedBy = CreatedBy
        self.UpdatedBy = UpdatedBy
        self.CreatedAt = CreatedAt
        self.UpdatedAt = UpdatedAt
        self.OCAssigned = OCAssigned
        self.FeederSubstation = FeederSubstation
        self.FeederCustomerCount = FeederCustomerCount
        self.AccessToTree = AccessToTree
        self.CreatedByName = CreatedByName
        self.AssignedToName = AssignedToName
        self.Identifier = Identifier
        self.SpeciesName = SpeciesName
        self.StatusName = StatusName
        self.Status = Status
        self.HotSpotImages = HotSpotImages
        self.AuditList = AuditList
        
        self.EnvCondition = EnvCondition
    }
}

class HotSpotTreeList : Decodable,Encodable{
    
    let hotSpotTreeId : Int
    let hotSpotId : Int
    let speciesId : Int
    let createdBy : Int
    let createdAt : String?
    let createdByName : String?
    let speciesName : String?
    
    enum CodingKeys: String, CodingKey {
        case hotSpotTreeId = "HotSpotTreeId"
        case hotSpotID = "HotSpotID"
        case speciesID = "SpeciesID"
        case createdBy = "CreatedBy"
        case createdAt = "CreatedAt"
        case createdByName = "CreatedByName"
        case speciesName = "SpeciesName"
    }
    
    
    enum encodingKeys : String,CodingKey {
        case hotSpotTreeId = "hotSpotTreeId"
        case hotSpotID = "hotSpotId"
        case speciesID = "speciesId"
        case createdBy = "createdBy"
        case createdAt = "createdAt"
        case createdByName = "createdByName"
        case speciesName = "speciesName"
    }
    
    
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: encodingKeys.self)
        
        try container.encode(hotSpotTreeId, forKey: .hotSpotTreeId)
        try container.encode(hotSpotId, forKey: .hotSpotID)
        try container.encode(speciesId, forKey: .speciesID)
        try container.encode(createdBy, forKey: .createdBy)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(createdByName, forKey: .createdByName)
        try container.encode(speciesName, forKey: .speciesName)
    }
    
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        hotSpotTreeId = try values.decode(Int.self, forKey: .hotSpotTreeId)
        hotSpotId = try values.decode(Int.self, forKey: .hotSpotID)
        speciesId = try values.decode(Int.self, forKey: .speciesID)
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


class HotSpotImages:Decodable,Encodable{
    let hotSpotImageId: Int
    let userId: Int
    let hotSpotId: Int
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
        case HotSpotImageId = "HotSpotImageId"
        case UserId = "UserId"
        case HotSpotId = "HotSpotId"
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
        case hotSpotImageId = "hotSpotImageId"
        case userId = "userId"
        case hotSpotId = "hotSpotId"
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
        
        try container.encode(hotSpotId, forKey: .hotSpotId)
        try container.encode(userId, forKey: .userId)
        try container.encode(hotSpotImageId, forKey: .hotSpotImageId)
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
        
        hotSpotImageId = try values.decode(Int.self, forKey: .HotSpotImageId)
        hotSpotId = try values.decode(Int?.self, forKey: .HotSpotId)!
        userId = try values.decode(Int.self, forKey: .UserId)
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
