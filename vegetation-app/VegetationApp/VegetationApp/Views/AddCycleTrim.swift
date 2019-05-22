//
//  AddCycleTrim.swift
//  VegetationApp
//
//  Created by Nitin Bhatia on 01/04/19.
//  Copyright © 2019 Nitin Bhatia. All rights reserved.
//

import UIKit
import CoreLocation

@IBDesignable

class AddCycleTrim: UIView,UITextViewDelegate,UITextFieldDelegate,CustomTableProtocol {
    
    //variables
    var feederOfRegion : [[String:Any]] = [[String:Any]]()
    
    //Outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet var fieldContainers: [UIView]!
    @IBOutlet weak var txtClearance: UITextField!
    @IBOutlet weak var btnSubmitSecond: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var buttonContainer: UIView!
    @IBOutlet weak var imgLocation: UIImageView!
    @IBOutlet weak var txtTreeSpeciesPer: UITextField!
    @IBOutlet weak var txtTreeSpecies: PopUpPickers!
    @IBOutlet weak var txtLocation: UITextField!
    @IBOutlet weak var txtComment: UITextView!
    @IBOutlet weak var txtCurrentCondition: PopUpPickers!
    @IBOutlet weak var txtAccessToLine: PopUpPickers!
    @IBOutlet weak var txtLineConstruction: PopUpPickers!
    @IBOutlet weak var txtTreeDensity: PopUpPickers!
   // @IBOutlet weak var txtPoleOfOrigin: DropDownField!
    @IBOutlet weak var txtFeederNo: PopUpPickers!
    
    @IBOutlet weak var unAssignedHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewUnAssgined: UIView!
    @IBOutlet weak var newlyAddedTreeSpeciesTableView: UITableView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var addImageCollView: UICollectionView!
    
    @IBOutlet weak var btnAddTreeSpecies: UIButton!
    @IBOutlet weak var btnSubmit: UIButton!
    
    @IBOutlet weak var lblUnassignedTitle: UILabel!
    @IBOutlet weak var newlyAddedTreeSpeciesContainer: UIView!
    
    @IBOutlet weak var unassginedLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var treeSpeciesPerContainer: UIView!
    @IBOutlet weak var newlyAddedTreeSpeciesHeightConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var headerTitleViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var imgHeaderChevron: UIImageView!
    @IBOutlet weak var lblHeaderTitle: UILabel!
    @IBOutlet weak var headerTitleView: UIView!
    @IBOutlet weak var addFormContainerHeightConstaraint: NSLayoutConstraint!
    
    override func draw(_ rect: CGRect) {
        for vi in fieldContainers{
            vi.addCornerRadius(corners: .allCorners, radius: 10)
            vi.addBorderAround(corners: .allCorners)
            vi.addShadow(offset: CGSize(width:-0.6,height:0.6))
            
            if let txt = vi.subviews[0] as? PopUpPickers {
                txt.delegate = self as! UITextFieldDelegate
                
            }
        }
        
        txtTreeSpecies.addCornerRadius(corners: .allCorners, radius: 10)
        treeSpeciesPerContainer.addCornerRadius(corners: .allCorners, radius: 10)
        btnAddTreeSpecies.addCornerRadius(corners: .allCorners, radius: 10)
        
        
        
        
        txtClearance.delegate = self
        txtComment.delegate = self
        txtComment.text = "Comment"
        txtComment.textColor = UIColor.lightGray
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideShowAddForm))
        self.headerTitleView.addGestureRecognizer(tapGesture)
        self.headerTitleView.isUserInteractionEnabled = true
    }
    
    
    
    @IBInspectable
    var ShowButtonContainer : Bool = false{
        didSet{
            buttonContainer.isHidden = false
            btnSubmit.isHidden = true
            self.btnNext.isHidden = false
        }
    }
    
    
    
    //Mark:- textfield delegate
    func textFieldDidEndEditing(_ textField: UITextField) {
//        nextTag += 1
//        
//        if ( textField.tag == 11 || textField.tag == 17 ) {
//            self.endEditing(true)
//            return
//        }
//        if let txtDrop = self.contentView.viewWithTag(nextTag) as? UITextField{
//            txtDrop.becomeFirstResponder()
//        } else {
//            self.contentView.endEditing(true)
//        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        guard let txtObj = textField as? PopUpPickers else {return true}
        let vx = CustomTable()
        vx.frame = CGRect(x: 0, y: 0, width: (self.superview?.frame.width)!, height: (self.superview?.frame.height)!)
        self.endEditing(true)
        vx.contentView.frame = vx.frame
        vx.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.6)
        self.superview?.addSubview(vx)
        self.bringSubviewToFront(vx)
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
        
        vx.selectedTextBoxObj = txtObj
        vx.navigationView.showRightButton = false
        vx.selectedId = txtObj.selectedId
        vx.EntityName = txtObj.EntityName
        vx.customTableDelegate = self
        return false
    }
    
    //Mark:- pop picker delegate
    func valueSelected(obj: PopUpPickers) {
        if ( obj.tag != 20 ) {
            let nextTag = obj.tag + 1
            if let txtDrop = self.contentView.viewWithTag(nextTag) as? PopUpPickers{
                if ( txtDrop.text!.isEmpty ) {
                    txtDrop.becomeFirstResponder()
                }
            }
        } else {
            if let txtDrop = txtTreeSpeciesPer{
                if ( txtDrop.text!.isEmpty ) {
                    txtDrop.becomeFirstResponder()
                }
            }
        }
        
        if ( obj == txtFeederNo ) {
           // let selectedId = obj.picker1Value[obj.selectedIndex]
         //   setPoleAccordingToFeeder(nearestFeederId: selectedId)
            //            txtPoleOfOrigin.text = ""
            //            txtPoleOfOrigin.picker1.reloadAllComponents()
            //            txtPoleOfOrigin.selectedIndex = -1
            
            //old
            //            let mcd = MasterDataController()
            //            let poles = mcd.getData(entityName: "Poles")
            //            txtPoleOfOrigin.picker1Value.removeAll()
            //            txtPoleOfOrigin.picker1Text.removeAll()
            //
            //            for temp in poles{
            //
            //                if ( temp["feederId"] as! Int == selectedId ) {
            //                    txtPoleOfOrigin.picker1Value.append(temp["id"] as! Int)
            //
            //                    txtPoleOfOrigin.picker1Text.append(temp["name"] as! String)
            //
            //                }
            //            }
            //            txtPoleOfOrigin.text = ""
            //            txtPoleOfOrigin.picker1.reloadAllComponents()
            //            txtPoleOfOrigin.selectedIndex = -1
        }
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == txtClearance {
            
            let countdots = textField.text!.components(separatedBy:".").count - 1
            let textAfterDot = textField.text!.components(separatedBy:".")
            
            if countdots > 0 && string == "."
            {
                return false
            }
            
            let isDeleteKey = string.isEmpty
            
            if ( textAfterDot.count > 1 && !isDeleteKey  ) {
                if ( textAfterDot[1].count >= 2 ) {
                    return false
                }
            }
            
            return range.location < 12
        }
        return true
    }
   
    
    //Mark:- textview delegates
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Comment"
            textView.textColor = UIColor.lightGray
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return range.location < 501
    }
    
    
    @IBInspectable
    var ShowHeader : Bool = false{
        didSet{
            self.headerTitleViewHeightConstraint.constant = 40
            self.addFormContainerHeightConstaraint.constant = 0
            self.scrollView.contentSize.height = btnNext.frame.origin.y + btnNext.frame.height
           
            for views in fieldContainers{
                views.isHidden = true
            }
            
            self.imgHeaderChevron.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        }
    }
    
    @objc func hideShowAddForm(_ sender:UITapGestureRecognizer){
        
        if ( self.addFormContainerHeightConstaraint.constant == 0 ) {
            
            UIView.animate(withDuration: 0.8, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.9, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                self.imgHeaderChevron.transform = CGAffineTransform(rotationAngle: CGFloat.pi*2)
            }, completion: { success in
                print("success")
            })
            
            if ( buttonContainer.isHidden ) {
                self.addFormContainerHeightConstaraint.constant =  btnSubmit.frame.origin.y + btnSubmit.frame.height + 30
            } else {
                
                self.addFormContainerHeightConstaraint.constant =  (buttonContainer.frame.origin.y + buttonContainer.frame.height)
            }
            
            for views in fieldContainers{
                views.isHidden = false
            }
        } else {
            
            self.addFormContainerHeightConstaraint.constant = 0
            
            for views in fieldContainers{
                views.isHidden = true
            }
            UIView.animate(withDuration: 0.8, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.9, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                self.imgHeaderChevron.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
            }, completion: { success in
                print("success")
            })
        }
       self.scrollView.contentSize.height = btnNext.frame.origin.y + btnNext.frame.height
    }
    
    //Mark:- get feeder in region
    func getFeederInRegion(){
        let mcd = MasterDataController()
        //get master data feeder list of particular region of user
        let userRegion = GetSaveUserDetailsFromUserDefault.getDetials()?.Region
        
        self.feederOfRegion = mcd.getRecordOfStringColumn(entityName: .FeederList, keyToSearch: "region", value: userRegion!)
        
        
    }
    
    //Mark:- Set poles according to feeder
    func setPoleAccordingToFeeder(nearestFeederId:Int){
//        self.showLoad()
//        let mcd = MasterDataController()
//        txtPoleOfOrigin.picker1Text.removeAll()
//        txtPoleOfOrigin.picker1Value.removeAll()
//        let poles = mcd.getPolesAccordingToFeeder(value: [nearestFeederId])
//
//        poles.map({
//            txtPoleOfOrigin.picker1Value.append($0["id"] as! Int)
//            txtPoleOfOrigin.picker1Text.append($0["name"] as! String)
//        })
//        txtPoleOfOrigin.picker1.reloadAllComponents()
//
//        //old
//        //        for temp in poles{
//        //            if ( temp["feederId"] as! Int == nearestFeederId ) {
//        //                txtPoleOfOrigin.picker1Value.append(temp["id"] as! Int)
//        //                txtPoleOfOrigin.picker1Text.append(temp["name"] as! String)
//        //            }
//        //        }
//        self.hideLoad()
    }
    
    //Mark:- set nearest pole
    func getNearestPole(location:CLLocation){
//        self.showLoad()
//        getFeederInRegion()
//        
//        let mcd = MasterDataController()
//        
//        let poles = mcd.getData(entityName: "Poles")
//        var finalPoles : [[String:Any]] = [[String:Any]]()
//        txtPoleOfOrigin.picker1Text.removeAll()
//        txtPoleOfOrigin.picker1Value.removeAll()
//        
//        var idsArray : [Int] = []
//        for i in self.feederOfRegion{
//            idsArray.append(i["id"] as! Int)
//        }
//        
//        finalPoles  = mcd.getPolesAccordingToFeeder(value: idsArray)
//        //old
////        poles.filter({
////            if ( idsArray.contains($0["feederId"] as! Int) ) {
////                print($0["feederId"])
////                return true
////            }
////            return false
////           // idsArray.contains($0["feederId"] as! Int)
////        })
//        
//       // finalPoles = poles
//        
//        //        for temp in feederOfRegion{
//        //            let poles = mcd.getRecordOfIntColumn(entityName: .Poles, keyToSearch: "feederId", value: temp["id"] as! Int)
//        //            finalPoles.append(poles)
//        //
//        ////            for pol in poles{
//        ////                if ( pol["feederId"] as! Int == temp["id"] as! Int ) {
//        ////                    finalPoles.append(pol)
//        ////                }
//        ////            }
//        //        }
//        
//        finalPoles.sort(by: {
//            let coordinate1 = CLLocation(latitude: $0["geoLat"] as! CLLocationDegrees, longitude: $0["geoLong"] as! CLLocationDegrees)
//            let coordinate2 = CLLocation(latitude: $1["geoLat"] as! CLLocationDegrees, longitude: $1["geoLong"] as! CLLocationDegrees)
//            let xLocation = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
//            //closest will be at top
//            return coordinate1.distance(from: xLocation) < coordinate2.distance(from:xLocation)
//        })
        
       
//        if ( finalPoles.count > 0 ) {
//            txtPoleOfOrigin.text = finalPoles[0]["name"] as? String
//            let nearestFeederId = finalPoles[0]["feederId"] as! Int
//
//
//            setPoleAccordingToFeeder(nearestFeederId: nearestFeederId)
//
            //old
            
           // let indexOfFeederId = txtFeederNo.picker1Value.index(of:nearestFeederId)
            //txtFeederNo.selectedIndex = indexOfFeederId!
           // txtFeederNo.text = txtFeederNo.picker1Text[txtFeederNo.selectedIndex]
      //  }
        
       // self.hideLoad()
    }
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        commonInit()
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit(){
        let view = Bundle.main.loadNibNamed("AddCycleTrim", owner: self, options: nil)?[0] as! UIView
        addSubview(view)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight,.flexibleWidth,.flexibleTopMargin]
        
    }
    

}
