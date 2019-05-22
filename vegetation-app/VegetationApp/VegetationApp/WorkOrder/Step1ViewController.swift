//
//  Step1ViewController.swift
//  VegetationApp
//
//  Created by Nitin Bhatia on 01/04/19.
//  Copyright © 2019 Nitin Bhatia. All rights reserved.
//

import UIKit

class Step1ViewController: UIViewController,DropDownFieldDelegate,UITextFieldDelegate {
    
    //variables
    var nextTag = 10
    
    //outlets
    @IBOutlet var textBoxContainers: [UIView]!
    @IBOutlet weak var txtSegementMiles: UITextField!
    @IBOutlet weak var txtFeeder: DropDownField!
    @IBOutlet weak var txtAssignedTo: DropDownField!
    @IBOutlet weak var txtOrderNo: UITextField!
    @IBOutlet weak var navigationBar: Navigation!
    
    //Mark:- call on load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setting views look
        for vi in textBoxContainers{
            vi.addCornerRadius(corners: .allCorners, radius: 10)
            vi.addBorderAround(corners: .allCorners)
            vi.addShadow(offset: CGSize(width:-0.6,height:0.6))
        }

        //setting navigation button icon
        let image = UIImage(named: "ico")
        navigationBar.btnMenu.setImage(image, for: .normal)
        navigationBar.btnMenu.addTarget(self, action: #selector(back(_:)), for: .touchUpInside)
        
        txtFeeder.delegateDropDown = self
        txtAssignedTo.delegateDropDown = self
        txtSegementMiles.delegate = self
        txtOrderNo.delegate = self
    }
    
    //Mark:- pop to vc
    @objc func back(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    //Mark:- drop down delegate
    func doneSelection(selected: Bool) {
        nextTag += 1
        
        if let txtDrop = self.view.viewWithTag(nextTag) as? UITextField {
            txtDrop.becomeFirstResponder()
        }
    }
    
    //Mark:- textfield delegate
    func textFieldDidEndEditing(_ textField: UITextField) {
        nextTag += 1
        if let txtDrop = self.view.viewWithTag(nextTag) as? UITextField {
            txtDrop.becomeFirstResponder()
        }
    }
    
    //Mark:- button action
    @IBAction func btnNext(_ sender: Any) {
        
    }
    
    //Mark:- prepare for segue and sending data too
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if ( txtFeeder.text == "" || txtOrderNo.text == "" || txtAssignedTo.text == ""  ) {
            showAlert(str: "Please fill the form carefully.")
            return
        }
        
        
        let vc = segue.destination as! Step2ViewController
        let mcd = MasterDataController()
        let feederId = txtFeeder.getData(obj: txtFeeder) as! Int
        let feederData = mcd.getRecordById(entityName: .FeederList, id: feederId)
        let segmentMiles = 0.0
        let userData = GetSaveUserDetailsFromUserDefault.getDetials()
        let userId = userData!.UserId
        let assignedTo = txtAssignedTo.getData(obj: txtAssignedTo) as! Int

        let workOrder =  WorkOrderModel(WorkOrderId: 0, FeederId: feederId, GeoLat: feederData["geoLat"] as! Double, GeoLong: feederData["geoLng"] as! Double, Status: 1, AssignedTo: assignedTo, SegamentMiles: segmentMiles, LocalOffice: feederData["localOffice"] as! String, Substation: feederData["substation"] as! String, OCID: feederData["oc"] as! Int, Comments: "Noida", CreatedBy: userId, ModifiedAt: "", CommitOn: "", WorkOrderAssignTo: "1", WorkOrderCreatedBy:"10" , HazardTreeWithImagesList: [], RowWithTreeList: [], CreatedAt: "", ModifiedBy: 1,AuditList: [])
        vc.workOrder = workOrder
    }
    
    
    



}
