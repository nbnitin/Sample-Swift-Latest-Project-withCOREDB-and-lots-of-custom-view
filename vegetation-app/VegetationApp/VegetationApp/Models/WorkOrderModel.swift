//
//  HazardTree.swift
//  VegetationApp
//
//  Created by Nitin Bhatia on 02/04/19.
//  Copyright © 2019 Nitin Bhatia. All rights reserved.
//

import Foundation

class WorkOrderModel:Decodable{
    let WorkOrderId: Int
    let FeederId: Int
    let GeoLat: Double
    let GeoLong: Double
    let Status: Int
    let AssignedTo: Int
    let SegamentMiles: Double
    let LocalOffice : String
    let Substation : String
    let OCID : Int
    let Comments : String
    let CreatedBy : Int
    let ModifiedBy : Int?
    let CreatedAt : String
    let ModifiedAt : String?
    let CommitOn : String?
    let WorkOrderAssignTo : String?
    let WorkOrderCreatedBy : String?
    let HazardTreeWithImagesList : [HazardTreeModel]?
    let RowWithTreeList : [CycleTrimModel]?
    let AuditList : [AuditList]?
    
    init(WorkOrderId : Int, FeederId:Int, GeoLat:Double,GeoLong:Double,Status:Int,AssignedTo:Int,SegamentMiles:Double,LocalOffice:String,Substation:String,OCID:Int,Comments:String,CreatedBy:Int,ModifiedAt:String,CommitOn:String,WorkOrderAssignTo:String,WorkOrderCreatedBy:String,HazardTreeWithImagesList:[HazardTreeModel]?,RowWithTreeList:[CycleTrimModel]?,CreatedAt:String,ModifiedBy:Int,AuditList:[AuditList]) {
        self.WorkOrderId = WorkOrderId
        self.FeederId = FeederId
        self.GeoLat = GeoLat
        self.GeoLong = GeoLong
        self.Status = Status
        self.AssignedTo = AssignedTo
        self.SegamentMiles = SegamentMiles
        self.LocalOffice = LocalOffice
        self.Substation = Substation
        self.OCID = OCID
        self.Comments = Comments
        self.CreatedAt = CreatedAt
        self.CreatedBy = CreatedBy
        self.ModifiedAt = ModifiedAt
        self.ModifiedBy = ModifiedBy
        self.CommitOn = CommitOn
        self.WorkOrderAssignTo = WorkOrderAssignTo
        self.WorkOrderCreatedBy = WorkOrderCreatedBy
        self.HazardTreeWithImagesList = HazardTreeWithImagesList
        self.RowWithTreeList = RowWithTreeList
        self.AuditList = AuditList
    }
}
