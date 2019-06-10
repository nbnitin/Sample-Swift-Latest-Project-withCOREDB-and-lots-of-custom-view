//
//  CycleTrimDetailVC.swift
//  VegetationApp
//
//  Created by Nitin Bhatia on 28/03/19.
//  Copyright © 2019 Nitin Bhatia. All rights reserved.
//

import UIKit

class CycleTrimDetailVC: UIViewController, UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UITextFieldDelegate,CustomTableProtocol {
   
    //variables
    var details = ["Title","Feeder No.","Tree Species","Tree Density","Segment Miles","Feeder Substation","Last Trimmed Clearance (ft.)","Last Trimmed","Customers Count","Line Construction","Access To Line","OC Assigned","Clearance (ft.)","Comment"]
    var values = ["12345","Pole No 1234","Oak (60%), Mapple (40%)","High","13","Romand Wood Land, CA","03ft as of 03 feb 2018","Mar, 2019","03","Vertical","Airboart","Nick","03","ABC"]
    var history = ["Cycle trim created by Daniel in 03 March,2019 at 08:00pm","Reviewed by Paul on 04 March,2019 at 08:30pm","Assigned to mike on 05 March,2019 at 08:00pm","Mark as completed by Mike on 06 March, 2019 at 08:00pm"]
    let height = 80
    let xAxis = 20
    var yAxis = 0
    var width = 0
    var totalDisplacement = 0
    var cycleTrimData : CycleTrimModel!
    var mcd : MasterDataController!
    var workOrderDetails : WorkOrderModel!
    var image : [ImageData]! = []
    var setImageWithTitle : SetImageWithTitle!
    var showEditButton : Bool = false
    var didOnce : Bool = false
    var isFromNotification = false

    //outlets
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
        
        //Mark:- setting right button in custom navigation
        navigationBar.showRightButton = self.showEditButton
        navigationBar.btnRight.setTitle("Edit", for: .normal)
        navigationBar.btnRight.addTarget(self, action: #selector(editCyleTrim(_:)), for: .touchUpInside)
        
        
        //checking for work order id is available or not
        if let x = cycleTrimData.workOrderId {
            if ( x > 0 ) {
            //details.insert("Work Order Id", at: 0)
            self.view.showLoad()
            self.callApi()
            }
        }
        
        setImageWithTitle = SetImageWithTitle()
        setImageWithTitle.contentView.frame = self.view.frame
        
        setImageWithTitle.btnBack.addTarget(self, action: #selector(cancelImageView(_:)), for: .touchUpInside)
        
        
        
        btnSubmit.addTarget(self, action: #selector(updateStatus), for: .touchUpInside)
        
        //locate gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(navigateAction(_:)))
        clickToNavigateView.addGestureRecognizer(tapGesture)
        clickToNavigateView.isUserInteractionEnabled = true
        
        txtStatus.delegate = self
    }
    
    //Mark:- setting scrollview content size
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(true)
       
        if ( !didOnce ) {
        //mark:- view setting up
            setupData()
            didOnce = true
        }
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
       
        var lastViewPosition : Int = 0
        
        if ( history.count > 0 ) {
            lastViewPosition = Int(historyContainerView.frame.origin.y + historyContainerView.frame.size.height + 30) //30 is for margin from bottom
        } else {
            lastViewPosition = Int(btnSubmit.frame.origin.y + btnSubmit.frame.height + 20)
        }
        scrollV.contentSize = CGSize(width: Int(UIScreen.main.bounds.size.width), height: lastViewPosition)
        
    }

    
    //Mark:- got to add screen for editing
    @objc private func editCyleTrim(_ sender:UIButton){
        let vc = storyboard?.instantiateViewController(withIdentifier: "addCycleTrim") as! AddCycleTrimVC
        vc.cycleTrimData = self.cycleTrimData
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
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
    
    
    
    //Mark:- setting up data
    private func setupData(){
        values.removeAll()
        
        if let workOrderId = cycleTrimData.workOrderId {
            if ( workOrderId > 0 ) {
               //adding work order id label seperately
               let lblWorkOrderId = UILabel(frame: CGRect(x: 38, y: yAxis, width: Int(self.view.frame.width), height: 25))
               let tapGesture = UITapGestureRecognizer(target: self, action: #selector(navigateToWorkOrderDetails(_:)))
               lblWorkOrderId.addGestureRecognizer(tapGesture)
               lblWorkOrderId.isUserInteractionEnabled = true
               self.scrollV.addSubview(lblWorkOrderId)
                yAxis = Int(lblWorkOrderId.frame.height - 2.8) //2.8 is adjustment in line y axiss
                
                let str = NSString(string: "Work order ID: \(workOrderId)" )
                let theRange = str.range(of: "\(workOrderId)")
                let theSecondRange = str.range(of:"Work order ID:")
                
               let myString:NSString = "Work order ID: \(workOrderId)" as NSString
               var myMutableString = NSMutableAttributedString()
               myMutableString = NSMutableAttributedString(string: myString as String, attributes: nil)
                myMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(hexString: "#3c698c")!, range: theRange)
                
                myMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.darkGray, range: theSecondRange)
                
               // set label Attribute
               lblWorkOrderId.attributedText = myMutableString
               

            }
        }
        values.append(cycleTrimData.title ?? "")
        values.append(mcd.getRecordById(entityName: .FeederList, id: cycleTrimData.feederId)["name"] as? String ?? "N/A")
       // values.append(mcd.getRecordById(entityName: .Poles, id: cycleTrimData.poleId ?? 0)["name"] as? String ?? "N/A")
        values.append(cycleTrimData.speciesName ?? "N/A")
        values.append(mcd.getRecordById(entityName: .TreeDensity, id: cycleTrimData.treeDensity)["name"] as? String ?? "N/A")
        
        let segmentMiles = cycleTrimData!.segamentMiles == 0 ? "":
        "\(cycleTrimData!.segamentMiles)"
        values.append(segmentMiles)
        
        values.append(cycleTrimData!.feederSubstation ?? "N/A")
        
        let lastTrimHeight = cycleTrimData!.lastTrimHeight == 0 ? "" : "\(cycleTrimData!.lastTrimHeight)"
        
        values.append(lastTrimHeight)
       
        if ( cycleTrimData.lastTrimAt != "" ) {
            values.append("\(DateFormatters.shared.dateFormatter2.string(from: DateFormatters.shared.dateFormatterNormal.date(from: cycleTrimData!.lastTrimAt ?? "")!))")
        } else {
            values.append("N/A")
        }
        
        let customerCount = cycleTrimData!.feederCustomerCount == 0 ? "":
        "\(cycleTrimData!.feederCustomerCount)"
        
        values.append(customerCount)
        values.append(mcd.getRecordById(entityName: .LineConstruction, id:cycleTrimData.lineContruction ?? 0) ["name"] as? String ?? "N/A")
        
        values.append(mcd.getRecordById(entityName: .AccessToLine, id:cycleTrimData.accessToLine ?? 0) ["name"] as? String ?? "N/A")
        values.append(cycleTrimData!.ocAssignedToName ?? "N/A")
        values.append("\(cycleTrimData!.clearance)")
        values.append(cycleTrimData!.comments ?? "N/A")
        
        let temp = cycleTrimData.rwTreeImages
        
        if ( temp != nil && temp!.count > 0 ) {
            
            for index in 0 ..< temp!.count{
                let img = temp![index]
                let imageData = ImageData(Id: 1, Name: img.imageFullPath! as Any,Title: img.description ?? "")
                self.image.append(imageData)
            }
            self.imageCollView.reloadData()
        }
        
        let historyTemp = cycleTrimData.auditList
        self.history.removeAll()
        
        if ( historyTemp != nil && historyTemp!.count > 0 ) {
            
            for index in 0 ..< historyTemp!.count {
                let str = historyTemp![index].Status + " by " + historyTemp![index].ActionBy + " on " + DateFormatters.shared.dateFormatter2.string(from: DateFormatters.shared.dateFormatterNormal.date(from: historyTemp![index].ActionDate)!)
                self.history.append(str)
            }
            
        }
        
        txtStatus.setText(EntityName: .Status, recId: cycleTrimData.status)
        
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
            
            let historyTemp = cycleTrimData.auditList
            
            let str = NSString(string: history[i])
            let theRange = str.range(of: historyTemp![i].ActionBy)

            
            let myString:NSString = history[i] as NSString
            var myMutableString = NSMutableAttributedString()
            myMutableString = NSMutableAttributedString(string: myString as String, attributes: nil)
            myMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: theRange)
            
            // set label Attribute
            lblHistoryDetails.attributedText = myMutableString
           // lblHistoryDetails.text = history[i]
            lblHistoryDetails.sizeToFit()

            lblHistoryDetails.frame.size.height = lblHistoryDetails.frame.height
            
           
           
            //25 is the starting point, -10 is own purpose so that it wont cross label
            let lineView = UIView(frame:CGRect(x:25,y:lblHistoryDetails.frame.origin.y+lblHistoryDetails.frame.height + 15,width:internalWidth - 10,height:0.4))
            lineView.backgroundColor = UIColor.gray
            
            historyContainerView.addSubview(squareView)
            historyContainerView.addSubview(lblHistoryDetails)
            historyContainerView.addSubview(lineView)
          
      
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
        vc.objectLocationLat = cycleTrimData.geoLat
        vc.objectLocationLong = cycleTrimData.geoLong
        self.navigationController?.pushViewController(vc, animated: true)
        
//        if (cycleTrimData.geoLong == 0.0 || cycleTrimData.geoLat == 0.0  ) {
//            Toast.showToast(message: "No coordinates found.", position: .MIDDLE, length: .DEFAULT)
//            return
//        }
//        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!))
//        {
//            let  url = "comgooglemaps://?saddr=&daddr=\(cycleTrimData.geoLat),\(cycleTrimData.geoLong)&directionsmode=driving"
//            let finalURL = URL(string: url)!
//            UIApplication.shared.open(finalURL, options: [:], completionHandler: nil)
//        } else {
//            // Navigate from one coordinate to another
//            let url = "http://maps.apple.com/maps?saddr=&daddr=\(cycleTrimData.geoLat),\(cycleTrimData.geoLong)"
//            let finalURL = URL(string: url)!
//            UIApplication.shared.open(finalURL, options: [:], completionHandler: nil)
//       }
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
        cell.btnTouch.tag = indexPath.row
        cell.btnTouch.addTarget(self, action: #selector(optionsActionOnImageTouch(_:)), for: .touchUpInside)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width:120,height:120)
    }
    
    
    //Mark:- image controller
   
    
    @objc func cancelImageView(_ sender:UIButton){
        self.view.bringSubviewToFront(self.view)
        self.setImageWithTitle.contentView.removeFromSuperview()
    }
    
    
  
    
    @objc func optionsActionOnImageTouch(_ sender:UIButton){
        self.viewImage(index: sender.tag)
        self.setImageWithTitle.btnSend.isEnabled = false
        self.setImageWithTitle.btnShare.isHidden = false
        self.setImageWithTitle.btnShare.isEnabled = true
        self.setImageWithTitle.vc = self
        self.setImageWithTitle.btnSend.isHidden = true
        self.setImageWithTitle.txtTitle.isEnabled = false
    }
    
   
    
    func viewImage(index:Int){
        let indexPath = IndexPath(item: index, section: 0)
        let cell = self.imageCollView.cellForItem(at: indexPath) as! NewlyAddedImageCell
        let images = cycleTrimData.rwTreeImages
        let imageName = images![index].imageFullPathOriginal
        let url = URL(string:imageName!)
        setImageWithTitle.contentView.showLoadOtherFormat(title: "Please wait...", desc: "Loading high resolution image.")
        self.setImageWithTitle.img!.sd_setImage(with: url, completed: {
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
        let trimId = cycleTrimData.rowId
        
        var parameters : [String:AnyObject] = [String:AnyObject]()
        parameters["RowTreeId"] = trimId as AnyObject
        parameters["Status"] = status as AnyObject?
        parameters["UserId"] = userId as AnyObject

        
        apiHandler.sendPostRequestTypeSecond(url: apiUrl.updateCycleTrimStatus,parameters:parameters, completionHandler: { response,error in
            
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
                        if ( model.WorkOrderId == self.cycleTrimData.workOrderId ) {
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
    
}
