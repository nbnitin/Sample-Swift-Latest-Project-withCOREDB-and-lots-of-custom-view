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
    var data : [[WorkOrderModel]] = [[WorkOrderModel]]()
    var mcd : MasterDataController!
    let leftInset = 8
    let rightInset = 8
    var apiData : [[String:AnyObject]] = [[String:AnyObject]]()
    var sections : [String] = [String]()
    
    //outlets
    @IBOutlet weak var workOrderCollectionView: UICollectionView!
    @IBOutlet weak var navigationBar: Navigation!
    @IBOutlet weak var btnAdd: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mcd = MasterDataController()
        
        
        btnAdd.addTarget(self, action: #selector(addNewWorkOrder(_:)), for: .touchUpInside)
        
        if ( GetSaveUserDetailsFromUserDefault.getDetials()!.Type > 2 ) {
            btnAdd.isHidden = true
        }
        
        
        cellWidth = self.view.bounds.width
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        setupMenuGestureRecognizer()


        navigationBar.btnMenu.addTarget(self.revealViewController(), action: #selector((SWRevealViewController.revealToggle) as (SWRevealViewController) -> (Void) -> Void), for: .touchUpInside)
        // Do any additional setup after loading the view.
        //sticky header
        let layout = workOrderCollectionView.collectionViewLayout as? UICollectionViewFlowLayout // casting is required because UICollectionViewLayout doesn't offer header pin. Its feature of UICollectionViewFlowLayout
        layout?.sectionHeadersPinToVisibleBounds = true
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
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "sections", for: indexPath) as? SectionHeader{
            sectionHeader.lblSectionTitle.text = sections[indexPath.section]
            
            return sectionHeader
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return data[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! WorkOrderCell
        cell.containerView.lblTitle.text = data[indexPath.section][indexPath.row].Title
        
        cell.containerView.lblWorkOrder.text = "\(data[indexPath.section][indexPath.row].WorkOrderId)"
        cell.containerView.lblAssginedTo.text =  data[indexPath.section][indexPath.row].AssignedToName
        cell.containerView.lblSegment.text = DateFormatters.shared.dateFormatter2.string(from: DateFormatters.shared.dateFormatterNormal.date(from: data[indexPath.section][indexPath.row].DueDate!)!)
        
        if (  data[indexPath.section][indexPath.row].HazardTreeList != nil && data[indexPath.section][indexPath.row].HazardTreeList!.count > 0 ) {
            cell.containerView.lblCycleHazardNoTitle.text = "No. Of Hazard Tree:"
            cell.containerView.lblNoOfHazardTree.text = "\((data[indexPath.section][indexPath.row].HazardTreeList?.count)!)"
        } else {
            cell.containerView.lblCycleHazardNoTitle.text = "No. Of Hot Spot:"
              cell.containerView.lblNoOfHazardTree.text = "\((data[indexPath.section][indexPath.row].HotSpotList?.count)!)"
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
        vc.workOrderData = self.data[indexPath.section][indexPath.row]
        let cell = collectionView.cellForItem(at: indexPath) as! WorkOrderCell
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
        sections.removeAll()
        
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
                    var tempWorkModel = [WorkOrderModel]()
                    
                    for tempData in data{
                        let jsonData = try? JSONSerialization.data(withJSONObject: tempData, options: [])
                        let model = try JSONDecoder().decode(WorkOrderModel.self, from: jsonData!)
                        tempWorkModel.append(model)
                    }
                    
                   tempWorkModel.sort(by: {
                        let rec1 = DateFormatters.shared.dateFormatterNormal.date(from: $0.CreatedAt)
                        let rec2 = DateFormatters.shared.dateFormatterNormal.date(from: $1.CreatedAt)
                        if (rec1!.compare(rec2!) == .orderedDescending){ return true }
                        return false
                    })
                    
                    let tempApproved = tempWorkModel.filter({$0.Status == 5})
                    let tempWorking = tempWorkModel.filter({$0.Status == 2})
                    let tempComplete = tempWorkModel.filter({$0.Status == 4})
                    let tempAssigned = tempWorkModel.filter({$0.Status == 6 || $0.Status == 3})
                    
                    
                    
                    self.data.append(tempAssigned)
                    self.data.append(tempWorking)
                    self.data.append(tempComplete)
                    self.data.append(tempApproved)
                    tempWorkModel.removeAll()

                    self.callApiUser()
                    
                    if ( data.count > 0 ) {
                        self.removeNoRecordFoundLabel()
                        self.sections.append("Assigned")
                        self.sections.append("Working")
                        self.sections.append("Complete")
                        self.sections.append("Approved")
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
