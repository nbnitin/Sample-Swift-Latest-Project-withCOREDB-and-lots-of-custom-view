//
//  ImageData.swift
//  VegetationApp
//
//  Created by Nitin Bhatia on 05/04/19.
//  Copyright © 2019 Nitin Bhatia. All rights reserved.
//

import Foundation

class ImageData{
    let Id : Int!
    let Name: Any!
    let Title : String!
    let Location : String
    
    init(Id:Int,Name:Any,Title:String,Location:String = ""){
        self.Id = Id
        self.Name = Name
        self.Title = Title
        self.Location = Location
    }
}
