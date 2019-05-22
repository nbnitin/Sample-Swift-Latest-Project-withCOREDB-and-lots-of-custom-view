//
//  DropDownField.swift
//  VegetationApp
//
//  Created by Nitin Bhatia on 04/04/19.
//  Copyright © 2019 Nitin Bhatia. All rights reserved.
//


import UIKit
@IBDesignable
class PopUpPickers: UITextField {
    
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    var staticFieldPickerValue : [String] = []
    var isApiSet : Bool = false
    var selectedName : String!
    var selectedId : Int! = -1
    var entityName : String = ""
    var apiNumber = -1
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    @IBInspectable
    var ApiName: Int {
        set {
            apiNumber = newValue
        }
        get {
            return apiNumber
        }
    }
    
    @IBInspectable
    var staticFieldsCommaSeperatedKeys: String = ""{
        didSet{
            self.staticFieldPickerValue = staticFieldsCommaSeperatedKeys.components(separatedBy: ",")
        }
    }
    
//    @IBInspectable
//    var staticFieldsCommaSeperatedValues: String = ""{
//        
//    }
    
    private func callApiUser(){
        
        let apiHandler = ApiHandler()
        let userData = GetSaveUserDetailsFromUserDefault.getDetials()
        let userId = userData!.UserId
        let url = apiUrl.getUsersList+"\(userId)"
        apiHandler.sendGetRequest(url: url,  completionHandler: { response,error in
            print(response)
            
            if((response["Status"] as! Int) != 0){
                let data = response["KeyValueList"] as! [[String:AnyObject]]
                
                
                for tempData in data{
                    if (tempData["UserId"] as! Int != (GetSaveUserDetailsFromUserDefault.getDetials()!.UserId )) {
                       
                    }
                }
                
            } else {
                // self.showAlert(str: response["StatusMessage"]! as! String)
            }
            
        })
    }
    
    
    @IBInspectable
    //newValue is default setter property defined in swift...
    var EntityName: String {
        set{
            entityName = newValue
        }
        get {
            return entityName
        }
    }
    
   
    
    
    
}

extension PopUpPickers{
    func setText(EntityName:EntityName,recId:Int) {
        let mcd = MasterDataController()
        self.text = mcd.getRecordById(entityName: EntityName, id: recId)["name"] as? String
        self.selectedName = self.text
        self.selectedId = recId
    }
}

