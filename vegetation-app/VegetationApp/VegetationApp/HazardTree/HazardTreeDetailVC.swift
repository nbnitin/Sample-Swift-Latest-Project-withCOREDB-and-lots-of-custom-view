//
//  HazardTreeDetailVC.swift
//  VegetationApp
//
//  Created by Nitin Bhatia on 29/03/19.
//  Copyright © 2019 Nitin Bhatia. All rights reserved.
//

import UIKit
import SDWebImage

class HazardTreeDetailVC: UIViewController, UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,CustomTableProtocol,UITextFieldDelegate {
    
    //variables
    var details = ["Title","Tree Status","Feeder No.","Location in RoW","Distance To Line (ft.)","Tree Species","Prescription","Current Condition","Diameter at Breast Height (in.)","Feeder Substation","Customers Count","Access To tree","Environmental Conditions","OC Assigned","Comment"]
    var values : [String] = []
    var history = ["Cycle trim created by Daniel in 03 March,2019 at 08:00pm","Reviewed by Paul on 04 March,2019 at 08:30pm","Assigned to mike on 05 March,2019 at 08:00pm","Mark as completed by Mike on 06 March, 2019 at 08:00pm"]
    let height = 80
    let xAxis = 20
    var yAxis = 0
    var width = 0
    var totalDisplacement = 0
    var hazardTreeData : HazardTreeModel!
    var mcd : MasterDataController!
    var workOrderDetails : WorkOrderModel!
    var image : [ImageData]! = []
    var setImageWithTitle : SetImageWithTitle!
    var showEditButton : Bool = false
    var ocAssignedName : String = ""
    var isFromNotification = false

    //outlets
    @IBOutlet weak var btnGoToWorkOrderFlow: UIButton!
    @IBOutlet weak var navigationBar: Navigation!
    @IBOutlet weak var historyContainerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageCollView: UICollectionView!
    @IBOutlet weak var imageCollViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollV: UIScrollView!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var statusContainer: UIView!
    @IBOutlet weak var txtStatus: PopUpPickers!
    @IBOutlet weak var lblHistoryTitle: UILabel!
    @IBOutlet weak var historyContainerView: UIView!
    
    @IBOutlet weak var clickToNavigateView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mcd = MasterDataController()
        
       
       
        
        imageCollView.register(UINib(nibName: "NewlyAddedImageCell", bundle: nil), forCellWithReuseIdentifier: "newlyAddedCell")
        
        //Mark:- setting view and initial width of screen
        width = Int(self.view.frame.size.width) - xAxis
        let image = UIImage(named: "ico")
        navigationBar.btnMenu.setImage(image, for: .normal)
        navigationBar.btnMenu.addTarget(self, action: #selector(back(_:)), for: .touchUpInside)
        
        //Mark:- setting up right button in custom navigation bar
        navigationBar.showRightButton = self.showEditButton
        navigationBar.btnRight.setTitle("Edit", for: .normal)
        navigationBar.btnRight.addTarget(self, action: #selector(editHazardTree(_:)), for: .touchUpInside)
        
        
        //checking for work order id is available or not
        if ( hazardTreeData.WorkOrderID != 0  ) {
           // details.insert("Work Order Id", at: 0)
            self.view.showLoad()
            self.callApi()
        }
        
        setImageWithTitle = SetImageWithTitle()
        setImageWithTitle.contentView.frame = self.view.frame
        
        setImageWithTitle.btnBack.addTarget(self, action: #selector(cancelImageView(_:)), for: .touchUpInside)
        
        //setting view setup functions
        self.callApiUser()
        
        
        btnSubmit.addTarget(self, action: #selector(updateStatus), for: .touchUpInside)

        //locate gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(navigateAction(_:)))
        clickToNavigateView.addGestureRecognizer(tapGesture)
        clickToNavigateView.isUserInteractionEnabled = true
        
        txtStatus.delegate = self
        
        //deciding eighter to show or not work order flow button
        if ( hazardTreeData.WorkOrderID != nil && hazardTreeData.WorkOrderID == 0 && GetSaveUserDetailsFromUserDefault.getDetials()!.Type <= 2 ) {
            btnGoToWorkOrderFlow.isHidden = false
            btnGoToWorkOrderFlow.addTarget(self, action: #selector(goToWorkOrderFlow(_:)), for: .touchUpInside)
        } else {
            btnGoToWorkOrderFlow.isHidden = true
        }
        
        
    }
    
    //Mark:- setting scrollview content size
    override func viewDidAppear(_ animated: Bool) {
        var lastViewPosition : Int = 0
        
        if ( history.count > 0 ) {
            lastViewPosition = Int(historyContainerView.frame.origin.y + historyContainerView.frame.size.height + 30) //30 is for margin from bottom
        } else {
            lastViewPosition = Int(btnSubmit.frame.origin.y + btnSubmit.frame.height + 20)
        }
        scrollV.contentSize = CGSize(width: width, height: Int(lastViewPosition) )
    }
    
    //Mark:- got to add screen for editing
    @objc private func editHazardTree(_ sender:UIButton){
        let vc = storyboard?.instantiateViewController(withIdentifier: "addHazardTree") as! AddHazardTreeVC
        vc.hazardTreeData = self.hazardTreeData
        self.navigationController?.pushViewController(vc, animated: true)
    }
    //Mark:- text field delegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        
        
        guard let txtObj = textField as? PopUpPickers else {return true}
        
        let vx = CustomTable()
        vx.frame = CGRect(x: 0, y: 0, width: (self.view.frame.width), height: (self.view.frame.height))
        vx.contentView.frame = vx.frame
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
        vx.EntityName = txtObj.EntityName
        vx.customTableDelegate = self
        return false
    }
    
    func valueSelected(obj: PopUpPickers) {}
    
    //Mark:- call user api
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
                    if (tempData["UserId"] as! Int == self.hazardTreeData.OCAssigned) {
                        self.ocAssignedName = tempData["FirstName"] as! String
                    }
                }
            } 
            
            self.setupData()
        })
    }
    
    //Mark:- setting up data
    private func setupData(){
        values.removeAll()
        
        if ( hazardTreeData.WorkOrderID != 0 ) {
            //adding work order id label seperately
            let lblWorkOrderId = UILabel(frame: CGRect(x: 38, y: yAxis, width: Int(self.view.frame.width), height: 25))
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(navigateToWorkOrderDetails(_:)))
            lblWorkOrderId.addGestureRecognizer(tapGesture)
            lblWorkOrderId.isUserInteractionEnabled = true
            self.scrollV.addSubview(lblWorkOrderId)
            yAxis = Int(lblWorkOrderId.frame.height - 2.8) //2.8 is adjustment in line y axiss
            
            let str = NSString(string: "Work order ID: \(hazardTreeData.WorkOrderID)" )
            let theRange = str.range(of: "\(hazardTreeData.WorkOrderID)")
            let theSecondRange = str.range(of:"Work order ID:")

            
            let myString:NSString = "Work order ID: \(hazardTreeData.WorkOrderID)" as NSString
            var myMutableString = NSMutableAttributedString()
            myMutableString = NSMutableAttributedString(string: myString as String, attributes: nil)
            myMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(hexString: "#3c698c")!, range: theRange)
            
            myMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.darkGray, range: theSecondRange)
            
            
            // set label Attribute
            lblWorkOrderId.attributedText = myMutableString
            
        }
        values.append(hazardTreeData.Title ?? "" )
        values.append((mcd.getRecordById(entityName:.Status, id: hazardTreeData!.Status)["name"] as? String)!)
        values.append((mcd.getRecordById(entityName:.FeederList, id: hazardTreeData!.FeederId)["name"] as? String)!)
       // values.append((mcd.getRecordById(entityName: .Poles, id: hazardTreeData!.PoleId!)["name"] as? String!)!!)
        let locationInRow = hazardTreeData.InSideRow == true ? "Inside RoW" : "Outside RoW"
        values.append(locationInRow)
        values.append("\(hazardTreeData!.DistLine)")
        values.append((mcd.getRecordById(entityName:.TreeSpecies, id: hazardTreeData!.TreeSpeciesId)["name"] as? String)!)
        values.append((mcd.getRecordById(entityName:.Prescription, id: hazardTreeData!.Prescription)["name"] as? String)!)
       
        values.append((mcd.getRecordById(entityName:.CurrentConditionHazardTree, id: hazardTreeData!.Condition)["name"] as? String)!)
        values.append((mcd.getRecordById(entityName:.DiameterAtBreastHeight, id: hazardTreeData!.DistBrush)["name"] as? String)!)
        //values.append((mcd.getRecordById(entityName:.RiskLevel, id: hazardTreeData!.RiskLevel)["name"] as? String)!)
        values.append(hazardTreeData!.FeederSubstation! == "0" ? "" : hazardTreeData!.FeederSubstation!)
        let customerCount = hazardTreeData!.FeederCustomerCount == 0 ? "":
            "\(hazardTreeData!.FeederCustomerCount)"
        
        values.append(customerCount)
        
        values.append((mcd.getRecordById(entityName:.AccessToTree, id: hazardTreeData!.AccessToTree)["name"] as? String)!)
        values.append(hazardTreeData!.EnvCondition!)
        
        let ocAssigned = hazardTreeData!.OCAssigned == 0 ? "":
        "\(hazardTreeData!.OCAssigned)"
        
        values.append(ocAssigned)
        values.append(hazardTreeData!.Comments!)
        
        txtStatus.setText(EntityName: .Status, recId: hazardTreeData.Status)
        
        let temp = hazardTreeData.HzTreeImages
        
        if ( temp != nil ) {
            for index in 0 ..< temp!.count{
                let img = temp![index]
                let imageData = ImageData(Id: 1, Name: img.imageFullPath! as Any,Title: img.description!)
                self.image.append(imageData)
            }
            self.imageCollView.reloadData()
        }
        
        let historyTemp = hazardTreeData.AuditList
        self.history.removeAll()
        
        if ( historyTemp != nil && historyTemp!.count > 0 ) {
            
            for index in 0 ..< historyTemp!.count {
                let str = historyTemp![index].Status + " by " + historyTemp![index].ActionBy + " on " + DateFormatters.shared.dateFormatter2.string(from: DateFormatters.shared.dateFormatterNormal.date(from: historyTemp![index].ActionDate)!)
                self.history.append(str)
            }
            
        }
        setupInitialView()
        setupHistoryView()
    }
    
    //Mark:- pop to vc
    @objc func back(_ sender: UIButton){
        if ( !isFromNotification ) {
            self.navigationController?.popViewController(animated: true)
        } else {
            if self.navigationController?.viewControllers.count == 0 {
                let storyBoard = UIStoryboard.init(name: "Home", bundle: nil)
                let vc = storyBoard.instantiateInitialViewController()
                let window = UIWindow()
                window.rootViewController = vc
                window.makeKeyAndVisible()
                
                present(vc!, animated: true, completion: {() in
                    //self.dismiss(animated: true, completion: nil)
                })
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    //Mark:- creating dotted view and setting data into it, also calculating totaldisplacement and arranging collection and remaning views here too
    
    func setupInitialView(){
        
        for i in 0..<details.count{
            imageCollView.frame.origin.y = CGFloat(yAxis)
            let rect = CGRect(x: self.xAxis, y: yAxis, width: width, height: height)
            let view = UIView(frame: CGRect.zero)
            view.backgroundColor = UIColor.clear
            let cycleView = CycleAndHazardDetailView()
            cycleView.backgroundColor = UIColor.clear
            let fixDeduction = (cycleView.circleView.frame.origin.y + cycleView.circleView.frame.size.height)
            var y0Axis = CGFloat(yAxis) - fixDeduction
            yAxis = yAxis + height
            view.frame = rect
            let xAxis = CGFloat(self.xAxis) + cycleView.circleView.frame.size.width + 6
            view.addSubview(cycleView)
            scrollV.addSubview(view)
            //scrollV.contentSize = CGSize(width: width, height: yAxis)
            let y1Axis = CGFloat(yAxis) - (fixDeduction)
            
            if( y0Axis < 0 ) {
                y0Axis = fixDeduction
            }
            cycleView.lblTitle.text = details[i]
            cycleView.lblValue.text = values[i]
            
//            if ( cycleView.lblTitle.text == "Work Order Id" ) {
//                cycleView.lblValue.text = values[i]
//                cycleView.lblValue.textColor = UIColor.blue
//                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(navigateToWorkOrderDetails(_:)))
//                view.addGestureRecognizer(tapGesture)
//                view.isUserInteractionEnabled = true
//            }
            
            addLine(xAxis: xAxis, y0Axis: CGFloat(y0Axis), y1Axis: CGFloat(y1Axis))
        }
        imageCollViewTopConstraint.constant = CGFloat(yAxis)
        statusContainer.addCornerRadius(corners: .allCorners, radius: 10)
        statusContainer.addBorderAround(corners: .allCorners)
        statusContainer.addShadow(offset: CGSize(width:-0.6,height:0.6))
        //
        //
        //
        //        totalDisplacement = yAxis + Int(imageCollView.frame.height) + Int(statusContainer.frame.origin.y) + Int(statusContainer.frame.height)
        //            + Int(btnSubmit.frame.origin.y) + Int(btnSubmit.frame.height)
        //            + Int(historyContainerView.frame.origin.y)
        //            + 20
        
    }
    
    //Mark:- navigate to work order details when click on work order id
    @objc func navigateToWorkOrderDetails(_ sender:UITapGestureRecognizer){
        
        if ( workOrderDetails == nil ) {
            showAlert(str: "Sorry, Work order not yet loaded or found.")
            return
        }
        
        let storyBoard = UIStoryboard(name: "WorkOrder", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "workOrderDetailVC") as! WorkOrderDetailVC
        vc.workOrderData = self.workOrderDetails
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //Mark:- creating history view and setting data into it, also calculating totaldisplacement and arranging collection and remaning views here too
    
    func setupHistoryView(){
        var tempInternalYAxis = 25
        
        
        
        
        for i in 0..<history.count{
            //deduction of 30 is own purpose to set in width less than parent
            let internalWidth = historyContainerView.frame.width - 40
            let squareView = UIView(frame: CGRect(x:16,y:tempInternalYAxis,width:14,height:14))
            squareView.addCornerRadius(corners: .allCorners, radius: 1)
            //squareView.backgroundColor = UIColor.red
            //addition of 20 for margin of 20pt in between square view
            //-5  to match starting position of square view and label
            let lblHistoryDetails = UILabel(frame: CGRect(x:Int(squareView.frame.origin.x+squareView.frame.width + 10)
                ,y:tempInternalYAxis - 5,width:Int(internalWidth),height:10))
            lblHistoryDetails.numberOfLines = 0
            lblHistoryDetails.lineBreakMode = .byWordWrapping
            
            var color : UIColor = UIColor()
            
            if ( i % 2 == 0 ) {
                color = UIColor.green
            } else {
                color = UIColor.purple
            }
            
            squareView.backgroundColor = color
            
            let historyTemp = hazardTreeData.AuditList
            
            let str = NSString(string: history[i])
            let theRange = str.range(of: historyTemp![i].ActionBy)
            
            
            let myString:NSString = history[i] as NSString
            var myMutableString = NSMutableAttributedString()
            myMutableString = NSMutableAttributedString(string: myString as String, attributes: nil)
            myMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: theRange)
            
            // set label Attribute
            lblHistoryDetails.attributedText = myMutableString

            
            
            //lblHistoryDetails.text = history[i]
            lblHistoryDetails.sizeToFit()
            
            lblHistoryDetails.frame.size.height = lblHistoryDetails.frame.height
            
            
            
            //25 is the starting point, -10 is own purpose so that it wont cross label
            let lineView = UIView(frame:CGRect(x:25,y:lblHistoryDetails.frame.origin.y+lblHistoryDetails.frame.height + 15,width:internalWidth - 10,height:0.4))
            lineView.backgroundColor = UIColor.gray
            
            historyContainerView.addSubview(squareView)
            historyContainerView.addSubview(lblHistoryDetails)
            historyContainerView.addSubview(lineView)
//            
//            if(i == 0){
//                squareView.backgroundColor = UIColor.blue
//            } else {
//                squareView.backgroundColor = UIColor.black
//            }
            
            //15.7 is own purpose for margin
            tempInternalYAxis = Int(lineView.frame.origin.y + lineView.frame.size.height + 15.7)
            //30 is own purpose for margin
            historyContainerViewHeightConstraint.constant = CGFloat(tempInternalYAxis + 30)
            yAxis += tempInternalYAxis
        }
        
        //adding radius to view
        historyContainerView.layer.cornerRadius = 3
        
        
        
    }
    
    //Mark:- add line to given point
    func addLine(xAxis:CGFloat,y0Axis:CGFloat,y1Axis:CGFloat){
        let aPath = UIBezierPath()
        aPath.move(to: CGPoint(x:xAxis, y:y0Axis))
        aPath.addLine(to: CGPoint(x:xAxis, y:y1Axis))
        //Keep using the method addLineToPoint until you get to the one where about to close the path
        aPath.close()
        //If you want to stroke it with a red color
        UIColor.red.set()
        aPath.stroke()
        //If you want to fill it as well
        aPath.fill()
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = aPath.cgPath
        shapeLayer.strokeColor = UIColor.red.cgColor
        shapeLayer.lineWidth = 1
        self.scrollV.layer.addSublayer(shapeLayer)
    }
    
    //Mark:- navigate button action
    @objc func navigateAction(_ sender: UITapGestureRecognizer) {
        
        let storyBoard = UIStoryboard(name:"Map",bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "locateVC") as! Locate
        vc.objectLocationLat = hazardTreeData.GeoLat
        vc.objectLocationLong = hazardTreeData.GeoLong
        vc.objectType = "hzt"
        self.navigationController?.pushViewController(vc, animated: true)
        
//        if (hazardTreeData.GeoLong == 0.0 || hazardTreeData.GeoLat == 0.0  ) {
//            Toast.showToast(message: "No coordinates found.", position: .MIDDLE, length: .DEFAULT)
//            return
//        }
//
//        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!))
//        {
//            let  url = "comgooglemaps://?saddr=&daddr=\(hazardTreeData.GeoLat),\(hazardTreeData.GeoLong)&directionsmode=driving"
//            let finalURL = URL(string:url)!
//          UIApplication.shared.open(finalURL, options: [:], completionHandler: nil)
//        } else {
//            // Navigate from one coordinate to another
//            let url = "http://maps.apple.com/maps?saddr=&daddr=\(hazardTreeData.GeoLat),\(hazardTreeData.GeoLong)"
//            let finalURL = URL(string: url)!
//            UIApplication.shared.open(finalURL, options: [:], completionHandler: nil)
//        }

    }
    
    
    //Mark:- collection view
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return image.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "newlyAddedCell", for: indexPath) as! NewlyAddedImageCell
        if let name = (image[indexPath.row].Name) as? String{
            let url = URL(string: name)
            cell.imgAddImage.sd_setImage(with:url, completed: nil)
        } else {
            cell.imgAddImage.image = (image[indexPath.row].Name) as? UIImage
        }
        cell.lblTitle.text = image[indexPath.row].Title
        cell.btnTouch.addTarget(self, action: #selector(optionsActionOnImageTouch(_:)), for: .touchUpInside)
        cell.btnTouch.tag = indexPath.row
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width:90,height:90)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }
    
    //Mark:- image view functionallity
    @objc func optionsActionOnImageTouch(_ sender:UIButton){
        viewImage(index: sender.tag)
        self.setImageWithTitle.btnSend.isEnabled = false
        self.setImageWithTitle.btnSend.isHidden = true
        self.setImageWithTitle.txtTitle.isEnabled = false
        self.setImageWithTitle.btnShare.isHidden = false
        self.setImageWithTitle.btnShare.isEnabled = true
        self.setImageWithTitle.vc = self
    }
    
   
    
    @objc func cancelImageView(_ sender:UIButton){
        self.view.bringSubviewToFront(self.view)
        self.setImageWithTitle.contentView.removeFromSuperview()
    }
    
    
    
    func viewImage(index:Int){
        let indexPath = IndexPath(item: index, section: 0)
        let cell = self.imageCollView.cellForItem(at: indexPath) as! NewlyAddedImageCell
        let images = hazardTreeData.HzTreeImages
        let imageName = images![index].imageFullPathOriginal
        let url = URL(string:imageName!)
        self.setImageWithTitle.contentView.showLoadOtherFormat(title: "Please wait...", desc: "Loading high resolution image.")
        self.setImageWithTitle.img.sd_setImage(with: url,  completed: {
            (image, error, cacheType, url) in
            self.setImageWithTitle.contentView.hideLoadOtherView()
            })
        self.view.addSubview(self.setImageWithTitle.contentView)
        self.view.bringSubviewToFront(self.setImageWithTitle.contentView)
        
        self.setImageWithTitle.txtTitle.text = cell.lblTitle.text == "" ? " " : cell.lblTitle.text
        self.setImageWithTitle.btnSend.isEnabled = false
        self.setImageWithTitle.btnSend.isHidden = true
    }
    
    //Mark:- update status
    @objc func updateStatus(){
        self.view.showLoad()
        
        let apiHandler = ApiHandler()
        let userData = GetSaveUserDetailsFromUserDefault.getDetials()
        let userId = userData!.UserId
        let status = txtStatus.selectedId
        let treeId = hazardTreeData.HazardTreeID
        
        var parameters : [String:AnyObject] = [String:AnyObject]()
        parameters["HazardTreeId"] = treeId as AnyObject
        parameters["Status"] = status as AnyObject?
        parameters["UserId"] = userId as AnyObject
        
        
        apiHandler.sendPostRequestTypeSecond(url: apiUrl.updateHazardTreeStatus,parameters:parameters, completionHandler: { response,error in
            
            if ( error != nil ) {
                self.showAlert(str: (error?.localizedDescription)!)
                return
            }
            
            Toast.showToast(message: response["StatusMessage"]! as! String, position: .BOTTOM, length: .DEFAULT)
            self.view.hideLoad()
        })
    }
    
    
    
    //Mark:- call api
    private func callApi(){
        let apiHandler = ApiHandler()
        let userData = GetSaveUserDetailsFromUserDefault.getDetials()
        let userId = userData!.UserId
        let url = apiUrl.getWorkOrder + "\(userId)"
        
        apiHandler.sendGetRequest(url: url,  completionHandler: { response,error in
            print(response)
            
            self.view.hideLoad()
            
            if((response["Status"] as! Int) != 0){
                do{
                    let data = response["KeyValueList"] as! [[String:AnyObject]]
                    print("i m here",data.count)
                    for tempData in data{
                        
                        let jsonData = try? JSONSerialization.data(withJSONObject: tempData, options: [])
                        let model = try JSONDecoder().decode(WorkOrderModel.self, from: jsonData!)
                        if ( model.WorkOrderId == self.hazardTreeData.WorkOrderID ) {
                            self.workOrderDetails = model
                        }
                    }
                } catch{
                    print("json error: \(error)")
                }
            } else {
                self.showAlert(str: response["StatusMessage"]! as! String)
            }
            
        })
    }
    
    //Mark:- go to work order flow
    @objc func goToWorkOrderFlow(_ sender : UIButton) {
        performSegue(withIdentifier: "goToWorkFlow", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! Step1ViewController
        vc.preSelectedId = hazardTreeData.HazardTreeID
        let data = mcd.getRecordById(entityName: .Prescription, id: hazardTreeData.Prescription)
        
        if ( data["type"] as! String == filterTypePrescription.SkyLine.rawValue ) {
            vc.workType = WorkType.SKYLINE.rawValue
        } else {
            vc.workType = WorkType.TREEREMOVAL.rawValue
        }

    }
}
