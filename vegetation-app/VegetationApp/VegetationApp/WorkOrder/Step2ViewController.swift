//
//  Step2ViewController.swift
//  VegetationApp
//
//  Created by Nitin Bhatia on 29/05/19.
//  Copyright © 2019 Nitin Bhatia. All rights reserved.
//

import UIKit

class Step2ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate {
    
    //variables
    var data : [AnyObject]! = [AnyObject]()
    let mcd = MasterDataController()
    var skylineFilter : [Int] = [Int]()
    var treeRemovalFilter : [Int] = [Int]()
    var selectedTemp : [Int] = [Int]()
    var filterData : [AnyObject] = [AnyObject]()
    var workOrder : WorkOrderModel!
    var preSelectedId : Int!
    
    //outlets
    @IBOutlet weak var navigationBar: Navigation!
    @IBOutlet weak var apiTableView: UITableView!
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image = UIImage(named: "ico")
        navigationBar.btnMenu.setImage(image, for: .normal)
        navigationBar.btnMenu.addTarget(self, action: #selector(back(_:)), for: .touchUpInside)
        
       
        let data = mcd.getData(entityName: "Prescription")
        
       _ = data.map({
            if (($0["type"] as! String) == filterTypePrescription.SkyLine.rawValue) {
                skylineFilter.append($0["id"] as! Int)
            } else {
                treeRemovalFilter.append($0["id"] as! Int)
            }
        })
        
        callApi()
        
        let searchBar = UISearchBar()
        searchBar.frame = CGRect(x: 0, y: 0, width: self.apiTableView.frame.width, height: 70)
        searchBar.delegate = self
        searchBar.showsCancelButton = false
        searchBar.searchBarStyle = .default
        searchBar.placeholder = ""
        searchBar.sizeToFit()
        
        apiTableView.tableHeaderView = searchBar
        apiTableView.tableFooterView = UIView()
        
    }
    
   
    
    //tableview delegates
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! WorkOrderApiTableCell
        var title = ""
        
        if let data = self.filterData[indexPath.row] as? HazardTreeModel {
            if let _ = data.Title, data.Title != "" {
                title = data.Title!
            } else {
              title = "\(mcd.getRecordById(entityName: .TreeSpecies, id: data.TreeSpeciesId)["name"] ?? "") - \(mcd.getRecordById(entityName: .FeederList, id: data.FeederId)["name"] ?? "")"
            }
            
           
            
        } else {
            let data = self.filterData[indexPath.row] as? HotSpotModel
            title = (data?.Title)!
            
           
            
            if ( title == "" ) {
                title = "HotSpot - \(mcd.getRecordById(entityName: .FeederList, id: data!.FeederId)["name"] ?? "")"
            }
        }
        
        cell.lblTitle.text = title
        cell.btnDetails.tag = indexPath.row
        cell.btnDetails.addTarget(self, action: #selector(goToDetailView(_:)), for: .touchUpInside)
        if ( selectedTemp.contains(indexPath.row) ) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        cell.selectionStyle = .none
       // let gesture = UILongPressGestureRecognizer(target: self, action: #selector(goToDetailView(_:)))
        cell.tag = indexPath.row
       // cell.addGestureRecognizer(gesture)
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let data = self.filterData[indexPath.row] as? HazardTreeModel {
            if ( preSelectedId != nil && data.HazardTreeID == preSelectedId ) {
                tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
                selectedTemp.append(indexPath.row)
                cell.accessoryType = .checkmark
            } else {
                
            }
        } else {
            let data = self.filterData[indexPath.row] as? HotSpotModel
            if ( preSelectedId != nil && data?.HotSpotID == preSelectedId ) {
                tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
                selectedTemp.append(indexPath.row)
                cell.accessoryType = .checkmark
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        selectedTemp.append(indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
        selectedTemp.remove(at: selectedTemp.index(of: indexPath.row)!)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    //Mark:- searchbar delegates
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if ( searchText != "" ) {
            if ( workOrder.WorkType == WorkType.HOTSPOT.rawValue ) {
                let data = self.data as! [HotSpotModel]
                filterData = data.filter({(($0.Title)?.lowercased().contains(searchText.lowercased()))!})
            } else {
                let data = self.data as! [HazardTreeModel]
                filterData = data.filter({(($0.Title)?.lowercased().contains(searchText.lowercased()))!})            }
        } else {
            filterData = data
        }
        apiTableView.reloadData()
        
    }
    
    
    func callApi(){
        var url = ""
        let apiHandler = ApiHandler()
        let userData = GetSaveUserDetailsFromUserDefault.getDetials()
        let userId = userData!.UserId
        
        switch workOrder.WorkType {
        case WorkType.SKYLINE.rawValue,WorkType.TREEREMOVAL.rawValue:
            url = apiUrl.getHazarList
            break
        case WorkType.HOTSPOT.rawValue:
            url = apiUrl.getHotSpotList
            break
        default:
            break
        }
        
        url = url + "\(userId)"
        data.removeAll()
        
        apiHandler.sendGetRequest(url: url,  completionHandler: { response,error in
            print(response)
            self.view.hideLoad()
            
            if ( error != nil  ) {
                self.showAlert(str: (error?.localizedDescription)!)
                return
            }
            
            if( (response["Status"] as! Int) != 0 ) {
                
                let data = response["KeyValueList"] as! [[String:AnyObject]]
                self.data.removeAll()
                do{
                   if ( self.workOrder.WorkType == WorkType.SKYLINE.rawValue || self.workOrder.WorkType == WorkType.TREEREMOVAL.rawValue ) {
                        for tempData in data{
                            if let id = tempData["WorkOrderID"] as? Int {
                                if ( id <= 0 ) {
                                    let jsonData = try? JSONSerialization.data(withJSONObject: tempData, options: [])
                                    let model = try JSONDecoder().decode(HazardTreeModel.self, from: jsonData!)
                                   
                                    self.data.append(model)
                                }
                            } else {
                                for tempData in data{
                                    let jsonData = try? JSONSerialization.data(withJSONObject: tempData, options: [])
                                    let model = try JSONDecoder().decode(HazardTreeModel.self, from: jsonData!)
                                    self.data.append(model)
                                }
                            }
                        }
                    } else {
                        for tempData in data{
                            if let id = tempData["WorkOrderID"] as? Int {
                                if ( id <= 0 ) {
                                    let jsonData = try? JSONSerialization.data(withJSONObject: tempData, options: [])
                                    let model = try JSONDecoder().decode(HotSpotModel.self, from: jsonData!)
                                    self.data.append(model)
                                }
                            } else {
                                for tempData in data{
                                    let jsonData = try? JSONSerialization.data(withJSONObject: tempData, options: [])
                                    let model = try JSONDecoder().decode(HotSpotModel.self, from: jsonData!)
                                    self.data.append(model)
                                }
                            }
                        }
                    }
                    
                    
                }
                catch {}
//                self.data.sort(by: {
//                    let rec1 = DateFormatters.shared.dateFormatterNormal.date(from: $0.CreatedAt!)
//                    let rec2 = DateFormatters.shared.dateFormatterNormal.date(from: $1.CreatedAt!)
//                    if (rec1!.compare(rec2!) == .orderedDescending){ return true }
//                    return false
//                })
               
                self.filterSortData()
                self.filterData = self.data
                self.apiTableView.reloadData()
                
                
                
            } else {
                self.showAlert(str: response["StatusMessage"]! as! String)
            }
            
        })
        
    }
    
    func filterSortData(){
        switch workOrder.WorkType {
        case WorkType.HOTSPOT.rawValue:
            var data = self.data as! [HotSpotModel]
           _ = data.filter({
                if let _ = $0.WorkOrderID as? Int {
                    if ( $0.WorkOrderID < 1 ) {
                        return true
                    }
                } else {
                    return true
                }
                return false
            })
            
            data.sort(by: {
                let rec1 = DateFormatters.shared.dateFormatterNormal.date(from: $0.CreatedAt!)
                let rec2 = DateFormatters.shared.dateFormatterNormal.date(from: $1.CreatedAt!)
                if (rec1!.compare(rec2!) == .orderedDescending){ return true }
                return false
            })
            self.data = data
            break
        case WorkType.SKYLINE.rawValue:
            var data = self.data as! [HazardTreeModel]
            var tempData = data.filter({
                if let _ = $0.WorkOrderID as? Int {
                    if ( $0.WorkOrderID < 1 ) {
                        if ( self.skylineFilter.contains($0.Prescription) ) {
                            return true
                        }
                        return false
                    }
                } else {
                    if ( self.skylineFilter.contains($0.Prescription) ) {
                        return true
                    }
                    return false
                }
                return false
            })
            
            tempData.sort(by: {
                let rec1 = DateFormatters.shared.dateFormatterNormal.date(from: $0.CreatedAt!)
                let rec2 = DateFormatters.shared.dateFormatterNormal.date(from: $1.CreatedAt!)
                if (rec1!.compare(rec2!) == .orderedDescending){ return true }
                return false
            })
            self.data = tempData
            break
        case WorkType.TREEREMOVAL.rawValue:
            var data = self.data as! [HazardTreeModel]
            var tempData = data.filter({
                if let _ = $0.WorkOrderID as? Int {
                    if ( $0.WorkOrderID < 1 ) {
                        if ( self.treeRemovalFilter.contains($0.Prescription) ) {
                            return true
                        }
                        return false
                    }
                } else {
                    if ( self.treeRemovalFilter.contains($0.Prescription) ) {
                        return true
                    }
                    return false
                }
                return false
            })
            
            tempData.sort(by: {
                let rec1 = DateFormatters.shared.dateFormatterNormal.date(from: $0.CreatedAt!)
                let rec2 = DateFormatters.shared.dateFormatterNormal.date(from: $1.CreatedAt!)
                if (rec1!.compare(rec2!) == .orderedDescending){ return true }
                return false
            })
            self.data = tempData
            break
        default:
            break
        }
        
    }
    
    //Mark:- pop to vc
    @objc func back(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        var selectedData : [AnyObject] = [AnyObject]()
        let finalIndex = apiTableView?.indexPathsForSelectedRows
        
        if ( finalIndex == nil || finalIndex!.count <= 0 ) {
            self.showAlert(str: "Please select atleast one item from the list.")
            return
        }
        
        
        for index in (finalIndex)! {
            selectedData.append(data![index.row])
        }
        
        
        let vc = segue.destination as! Step3ViewController
        vc.workOrder = self.workOrder
        vc.selectedData = selectedData
        
        
    }
    
    //Mark:- long press gesture action, go to detail view
    @objc func goToDetailView(_ sender:UIButton){
        
//        if ( sender.state != .ended ) {
//            return
//        }
        
       // let cell = sender.view as! UITableViewCell
        let indexTag = sender.tag
        if let data = self.data[indexTag] as? HazardTreeModel{
            let storyBoard = UIStoryboard(name:"HazardTree",bundle: nil)
            let vc = storyBoard.instantiateViewController(withIdentifier: "hazardTreeDetailVC") as! HazardTreeDetailVC
            vc.hazardTreeData = data
            vc.showEditButton = true
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            let data = self.data[indexTag] as? HotSpotModel
            let storyBoard = UIStoryboard(name:"HotSpot",bundle: nil)
            let vc = storyBoard.instantiateViewController(withIdentifier: "hotSpotDetailVC") as! HotSpotDetailVC
            vc.hotSpotData = data
            vc.showEditButton = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
}
