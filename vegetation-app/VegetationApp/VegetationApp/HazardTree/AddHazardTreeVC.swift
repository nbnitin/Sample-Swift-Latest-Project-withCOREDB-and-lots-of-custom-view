//
//  AddHazardTree.swift
//  VegetationApp
//
//  Created by Nitin Bhatia on 01/04/19.
//  Copyright © 2019 Nitin Bhatia. All rights reserved.
//

import UIKit
import CoreLocation
import SDWebImage
import CropViewController

class AddHazardTreeVC: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UINavigationControllerDelegate,UIImagePickerControllerDelegate,searchCurrentLocation,MapLocationDelegate,UITextFieldDelegate,CropViewControllerDelegate,ARMeasurePickedDelegate,DropDownFieldDelegate,VCOptionsDelegate{
    
    
    
    //variables
    var image : [ImageData]! = [ImageData]()
    var cp : ChoosePicture!
    var imagePickedlocation:String!
    var isImageRemoved : Bool!
    var setImageWithTitle : SetImageWithTitle!
    var getLocation : GetUserLocation!
    var searchLocationDelegate : searchCurrentLocation!
    var currentLocation : CLLocationCoordinate2D!
    var viewWithError : [UIView] = []
    var hazardTreeData : HazardTreeModel!
    let apiHandler = ApiHandler()
    var doneAlready = false
    var diameterData : [[String:Any]]!
    let mcd = MasterDataController()
    var feederOfRegion : [[String:Any]] = [[String:Any]]()

    //outlets
    @IBOutlet weak var addHazardForm: AddHazardTree!
    @IBOutlet weak var navigationBar: Navigation!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addHazardForm.addImageCollView.register(UINib(nibName: "AddImageCell", bundle: nil), forCellWithReuseIdentifier: "addCell")
        addHazardForm.addImageCollView.register(UINib(nibName: "NewlyAddedImageCell", bundle: nil), forCellWithReuseIdentifier: "newlyAddedCell")

        addHazardForm.addImageCollView.delegate = self
        addHazardForm.addImageCollView.dataSource = self
        
        let image = UIImage(named: "ico")
        navigationBar.btnMenu.setImage(image, for: .normal)
        navigationBar.btnMenu.addTarget(self, action: #selector(back(_:)), for: .touchUpInside)
        
        addHazardForm.btnSubmit.addTarget(self, action: #selector(addHazardTree(_:)), for: .touchUpInside)
        
        cp = ChoosePicture()
        setImageWithTitle = SetImageWithTitle()
        setImageWithTitle.contentView.frame = self.view.frame
        setImageWithTitle.btnSend.addTarget(self, action: #selector(btnSendImageWithTitle(_:)), for: .touchUpInside)
        setImageWithTitle.btnBack.addTarget(self, action: #selector(cancelImageView(_:)), for: .touchUpInside)
        self.setImageWithTitle.btnShare.isHidden = true
        self.setImageWithTitle.btnShare.isEnabled = false
        self.setImageWithTitle.vc = nil
        
        //set location textbox gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(goToMapView(_:)))
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(goToMapView(_:)))
        addHazardForm.txtLocation.addGestureRecognizer(tapGesture)
        addHazardForm.imgLocation.addGestureRecognizer(tapGesture2)
        
        addHazardForm.txtLocation.isUserInteractionEnabled = true
        addHazardForm.txtLocation.isEnabled = true
        addHazardForm.imgLocation.isUserInteractionEnabled = true
        
        //get master data feeder list of particular region of user
        let feeders = mcd.getData(entityName: "FeederList")
        let userRegion = GetSaveUserDetailsFromUserDefault.getDetials()?.Region
        
        for itemsFeeder in feeders {
            if ( (itemsFeeder["region"] as! String) == userRegion ) {
                self.feederOfRegion.append(itemsFeeder)
            }
        }
        
        
        //check for is editing
        if ( hazardTreeData != nil ) {
            currentLocation = CLLocationCoordinate2D(latitude: hazardTreeData.GeoLat, longitude: hazardTreeData.GeoLong)
            let location = CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
            self.setCurrentAddress(location: location)
        } else {
            //set location first time
            getLocation = GetUserLocation()
            getLocation.delegate = self
        }
        
        //giving target to button to go to ar view
        addHazardForm.btnARMeasure.addTarget(self, action: #selector(goToAr(_:)), for: .touchUpInside)
        
        //get master data diameter at breast height from local db
        let mcd = MasterDataController()
        self.diameterData = mcd.getData(entityName: "DiameterAtBreastHeight")
        
        
    }
    
    
    
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let lastView = addHazardForm.btnSubmit
        addHazardForm.scrollView.contentSize = CGSize(width:self.view.frame.width,height:(lastView?.frame.origin.y)! + (lastView?.frame.height)! + 50)
    }
    
   
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        //check for is editing
        if ( hazardTreeData != nil && !doneAlready ) {
            doneAlready = true
            setupViewForEditing()
        }
       
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return false
    }
    
    //Mark:- setup view for editing
    private func setupViewForEditing(){
        
        
        addHazardForm.txtFeederNo.setText(EntityName: .FeederList, recId: hazardTreeData.FeederId)
      //  addHazardForm.setPoleAccordingToFeeder(nearestFeederId: hazardTreeData.FeederId)
       // addHazardForm.txtPoleOfOrigin.text = mcd.getRecordById(entityName: .Poles, id: hazardTreeData.PoleId!)["name"] as? String
        
        if ( hazardTreeData.InSideRow! ) {
            addHazardForm.btnLocationIn(addHazardForm.btnInsideRoW)
        } else {
            addHazardForm.btnLocationOut(addHazardForm.btnOutsideRoW)
        }
        
        addHazardForm.txtDiameterAtBreastHeight.setText(EntityName: .DiameterAtBreastHeight, recId: hazardTreeData.Diameter)
        addHazardForm.txtDistanceToLine.text = "\(hazardTreeData.DistLine)"
        addHazardForm.txtTreeSpecies.setText(EntityName: .TreeSpecies, recId: hazardTreeData.TreeSpeciesId)
        addHazardForm.txtCurrentCondition.setText(EntityName: .CurrentConditionHazardTree, recId: hazardTreeData.Condition)
        addHazardForm.txtPrescription.setText(EntityName: .Prescription, recId: hazardTreeData.Prescription)
        addHazardForm.txtAccessToTree.setText(EntityName: .AccessToTree, recId: hazardTreeData.AccessToTree)
        addHazardForm.txtEnvComment.text = hazardTreeData.EnvCondition
        
        if ( hazardTreeData.EnvCondition != "" ) {
            addHazardForm.btnEnvYes(addHazardForm.btnEnvYes)
            addHazardForm.txtEnvComment.textColor = UIColor.black
        } else {
            addHazardForm.btnEnvNo(addHazardForm.btnEnvNo)
        }
        
        
       // addHazardForm.txtRiskLevel.setText(EntityName: .RiskLevel, recId: hazardTreeData.RiskLevel)
        addHazardForm.txtComment.text = hazardTreeData.Comments
        
        if ( addHazardForm.txtComment.text == ""  ) {
            addHazardForm.txtComment.textColor = UIColor.gray
        } else {
            addHazardForm.txtComment.textColor = UIColor.black
        }
        
        let temp = hazardTreeData.HzTreeImages
        
        if ( temp != nil ) {
            for index in 0 ..< temp!.count{
                let img = temp![index]
                let imageData = ImageData(Id: 1, Name: img.imageFullPath! as Any,Title: img.description!)
                self.image.append(imageData)
            }
            self.addHazardForm.addImageCollView.reloadData()
        }
    }
    
    //Mark:- go to map view
    @objc func goToMapView(_ sender:UITapGestureRecognizer){
        let storyBoard = UIStoryboard(name: "Map", bundle: nil)
        let vc = storyBoard.instantiateInitialViewController() as! Map
        vc.mapLocationDelegate = self
        
        if ( currentLocation != nil ) {
            vc.location = CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
        }
        
        self.present(vc, animated: true, completion: nil)
    }
    
    //Mark:- done with map location delegate
    func doneWithMap(location: CLLocation) {
        self.currentLocation = location.coordinate
        self.setCurrentAddress(location: location)
    }
    
    func getCurrentLocation(location: CLLocation) {
        currentLocation = location.coordinate
        self.setCurrentAddress(location: location)
        
//        if ( addHazardForm.txtPoleOfOrigin.text == "" ) {
//            //addHazardForm.getNearestPole(location:location)
//        }
    }
    
    func setCurrentAddress(location:CLLocation){
        location.geocode { placemark, error in
            if let error = error as? CLError {
                print("CLError:", error)
                return
            } else if let placemark = placemark?.first {
                // you should always update your UI in the main thread
                DispatchQueue.main.async {
                    
                    //  update UI here
                    print("name:", placemark.name ?? "unknown")
                    
                    print("address1:", placemark.thoroughfare ?? "unknown")
                    self.addHazardForm.txtLocation.text = placemark.mailingAddress
                    
                }
            }
        }
    }
    
    //Mark:- pop to vc
    @objc func back(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    //Mark:- collectionview
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return image.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if ( indexPath.row == 0 ) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "addCell", for: indexPath) as! AddImageCell
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "newlyAddedCell", for: indexPath) as! NewlyAddedImageCell
        if let name = (image[indexPath.row - 1].Name) as? String{
            let url = URL(string: name)
            cell.imgAddImage.sd_setImage(with:url, completed: nil)
        } else {
            cell.imgAddImage.image = (image[indexPath.row - 1].Name) as? UIImage
        }
        cell.lblTitle.text = image[indexPath.row - 1].Title
        cell.btnTouch.addTarget(self, action: #selector(optionsActionOnImageTouch(_:)), for: .touchUpInside)
        cell.btnTouch.tag = indexPath.row
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width:120,height:120)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 3, left:3 , bottom: 3, right: 3)
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let _ = collectionView.cellForItem(at: indexPath) as? AddImageCell{
            let vc : UIViewController = self
            cp.openActions(vc: vc,target: self)
            cp.vcOption = self
           //If you want remove photo option
            cp.openActions(vc: self, target: self,removePictureOption: true)
        } else {
            let cell = collectionView.cellForItem(at: indexPath) as! NewlyAddedImageCell
            self.setImageWithTitle.img.image = cell.imgAddImage.image
            self.view.addSubview(self.setImageWithTitle.contentView)
            self.view.bringSubviewToFront(self.setImageWithTitle.contentView)
            self.setImageWithTitle.txtTitle.text = cell.lblTitle.text!
           
        }
    }
    
    //Mark:- get location of image picked
    
    func optionSelected(_ location: ImagePickedLocationEnum) {
        self.imagePickedlocation = location.rawValue
    }
    
    
    @objc func optionsActionOnImageTouch(_ sender:UIButton){
        let alert = UIAlertController(title: "", message: "Please choose, what you want to do?", preferredStyle: .actionSheet)
        let alertActionRemove = UIAlertAction(title: "Remove", style: .destructive, handler: {_ in self.removeImage(index: sender.tag)})
        let alertActionView = UIAlertAction(title: "View", style: .default, handler: { _ in self.viewImage(index: sender.tag)})

        if ( image[sender.tag - 1].Id == 2 ) {
            alert.addAction(alertActionRemove)
            alert.addAction(alertActionView)
        } else {
            alert.addAction(alertActionView)
        }
       
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func btnSendImageWithTitle(_ sender:UIButton){
        let imageData = ImageData(Id: 2, Name: setImageWithTitle.img.image!,Title:self.setImageWithTitle.txtTitle.text!,Location:self.imagePickedlocation)
        self.image.append(imageData)
        self.view.bringSubviewToFront(self.addHazardForm.contentView)
        self.setImageWithTitle.contentView.removeFromSuperview()
        self.addHazardForm.addImageCollView.reloadData()
        
    }
    
    @objc func cancelImageView(_ sender:UIButton){
        self.view.bringSubviewToFront(self.addHazardForm.contentView)
        self.setImageWithTitle.contentView.removeFromSuperview()
    }
   
    
    func imagePickerController(_ picker: UIImagePickerController,                           didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey  : Any])
    {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            dismiss(animated: true, completion: {
                let cropViewController = CropViewController(image: pickedImage.fixOrientation())
                cropViewController.delegate = self
                self.present(cropViewController, animated: true, completion: nil)
                
            })
        }
        
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated:true, completion: nil)
        
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        self.setImageWithTitle.img.image = image //fixes upside donw image problem clicked from camera
        self.view.addSubview(self.setImageWithTitle.contentView)
        self.view.bringSubviewToFront(self.setImageWithTitle.contentView)
        self.setImageWithTitle.txtTitle.text = ""
        self.setImageWithTitle.btnSend.isEnabled = true
        self.setImageWithTitle.btnSend.isHidden = false
        self.setImageWithTitle.btnShare.isEnabled = false
        self.setImageWithTitle.btnShare.isHidden = true
        cropViewController.dismiss(animated: true, completion: nil)
    }
    
    func removeImage(index:Int){
        self.image.remove(at: index - 1)
        self.addHazardForm.addImageCollView.reloadData()
    }
    
    func viewImage(index:Int){
        let indexPath = IndexPath(item: index, section: 0)
        let cell = self.addHazardForm.addImageCollView.cellForItem(at: indexPath) as! NewlyAddedImageCell
        
        if ( hazardTreeData != nil ){
            let treeImages = hazardTreeData.HzTreeImages
            
            if ( index < treeImages!.count  ) {
                let imageName = treeImages![index - 1].imageFullPathOriginal
                let url = URL(string:imageName!)
                setImageWithTitle.activity.startAnimating()
                setImageWithTitle.loadingContainer.isHidden = false
                self.setImageWithTitle.img.sd_setImage(with: url, completed: {
                    (image, error, cacheType, url) in
                    self.setImageWithTitle.loadingContainer.isHidden = true
                    self.setImageWithTitle.activity.stopAnimating()
                    self.setImageWithTitle.activity.isHidden = true
                    })
            } else {
                self.setImageWithTitle.img.image = cell.imgAddImage.image
            }
        } else {
            self.setImageWithTitle.img.image = cell.imgAddImage.image
        }
        self.view.addSubview(self.setImageWithTitle.contentView)
        self.view.bringSubviewToFront(self.setImageWithTitle.contentView)
        self.setImageWithTitle.txtTitle.text = cell.lblTitle.text!
        self.setImageWithTitle.btnSend.isEnabled = false
        self.setImageWithTitle.btnSend.isHidden = true
        self.setImageWithTitle.btnShare.isHidden = false
        self.setImageWithTitle.btnShare.isEnabled = true
        self.setImageWithTitle.vc = self
    }
    
    //Mark:- go to ar view to pick up diameter
    @objc private func goToAr(_ sender:UIButton){
        if #available(iOS 12.0, *) {
            // use the feature only available in iOS 9
            // for ex. UIStackView
        
        let storyBoard = UIStoryboard(name: "ARMeasure", bundle: nil)
        let vc = storyBoard.instantiateInitialViewController() as! NewVC
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
        }else {
            self.showAlert(str: "Sorry, this is not supported in your current OS Version.")
        }
    }
    
    func diameterPicked(dia: Double) {
        //let values = self.addHazardForm.txtDiameterAtBreastHeight.picker1Text
        print(dia)
        var index = 0
        var flag = false
        
        
        
        for range in diameterData{
            let lowerBound = range["min"] as! Double
            let upperBound = range["max"] as! Double
            
            if ((lowerBound...upperBound).contains(dia.roundToDecimal(1))) {
                flag = true
                break
            }
            index += 1
        }
        
        if ( flag ) {
           
            addHazardForm.txtDiameterAtBreastHeight.text = diameterData[index]["name"] as? String
            addHazardForm.txtDiameterAtBreastHeight.selectedName = diameterData[index]["name"] as? String
            addHazardForm.txtDiameterAtBreastHeight.selectedId = diameterData[index]["id"] as? Int
        }
    }
  
    
    //Mark:- add hazard tree api
    @objc private func addHazardTree(_ sender:UIButton){
        
        
        if(validateForm()){
            return
        }
        
        if ( currentLocation == nil ) {
            self.showAlertWithSettings()
            return
        }
        

        
        let feederData = addHazardForm.txtFeederNo.selectedId
        
        //let poleOfOrigin = addHazardForm.txtPoleOfOrigin.getData(obj:addHazardForm.txtPoleOfOrigin) as! Int
        
        let poleOfOrigin = 0
        
        var locationInRoW : Bool = false
        let locationInBtnImage = addHazardForm.btnInsideRoW.currentImage
        
        if ( locationInBtnImage == UIImage(named: "radioSelected") ) {
            locationInRoW = true
        } else {
            locationInRoW = false
        }
        
        
        let distanceInLine = addHazardForm.txtDistanceToLine.text!
        let treeSpecies = addHazardForm.txtTreeSpecies.selectedId
        let currentCondition = addHazardForm.txtCurrentCondition.selectedId
        let prescription = addHazardForm.txtPrescription.selectedId
        let accessToTree = addHazardForm.txtAccessToTree.selectedId
        var enviromentalCondition = addHazardForm.txtEnvComment.text!
        
        let locationEnvBtnImage = addHazardForm.btnEnvYes.currentImage
        
        if ( locationEnvBtnImage == UIImage(named: "radioSelected") ) {
            enviromentalCondition = addHazardForm.txtEnvComment.textColor == UIColor.lightGray ? "" : addHazardForm.txtEnvComment.text!
        } else {
            enviromentalCondition = ""
        }
        
        
        let diameterAtBreast = addHazardForm.txtDiameterAtBreastHeight.selectedId
       // let riskLevel = addHazardForm.txtRiskLevel.getData(obj:addHazardForm.txtRiskLevel) as! Int
        let comment = addHazardForm.txtComment.textColor == UIColor.lightGray ? "" : addHazardForm.txtComment.text!
  
        
        var parameter : [String:Any] = [:]
       
        parameter["FeederId"] = feederData
        parameter["Prescription"] = prescription
        parameter["TreeSpeciesId"] = treeSpecies
        parameter["DistLine"] = distanceInLine
       // parameter["RiskLevel"] = riskLevel
        parameter["Comments"] = comment
        parameter["Condition"] = currentCondition
        parameter["Diameter"] = diameterAtBreast
        parameter["AccessToTree"] = accessToTree
        parameter["EnvCondition"] = enviromentalCondition
        parameter["InSideRow"] = locationInRoW
        parameter["PoleId"] = poleOfOrigin

       
        
        parameter["HazardTreeId"] = hazardTreeData == nil ? 0 : hazardTreeData.HazardTreeID
        parameter["GeoLat"] = currentLocation.latitude
        parameter["GeoLong"] = currentLocation.longitude
        parameter["WeatherData"] = ""
        parameter["Status"] = hazardTreeData == nil ? 1 : hazardTreeData.Status
        parameter["AssignedTo"] = hazardTreeData == nil ? 0 : hazardTreeData.AssignedTo
        parameter["CreatedBy"] = ((GetSaveUserDetailsFromUserDefault.getDetials())?.UserId)
        parameter["CreatedAt"] = hazardTreeData == nil ? DateFormatters.shared.dateFormatterNormal.string(from:Date()) : hazardTreeData.CreatedAt
        parameter["HoursSpend"] = hazardTreeData == nil ? 0 : hazardTreeData.HoursSpend
        parameter["OCAssigned"] = hazardTreeData == nil ? 0 : hazardTreeData.OCAssigned
        parameter["FeederSubstation"] = hazardTreeData == nil ? 0 : hazardTreeData.FeederSubstation
        parameter["FeederCustomerCount"] = hazardTreeData == nil ? 0 : hazardTreeData.FeederCustomerCount
        parameter["DistBrush"] = diameterAtBreast
        parameter["WorkOrderID"] = hazardTreeData == nil ? 0 : hazardTreeData.WorkOrderID
        
        if ( image.count <= 0 || image == nil ) {
            let alert = UIAlertController(title: "Confirm?", message: "Are you sure, you want to add Hazard Tree without image ?", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Continue", style: .default, handler: {(UIAlertAction) in
                self.view.showLoad()
                self.addHazardTreeApi(parameters: parameter)
            })
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        } else {
            self.view.showLoad()
            self.addHazardTreeApi(parameters: parameter)
        }
        
        
    
    }
    
    private func validateForm()->Bool{
        
        addHazardForm.fieldContainers.sort(by: {$0.tag < $1.tag})
        var isError = false
        
        for index in 1...addHazardForm.fieldContainers.count - 1{
            
            let view = self.addHazardForm.fieldContainers[index]
            if(view.tag != 0){
                let txt = view.subviews[0] as! UITextField
                
                if ( txt.text == "" ) {
                    self.showAlert(str: "Please enter "+txt.placeholder!)
                    view.addBorderAround(corners: .allCorners, borderCol: UIColor.red.cgColor,layerName:"error")
                    if(!viewWithError.contains(view)){
                        self.viewWithError.append(view)
                    }
                    self.addHazardForm.scrollView.scrollRectToVisible(view.frame, animated: true)
                    
                    isError = true
                    break
                } else {
                    if ( viewWithError.contains(view) ) {
                        
                        for layer in view.layer.sublayers!{
                            if(layer.name == "error") {
                                layer.removeFromSuperlayer()
                            }
                        }
                        viewWithError.remove(at: viewWithError.firstIndex(of: view)!)
                    }
                }
            }
        }
        return isError
        
        
        
        
    }
    
    
    private func addHazardTreeApi(parameters:[String:Any]){
     
        apiHandler.sendPostRequestTypeSecond(url: apiUrl.addHazardTree,parameters:parameters, completionHandler: { response,error in
            print(response)
            
            if ( error != nil ) {
                self.showAlert(str: (error?.localizedDescription)!)
                return
            }
            self.clearForm()
            Toast.showToast(message: response["StatusMessage"]! as! String, position: .BOTTOM, length: .DEFAULT)
            self.view.hideLoad()
            self.addImages(hazardTreeId: response["Id"] as! Int)
            
        })
        
    }
    
    private func addImages(hazardTreeId: Int){
        self.view.showLoad()
        
        for img in self.image{
            if ( img.Id == 2 ) {
                let imageData:NSData = (img.Name as! UIImage).jpegData(compressionQuality: 0.7)! as NSData
                
                var parameter : [String:Any] = [:]
                parameter["HazardTreeId"] = hazardTreeId
                parameter["UserId"] = GetSaveUserDetailsFromUserDefault.getDetials()?.UserId
                parameter["Status"] = 1
                parameter["Description"] = img.Title
                
                if ( img.Location != ImagePickedLocationEnum.gallery.rawValue) {
                    parameter["Geo_Lat"] = currentLocation.latitude
                    parameter["Geo_Long"] = currentLocation.longitude
                } else {
                    parameter["Geo_Lat"] = 0.0
                    parameter["Geo_Long"] = 0.0
                }
                parameter["Weather_Data"] = ""
                parameter["SeqNo"] = 0
                parameter["RefGeoLat"] = currentLocation.latitude
                parameter["RefGeoLong"] = currentLocation.longitude
                parameter["imgText"] = imageData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
                parameter["FileExtensionWithoutDot"] = "jpg"
                
                apiHandler.sendPostRequestTypeSecond(url: apiUrl.addImageToHazardTree,parameters:parameter, completionHandler: { response,error in
                    print(response)
                    
                    if ( error != nil ) {
                        self.showAlert(str: (error?.localizedDescription)!)
                        return
                    }
                    
                    
                })
            }
        }
        self.image.removeAll()
        self.addHazardForm.addImageCollView.reloadData()
        self.view.hideLoad()
        
        if ( self.hazardTreeData == nil ) {
            self.confirmToAddMore()
        } else {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    private func clearForm(){
        for view in addHazardForm.fieldContainers{
            if let txt =  view.subviews[0] as? PopUpPickers {
                txt.text = ""
                txt.selectedName = ""
                txt.selectedId = -1
            } else if let txt = view.subviews[0] as? UITextView{
                txt.text = "Comment"
                txt.textColor = UIColor.lightGray
            } else {
                let txt = view.subviews[0] as? UITextField
                txt?.text = ""
            }
        }
        
    }
    
    private func confirmToAddMore(){
        let alert = UIAlertController(title: "Confirm?", message: "Do you want to add more hazard tree ?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default, handler: nil)
        let noAciton = UIAlertAction(title: "No", style: .cancel, handler: {(UIAlertAction) in
            self.navigationController?.popToRootViewController(animated: true)
        })
        alert.addAction(yesAction)
        alert.addAction(noAciton)
        self.present(alert, animated: true, completion: nil)
    }
    

}

extension Double {
    func roundToDecimal(_ fractionDigits: Int) -> Double {
        let multiplier = pow(10, Double(fractionDigits))
        return Darwin.round(self * multiplier) / multiplier
    }
}
