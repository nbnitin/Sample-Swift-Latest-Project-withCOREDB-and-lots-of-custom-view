//
//  Step1ViewController.swift
//  VegetationApp
//
//  Created by Nitin Bhatia on 01/04/19.
//  Copyright © 2019 Nitin Bhatia. All rights reserved.
//

import UIKit

class Step1ViewController: UIViewController,DropDownFieldDelegate,UITextFieldDelegate,CustomTableProtocol {
    
    //variables
    var nextTag = 10
    var workType : Int!
    var preSelectedId : Int!
    
    //outlets
    @IBOutlet var textBoxContainers: [UIView]!
    @IBOutlet weak var txtSegementMiles: UITextField!
    @IBOutlet weak var txtWorkType: PopUpPickers!
    @IBOutlet weak var txtAssignedTo: PopUpPickers!
    @IBOutlet weak var txtOrderNo: UITextField!
    @IBOutlet weak var navigationBar: Navigation!
    
    //Mark:- call on load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        //setting navigation button icon
        let image = UIImage(named: "ico")
        navigationBar.btnMenu.setImage(image, for: .normal)
        navigationBar.btnMenu.addTarget(self, action: #selector(back(_:)), for: .touchUpInside)

        txtWorkType.delegate = self as UITextFieldDelegate
        txtAssignedTo.delegate = self as UITextFieldDelegate
        
        if ( workType != nil ) {
            txtWorkType.selectedId = workType
            txtWorkType.text = workTypeString[workType]
        }
    }
    
   

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        //setting views look
        for vi in textBoxContainers{
            vi.addCornerRadius(corners: .allCorners, radius: 10)
            vi.addBorderAround(corners: .allCorners)
            vi.addShadow(offset: CGSize(width:-0.6,height:0.6))
            
            if ( vi.subviews.count > 1 ) {
                if let img = vi.subviews[1] as? UIImageView {
                    let gesTap = UITapGestureRecognizer(target: self, action: #selector(openCorrespondingTextField(_:)))
                    img.addGestureRecognizer(gesTap)
                    img.isUserInteractionEnabled = true
                }
            }
        }
    }
    
    @objc func openCorrespondingTextField(_ sender:UITapGestureRecognizer) {
        let view = sender.view as! UIImageView
        let superView = view.superview as! UIView
        if let txt = superView.subviews[0] as? PopUpPickers {
            txt.becomeFirstResponder()
        }
    }
    
    //Mark:- pop to vc
    @objc func back(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
   
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        
        
        guard let txtObj = textField as? PopUpPickers else {return true}
        
        let vx = CustomTable()
        vx.frame = CGRect(x: 0, y: 0, width: (self.view?.frame.width)!, height: (self.view.frame.height))
        vx.contentView.frame = vx.frame
        self.view.endEditing(true)
        vx.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.6)
        self.view.addSubview(vx)
        vx.navigationView.navigationTitle = txtObj.placeholder!
        
        vx.alpha = 0.0
        vx.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        //view animation
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear, animations: {
            vx.alpha = 1.0;
            vx.transform = CGAffineTransform.identity
        }, completion: { _ in
            vx.alpha = 1.0
            vx.transform = CGAffineTransform.identity
        })
        
        self.view.bringSubviewToFront(vx)
        vx.selectedTextBoxObj = txtObj
        vx.navigationView.showRightButton = false
        vx.data = txtObj.staticData
        vx.filterData = vx.data
        vx.tableView.reloadData()
        vx.customTableDelegate = self
        vx.selectedId = txtObj.selectedId
        return false
    }
    
    func valueSelected(obj:PopUpPickers) {
       
        if ( obj == txtWorkType ) {
            
            if obj.selectedId == WorkType.HOTSPOT.rawValue {
                workType = WorkType.HOTSPOT.rawValue
            } else if obj.selectedId == WorkType.SKYLINE.rawValue  {
                workType = WorkType.SKYLINE.rawValue
            } else {
                workType = WorkType.TREEREMOVAL.rawValue
            }
        }
        
    }
    
    
    
    //Mark:- button action
    @IBAction func btnNext(_ sender: Any) {
        
    }
    
    //Mark:- prepare for segue and sending data too
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if ( txtWorkType.text == "" || txtAssignedTo.text == "" ) {
            showAlert(str: "Please fill the form carefully.")
            return
        }


        let vc = segue.destination as! Step2ViewController
        
        let userData = GetSaveUserDetailsFromUserDefault.getDetials()
        let userId = userData!.UserId
        let assignedTo = txtAssignedTo.selectedId
        
        
        let workOrder =  WorkOrderModel(WorkOrderId: 0, DueDate: "",  Title:"", Status: 0, AssignedTo: assignedTo! , Comments: "Noida", CreatedBy: userId, ModifiedAt: "", CommitOn: "", WorkOrderAssignTo: "1", WorkOrderCreatedBy:"10" , HazardTreeList: [], RowList: [], HotSpotList: [],CreatedAt: "", ModifiedBy: 1,AuditList: [],WorkType: workType,AssignedToName: "")
        vc.workOrder = workOrder
        vc.preSelectedId = preSelectedId
    }
    
    
    



}
