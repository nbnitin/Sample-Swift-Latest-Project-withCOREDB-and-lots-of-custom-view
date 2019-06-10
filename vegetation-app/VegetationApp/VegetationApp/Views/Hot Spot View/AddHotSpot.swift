//
//  AddHazardTree.swift
//  VegetationApp
//
//  Created by Nitin Bhatia on 24/05/19.
//  Copyright © 2019 Nitin Bhatia. All rights reserved.
//

import UIKit
import CoreLocation

@IBDesignable
class AddHotSpot: UIView,UITextViewDelegate,CLLocationManagerDelegate,DropDownFieldDelegate,UITextFieldDelegate,CustomTableProtocol {
    
    //variables
    let textEnvriomentHeight = 128
    let margin = 10
    var nextTag = 12
    var feederOfRegion : [[String:Any]] = [[String:Any]]()
    var isForceEndEditing : Bool = false
    
    //outlets
    
    @IBOutlet weak var envHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var txtEnvComment: UITextView!
    @IBOutlet weak var btnEnvYes: UIButton!
    @IBOutlet weak var btnEnvNo: UIButton!
    
    
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var buttonsContainer: UIView!
    
    @IBOutlet weak var btnSubmitSecond: UIButton!
    @IBOutlet weak var lblUnassignedLabel: UILabel!
    @IBOutlet weak var txtTreeSpecies: PopUpPickers!
    
    @IBOutlet weak var newlyAddedTreeSpeciesHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var unAssignedViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var unassignedLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewUnAssigned: UIView!
    
    @IBOutlet var contentView: UIView!
    
    @IBOutlet var fieldContainers: [UIView]!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var addImageCollView: UICollectionView!
   
    @IBOutlet weak var btnSubmit: UIButton!
   
    @IBOutlet weak var imgLocation: UIImageView!
    @IBOutlet weak var txtLocation: UITextField!
    @IBOutlet weak var txtComment: UITextView!
    
    @IBOutlet weak var txtTitle: UITextField!
    
    @IBOutlet weak var txtAccessToTree: PopUpPickers!
    @IBOutlet weak var txtFeederNo: PopUpPickers!
    
    
    @IBOutlet weak var headerTitleViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var imgHeaderChevron: UIImageView!
    @IBOutlet weak var lblHeaderTitle: UILabel!
    @IBOutlet weak var headerTitleView: UIView!
    @IBOutlet weak var addFormContainerHeightConstaraint: NSLayoutConstraint!
    
    @IBOutlet weak var btnAddNewTreeSpecies: UIButton!
    
    @IBOutlet weak var newlyAddedTreeSpeciesTableView: UITableView!
    override func draw(_ rect: CGRect) {
        
        var index = 0
        
        for vi in fieldContainers{
            
            
                vi.addCornerRadius(corners: .allCorners, radius: 10)
                vi.addBorderAround(corners: .allCorners)
                vi.addShadow(offset: CGSize(width:-0.6,height:0.6))
                
                if let txt = vi.subviews[0] as? PopUpPickers {                    txt.delegate = self as UITextFieldDelegate
                }
            if ( vi.subviews.count > 1 ) {
                if let img = vi.subviews[1] as? UIImageView {
                    let gesTap = UITapGestureRecognizer(target: self, action: #selector(openCorrespondingTextField(_:)))
                    img.addGestureRecognizer(gesTap)
                    img.isUserInteractionEnabled = true
                }
            }
            
            index += 1
        }
       
        btnEnvNo.addTarget(self, action: #selector(btnEnvNo(_:)), for: .touchUpInside)
        btnEnvYes.addTarget(self, action: #selector(btnEnvYes(_:)), for: .touchUpInside)
        
        txtComment.delegate = self
        txtComment.text = "Comment"
        txtComment.textColor = UIColor.lightGray
        
        
        txtEnvComment.delegate = self
        txtEnvComment.textColor = UIColor.lightGray
        txtEnvComment.text = "Comment"
        
        txtTreeSpecies.delegate = self as UITextFieldDelegate
       
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideShowAddForm))
//        self.headerTitleView.addGestureRecognizer(tapGesture)
//        self.headerTitleView.isUserInteractionEnabled = true
        
        
        
    }
    
    @objc public func btnEnvYes(_ sender : UIButton){
        if ( !txtEnvComment.isHidden && btnEnvYes.currentImage == UIImage(named: "radioSelected" ) ) { return  }
        
        
        btnEnvYes.setImage(UIImage(named: "radioSelected"), for: .normal)
        btnEnvNo.setImage(UIImage(named: "radio"), for: .normal)
        envHeightConstraint.constant += (128 + 10) // 128 is the height of textview and 10 is for margin
        txtEnvComment.isHidden = false
        txtEnvComment.frame.size.height = 128
        txtEnvComment.addBorderAround(corners: .allCorners)
        self.addFormContainerHeightConstaraint.constant += (128 + 10)
        
        
        
        
        
        self.contentView.layoutIfNeeded()
        
    }
    
    @objc public func btnEnvNo(_ sender : UIButton){
        if ( txtEnvComment.isHidden && btnEnvNo.currentImage == UIImage(named: "radioSelected") ) { return  }
        
        btnEnvNo.setImage(UIImage(named: "radioSelected"), for: .normal)
        btnEnvYes.setImage(UIImage(named: "radio"), for: .normal)
        
        if ( !txtEnvComment.isHidden ) {
            envHeightConstraint.constant -= (128 + 10) // 128 is the height of textview and 10 is for margin
            txtEnvComment.frame.size.height = 0
            txtEnvComment.isHidden = true
            self.addFormContainerHeightConstaraint.constant -= (128 + 10)
        }
        
        
    }
    
    @objc func openCorrespondingTextField(_ sender:UITapGestureRecognizer) {
        let view = sender.view as! UIImageView
        let superView = view.superview as! UIView
        if let txt = superView.subviews[0] as? PopUpPickers {
            txt.becomeFirstResponder()
        }
    }
    
    @IBInspectable
    var ShowButtonContainer : Bool = false{
        didSet{
            self.btnSubmit.isHidden = true
            self.buttonsContainer.isHidden = false
            self.btnNext.isHidden = false
        }
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
            
            if ( buttonsContainer.isHidden ) {
                self.addFormContainerHeightConstaraint.constant =  btnSubmit.frame.origin.y + btnSubmit.frame.height + 30
            } else {
                
                self.addFormContainerHeightConstaraint.constant =  buttonsContainer.frame.origin.y + buttonsContainer.frame.height + 30
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
    
    
    //Mark:- textfield delegate
    func textFieldDidEndEditing(_ textField: UITextField) {
        if ( isForceEndEditing ) {return}
        
        nextTag = textField.tag + 1
        if let txtDrop = self.contentView.viewWithTag(nextTag) as? UITextField{
            txtDrop.becomeFirstResponder()
        } else {
            self.contentView.endEditing(true)
            
        }
        
        
        
        
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        
        
        guard let txtObj = textField as? PopUpPickers else {return true}
        
        let vx = CustomTable()
        vx.frame = CGRect(x: 0, y: 0, width: (self.superview?.frame.width)!, height: (self.superview?.frame.height)!)
        vx.contentView.frame = vx.frame
        isForceEndEditing = true
        self.endEditing(true)
        vx.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.6)
        self.superview?.addSubview(vx)
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
        
        self.bringSubviewToFront(vx)
        vx.selectedTextBoxObj = txtObj
        vx.navigationView.showRightButton = false
        vx.selectedId = txtObj.selectedId
        vx.EntityName = txtObj.EntityName
        vx.customTableDelegate = self
        return false
    }
    
    //Mark:- pop picker delegate
    func valueSelected(obj: PopUpPickers) {
        
        isForceEndEditing = false
        
        
        
        if ( obj.tag != 20 ) {
            let nextTag = obj.tag + 1
            if let txtDrop = self.contentView.viewWithTag(nextTag) as? PopUpPickers{
                
                
                    if ( txtDrop.text!.isEmpty  ) {
                        txtDrop.becomeFirstResponder()
                    }
               
            }
        } else {
            if let txtDrop = txtTreeSpecies{
                if ( txtDrop.text!.isEmpty ) {
                    txtDrop.becomeFirstResponder()
                }
            }
        }
        
        
        
        if ( obj == txtFeederNo ) {
            
            
            
            //let selectedId = obj.picker1Value[obj.selectedIndex]
            //setPoleAccordingToFeeder(nearestFeederId: selectedId)
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
        
        if ( textField == txtTitle ) {
            return range.location < 20
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
        //old
        ////        for temp in poles{
        ////            if ( temp["feederId"] as! Int == nearestFeederId ) {
        ////                txtPoleOfOrigin.picker1Value.append(temp["id"] as! Int)
        ////                txtPoleOfOrigin.picker1Text.append(temp["name"] as! String)
        ////            }
        ////        }
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
        //        finalPoles = mcd.getPolesAccordingToFeeder(value: idsArray)
        //
        //        //old
        ////        poles.filter({
        ////            idsArray.contains($0["feederId"] as! Int)
        ////        })
        ////
        ////        finalPoles = poles
        //
        ////        for temp in feederOfRegion{
        ////            let poles = mcd.getRecordOfIntColumn(entityName: .Poles, keyToSearch: "feederId", value: temp["id"] as! Int)
        ////            finalPoles.append(poles)
        ////
        //////            for pol in poles{
        //////                if ( pol["feederId"] as! Int == temp["id"] as! Int ) {
        //////                    finalPoles.append(pol)
        //////                }
        //////            }
        ////        }
        //
        //        finalPoles.sort(by: {
        //            let coordinate1 = CLLocation(latitude: $0["geoLat"] as! CLLocationDegrees, longitude: $0["geoLong"] as! CLLocationDegrees)
        //            let coordinate2 = CLLocation(latitude: $1["geoLat"] as! CLLocationDegrees, longitude: $1["geoLong"] as! CLLocationDegrees)
        //            let xLocation = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        //            //closest will be at top
        //            return coordinate1.distance(from: xLocation) < coordinate2.distance(from:xLocation)
        //        })
        //
        //        if ( finalPoles.count > 0 ) {
        //            txtPoleOfOrigin.text = finalPoles[0]["name"] as? String
        //            let nearestFeederId = finalPoles[0]["feederId"] as! Int
        //
        //
        //            setPoleAccordingToFeeder(nearestFeederId: nearestFeederId)
        //
        //            let indexOfFeederId = txtFeederNo.picker1Value.index(of:nearestFeederId)
        //            txtFeederNo.selectedIndex = indexOfFeederId!
        //            txtFeederNo.text = txtFeederNo.picker1Text[txtFeederNo.selectedIndex]
        //        }
        //
        //        self.hideLoad()
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
        let view = Bundle.main.loadNibNamed("AddHotSpot", owner: self, options: nil)?[0] as! UIView
        addSubview(view)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight,.flexibleWidth,.flexibleTopMargin]
        
        
    }
    
    
    
}


