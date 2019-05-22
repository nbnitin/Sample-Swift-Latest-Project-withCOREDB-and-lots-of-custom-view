//
//  HazardTreeVC.swift
//  VegetationApp
//
//  Created by Nitin Bhatia on 29/03/19.
//  Copyright © 2019 Nitin Bhatia. All rights reserved.
//

import UIKit

class WorkOrderVC: UIViewController,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    //variables
    var cellHeight : CGFloat = 180
    var cellWidth : CGFloat = 0.0
    var data : [WorkOrderModel] = []
    var mcd : MasterDataController!
    let leftInset = 8
    let rightInset = 8
    var apiData : [[String:AnyObject]] = [[String:AnyObject]]()
    
    //outlets
    @IBOutlet weak var workOrderCollectionView: UICollectionView!
    @IBOutlet weak var navigationBar: Navigation!
    @IBOutlet weak var btnAdd: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mcd = MasterDataController()
        
        
        btnAdd.addTarget(self, action: #selector(addNewWorkOrder(_:)), for: .touchUpInside)
        
        
        cellWidth = self.view.bounds.width
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        setupMenuGestureRecognizer()


        navigationBar.btnMenu.addTarget(self.revealViewController(), action: #selector((SWRevealViewController.revealToggle) as (SWRevealViewController) -> (Void) -> Void), for: .touchUpInside)
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.view.showLoad()
        callApi()
    }
    
    
    
    
    //Mark:- go to add screen
    @objc private func addNewWorkOrder(_ sender:UIButton){
        performSegue(withIdentifier: "addNewCycleTrim", sender: self)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! WorkOrderCell
        cell.containerView.lblFeeder.text = mcd.getRecordById(entityName: .FeederList, id: data[indexPath.row].FeederId)["name"] as? String
        cell.containerView.lblWorkOrder.text = "\(data[indexPath.row].WorkOrderId)"
        cell.containerView.lblSegment.text = "\(data[indexPath.row].SegamentMiles)"
        cell.containerView.lblAssginedTo.text = getUserName(id: data[indexPath.row].AssignedTo)
        
        if ( data[indexPath.row].HazardTreeWithImagesList!.count > 0 ) {
            cell.containerView.lblCycleHazardNoTitle.text = "No. Of Hazard Tree:"
            cell.containerView.lblNoOfHazardTree.text = "\((data[indexPath.row].HazardTreeWithImagesList?.count)!)"
        } else {
            cell.containerView.lblCycleHazardNoTitle.text = "No. Of Cycle Trim:"
              cell.containerView.lblNoOfHazardTree.text = "\((data[indexPath.row].RowWithTreeList?.count)!)"
        }
        

        
        cell.containerView.imgView.isHidden = true
        
        cell.containerView.frame.size.height = cellHeight
        cell.containerView.frame.size.width = cellWidth - CGFloat((leftInset + rightInset))
        cell.dropShadow(color: .black, opacity: 0.5, offSet: CGSize(width: -0.6, height: 0.6), radius: 3, scale: true)
        cell.containerView.addCornerRadius(corners: .allCorners, radius: 5)
        // cell.containerView.contentView.backgroundColor = UIColor.clear
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: cellWidth - 16 , height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top:10 , left:CGFloat(leftInset), bottom:10, right:CGFloat(rightInset))
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "workOrderDetailVC") as! WorkOrderDetailVC
        vc.workOrderData = self.data[indexPath.row]
        let cell = collectionView.cellForItem(at: indexPath) as! WorkOrderCell
        vc.assignedToName = cell.containerView.lblAssginedTo.text!
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 40.0
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
                self.apiData.removeAll()
                
                for tempData in data{
                    if (tempData["UserId"] as! Int != (GetSaveUserDetailsFromUserDefault.getDetials()!.UserId )) {
                        self.apiData.append(tempData)
                    }
                }
                self.workOrderCollectionView.reloadData()

                
            } else {
                // self.showAlert(str: response["StatusMessage"]! as! String)
            }
            
        })
    }
    
    //Mark:- call api
    private func callApi(){
        let apiHandler = ApiHandler()
        let userData = GetSaveUserDetailsFromUserDefault.getDetials()
        let userId = userData!.UserId
        let url = apiUrl.getWorkOrder + "\(userId)"
        data.removeAll()
        
        apiHandler.sendGetRequest(url: url,  completionHandler: { response,error in
            print(response)
            self.view.hideLoad()
            
            if ( error != nil  ) {
                self.showAlert(str: (error?.localizedDescription)!)
                return
            }
            
            if( (response["Status"] as! Int) != 0 ) {
                do{
                    let data = response["KeyValueList"] as! [[String:AnyObject]]
                    
                    for tempData in data{
                        let jsonData = try? JSONSerialization.data(withJSONObject: tempData, options: [])
                        let model = try JSONDecoder().decode(WorkOrderModel.self, from: jsonData!)
                        self.data.append(model)
                    }
                    
                    self.callApiUser()
                    
                    if ( data.count > 0 ) {
                        self.removeNoRecordFoundLabel()
                        self.workOrderCollectionView.reloadData()
                    } else {
                        self.addNoRecordLabel(text: "No work order found", topConstraintToView: self.navigationBar)
                    }
                } catch{
                    print("json error: \(error)")
                }
            } else {
                self.showAlert(str: response["StatusMessage"]! as! String)
            }
            
        })
    }
    
    //Mark:- returns userName
    private func getUserName(id:Int)->String{
        var flag = false
        var name = ""
        
        if ( apiData.count == 0 ) {
            return ""
        }
        
        for users in apiData{
            if ( users["UserId"] as! Int == id ) {
                name = users["FirstName"] as! String
                flag = true
                break
            }
        }
        
        if ( flag ) {
            return name
        }
        return name
    }
    
}
