//
//  CycleTrimVC.swift
//  VegetationApp
//
//  Created by Nitin Bhatia on 27/03/19.
//  Copyright © 2019 Nitin Bhatia. All rights reserved.
//

import UIKit
import CoreData
import SDWebImage

class CycleTrimVC: UIViewController,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIAdaptivePresentationControllerDelegate,UIPopoverPresentationControllerDelegate,SortFilterDelegate{
    
    //variables
    var cellHeight : CGFloat = 173
    var cellWidth : CGFloat = 0.0
    var data : [CycleTrimModel] = []
    var mcd : MasterDataController!
    let leftInset = 8
    let rightInset = 8
    
    //outlets
    @IBOutlet weak var cycleTrimCollectionView: UICollectionView!
    @IBOutlet weak var navigationBar: Navigation!
    
    @IBOutlet weak var btnAdd: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mcd = MasterDataController()
        
        self.view.showLoad()
        
        //clearing cache of sd web image
//        SDImageCache.shared().clearMemory()
//        SDImageCache.shared().clearDisk()
        
        
        
        btnAdd.addTarget(self, action: #selector(addNewCycleTrim(_:)), for: .touchUpInside)
        
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        setupMenuGestureRecognizer()
        
        
        navigationBar.btnMenu.addTarget(self.revealViewController(), action: #selector((SWRevealViewController.revealToggle) as (SWRevealViewController) -> (Void) -> Void), for: .touchUpInside)
        
        let image = UIImage(named: "ic_filter_list")
        navigationBar.btnRight.setTitle("", for: .normal)
        navigationBar.btnRight.setImage(image, for: .normal)
        navigationBar.btnRight.addTarget(self, action: #selector(filter(_:)), for: .touchUpInside)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        callApi()
        
        cellWidth = self.view.bounds.width
        cycleTrimCollectionView.reloadData()
    }
    
    //popover delegate
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        setAlphaOfBackgroundViews(alpha: 1)
    }
    
    func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
        setAlphaOfBackgroundViews(alpha: 0.7)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        // Tells iOS that we do NOT want to adapt the presentation style for iPhone
        return .none
    }
    
    @objc private func filter(_ sender: UIButton){
        //performSegue(withIdentifier: "filter", sender: self)
        let vc = storyboard?.instantiateViewController(withIdentifier: "filterVC") as? FilterVC
        vc?.modalPresentationStyle = .popover
        vc?.popoverPresentationController?.delegate = self
        vc?.popoverPresentationController?.permittedArrowDirections = [.down,.up]
        vc?.popoverPresentationController?.sourceView = sender
        vc?.popoverPresentationController?.sourceRect = sender.bounds
        vc?.preferredContentSize = CGSize(width: self.view.frame.width - 30, height: self.view.frame.height-40)
        vc?.filterFieldDelegate = self
        self.present(vc!, animated: true, completion: nil)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle{
        return .none
    }
    
    //Mark:- sort filter delegate
    func setSortFilterValue(data: [String : Any]) {
        print(data)
        setAlphaOfBackgroundViews(alpha: 1)
    }
    
    
    //Mark:- get maximum percetage of tree species
    func getHighestPerTreeSpecies(trimData : CycleTrimModel)->String{
        if(trimData.rowTreeList!.count < 1){
            return ""
        }
        trimData.rowTreeList?.sort(by: {$0.percentage > $1.percentage })
        let treeName = mcd.getRecordById(entityName: .TreeSpecies, id: trimData.rowTreeList![0].speciesId)["name"] as! String
        return treeName + "-" + "\(trimData.rowTreeList![0].percentage)%"
    }
    
    //Mark:- go to add screen
    @objc private func addNewCycleTrim(_ sender:UIButton){
        performSegue(withIdentifier: "addNewCycleTrim", sender: self)
    }
    
    //Mark:- collection view
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CycleTrimCell
        cell.containerView.lblRecId.text = "\(data[indexPath.row].rowId)"
        cell.containerView.lblClearance.text = "\(data[indexPath.row].clearance)"
        cell.containerView.lblFeeder.text = mcd.getRecordById(entityName: .FeederList, id: data[indexPath.row].feederId)["name"] as? String
        cell.containerView.lblStatus.text = mcd.getRecordById(entityName: .Status, id: data[indexPath.row].status)["name"] as? String
        cell.containerView.lblNetwork.text = data[indexPath.row].localOffice
        cell.containerView.lblTreeSpecies.text = getHighestPerTreeSpecies(trimData: data[indexPath.row])
        cell.containerView.frame.size.height = cellHeight
        cell.containerView.frame.size.width = cellWidth - CGFloat((leftInset + rightInset))
        cell.dropShadow(color: .black, opacity: 0.5, offSet: CGSize(width: -0.6, height: 0.1), radius: 3, scale: true)
        cell.containerView.addCornerRadius(corners: .allCorners, radius: 5)
        cell.containerView.contentView.backgroundColor = UIColor.clear
        cell.containerView.clickToNavigateView.isHidden = true

        
       
        let images = data[indexPath.row].rwTreeImages
       
        if ( images!.count > 0 ) {
            if let url = URL(string:(images?[0].imageFullPath!)!){
                cell.containerView.img.image = nil
                cell.containerView.img!.sd_setImage(with: url, placeholderImage: nil, options: [.refreshCached], completed: nil)
            }
        } else {
            cell.containerView.img.image = UIImage(named:"noimage")
        }
        //cell.containerView.btnEdit.addTarget(self, action: #selector(editCyleTrim(_:)), for: .touchUpInside)
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: cellWidth - CGFloat((leftInset+rightInset)) , height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        return UIEdgeInsets(top:10 , left:CGFloat(leftInset), bottom:10, right:CGFloat(rightInset))

    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 40.0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        performSegue(withIdentifier: "goToDetail", sender: indexPath)
        let vc = storyboard?.instantiateViewController(withIdentifier: "cycleTrimDetailVC") as! CycleTrimDetailVC
        vc.cycleTrimData = data[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func setAlphaOfBackgroundViews(alpha: CGFloat) {
        let statusBarWindow = UIApplication.shared.value(forKey: "statusBarWindow") as? UIWindow
        UIView.animate(withDuration: 0.2) {
            statusBarWindow?.alpha = alpha;
            self.view.alpha = alpha;
            self.navigationController?.navigationBar.alpha = alpha;
        }
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "filter" {
//            let popoverViewController = segue.destination
//            popoverViewController.popoverPresentationController!.delegate = self
//        }
//    }
    
    //Mark:- call api
    private func callApi(){
        let apiHandler = ApiHandler()
        let userData = GetSaveUserDetailsFromUserDefault.getDetials()
        let userId = userData!.UserId
        let url = apiUrl.getCycletrimList + "\(userId)"
        
        apiHandler.sendGetRequest(url: url,  completionHandler: { response,error in
            print(response)
            
            self.view.hideLoad()
            self.data.removeAll()
            
            if( (response["Status"] as! Int) != 0 ) {
                do{
                    let data = response["KeyValueList"] as! [[String:AnyObject]]
                    
                    for tempData in data{
                        
                        let jsonData = try? JSONSerialization.data(withJSONObject: tempData, options: [])
                        let model = try JSONDecoder().decode(CycleTrimModel.self, from: jsonData!)
                        //self.saveCoreData(jsonString:model)
                       
                        self.data.append(model)
                    }
                    
                    self.data.sort(by: {
                        let rec1 = DateFormatters.shared.dateFormatterNormal.date(from: $0.createdAt!)
                        let rec2 = DateFormatters.shared.dateFormatterNormal.date(from: $1.createdAt!)
                        if (rec1!.compare(rec2!) == .orderedDescending){ return true }
                        return false
                    })
                    
                  //  self.getCoreData()
                    
                    
                    if( self.data.count > 0 ) {
                        self.cycleTrimCollectionView.reloadData()
                        self.removeNoRecordFoundLabel()
                        self.cycleTrimCollectionView.isHidden = false
                        self.removeNoRecordFoundLabel()
                    } else {
                        self.addNoRecordLabel(text: "No cycle trim found",topConstraintToView: self.navigationBar)
                        self.cycleTrimCollectionView.isHidden = true
                    }
                } catch{
                    print("json error: \(error)")
                }
            } else {
                self.showAlert(str: response["StatusMessage"]! as! String)
            }
            
        })
    }
    
    //trasnfer it to Manage master file for db
    func saveCoreData(jsonString:CycleTrimModel){
//        for model in self.data{
//            let managedContext = MasterDataController.shared.managedContext!
            //let cycleEntity = CycleTrimEntity(context: managedContext)
//            for items in model.rowTreeList!{
//                let dict = items.dictionary!
//                let objRelation = RowTreeListEntity(context: managedContext)
//                objRelation.setValuesForKeys(dict)
//                cycleEntity.addToRelationship(objRelation)
//            }
//            let dict = model.dictionary!
//            cycleEntity.setValuesForKeys(dict)
//            do{
//                try managedContext.save()
//            }
//            catch{}
//           }
        //let x = getCoreData()
        
        let dict = ["id":jsonString.rowId,"jsonData":jsonString] as [String : Any]
        let managedContext = MasterDataController.shared.managedContext!
        let mcd = MasterDataController()
        mcd.saveIntoCoreData(entityName: "CycleTrimEntity", dict: dict)

    }
    
    func getCoreData(){
            let context =  MasterDataController.shared.managedContext!
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CycleTrimEntity")
            var data = [[String:Any]]()
            do {
                let results = try context.fetch(fetchRequest) as! [NSManagedObject]
                for res in results{
                    //let model = try JSONDecoder().decode(CycleTrimModel.self, from: res.value(forKey: "jsonData") as! Data)
                    self.data.append(res.value(forKey: "jsonData") as! CycleTrimModel)

//                    var temp = [String:Any]()
//                    var tempRelation = [[String:Any]]()
//                    let r = res as! CycleTrimEntity
//                    let p = r.relationship?.allObjects as! [RowTreeListEntity]
//                    for parent in p {
//                        var tempParent = [String:Any]()
//                        for attribute in parent.entity.attributesByName{
//                            //check if value is present, then add key to dictionary so as to avoid the nil value crash
//                            if let value = parent.value(forKey: attribute.key) {
//                                tempParent[attribute.key] = value
//                            }
//                        }
//                        tempRelation.append(tempParent)
//                    }
//
//                    for attribute in res.entity.attributesByName{
//                        //check if value is present, then add key to dictionary so as to avoid the nil value crash
//                        if let value = res.value(forKey: attribute.key) {
//                            temp[attribute.key] = value
//                        }
//                    }
//                    temp["rowTreeList"] = tempRelation
//                    data.append(temp)
                }
                self.data.sort(by: {
                    let rec1 = DateFormatters.shared.dateFormatterNormal.date(from: $0.createdAt!)
                    let rec2 = DateFormatters.shared.dateFormatterNormal.date(from: $1.createdAt!)
                    if (rec1!.compare(rec2!) == .orderedDescending){ return true }
                    return false
                })
                self.cycleTrimCollectionView.reloadData()
//
            } catch {
//                fatalError("Failed to fetch person: \(error)")
            }
                
        }
        
   
    

}
