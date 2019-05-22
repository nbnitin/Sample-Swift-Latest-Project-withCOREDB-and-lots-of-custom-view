//
//  DropDownField.swift
//  VegetationApp
//
//  Created by Nitin Bhatia on 04/04/19.
//  Copyright © 2019 Nitin Bhatia. All rights reserved.
//

@objc protocol DropDownFieldDelegate {
    @objc optional func doneSelection(selected : Bool)
    @objc optional func valueSelectedFrom(obj:DropDownField)
}


import UIKit
@IBDesignable
class DropDownField: UITextField,UIPickerViewDelegate,UIPickerViewDataSource {

    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    var picker1 : UIPickerView = UIPickerView()
    var picker1Text = ["01","02","03","04"]
    var picker1Value : [Int] = []
    var staticFieldPickerValue : [String] = []
    var toolBar1 : UIToolbar = UIToolbar()
    var selectedIndex : Int = -1
    var apiData : [[String:Any]] = [[:]]
    var isApiSet : Bool = false
    var delegateDropDown : DropDownFieldDelegate!
    var selectedName : String!
    var selectedId : Int! = -1
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setTextField(txt: self, picker: picker1, toolBar: toolBar1)
    }
    
    func getData(obj:DropDownField)->Any{
        
        if ( isApiSet ) {
            return apiData[selectedIndex]["UserId"] as Any
        }
        if ( selectedIndex < 0 && !isApiSet ) {
            let text = obj.text
            let index = picker1Text.firstIndex(of: text!)
            selectedIndex = index!
        }
        if ( staticFieldPickerValue.count > 0 ) {
            return staticFieldPickerValue[selectedIndex]
        }
        return picker1Value[selectedIndex]
    }
    
    @IBInspectable
    var ApiName: Int = -1{
        didSet{
            isApiSet = true
            if (ApiName == 0){
                callApiUser()
           } //else if(ApiName == 1){
//                callApiRiskLevel()
//            }
        }
    }
    
    @IBInspectable
    var staticFieldsCommaSeperatedKeys: String = ""{
        didSet{
            self.staticFieldPickerValue = staticFieldsCommaSeperatedKeys.components(separatedBy: ",")
        }
    }
    
    @IBInspectable
    var staticFieldsCommaSeperatedValues: String = ""{
        didSet{
            self.picker1Text = staticFieldsCommaSeperatedValues.components(separatedBy: ",")
        }
    }
    
    private func callApiUser(){
        
        let apiHandler = ApiHandler()
        let userData = GetSaveUserDetailsFromUserDefault.getDetials()
        let userId = userData!.UserId
        let url = apiUrl.getUsersList+"\(userId)"
        apiHandler.sendGetRequest(url: url,  completionHandler: { response,error in
            print(response)
            
            if((response["Status"] as! Int) != 0){
                let data = response["KeyValueList"] as! [[String:AnyObject]]
                self.picker1Text.removeAll()
                self.apiData.removeAll()
                
                for tempData in data{
                    if (tempData["UserId"] as! Int != (GetSaveUserDetailsFromUserDefault.getDetials()!.UserId )) {
                        self.picker1Text.append(tempData["FirstName"] as! String)
                        self.picker1Value.append(tempData["UserId"] as! Int)
                        self.apiData.append(tempData)
                    }
                }
                
            } else {
               // self.showAlert(str: response["StatusMessage"]! as! String)
            }
            
        })
    }
//
//    private func callApiRiskLevel(){
//        let apiHandler = ApiHandler()
////        let userData = GetSaveUserDetailsFromUserDefault.getDetials()
////        let userId = userData!.UserId
//        let url = apiUrl.getRiskLevel
//        apiHandler.sendGetRequest(url: url,  completionHandler: { response,error in
//            print(response)
//            
//            if((response["Status"] as! Int) != 0){
//                do{
//                    let data = response["KeyValueList"] as! [[String:AnyObject]]
//                    self.picker1Text.removeAll()
//                    for tempData in data{
//                        let jsonData = try? JSONSerialization.data(withJSONObject: tempData, options: [])
//                        let model = try JSONDecoder().decode(RiskLevel.self, from: jsonData!)
//                        self.picker1Text.append(model.Name)
//                        self.riskLevelData.append(model)
//                    }
//                } catch{
//                    print("json error: \(error)")
//                }
//            } else {
//                // self.showAlert(str: response["StatusMessage"]! as! String)
//            }
//            
//        })
//    }
//    

    
    @IBInspectable
    //newValue is default setter property defined in swift...
    var EntityName: String = ""{
        didSet{
            let mcd = MasterDataController()
            let data = mcd.getData(entityName: EntityName)
            picker1Text.removeAll()
            for tempData in data{
                picker1Text.append(tempData["name"] as! String)
                picker1Value.append(tempData["id"] as! Int)
            }
        }
    }

    //use to update view, can be called by setNeedsDisplay
//    override func draw(_ rect: CGRect) {
//
//    }

    //Mark:- call on done button in picker toolbar
    @objc func donePicker(_ sender:UIBarButtonItem){
        
//            if ( self.text == "" ) {
        self.text = picker1Text[self.picker1.selectedRow(inComponent: 0)]
        self.selectedIndex = self.picker1.selectedRow(inComponent: 0)
       // self.delegateDropDown.doneSelection!(selected: true)
        if (delegateDropDown != nil) {
            self.delegateDropDown.valueSelectedFrom?(obj: self)
        }
           // }
      
        
        self.endEditing(true)
    }
    
    //Mark:- call on cancle button in picker toolbar
    @objc func cancelPicker(_ sender:UIBarButtonItem){
        self.text = ""
        self.endEditing(true)
        self.selectedIndex = -1
    }
    
    //Mark:- Set pickerview and toolbar to textbox
    func setTextField(txt: UITextField, picker: UIPickerView, toolBar: UIToolbar ){
        let screenSize: CGRect = UIScreen.main.bounds

        picker.frame =  CGRect(x:0, y:0, width:screenSize.width, height:300)
        picker.backgroundColor = .white
        
        picker.showsSelectionIndicator = true
        picker.delegate = self
        picker.dataSource = self
        
        
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 67/255, green: 67/255, blue: 67/255, alpha: 1)
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action:  #selector(donePicker(_:)))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let title = UIBarButtonItem(title: txt.placeholder, style: .plain, target: nil, action: nil)
        title.tintColor = UIColor.lightGray
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItem.Style.plain, target: self, action: #selector(cancelPicker(_:)))
        
        
        toolBar.setItems([cancelButton, spaceButton,title,spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        txt.inputView = picker
        txt.inputAccessoryView = toolBar
        
    }
    
    
    //Mark:- Pickerview
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
            return picker1Text.count
       
    }
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
            return picker1Text[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
       
        selectedIndex = row
        self.text = picker1Text[row]
        
    }


}
