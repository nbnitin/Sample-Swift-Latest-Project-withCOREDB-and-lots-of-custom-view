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
    var staticFieldPickerValue : [String] = [String]()
    var staticFieldPickerString : [String] = [String]()
    var isApiSet : Bool = false
    var selectedName : String!
    var selectedId : Int! = -1
    var entityName : String = ""
    var apiNumber = -1
    var staticData : [[String:Any]] = [[String:Any]]()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    @IBInspectable
    var ApiName: Int = -1{
        didSet{
            isApiSet = true
            if (ApiName == 0){
                callApiUser()
            }
        }
    }
    
    @IBInspectable
    var isWorkTypeObject: Bool = false {
        didSet {
            for (key,value) in workTypeString{
                let x = ["id":Int(key) ,"name":value] as [String : Any]
                self.staticData.append(x)
            }
        }
    }
    
    @IBInspectable
    var staticFieldsCommaSeperatedKeys: String = ""{
        didSet{
            self.staticFieldPickerString = staticFieldsCommaSeperatedKeys.components(separatedBy: ",")
        }
    }
    
    @IBInspectable
    var staticFieldsCommaSeperatedValues: String = ""{
        didSet{
            self.staticFieldPickerValue = staticFieldsCommaSeperatedValues.components(separatedBy: ",")
            
            for index in 0 ..< staticFieldPickerString.count {
                let x = ["id":Int(staticFieldPickerValue[index]) ,"name":staticFieldPickerString[index]] as [String : Any]
                self.staticData.append(x)
            }
        }
    }
    
    private func callApiUser(){
        
        let apiHandler = ApiHandler()
        let userData = GetSaveUserDetailsFromUserDefault.getDetials()
        let userId = userData!.UserId
        let url = apiUrl.getContractorsAndLineManList+"\(userId)"
        apiHandler.sendGetRequest(url: url,  completionHandler: { response,error in
            print(response)
            
            if((response["Status"] as! Int) != 0){
                let data = response["KeyValueList"] as! [[String:AnyObject]]
                
                
                for tempData in data{
                    if (tempData["UserId"] as! Int != (GetSaveUserDetailsFromUserDefault.getDetials()!.UserId )) {
                        let x = ["id":Int(tempData["UserId"]! as! NSNumber) ,"name":tempData["FirstName"] as! String,"image":tempData["Image"]] as [String : Any]
                        self.staticData.append(x)
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

