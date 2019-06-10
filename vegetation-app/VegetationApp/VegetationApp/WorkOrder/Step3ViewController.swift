//
//  Step3ViewController.swift
//  VegetationApp
//
//  Created by Nitin Bhatia on 29/05/19.
//  Copyright © 2019 Nitin Bhatia. All rights reserved.
//

import Foundation

class Step3ViewController : UIViewController,UITextFieldDelegate,UITextViewDelegate {
    
    //variables
    var workOrder : WorkOrderModel!
    var selectedData : [AnyObject]! = [AnyObject]()
    var selectedIds : [Int] = [Int]()
    
    //outlets
    @IBOutlet weak var navigation: Navigation!
    @IBOutlet var fieldContainers: [UIView]!
    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var txtVComment: UITextView!
    @IBOutlet weak var txtDate: UITextField!
    let datePickerView:UIDatePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image = UIImage(named: "ico")
        navigation.btnMenu.setImage(image, for: .normal)
        navigation.btnMenu.addTarget(self, action: #selector(back(_:)), for: .touchUpInside)
        
        let today = Date()
        let nextDate = Calendar.current.date(byAdding: .day, value: 10, to: today)
       
        txtDate.text = DateFormatters.shared.dateFormatter2.string(from: nextDate!)
        txtDate.placeholder = "Select Date"
        datePickerView.date = nextDate!
        txtDate.delegate = self
        datePickerView.datePickerMode = .date
        datePickerView.minimumDate = Date()
        txtDate.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: UIControl.Event.valueChanged)
        
        txtVComment.delegate = self
        txtVComment.text = "Comment"
        txtVComment.textColor = UIColor.lightGray
        
        setTitle()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        for vi in fieldContainers{
            vi.addCornerRadius(corners: .allCorners, radius: 10)
            vi.addBorderAround(corners: .allCorners)
            vi.addShadow(offset: CGSize(width:-0.6,height:0.6))
        }
    }
    
    //Mark:- textview delegates
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Comment"
            textView.textColor = UIColor.lightGray
        }
    }
    
   
    func setTitle(){
        var feeders = ""
        var title = ""
        var tmpFeederIDs = [Int]()
        
        if let data = selectedData as? [HazardTreeModel] {
            
            
            _ = data.map({
                // logic to avoid duplicate Feeder Name in work Order title
                if ( !tmpFeederIDs.contains($0.FeederId) ) {
                    feeders += getFeederName(feederId: $0.FeederId) + ", "
                    tmpFeederIDs.append($0.FeederId)
                }
                selectedIds.append($0.HazardTreeID)
            })
            

        } else {
            let tempData = selectedData as! [HotSpotModel]
            _ = tempData.map({
                // logic to avoid duplicate Feeder Name in work Order title
                if ( !tmpFeederIDs.contains($0.FeederId) ) {
                    feeders += getFeederName(feederId: $0.FeederId) + ", "
                    tmpFeederIDs.append($0.FeederId)
                }
                selectedIds.append($0.HotSpotID)
            })
        }
        
        //remove space
        feeders = String(feeders.dropLast())
        //remove comma
        feeders = String(feeders.dropLast())
        
        
        switch workOrder.WorkType {
        case WorkType.HOTSPOT.rawValue:
            title = "HotSpot - " + feeders
            break
        case WorkType.SKYLINE.rawValue:
            title = "Sky Line - " + feeders
            break
        case WorkType.TREEREMOVAL.rawValue:
            title = "Tree Removal - " + feeders
            break
        default:
            break
        }
        txtTitle.text = title
    }
    
    func getFeederName(feederId:Int) -> String {
        let mcd = MasterDataController()
        let tempFeeder = mcd.getRecordById(entityName: .FeederList, id: feederId)["name"] as! String
        return tempFeeder
    }
    
   
    @objc func datePickerValueChanged(_ sender:UIDatePicker) {
        txtDate.text = DateFormatters.shared.dateFormatter2.string(from: sender.date)
    }
    
    //Mark:- pop to vc
    @objc func back(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSubmitAction(_ sender: Any) {
        addWorkOrder()
    }
    
    func addWorkOrder(){
        let apiHandler = ApiHandler()
        
        
        var parameters :[String:Any] = [:]
        parameters["WorkOrderId"] = workOrder.WorkOrderId
        parameters["Status"] = workOrder.Status
        parameters["AssignedTo"] = workOrder.AssignedTo
        parameters["DueDate"] = DateFormatters.shared.dateFormatterNormal.string(from:datePickerView.date)
        parameters["Title"] = txtTitle.text!
        parameters["WorkType"] = workOrder.WorkType
        parameters["CommentBox"] = txtVComment.textColor == UIColor.lightGray ? "" : txtVComment.text!
        parameters["CreatedBy"] = workOrder.CreatedBy
        parameters["Ids"] = (selectedIds.map{String($0)}).joined(separator: ",")
        
        
        apiHandler.sendPostRequestTypeSecond(url: apiUrl.saveWorkOrder,parameters:parameters, completionHandler: { response,error in
            print(response)
            self.view.hideLoad()
            
            if ( error != nil ) {
                self.showAlert(str: (error?.localizedDescription)!)
                return
            }
            
            if((response["Status"] as! Int) != 0){
                
                Toast.showToast(message: response["StatusMessage"]! as! String, position: .BOTTOM, length: .DEFAULT)
                
                self.navigationController?.popToRootViewController(animated: true)
            } else {
                self.showAlert(str: response["StatusMessage"]! as! String)
            }
            //self.callApi()
        })
    }
}
