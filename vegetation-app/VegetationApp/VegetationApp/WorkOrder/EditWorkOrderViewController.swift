//
//  EditWorkOrderViewController.swift
//  VegetationApp
//
//  Created by Nitin Bhatia on 30/05/19.
//  Copyright © 2019 Nitin Bhatia. All rights reserved.
//

import UIKit

protocol EditWorkOrderProtocol {
    func editingDone(workOrder : WorkOrderModel)
}

class EditWorkOrderViewController: UIViewController,UITextFieldDelegate,CustomTableProtocol {
    
    //variables
    var workOrderData : WorkOrderModel!
    var delegate : EditWorkOrderProtocol!
    
    //outlets
    @IBOutlet weak var txtStatus: PopUpPickers!
    @IBOutlet weak var txtAssignedTo: PopUpPickers!
    @IBOutlet var textBoxContainers: [UIView]!
    @IBOutlet weak var navigationBar: Navigation!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        let image = UIImage(named: "ico")
        navigationBar.btnMenu.setImage(image, for: .normal)
        navigationBar.btnMenu.addTarget(self, action: #selector(back(_:)), for: .touchUpInside)
        
        txtStatus.delegate = self as UITextFieldDelegate
        
        txtAssignedTo.delegate = self as UITextFieldDelegate
        
        if ( GetSaveUserDetailsFromUserDefault.getDetials()!.Type > 2 ) {
            txtAssignedTo.isEnabled = false
            txtAssignedTo.superview!.backgroundColor = UIColor.lightGray
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        //setting views look
        for vi in textBoxContainers{
            vi.addCornerRadius(corners: .allCorners, radius: 10)
            vi.addBorderAround(corners: .allCorners)
            vi.addShadow(offset: CGSize(width:-0.6,height:0.6))
        }
        
        txtAssignedTo.selectedId = workOrderData.AssignedTo
        txtAssignedTo.selectedName = workOrderData.AssignedToName
        txtAssignedTo.text = workOrderData.AssignedToName
        txtStatus.setText(EntityName: .Status, recId: workOrderData.Status)
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
        vx.selectedId = txtObj.selectedId

        if ( txtObj == txtStatus ) {
            vx.EntityName = txtObj.EntityName
        } else {
            vx.data = txtObj.staticData
            vx.filterData = txtObj.staticData
            
            vx.tableView.reloadData()
        }
        
        
        //vx.tableView.reloadData()
        vx.customTableDelegate = self
        return false
    }
    
    func valueSelected(obj:PopUpPickers) {
        
//        if ( obj == txtWorkType ) {
//
//            if obj.selectedId == WorkType.HOTSPOT.rawValue {
//                workType = WorkType.HOTSPOT.rawValue
//            } else if obj.selectedId == WorkType.SKYLINE.rawValue  {
//                workType = WorkType.SKYLINE.rawValue
//            } else {
//                workType = WorkType.TREEREMOVAL.rawValue
//            }
//        }
        
    }
    
    @IBAction func btnSubtmitAction(_ sender: Any) {
        updateWorkOrder()
    }
    
    func updateWorkOrder(){
        let apiHandler = ApiHandler()
        
        let userData = GetSaveUserDetailsFromUserDefault.getDetials()
        let userId = userData!.UserId
        var parameters :[String:Any] = [:]
        parameters["WorkOrderId"] = workOrderData.WorkOrderId
        parameters["Status"] = txtStatus.selectedId
        parameters["AssignedTo"] = txtAssignedTo.selectedId
        parameters["UserId"] = userId
        
        
        apiHandler.sendPostRequestTypeSecond(url: apiUrl.editWorkOrder,parameters:parameters, completionHandler: { response,error in
            print(response)
            self.view.hideLoad()
            
            if ( error != nil ) {
                self.showAlert(str: (error?.localizedDescription)!)
                return
            }
            
            if((response["Status"] as! Int) != 0){
                
                Toast.showToast(message: response["StatusMessage"]! as! String, position: .BOTTOM, length: .DEFAULT)
                //workOrderData.AssignedTo = txtAssignedTo.selectedId
                //workOrderData.Status = txtStatus
                //delegate.editingDone(workOrder: workOrderData)
                
                self.navigationController?.popToRootViewController(animated: true)
            } else {
                self.showAlert(str: response["StatusMessage"]! as! String)
            }
            //self.callApi()
        })
    }

}
