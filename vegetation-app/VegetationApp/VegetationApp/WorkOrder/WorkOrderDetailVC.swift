//
//  HazardTreeDetailVC.swift
//  VegetationApp
//
//  Created by Nitin Bhatia on 29/03/19.
//  Copyright © 2019 Nitin Bhatia. All rights reserved.
//

import UIKit

class WorkOrderDetailVC: UIViewController, UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,EditWorkOrderProtocol {
    
    
    //variables
    var details = ["Title","Work Order","Assigned To","Due Date","No. of Hazard Tree","No. of Hot Spot","Status","Comment"]
    var values = ["12345","Inside","03ft","Oak (60%), Mapple (40%)","Skyline","Approved"]
    
    var history = ["Cycle trim created by Daniel in 03 March,2019 at 08:00pm","Reviewed by Paul on 04 March,2019 at 08:30pm","Assigned to mike on 05 March,2019 at 08:00pm","Mark as completed by Mike on 06 March, 2019 at 08:00pm"]
    
    let height = 80
    let xAxis = 20
    var yAxis = 0
    var width = 0
    var totalDisplacement = 0
    var workOrderData : WorkOrderModel!
    var mcd : MasterDataController!
    var cellHeight : CGFloat = 250 + 10 //(60 is the fixed height of navigate button)
    var cellWidth : CGFloat = 0.0
    var hazardTreeData : [HazardTreeModel]! = []
    var cycleTrimData : [CycleTrimModel]! = []
    var hotSpotData : [HotSpotModel]! = []
    var workOrderID : Int!
    let leftInset = 10
    let rightInset = 16
    var isFromNotification = false
    
    //outlets
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var headingLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var dataCollHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var navigationBar: Navigation!
    @IBOutlet weak var historyContainerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var dataCollView: UICollectionView!
    @IBOutlet weak var dataCollViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollV: UIScrollView!
    @IBOutlet weak var lblHistoryTitle: UILabel!
    @IBOutlet weak var historyContainerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mcd = MasterDataController()
        
        
        //Mark:- setting view and initial width of screen
        width = Int(self.view.frame.size.width) - xAxis
        let image = UIImage(named: "ico")
        navigationBar.btnMenu.setImage(image, for: .normal)
        navigationBar.btnMenu.addTarget(self, action: #selector(back(_:)), for: .touchUpInside)
        
        navigationBar.btnRight.setTitle("Edit", for: .normal)
        navigationBar.btnRight.addTarget(self, action: #selector(editWorkOrder(_:)), for: .touchUpInside)
        
        callApiUser()

        if ( isFromNotification ) {
           showNotificationAlert()
        }
       
    }
    
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let lastViewPosition =  historyContainerView.frame.origin.y + historyContainerViewHeightConstraint.constant//30 is for margin from bottom
        scrollV.contentSize = CGSize(width: width, height: Int(lastViewPosition) )
    }
    
    //Mark:- setting up data
    private func setupData(){
        values.removeAll()
        
        values.append(workOrderData!.Title ?? "")
        values.append("\(workOrderData!.WorkOrderId)")
        values.append(workOrderData.AssignedToName ?? "")
        values.append(DateFormatters.shared.dateFormatter2.string(from: DateFormatters.shared.dateFormatterNormal.date(from: workOrderData.DueDate!)!))
        
        if ( workOrderData.HazardTreeList != nil && workOrderData.HazardTreeList!.count > 0 ) {
            values.append("\(workOrderData.HazardTreeList?.count ?? 0)")
        } else  {
            details.remove(at: details.index(of: "No. of Hazard Tree")!)
        }
        if ( workOrderData.HotSpotList!.count > 0 ) {
            values.append("\(workOrderData.HotSpotList?.count ?? 0)")
        } else {
            details.remove(at: details.index(of: "No. of Hot Spot")!)
        }
        
        values.append((mcd.getRecordById(entityName: .Status, id: workOrderData.Status)["name"] as? String)!)
        values.append(workOrderData.Comments)
        
        if ( workOrderData.HazardTreeList != nil && workOrderData.HazardTreeList!.count > 0 ) {
            hazardTreeData = workOrderData.HazardTreeList
            lblHeading.text = "Hazard Tree"
            dataCollHeightConstraint.constant = cellHeight * CGFloat(workOrderData.HazardTreeList!.count) + 70
            self.dataCollView.reloadData()
        } else if ( workOrderData.HotSpotList!.count > 0 ) {
            hotSpotData = workOrderData.HotSpotList
            lblHeading.text = "Hot Spot"
            //cellHeight = 158
            dataCollHeightConstraint.constant = cellHeight * CGFloat(workOrderData.HotSpotList!.count) + 70
            self.dataCollView.reloadData()
        }
        
        
        let historyTemp = workOrderData.AuditList
        self.history.removeAll()
        
        if ( historyTemp != nil && historyTemp!.count > 0 ) {
            
            for index in 0 ..< historyTemp!.count {
                let str = historyTemp![index].Status + " by " + historyTemp![index].ActionBy + " on " + DateFormatters.shared.dateFormatter2.string(from: DateFormatters.shared.dateFormatterNormal.date(from: historyTemp![index].ActionDate)!)
                self.history.append(str)
            }
            
        } else {
            historyContainerViewHeightConstraint.constant = 0
            lblHistoryTitle.isHidden = true
        }
        cellWidth = self.view.bounds.width

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
            
            
            dataCollView.frame.origin.y = CGFloat(yAxis)
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
            
            addLine(xAxis: xAxis, y0Axis: CGFloat(y0Axis), y1Axis: CGFloat(y1Axis))
        }
        
        if ( ( workOrderData.HotSpotList != nil && workOrderData.HazardTreeList != nil ) && ( workOrderData.HotSpotList?.count == 0 && workOrderData.HazardTreeList!.count == 0 ) ) {
            lblHeading.isHidden = true
        } else {
            headingLabelTopConstraint.constant = CGFloat(yAxis)
        }
    }
    
    //Mark:- creating history view and setting data into it, also calculating totaldisplacement and arranging collection and remaning views here too
    
    func setupHistoryView(){
        var tempInternalYAxis = 25
        for i in 0..<history.count{
            //deduction of 30 is own purpose to set in width less than parent
            let internalWidth = historyContainerView.frame.width - 30
            let squareView = UIView(frame: CGRect(x:16,y:tempInternalYAxis,width:14,height:14))
            squareView.addCornerRadius(corners: .allCorners, radius: 1)
            squareView.backgroundColor = UIColor.red
            //addition of 20 for margin of 20pt in between square view
            //-5  to match starting position of square view and label
            let lblHistoryDetails = UILabel(frame: CGRect(x:Int(squareView.frame.origin.x+squareView.frame.width + 20)
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
            
            let historyTemp = workOrderData.AuditList
            
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
    
    //Mark:- collection view
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if ( hazardTreeData.count > 0 ) {
            //dataCollHeightConstraint.constant = CGFloat((hazardTreeData.count * Int((cellHeight) + 30))) //30 is margin extra space
            return hazardTreeData.count
        }
        
        if ( hotSpotData.count > 0 ) {
           // dataCollHeightConstraint.constant = CGFloat((cycleTrimData.count * Int((cellHeight) + 30))) //30 is margin extra space
        }
        return hotSpotData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if ( hazardTreeData.count > 0 ) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! HazardTreeCell
            cell.containerView.imgView.isHidden = true
            cell.containerView.lblRecId.text = "\(hazardTreeData[indexPath.row].HazardTreeID)"
            cell.containerView.lblFeeder.text = mcd.getRecordById(entityName: .FeederList, id: hazardTreeData[indexPath.row].FeederId)["name"] as? String
            cell.containerView.lblStatus.text = "\(hazardTreeData[indexPath.row].Status)"
          //  cell.containerView.lblRiskLevel.text = mcd.getRecordById(entityName: .RiskLevel, id: hazardTreeData[indexPath.row].RiskLevel)["name"] as? String
            cell.containerView.lblCurrentCondition.text = mcd.getRecordById(entityName: .CurrentConditionHazardTree, id: hazardTreeData[indexPath.row].Condition)["name"] as? String
            cell.containerView.lblPrescription.text = mcd.getRecordById(entityName:.Prescription, id: hazardTreeData[indexPath.row].Prescription)["name"] as? String
            
            cell.containerView.frame.size.height = cellHeight
            cell.containerView.frame.size.width = cellWidth - CGFloat((leftInset+rightInset))
            cell.dropShadow(color: .black, opacity: 0.5, offSet: CGSize(width: -0.6, height: 0.6), radius: 3, scale: true)
            cell.containerView.addCornerRadius(corners: .allCorners, radius: 5)
            let tapGestureForNavigate = UITapGestureRecognizer(target: self, action: #selector(navigateToTree(_:)))
            cell.containerView.clickToNavigateView.isHidden = false
            cell.containerView.clickToNavigateView.tag = indexPath.row
            cell.containerView.clickToNavigateView.addGestureRecognizer(tapGestureForNavigate)
            cell.containerView.clickToNavigateView.isUserInteractionEnabled = true

            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "hotSpotCell", for: indexPath) as! HotSpotCell
        cell.containerView.imgView.isHidden = true
        cell.containerView.lblTitle.text = hotSpotData[indexPath.row].Title
        cell.containerView.lblRecId.text = "\(hotSpotData[indexPath.row].HotSpotID)"
        cell.containerView.lblCustomerCount.text = "\(hotSpotData[indexPath.row].FeederCustomerCount)"
        cell.containerView.lblAccessToTree.text = mcd.getRecordById(entityName: .AccessToTree, id: hotSpotData[indexPath.row].AccessToTree)["name"] as? String
        cell.containerView.lblStatus.text = mcd.getRecordById(entityName: .Status, id: hotSpotData[indexPath.row].Status)["name"] as? String
        
        cell.containerView.lblTreeSpecies.text = hotSpotData[indexPath.row].SpeciesName
        cell.containerView.frame.size.height = cellHeight
        cell.containerView.frame.size.width = cellWidth - CGFloat((leftInset+rightInset))
        cell.dropShadow(color: .black, opacity: 0.5, offSet: CGSize(width: -0.6, height: 0.1), radius: 3, scale: true)
        cell.containerView.addCornerRadius(corners: .allCorners, radius: 5)
        cell.containerView.contentView.backgroundColor = UIColor.clear
        cell.containerView.clickToNavigateView.isHidden = false
        cell.containerView.clickToNavigateView.tag = indexPath.row
         let tapGestureForNavigate = UITapGestureRecognizer(target: self, action: #selector(navigateToCycle(_:)))
        cell.containerView.clickToNavigateView.addGestureRecognizer(tapGestureForNavigate)
        cell.containerView.clickToNavigateView.isUserInteractionEnabled = true
       
        return cell

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: cellWidth-CGFloat((leftInset+rightInset))  , height: cellHeight)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top:10 , left:CGFloat(leftInset), bottom:10, right:0)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 40
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let _ = collectionView.cellForItem(at: indexPath) as? HotSpotCell {
            let storyboard = UIStoryboard(name: "HotSpot", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "hotSpotDetailVC") as! HotSpotDetailVC
            vc.hotSpotData = self.hotSpotData[indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            let storyboard = UIStoryboard(name: "HazardTree", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "hazardTreeDetailVC") as! HazardTreeDetailVC
            vc.hazardTreeData = self.hazardTreeData[indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func editWorkOrder(_ sender:UIButton){
        performSegue(withIdentifier: "editWorkOrder", sender: self)
    }
    
    func editingDone(workOrder: WorkOrderModel) {
        self.workOrderData = workOrder
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
        if ( segue.identifier == "editWorkOrder" ) {
            let vc = segue.destination as! EditWorkOrderViewController
            vc.delegate = self
            vc.workOrderData = workOrderData
        }
    }
    
    //Mark:- navigation button action
    //Mark:- navigate button action
    @objc func navigateToTree(_ sender: UITapGestureRecognizer) {
        let lat = hazardTreeData[sender.view!.tag].GeoLat
        let long = hazardTreeData[sender.view!.tag].GeoLong
        
        let storyBoard = UIStoryboard(name:"Map",bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "locateVC") as! Locate
        vc.objectLocationLat = lat
        vc.objectLocationLong = long
        vc.objectType = "hzt"
        self.navigationController?.pushViewController(vc, animated: true)
        
//        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
//            let  url = "comgooglemaps://?saddr=&daddr=\(lat),\(long)&directionsmode=driving"
//            let finalURL = URL(string: url)!
//            UIApplication.shared.open(finalURL, options: [:], completionHandler: nil)
//
//        } else {
//            // Navigate from one coordinate to another
//            let url = "http://maps.apple.com/maps?saddr=&daddr=\(lat),\(long)"
//            let finalURL = URL(string: url)!
//            UIApplication.shared.open(finalURL, options: [:], completionHandler: nil)
//        }
        
    }
    
    @objc func navigateToCycle(_ sender: UITapGestureRecognizer) {
        let lat = hotSpotData[sender.view!.tag].GeoLat
        let long = hotSpotData[sender.view!.tag].GeoLong
        
        let storyBoard = UIStoryboard(name:"Map",bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "locateVC") as! Locate
        vc.objectLocationLat = lat
        vc.objectLocationLong = long
        self.navigationController?.pushViewController(vc, animated: true)
        
//        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
//            let  url = "comgooglemaps://?saddr=&daddr=\(lat),\(long)&directionsmode=driving"
//            let finalURL = URL(string: url)!
//            UIApplication.shared.open(finalURL, options: [:], completionHandler: nil)
//
//        } else {
//            // Navigate from one coordinate to another
//            let url = "http://maps.apple.com/maps?saddr=&daddr=\(lat),\(long)"
//            let finalURL = URL(string: url)!
//            UIApplication.shared.open(finalURL, options: [:], completionHandler: nil)
//        }
        
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
                
                for tempData in data{
                    if (tempData["UserId"] as! Int == self.workOrderData.AssignedTo) {
                        //self.assignedToName = tempData["FirstName"] as! String
                    }
                }
                self.setupData()
                
            } else {
                // self.showAlert(str: response["StatusMessage"]! as! String)
            }
            
        })
    }
    
    //Mark:- get work order details when come from push response
    //Mark:- call api
    private func getWorkOrderDetails(){
        let apiHandler = ApiHandler()
        let url = apiUrl.getWorkOrderSearch
       
        var parameter : [String:String] = [:]
        parameter["WorkOrderID"] = "\(self.workOrderID!)"
         parameter["FeederID"] = "0"
         parameter["AssignedID"] = "0"
          parameter["Status"] = "0"
          parameter["CreateDate"] = "0"
          parameter["OrderBy"] = "0"
          parameter["OrderBYDirection"] = "0"
           parameter["PageNo"] = "0"
           parameter["PageSize"] = "0"
        
        apiHandler.sendPostRequestTypeSecond(url: url,parameters: parameter  ,completionHandler: { response,error in
            print(response)
            self.view.hideLoad()
            
            if ( error != nil  ) {
                self.showAlert(str: (error?.localizedDescription)!)
                return
            }
            
            if( (response["Status"] as! Int) != 0 ) {
                do{
                    let data = response["KeyValueList"] as! [[String:AnyObject]]
                    
                   
                        let jsonData = try? JSONSerialization.data(withJSONObject: data[0], options: [])
                        self.workOrderData = try JSONDecoder().decode(WorkOrderModel.self, from: jsonData!)
                    
                        self.callApiUser()
                        self.showNotificationAlert()
                } catch{
                    print("json error: \(error)")
                }
            } else {
                self.showAlert(str: response["StatusMessage"]! as! String)
            }
            
        })
    }
    
    private func showNotificationAlert(){
        let alert = UIAlertController(title: "Confirm?", message: "You have new order assigned", preferredStyle: .actionSheet)
        let acceptAction = UIAlertAction(title: "Accept", style: .default, handler:{ (UIAlertAction) in
            self.view.showLoad()
            
            NotificationHandler.shared.updateWorkOrder(status:2,workOrderId : self.workOrderID,assignTo:self.workOrderData.AssignedTo!,completionHandler:{(response,error) in
                self.view.hideLoad()
                if ( error != nil ) {
                    self.showAlert(str: error!.localizedDescription)
                    return
                }
                
                self.showAlert(str: response["StatusMessage"] as! String)

            })
        })
        let rejectAction = UIAlertAction(title: "Reject", style: .default, handler:{ (UIAlertAction) in
                self.view.showLoad()
            NotificationHandler.shared.updateWorkOrder(status:-1,workOrderId:self.workOrderID,assignTo:self.workOrderData.AssignedTo!,completionHandler:{(response,error) in
                self.view.hideLoad()
               
                if ( error != nil ) {
                    self.showAlert(str: error!.localizedDescription)
                    return
                }
                
                self.showAlert(str: response["StatusMessage"] as! String)

            })
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(acceptAction)
        alert.addAction(rejectAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
}
