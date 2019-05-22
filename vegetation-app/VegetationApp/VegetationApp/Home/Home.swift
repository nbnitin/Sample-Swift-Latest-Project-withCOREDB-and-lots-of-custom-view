//
//  Home.swift
//  VegetationApp
//
//  Created by Nitin Bhatia on 26/03/19.
//  Copyright © 2019 Nitin Bhatia. All rights reserved.
//

import UIKit

class Home: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    //variables
    var expandedHeight : CGFloat = 225
    var notExpandedHeight : CGFloat = 162
    var cellWidth:CGFloat{
        return dashboardCollectionView.frame.size.width - 16
    }
    var isExpanded = [Bool]()
    var cycleTrim : CycleTrimModel!
    var hazardTree : HazardTreeModel!
    var workOrder : WorkOrderModel!
    var cycleTrimIncomplete = 0
    var hazardTreeIncomplete = 0
    var workOrderIncomplete = 0
    var mcd = MasterDataController()
    var data : Int = 0
    //outlets
    @IBOutlet weak var loadingViewContainer: UIView!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var loadingSubView: UIView!
    @IBOutlet weak var navigationBar: Navigation!
    @IBOutlet weak var dashboardCollectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        setupMenuGestureRecognizer()
        isExpanded = Array(repeating: false, count: 3)
        
        callApi()

        navigationBar.btnMenu.addTarget(self.revealViewController(), action: #selector((SWRevealViewController.revealToggle) as (SWRevealViewController) -> (Void) -> Void), for: .touchUpInside)
       // navigationBar.lblTitle.text = "Dashboard"
        
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("freezed")
        hideShowLoadingContainer()
        let mdc = MasterDataController()
        mdc.callApi(completionHandler:{response,error in
            print("released")
            //print( mdc.getData(entityName: "AccessToTree"))
             DispatchQueue.main.async {
                self.hideShowLoadingContainer()
            }
        })
    }
    
    //Mark:- hide show loading container
    func hideShowLoadingContainer(){
       
        if ( loadingViewContainer.isHidden ) {
            loadingViewContainer.isHidden = false
            loadingSubView.isHidden = false
            activity.startAnimating()
            activity.isHidden = false
            self.view.bringSubviewToFront(loadingViewContainer)
        } else {
            loadingViewContainer.isHidden = true
            loadingSubView.isHidden = true
            activity.stopAnimating()
            activity.isHidden = true
            self.view.sendSubviewToBack(loadingViewContainer)
        }
    }
    
    //Mark:- collectionview
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! DashboardCell
       
        if ( indexPath.row == 0 ) {
            
            cell.imgCell.image = UIImage(named: "Group-110")
            cell.contentView.backgroundColor = UIColor.init(hexString: "#5773FF")
            cell.lowerContainerView.backgroundColor = UIColor.init(hexString: "#5773FF")
            cell.lblCount.text = "\(cycleTrimIncomplete)"
            
            if (cycleTrim != nil ) {
                cell.lblFeadrer.text = mcd.getRecordById(entityName: .FeederList, id: cycleTrim.feederId)["name"] as? String
                cell.lblRiskLevel.text = mcd.getRecordById(entityName: .Status, id: cycleTrim.status)["name"] as? String
                let tap = UITapGestureRecognizer(target: self, action: #selector(goToDetailView(_:)))
                cell.lowerContainerView.addGestureRecognizer(tap)
                cell.lowerContainerView.tag = 1
                cell.lowerContainerView.isUserInteractionEnabled = true
            }
            
            
        } else if ( indexPath.row == 1) {
            cell.imgCell.image = UIImage(named: "Group-111")
            cell.contentView.backgroundColor = UIColor.init(hexString: "#3497FD")
            cell.lowerContainerView.backgroundColor = UIColor.init(hexString: "#3497FD")
            cell.lblCount.text = "\(hazardTreeIncomplete)"
           
            if ( hazardTree != nil ) {
                cell.lblFeadrer.text = mcd.getRecordById(entityName: .FeederList, id: hazardTree.FeederId)["name"] as? String
                cell.lblRiskLevel.text = mcd.getRecordById(entityName: .Status, id: hazardTree.Status)["name"] as? String
                let tap = UITapGestureRecognizer(target: self, action: #selector(goToDetailView(_:)))
                cell.lowerContainerView.addGestureRecognizer(tap)
                cell.lowerContainerView.tag = 2
                cell.lowerContainerView.isUserInteractionEnabled = true
                
            }
            
        } else {
            cell.imgCell.image = UIImage(named: "Group-112")
            cell.contentView.backgroundColor = UIColor.init(hexString: "#FC3459")
            cell.lowerContainerView.backgroundColor = UIColor.init(hexString: "#FC3459")
            cell.lblCount.text = "\(workOrderIncomplete)"
           
            if (workOrder != nil) {
                cell.lblFeadrer.text = mcd.getRecordById(entityName: .FeederList, id: workOrder.FeederId)["name"] as? String
                cell.lblRiskLevel.text = mcd.getRecordById(entityName: .Status, id: workOrder.Status)["name"] as? String
                let tap = UITapGestureRecognizer(target: self, action: #selector(goToDetailView(_:)))
                cell.lowerContainerView.addGestureRecognizer(tap)
                cell.lowerContainerView.tag = 3
                cell.lowerContainerView.isUserInteractionEnabled = true
            }
           
        }
        
       // cell.lblCount.text = "91"
        if(indexPath.row == 0){
            cell.lblTitle.text = "Cycle Trim"
        } else if(indexPath.row == 1){
            cell.lblTitle.text = "Hazard Tree"
        } else {
            cell.lblTitle.text = "Work Order"
        }
        cell.indexPath = indexPath
        cell.delegate = self
       // cell.lblFeadrer.text = "999494"
       // cell.lblRiskLevel.text = "30"
        
        if(isExpanded[indexPath.row]){
            cell.lowerContainerView.isHidden = false
            cell.lblViewStatus.text = "View Less"
            cell.imgChevron.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        } else {
            cell.lowerContainerView.isHidden = true
            cell.lblViewStatus.text = "View More"
            cell.imgChevron.transform = CGAffineTransform(rotationAngle: CGFloat.pi*2)
        }
        
        cell.layer.cornerRadius = 10
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if isExpanded[indexPath.row] == true{
            return CGSize(width: cellWidth, height: expandedHeight)
        }else{
            return CGSize(width: cellWidth, height: notExpandedHeight)
        }    }
//
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 12, left: 8, bottom: 8, right: 8)
    }
//
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20.0
    }
    
    @objc func goToDetailView(_ sender:UITapGestureRecognizer){
        if ( sender.view?.tag == 1 ) {
            let storyboard = UIStoryboard(name: "CycleTrim", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "cycleTrimDetailVC") as! CycleTrimDetailVC
            vc.cycleTrimData = cycleTrim
            self.navigationController?.pushViewController(vc, animated: true)
        } else if (sender.view?.tag == 2) {
            let storyboard = UIStoryboard(name: "HazardTree", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "hazardTreeDetailVC") as! HazardTreeDetailVC
            vc.hazardTreeData = hazardTree
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            let storyboard = UIStoryboard(name: "WorkOrder", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "workOrderDetailVC") as! WorkOrderDetailVC
            vc.workOrderData = workOrder
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    //Mark:- call api for dashboard data
    private func callApi(){
        let apiHandler = ApiHandler()
        let userData = GetSaveUserDetailsFromUserDefault.getDetials()
        let userId = userData!.UserId
        let url = apiUrl.dashboard + "\(userId)"
        
        apiHandler.sendGetRequest(url: url,  completionHandler: { response,error in
            print(response)
            
            if ( error != nil ) {
                self.showAlert(str: error!.localizedDescription)
            }
            
            self.view.hideLoad()
            
            if( (response["Status"] as! Int) != 0 ) {
                do{
                    let data = response["KeyValueList"] as! [String:AnyObject]
                    self.hazardTreeIncomplete = data["HTreeIncomplete"] as! Int
                    self.cycleTrimIncomplete = data["RowIncomplete"] as! Int
                    self.workOrderIncomplete = data["WorkOrderIncomplete"] as! Int
                    
                
                    if (JSONSerialization.isValidJSONObject(data["RowRecentData"])) {
                        let jsonDataOfCycleTrim = try? JSONSerialization.data(withJSONObject: data["RowRecentData"], options: [])
                        self.cycleTrim = try JSONDecoder().decode(CycleTrimModel.self, from: jsonDataOfCycleTrim!)
                    }
                    if (JSONSerialization.isValidJSONObject(data["HTreeRecentData"])) {
                        let jsonDataOfHazard = try? JSONSerialization.data(withJSONObject: data["HTreeRecentData"], options: [])
                        self.hazardTree = try JSONDecoder().decode(HazardTreeModel.self, from: jsonDataOfHazard!)
                    }
                    if (JSONSerialization.isValidJSONObject(data["WorkOrderRecentData"])) {
                        let jsonDataOfWorkOrder = try? JSONSerialization.data(withJSONObject: data["WorkOrderRecentData"], options: [])
                        self.workOrder = try JSONDecoder().decode(WorkOrderModel.self, from: jsonDataOfWorkOrder!)
                    }
                    self.data = 2
                    self.dashboardCollectionView.reloadData()
                }
                catch let jsonErr{
                    print("Error serializing json", jsonErr)
                }
            } else {
                self.showAlert(str: response["Message"] as! String)
            }
            
        })
    }
    
    

}

extension Home:ExpandedCellDelegate{
    func topButtonTouched(indexPath: IndexPath) {
        self.isExpanded[indexPath.row] = !self.isExpanded[indexPath.row]
        UIView.animate(withDuration: 0.8, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.9, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.dashboardCollectionView.reloadItems(at: [indexPath])
        }, completion: { success in
            print("success")
        })
    }
}
