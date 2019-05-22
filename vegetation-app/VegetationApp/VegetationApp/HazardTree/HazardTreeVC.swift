//
//  HazardTreeVC.swift
//  VegetationApp
//
//  Created by Nitin Bhatia on 29/03/19.
//  Copyright © 2019 Nitin Bhatia. All rights reserved.
//

import UIKit
import SDWebImage

class HazardTreeVC: UIViewController,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIAdaptivePresentationControllerDelegate,UIPopoverPresentationControllerDelegate,HazardTreeSortFilterDelegate{
    
    //variables
    var cellHeight : CGFloat =  220 - 72//250 - 72.3 //(60 + some extra to fixed height of navigate button)
    var cellWidth : CGFloat = 0.0
    var data : [HazardTreeModel] = []
    var mcd : MasterDataController!
    let leftInset = 8
    let rightInset = 8
    
    //outlets
    @IBOutlet weak var hazardTreeCollectionView: UICollectionView!
    @IBOutlet weak var navigationBar: Navigation!
    @IBOutlet weak var btnAdd: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mcd = MasterDataController()

       
        
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
        self.view.showLoad()
        cellWidth = self.view.bounds.width

        callApi()
    }
    
    //popover delegate
    
    func setAlphaOfBackgroundViews(alpha: CGFloat) {
        let statusBarWindow = UIApplication.shared.value(forKey: "statusBarWindow") as? UIWindow
        UIView.animate(withDuration: 0.2) {
            statusBarWindow?.alpha = alpha;
            self.view.alpha = alpha;
            self.navigationController?.navigationBar.alpha = alpha;
        }
    }
    
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
        let vc = storyboard?.instantiateViewController(withIdentifier: "filterVC") as? FilterVCHazardTree
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
    
    
//    //Mark:- got to add screen for editing
//    @objc private func editHazardTree(_ sender:UIButton){
//        let vc = storyboard?.instantiateViewController(withIdentifier: "addHazardTree") as! AddHazardTreeVC
//        vc.hazardTreeData = self.data[sender.tag]
//        self.navigationController?.pushViewController(vc, animated: true)
//    }
    
    
    //Mark:- go to add screen
    @objc private func addNewCycleTrim(_ sender:UIButton){
        performSegue(withIdentifier: "addNewCycleTrim", sender: self)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! HazardTreeCell
        cell.containerView.lblRecId.text = "\(data[indexPath.row].HazardTreeID)"
        cell.containerView.lblFeeder.text = mcd.getRecordById(entityName: .FeederList, id: data[indexPath.row].FeederId)["name"] as? String
        cell.containerView.lblStatus.text = mcd.getRecordById(entityName: .Status, id: data[indexPath.row].Status)["name"] as? String
        //cell.containerView.lblRiskLevel.text = mcd.getRecordById(entityName: .RiskLevel, id: data[indexPath.row].RiskLevel)["name"] as? String
        cell.containerView.lblCurrentCondition.text = mcd.getRecordById(entityName: .CurrentConditionHazardTree, id: data[indexPath.row].Condition)["name"] as? String
        cell.containerView.lblPrescription.text = mcd.getRecordById(entityName:.Prescription, id: data[indexPath.row].Prescription)["name"] as? String
        
        cell.containerView.frame.size.height = cellHeight
        cell.containerView.frame.size.width = cellWidth - CGFloat((leftInset+rightInset))
        cell.dropShadow(color: .black, opacity: 0.5, offSet: CGSize(width: -0.6, height: 0.6), radius: 3, scale: true)
        cell.containerView.addCornerRadius(corners: .allCorners, radius: 5)
        cell.containerView.clickToNavigateView.isHidden = true
              
        let urlImage = data[indexPath.row].HzTreeImages!.count > 0 ? data[indexPath.row].HzTreeImages![0].imageFullPath : ""
        
        
        if let url = URL(string:urlImage!){
//            cell.containerView.imgView?.sd_setHighlightedImage(with: url, options:.init(rawValue: 0) , completed: { (image, error, cacheType, imageURL) in
//                cell.containerView.imgView.image = image
//            })
            cell.containerView.imgView.image = nil
            cell.containerView.imgView?.sd_setImage(with: url, placeholderImage: nil,options: .refreshCached)
        } else {
            cell.containerView.imgView.image = UIImage(named:"noimage")
        }
       // cell.containerView.btnEdit.addTarget(self, action: #selector(editHazardTree(_:)), for: .touchUpInside)
       // cell.containerView.contentView.backgroundColor = UIColor.clear
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: cellWidth - CGFloat((leftInset+rightInset)) , height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top:10 , left:CGFloat(leftInset), bottom:10, right:CGFloat(rightInset))
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "hazardTreeDetailVC") as! HazardTreeDetailVC
        vc.hazardTreeData = self.data[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 40.0
    }
    
    //Mark:- call api
    private func callApi(){
        let apiHandler = ApiHandler()
        let userData = GetSaveUserDetailsFromUserDefault.getDetials()
        let userId = userData!.UserId
        let url = apiUrl.getHazarList + "\(userId)"
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
                        let model = try JSONDecoder().decode(HazardTreeModel.self, from: jsonData!)
                        self.data.append(model)
                    }
                    
                    self.data.sort(by: {
                        let rec1 = DateFormatters.shared.dateFormatterNormal.date(from: $0.CreatedAt!)
                        let rec2 = DateFormatters.shared.dateFormatterNormal.date(from: $1.CreatedAt!)
                        if (rec1!.compare(rec2!) == .orderedDescending){ return true }
                        return false
                    })
                    
                    
                    if ( data.count > 0 ) {
                        self.removeNoRecordFoundLabel()
                        self.hazardTreeCollectionView.reloadData()
                    } else {
                        self.addNoRecordLabel(text: "No hazard tree found", topConstraintToView: self.navigationBar)
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
