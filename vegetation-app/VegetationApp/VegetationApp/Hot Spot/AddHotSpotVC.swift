//
//  AddHotSpot.swift
//  VegetationApp
//
//  Created by Nitin Bhatia on 24/05/19.
//  Copyright © 2019 Nitin Bhatia. All rights reserved.
//

import UIKit
import CoreLocation
import SDWebImage
import CropViewController

class AddHotSpotVC: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UINavigationControllerDelegate,UIImagePickerControllerDelegate,searchCurrentLocation,MapLocationDelegate,UITextFieldDelegate,CropViewControllerDelegate,DropDownFieldDelegate,VCOptionsDelegate,UITableViewDelegate,UITableViewDataSource{
    
    
    
    //variables
    var image : [ImageData]! = [ImageData]()
    var treeSpeciesData : [TreeSpeciesPercentage] = []
    let heightOfTreeSpeciesCell : CGFloat = 70.0
    var cp : ChoosePicture!
    var imagePickedlocation:String!
    var isImageRemoved : Bool!
    var setImageWithTitle : SetImageWithTitle!
    var getLocation : GetUserLocation!
    var searchLocationDelegate : searchCurrentLocation!
    var currentLocation : CLLocationCoordinate2D!
    var viewWithError : [UIView] = []
    var hotSpotData : HotSpotModel!
    let apiHandler = ApiHandler()
    var doneAlready = false
    var diameterData : [[String:Any]]!
    let mcd = MasterDataController()
    var feederOfRegion : [[String:Any]] = [[String:Any]]()
    
    //outlets
    @IBOutlet weak var addHotSpotForm: AddHotSpot!
    @IBOutlet weak var navigationBar: Navigation!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addHotSpotForm.btnAddNewTreeSpecies.addTarget(self, action: #selector(addNewTreeSpecies(_:)), for: .touchUpInside)
        addHotSpotForm.newlyAddedTreeSpeciesTableView.register(UINib(nibName: "NewlyAddedTreeSpecies", bundle: nil), forCellReuseIdentifier: "cell")
        addHotSpotForm.newlyAddedTreeSpeciesHeightConstraint.constant = 1
        addHotSpotForm.newlyAddedTreeSpeciesTableView.delegate = self
        addHotSpotForm.newlyAddedTreeSpeciesTableView.dataSource = self
        
        addHotSpotForm.addImageCollView.register(UINib(nibName: "AddImageCell", bundle: nil), forCellWithReuseIdentifier: "addCell")
        addHotSpotForm.addImageCollView.register(UINib(nibName: "NewlyAddedImageCell", bundle: nil), forCellWithReuseIdentifier: "newlyAddedCell")
        
        addHotSpotForm.addImageCollView.delegate = self
        addHotSpotForm.addImageCollView.dataSource = self
        
        let image = UIImage(named: "ico")
        navigationBar.btnMenu.setImage(image, for: .normal)
        navigationBar.btnMenu.addTarget(self, action: #selector(back(_:)), for: .touchUpInside)
        
        addHotSpotForm.btnSubmit.addTarget(self, action: #selector(addHotSpot(_:)), for: .touchUpInside)
        
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
        addHotSpotForm.txtLocation.addGestureRecognizer(tapGesture)
        addHotSpotForm.imgLocation.addGestureRecognizer(tapGesture2)
        
        addHotSpotForm.txtLocation.isUserInteractionEnabled = true
        addHotSpotForm.txtLocation.isEnabled = true
        addHotSpotForm.imgLocation.isUserInteractionEnabled = true
        
        //get master data feeder list of particular region of user
        let feeders = mcd.getData(entityName: "FeederList")
        let userRegion = GetSaveUserDetailsFromUserDefault.getDetials()?.Region
        
        for itemsFeeder in feeders {
            if ( (itemsFeeder["region"] as! String) == userRegion ) {
                self.feederOfRegion.append(itemsFeeder)
            }
        }
        
        
        //check for is editing
        if ( hotSpotData != nil ) {
            currentLocation = CLLocationCoordinate2D(latitude: hotSpotData.GeoLat, longitude: hotSpotData.GeoLong)
            let location = CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
            self.setCurrentAddress(location: location)
            navigationBar.lblTitle.text = "Edit Hot Spot"
        } else {
            //set location first time
            getLocation = GetUserLocation()
            getLocation.delegate = self
        }
      
    }
  
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let lastView = addHotSpotForm.btnSubmit
        addHotSpotForm.scrollView.contentSize = CGSize(width:self.view.frame.width,height:(lastView?.frame.origin.y)! + (lastView?.frame.height)! + 50)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        //check for is editing
        if ( hotSpotData != nil && !doneAlready ) {
            doneAlready = true
            setupViewForEditing()
        }
        
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return false
    }
    
    //Mark:- setup view for editing
    private func setupViewForEditing(){
        addHotSpotForm.txtTitle.text = hotSpotData.Title
        addHotSpotForm.txtTitle.superview?.backgroundColor = UIColor.white
        addHotSpotForm.txtTitle.isEnabled = true
        addHotSpotForm.txtFeederNo.setText(EntityName: .FeederList, recId: hotSpotData.FeederId)
        addHotSpotForm.txtComment.text = hotSpotData.Comments
        addHotSpotForm.txtAccessToTree.setText(EntityName: .AccessToTree, recId: hotSpotData.AccessToTree)
        
        if ( addHotSpotForm.txtComment.text == ""  ) {
            addHotSpotForm.txtComment.textColor = UIColor.gray
        } else {
            addHotSpotForm.txtComment.textColor = UIColor.black
        }
        
        if ( hotSpotData.EnvCondition != "" ) {
            addHotSpotForm.btnEnvYes(addHotSpotForm.btnEnvYes)
            addHotSpotForm.txtEnvComment.textColor = UIColor.black
            addHotSpotForm.txtEnvComment.text = hotSpotData.EnvCondition
        } else {
            addHotSpotForm.btnEnvNo(addHotSpotForm.btnEnvNo)
        }
        
        for data in (hotSpotData?.HotSpotTreeList)!{
            addNewTreeSpecies(treeSpeciesId: data.speciesId,name: data.speciesName!,percentage: "")
        }
        
        let temp = hotSpotData.HotSpotImages
        
        if ( temp != nil ) {
            for index in 0 ..< temp!.count{
                let img = temp![index]
                let imageData = ImageData(Id: 1, Name: img.imageFullPath! as Any,Title: img.description!)
                self.image.append(imageData)
            }
            self.addHotSpotForm.addImageCollView.reloadData()
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
        
        //        if ( addHotSpotForm.txtPoleOfOrigin.text == "" ) {
        //            //addHotSpotForm.getNearestPole(location:location)
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
                    self.addHotSpotForm.txtLocation.text = placemark.mailingAddress
                    
                }
            }
        }
    }
    
    //Mark:- pop to vc
    @objc func back(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    private func addNewTreeSpecies(treeSpeciesId:Int,name:String,percentage:String){
        
        let treeSpeciesTempData = TreeSpeciesPercentage(id: treeSpeciesId, name:name, percentage: 0)
        self.treeSpeciesData.append(treeSpeciesTempData)
        
        addHotSpotForm.newlyAddedTreeSpeciesTableView.reloadData()
        addHotSpotForm.newlyAddedTreeSpeciesHeightConstraint.constant += heightOfTreeSpeciesCell
        addHotSpotForm.addFormContainerHeightConstaraint.constant += heightOfTreeSpeciesCell
    }
    
    //Mark:- add new tree species into model and reload collectionview
    @objc private func addNewTreeSpecies(_ sender : UIButton){
        
        if ( addHotSpotForm.txtTreeSpecies.text == "" ) {
            self.showAlert(str: "Please select tree species.")
            return
        }
        
        let treeSpeciesId = addHotSpotForm.txtTreeSpecies.selectedId
        let treeSpeciesName = addHotSpotForm.txtTreeSpecies.text!
        addHotSpotForm.txtTreeSpecies.text = ""
        
        var isTreeAlreadyAdded = false
        var treeFoundAt = -1
        
        for treeAlready in treeSpeciesData{
            treeFoundAt += 1
            if ( treeAlready.id == treeSpeciesId ) {
                treeSpeciesData[treeFoundAt].percentage = 0
                isTreeAlreadyAdded = true
                break
            }
        }
        
        
        
        //update if already exists
        if ( isTreeAlreadyAdded ) {
            treeSpeciesData[treeFoundAt].percentage = 0
            treeSpeciesData[treeFoundAt].name = treeSpeciesName
            addHotSpotForm.newlyAddedTreeSpeciesTableView.reloadData()
        } else {
            //insert if not exists
            addNewTreeSpecies(treeSpeciesId: treeSpeciesId!,name: treeSpeciesName,percentage: "")
        }
        addHotSpotForm.txtTreeSpecies.selectedId = -1
        addHotSpotForm.txtTreeSpecies.selectedName = ""
    }
    
    //Mark:- remove tree species
    @objc private func removeNewTreeSpecies(_ sender : UIButton){
        treeSpeciesData.remove(at: sender.tag)
        addHotSpotForm.newlyAddedTreeSpeciesHeightConstraint.constant -= heightOfTreeSpeciesCell
        addHotSpotForm.addFormContainerHeightConstaraint.constant -= heightOfTreeSpeciesCell
        addHotSpotForm.newlyAddedTreeSpeciesTableView.reloadData()
    }
    
    //Mark:- treespecies tree view
    func numberOfSections(in tableView: UITableView) -> Int {
        return treeSpeciesData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! NewlyAddedTreeSpeciesTableViewCell
        cell.lblTreeSpeciesName.text = treeSpeciesData[indexPath.section].name
        cell.addCornerRadius(corners: .allCorners, radius: 5)
        cell.btnDelete.tag = indexPath.section
        cell.btnDelete.addTarget(self, action: #selector(self.removeNewTreeSpecies(_:)),for: .touchUpInside)
        cell.selectionStyle = .none
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    // Set the spacing between sections
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    // Make the background color show through
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        
        return headerView
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
        self.view.bringSubviewToFront(self.addHotSpotForm.contentView)
        self.setImageWithTitle.contentView.removeFromSuperview()
        self.addHotSpotForm.addImageCollView.reloadData()
        
    }
    
    @objc func cancelImageView(_ sender:UIButton){
        self.view.bringSubviewToFront(self.addHotSpotForm.contentView)
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
        self.addHotSpotForm.addImageCollView.reloadData()
    }
    
    func viewImage(index:Int){
        let indexPath = IndexPath(item: index, section: 0)
        let cell = self.addHotSpotForm.addImageCollView.cellForItem(at: indexPath) as! NewlyAddedImageCell
        
        if ( image[index-1].Id as? Int == 1 ){
            let treeImages = hotSpotData.HotSpotImages
            
            if ( index - 1 < treeImages!.count  ) {
                let imageName = treeImages![index - 1].imageFullPathOriginal
                let url = URL(string:imageName!)
                setImageWithTitle.contentView.showLoadOtherFormat(title: "Please wait...", desc: "Loading high resolution image.")
                self.setImageWithTitle.img.sd_setImage(with: url, completed: {
                    (image, error, cacheType, url) in
                    self.setImageWithTitle.contentView.hideLoadOtherView()
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
    
    
    
    //Mark:- add hazard tree api
    @objc private func addHotSpot(_ sender:UIButton){
        
        
        if(validateForm()){
            return
        }
        
        if ( currentLocation == nil ) {
            self.showAlertWithSettings()
            return
        }
        
        
        
        let feederData = addHotSpotForm.txtFeederNo.selectedId
        let title = addHotSpotForm.txtTitle.text!
        //let poleOfOrigin = addHotSpotForm.txtPoleOfOrigin.getData(obj:addHotSpotForm.txtPoleOfOrigin) as! Int
        
        let poleOfOrigin = 0
        
        
        
        var str = ""
        for treeSpeciesName in treeSpeciesData{
            str += "\(treeSpeciesName.id):\(treeSpeciesName.percentage),"
        }
        if(str == ""){
            self.showAlert(str: "Please select atleast one tree species.")
            return
        }
        str = str.substring(to: str.index(before: str.endIndex))
        
        
        let accessToTree = addHotSpotForm.txtAccessToTree.selectedId
        let comment = addHotSpotForm.txtComment.textColor == UIColor.lightGray ? "" : addHotSpotForm.txtComment.text!
        
        var enviromentalCondition = addHotSpotForm.txtEnvComment.text!
        let locationEnvBtnImage = addHotSpotForm.btnEnvYes.currentImage
     
        if ( locationEnvBtnImage == UIImage(named: "radioSelected") ) {
            enviromentalCondition = addHotSpotForm.txtEnvComment.textColor == UIColor.lightGray ? "" : addHotSpotForm.txtEnvComment.text!
        } else {
            enviromentalCondition = ""
        }
        
        
        
        
        var parameter : [String:Any] = [:]
        parameter["Title"] = title
        parameter["FeederId"] = feederData
        parameter["PoleId"] = poleOfOrigin
        parameter["SpeciesSelected"] = str
        parameter["Comments"] = comment
        parameter["AccessToTree"] = accessToTree
        parameter["HotSpotId"] = hotSpotData == nil ? 0 : hotSpotData.HotSpotID
        parameter["GeoLat"] = currentLocation.latitude
        parameter["GeoLong"] = currentLocation.longitude
        parameter["WeatherData"] = ""
        parameter["Status"] = hotSpotData == nil ? 1 : hotSpotData.Status
        parameter["AssignedTo"] = hotSpotData == nil ? 0 : hotSpotData.AssignedTo
        parameter["CreatedBy"] = ((GetSaveUserDetailsFromUserDefault.getDetials())?.UserId)
        parameter["CreatedAt"] = hotSpotData == nil ? DateFormatters.shared.dateFormatterNormal.string(from:Date()) : hotSpotData.CreatedAt
        parameter["OCAssigned"] = hotSpotData == nil ? 0 : hotSpotData.OCAssigned
        parameter["FeederSubstation"] = hotSpotData == nil ? 0 : hotSpotData.FeederSubstation
        parameter["FeederCustomerCount"] = hotSpotData == nil ? 0 : hotSpotData.FeederCustomerCount
        parameter["WorkOrderID"] = hotSpotData == nil ? 0 : hotSpotData.WorkOrderID
        parameter["EnvCondition"] = enviromentalCondition
        
        if ( image.count <= 0 || image == nil ) {
            let alert = UIAlertController(title: "Confirm?", message: "Are you sure, you want to add Hot Spot without image ?", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Continue", style: .default, handler: {(UIAlertAction) in
                self.view.showLoad()
                self.addHotSpotApi(parameters: parameter)
            })
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        } else {
            self.view.showLoad()
            self.addHotSpotApi(parameters: parameter)
        }
        
        
        
    }
    
    private func validateForm()->Bool{
        
        addHotSpotForm.fieldContainers.sort(by: {$0.tag < $1.tag})
        var isError = false
        
        for index in 1...addHotSpotForm.fieldContainers.count - 1{
            
            let view = self.addHotSpotForm.fieldContainers[index]
            
            if ( view.tag != 0 ) {
                let txt = view.subviews[0] as! UITextField
                
                if ( txt.text == "" ) {
                    self.showAlert(str: "Please enter "+txt.placeholder!)
                    view.addBorderAround(corners: .allCorners, borderCol: UIColor.red.cgColor,layerName:"error")
                    if(!viewWithError.contains(view)){
                        self.viewWithError.append(view)
                    }
                    self.addHotSpotForm.scrollView.scrollRectToVisible(view.frame, animated: true)
                    
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
    
    
    private func addHotSpotApi(parameters:[String:Any]){
        
        apiHandler.sendPostRequestTypeSecond(url: apiUrl.addHotSpot,parameters:parameters, completionHandler: { response,error in
            print(response)
            self.view.hideLoad()

            if ( error != nil ) {
                self.showAlert(str: (error?.localizedDescription)!)
                return
            }
            self.clearForm()
            Toast.showToast(message: response["StatusMessage"]! as! String, position: .BOTTOM, length: .DEFAULT)
            self.view.hideLoad()
            self.addImages(hotSpotId: response["Id"] as! Int)
        })
        
    }
    
    private func addImages(hotSpotId: Int){
        self.view.showLoad()
        
        for img in self.image{
            if ( img.Id == 2 ) {
                let imageData:NSData = (img.Name as! UIImage).jpegData(compressionQuality: 0.7)! as NSData
                
                var parameter : [String:Any] = [:]
                parameter["HotSpotImageId"] = 0
                parameter["HotSpotId"] = hotSpotId
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
                
                apiHandler.sendPostRequestTypeSecond(url: apiUrl.addHotSpotImage,parameters:parameter, completionHandler: { response,error in
                    print(response)
                    
                    if ( error != nil ) {
                        self.showAlert(str: (error?.localizedDescription)!)
                        return
                    }
                    
                    
                })
            }
        }
        self.image.removeAll()
        self.addHotSpotForm.addImageCollView.reloadData()
        self.view.hideLoad()
        
        if ( self.hotSpotData == nil ) {
            self.confirmToAddMore()
        } else {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    private func clearForm(){
        for view in addHotSpotForm.fieldContainers{
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
       
        treeSpeciesData.removeAll()
        addHotSpotForm.newlyAddedTreeSpeciesTableView.reloadData()
        addHotSpotForm.newlyAddedTreeSpeciesHeightConstraint.constant = 0
        addHotSpotForm.txtEnvComment.text = ""
        addHotSpotForm.btnEnvNo(addHotSpotForm.btnEnvNo)
        addHotSpotForm.btnEnvNo.setImage(UIImage(named: "radio"), for: .normal)
    }
    
    private func confirmToAddMore(){
        let alert = UIAlertController(title: "Submitted", message: "Do you want to create more?", preferredStyle: .alert)
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
