//
//  AuditList.swift
//  VegetationApp
//
//  Created by Nitin Bhatia on 29/04/19.
//  Copyright © 2019 Nitin Bhatia. All rights reserved.
//

import Foundation

class AuditList:Decodable,Encodable{
    let Status: String
    let ActionDate: String
    let ActionBy: String
    
    init(Status:String,ActionDate:String,ActionBy:String) {
        self.Status = Status
        self.ActionBy = ActionBy
        self.ActionDate = ActionDate
    }
}
