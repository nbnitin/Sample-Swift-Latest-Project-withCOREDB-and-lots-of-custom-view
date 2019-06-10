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
    let Title : String?
    let DueDate : String?
    let Status: Int
    let AssignedTo: Int?
    let Comments : String
    let CreatedBy : Int
    let ModifiedBy : Int?
    let CreatedAt : String
    let ModifiedAt : String?
    let CommitOn : String?
    let WorkOrderAssignTo : String?
    let WorkOrderCreatedBy : String?
    let HazardTreeList : [HazardTreeModel]?
    let RowList : [CycleTrimModel]?
    let HotSpotList : [HotSpotModel]?
    let AuditList : [AuditList]?
    let WorkType : Int
    let AssignedToName : String?
    
    init(WorkOrderId : Int,DueDate: String,Title:String, Status:Int,AssignedTo:Int?,Comments:String,CreatedBy:Int,ModifiedAt:String,CommitOn:String,WorkOrderAssignTo:String,WorkOrderCreatedBy:String,HazardTreeList:[HazardTreeModel]?,RowList:[CycleTrimModel]?,HotSpotList:[HotSpotModel],CreatedAt:String,ModifiedBy:Int,AuditList:[AuditList],WorkType:Int,AssignedToName:String?) {
        self.WorkOrderId = WorkOrderId
        self.DueDate = DueDate
        self.Status = Status
        self.AssignedTo = AssignedTo
        self.Title = Title
        self.Comments = Comments
        self.CreatedAt = CreatedAt
        self.CreatedBy = CreatedBy
        self.ModifiedAt = ModifiedAt
        self.ModifiedBy = ModifiedBy
        self.CommitOn = CommitOn
        self.WorkOrderAssignTo = WorkOrderAssignTo
        self.WorkOrderCreatedBy = WorkOrderCreatedBy
        self.HazardTreeList = HazardTreeList
        self.RowList = RowList
        self.AuditList = AuditList
        self.WorkType = WorkType
        self.HotSpotList = HotSpotList
        self.AssignedToName = AssignedToName
    }
}
