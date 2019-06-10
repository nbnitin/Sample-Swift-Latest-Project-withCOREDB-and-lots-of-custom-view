//
//  Step3ViewController.swift
//  VegetationApp
//
//  Created by Nitin Bhatia on 10/04/19.
//  Copyright © 2019 Nitin Bhatia. All rights reserved.
//

import Foundation
import CoreLocation
import CropViewController
import SDWebImage

class Step3HazardTreeViewController : UIViewController,searchCurrentLocation,MapLocationDelegate,UICollectionViewDataSource,UICollectionViewDelegate,removeDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UICollectionViewDelegateFlowLayout,UITextFieldDelegate,CropViewControllerDelegate,VCOptionsDelegate{
    
    fileprivate lazy var dateFormatterNormal : DateFormatter =  {
        [unowned self] in
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        df.locale = Locale(identifier: "en_US_POSIX")
        df.timeZone = TimeZone(secondsFromGMT:0)
        return df
        }()
    
    //variables
    var workOrder:WorkOrderModel!
    var data : [HazardTreeModel] = [HazardTreeModel]()
    var unAssignedSelected : [Int] = []
    var idToBeSelected : Int = 0
    var getLocation : GetUserLocation!
    var searchLocationDelegate : searchCurrentLocation!
    var currentLocation : CLLocationCoordinate2D!
    var viewWithError : [UIView] = []
    var image : [ImageData]! = []
    var cp : ChoosePicture!
    var imagePickedlocation:String!
    var isImageRemoved : Bool!
    var base64String : String!
    var setImageWithTitle : SetImageWithTitle!
    let apiHandler : ApiHandler = ApiHandler()

    //outlets
    
    @IBOutlet weak var addHazardTreeForm: AddHazardTree!
    @IBOutlet weak var navigationBar: Navigation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addHazardTreeForm.addImageCollView.register(UINib(nibName: "AddImageCell", bundle: nil), forCellWithReuseIdentifier: "addCell")
        addHazardTreeForm.addImageCollView.register(UINib(nibName: "NewlyAddedImageCell", bundle: nil), forCellWithReuseIdentifier: "newlyAddedCell")
        
        addHazardTreeForm.addImageCollView.delegate = self
        addHazardTreeForm.addImageCollView.dataSource = self
        
        let image = UIImage(named: "ico")
        navigationBar.btnMenu.setImage(image, for: .normal)
        navigationBar.btnMenu.addTarget(self, action: #selector(back(_:)), for: .touchUpInside)
        
        addHazardTreeForm.btnSubmit.addTarget(self, action: #selector(addHazardTree(_:)), for: .touchUpInside)
        
        cp = ChoosePicture()
        setImageWithTitle = SetImageWithTitle()
        setImageWithTitle.contentView.frame = self.view.frame
        setImageWithTitle.btnSend.addTarget(self, action: #selector(btnSendImageWithTitle(_:)), for: .touchUpInside)
        
        
        //set location textbox gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(goToMapView(_:)))
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(goToMapView(_:)))
        addHazardTreeForm.txtLocation.addGestureRecognizer(tapGesture)
        addHazardTreeForm.imgLocation.addGestureRecognizer(tapGesture2)
        
        addHazardTreeForm.txtLocation.isUserInteractionEnabled = true
        addHazardTreeForm.txtLocation.isEnabled = true
        addHazardTreeForm.imgLocation.isUserInteractionEnabled = true
        addHazardTreeForm.txtLocation.delegate = self
        
        //set location first time
        getLocation = GetUserLocation()
        getLocation.delegate = self
        
         addHazardTreeForm.btnSubmit.addTarget(self, action: #selector(addHazardTree(_:)), for: .touchUpInside)
        
       
        
        //setting buttons action
        addHazardTreeForm.btnNext.addTarget(self, action: #selector(submitWorkOrder(_sender:)), for: .touchUpInside)
        addHazardTreeForm.btnSubmitSecond.addTarget(self, action: #selector(addHazardTree(_:)), for: .touchUpInside)
        callApi()
        
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    
    //Mark:- go to map view
    @objc func goToMapView(_ sender:UITapGestureRecognizer){
        let storyBoard = UIStoryboard(name: "Map", bundle: nil)
        let vc = storyBoard.instantiateInitialViewController() as! Map
        vc.mapLocationDelegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
    //Mark:- long press gesture action, go to detail view
    @objc func goToDetailView(_ sender:UILongPressGestureRecognizer){
        
        if ( sender.state != .ended ) {
            return
        }
        
        let lbl = sender.view as! UILabel
        let storyBoard = UIStoryboard(name:"HazardTree",bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "hazardTreeDetailVC") as! HazardTreeDetailVC
        vc.hazardTreeData = self.data[lbl.tag]
        vc.showEditButton = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //Mark:- done with map location delegate
    func doneWithMap(location: CLLocation) {
        self.currentLocation = location.coordinate
        self.setCurrentAddress(location: location)
    }
    
    func getCurrentLocation(location: CLLocation) {
        currentLocation = location.coordinate
        self.setCurrentAddress(location: location)
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
                    self.addHazardTreeForm.txtLocation.text = placemark.mailingAddress
                    
                }
            }
        }
    }
    
    
    //Mark:- seeting signed assgined logic here
    @objc func setUnAssignedData(_ sender:UITapGestureRecognizer){
        let lbl = sender.view as! UILabel
        if ( unAssignedSelected.contains(lbl.tag)  ) {
            setUnassignedViewStatus(status: true, label: lbl)
        } else {
            setUnassignedViewStatus(status: false, label: lbl)
        }
    }
    
    //Mark:- set or remove records from array
    private func setUnassignedViewStatus(status : Bool, label : UILabel){
       
        if ( status ) {
            unAssignedSelected.remove(at: unAssignedSelected.firstIndex(of: label.tag)!)
            label.textColor = UIColor.black
            let parentV = label.superview
            parentV?.backgroundColor = UIColor.white
        } else {
            label.textColor = UIColor.white
            let parentV = label.superview
            parentV?.backgroundColor = UIColor.black
            unAssignedSelected.append(label.tag)
        }
    }
    
    
    
    //Mark:- reload unassigned view
    
    private func removeAlreadyAddedSubViews(){
        let view = addHazardTreeForm.viewUnAssigned.subviews
        for v in view{
            v.removeFromSuperview()
        }
        addHazardTreeForm.unAssignedViewHeightConstraint.constant = 0
    }
    
    
    
    private func reloadUnassignedView(){
        var y = 0
        var tag = 0
        let heightOfButton = 40
        var index = 0
        self.unAssignedSelected.removeAll()
        removeAlreadyAddedSubViews()
        
        for hazardTree in data{
            
            tag = index
            index += 1
            
            let v =  UnAssignedButton()
            
            v.frame = CGRect(x: 0, y: y, width: Int(addHazardTreeForm.viewUnAssigned.frame.width), height: heightOfButton)
            v.contentView.frame = CGRect(x: 0, y: 0, width: Int(addHazardTreeForm.viewUnAssigned.frame.width), height: heightOfButton)
            v.lblTitle.tag = hazardTree.HazardTreeID
            v.imgStatus.tag = tag
            let touch = UITapGestureRecognizer(target: self, action: #selector(setUnAssignedData(_:)))
            let touchSecond = UILongPressGestureRecognizer(target: self, action: #selector(goToDetailView(_:)))
            v.lblTitle.addGestureRecognizer(touch)
            v.lblTitle.addGestureRecognizer(touchSecond)
            v.lblTitle.isUserInteractionEnabled = true
            
            
            
            v.contentView.backgroundColor = UIColor.white
            v.lblTitle.text = "Hazard Tree -  \(hazardTree.HazardTreeID)"
            v.lblTitle.textColor = UIColor.black
            addHazardTreeForm.viewUnAssigned.addSubview(v)
            
            //Mark:- set default selected if added new record
            if ( idToBeSelected > 0 && v.lblTitle.tag == idToBeSelected ) {
                setUnassignedViewStatus(status: false, label: v.lblTitle)
            }
            
            y += (heightOfButton + 10)
        }
        addHazardTreeForm.unAssignedViewHeightConstraint.constant = CGFloat(y + 10)
        addHazardTreeForm.unassignedLabelHeightConstraint.constant = 40
        addHazardTreeForm.lblUnassignedLabel.text = " Un Assigned Hazard Tree"
    }
    
    
    
    //Mark:- pop to vc
    @objc func back(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
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
        
     
        let feederData = addHazardTreeForm.txtFeederNo.selectedId
        
        //let poleOfOrigin = addHazardForm.txtPoleOfOrigin.getData(obj:addHazardForm.txtPoleOfOrigin) as! Int
        
        let poleOfOrigin = 0
        
        var locationInRoW : Bool = false
        let locationInBtnImage = addHazardTreeForm.btnInsideRoW.currentImage
        
        if ( locationInBtnImage == UIImage(named: "radioSelected") ) {
            locationInRoW = true
        } else {
            locationInRoW = false
        }
        
        
        let distanceInLine = addHazardTreeForm.txtDistanceToLine.text!
        let treeSpecies = addHazardTreeForm.txtTreeSpecies.selectedId
        let currentCondition = addHazardTreeForm.txtCurrentCondition.selectedId
        let prescription = addHazardTreeForm.txtPrescription.selectedId
        let accessToTree = addHazardTreeForm.txtAccessToTree.selectedId
        var enviromentalCondition = addHazardTreeForm.txtEnvComment.text!
        
        let locationEnvBtnImage = addHazardTreeForm.btnEnvYes.currentImage
        
        if ( locationEnvBtnImage == UIImage(named: "radioSelected") ) {
            enviromentalCondition = addHazardTreeForm.txtEnvComment.textColor == UIColor.lightGray ? "" : addHazardTreeForm.txtEnvComment.text!
        } else {
            enviromentalCondition = ""
        }
        
        
        let diameterAtBreast = addHazardTreeForm.txtDiameterAtBreastHeight.selectedId
        // let riskLevel = addHazardTreeForm.txtRiskLevel.getData(obj:addHazardTreeForm.txtRiskLevel) as! Int
        let comment = addHazardTreeForm.txtComment.textColor == UIColor.lightGray ? "" : addHazardTreeForm.txtComment.text!
        
        
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

        
        
        parameter["HazardTreeId"] = 0
        parameter["GeoLat"] = currentLocation.latitude
        parameter["GeoLong"] = currentLocation.longitude
        parameter["WeatherData"] = ""
        parameter["Status"] = 1
        parameter["AssignedTo"] = 11
        parameter["CreatedBy"] = ((GetSaveUserDetailsFromUserDefault.getDetials())?.UserId)
        parameter["CreatedAt"] = dateFormatterNormal.string(from: Date())
        parameter["HoursSpend"] = 11
        parameter["OCAssigned"] = 11
        parameter["FeederSubstation"] = 11
        parameter["FeederCustomerCount"] = 0
        parameter["DistBrush"] = 0
        parameter["WorkOrderID"] = 0
        
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
        
        addHazardTreeForm.fieldContainers.sort(by: {$0.tag < $1.tag})
        var isError = false
        
        for index in 1...addHazardTreeForm.fieldContainers.count - 1{
            
            let view = self.addHazardTreeForm.fieldContainers[index]
            if(view.tag != 0){
                let txt = view.subviews[0] as! UITextField
                
                if ( txt.text == "" ) {
                    self.showAlert(str: "Please enter "+txt.placeholder!)
                    view.addBorderAround(corners: .allCorners, borderCol: UIColor.red.cgColor,layerName:"error")
                    if(!viewWithError.contains(view)){
                        self.viewWithError.append(view)
                    }
                    self.addHazardTreeForm.scrollView.scrollRectToVisible(view.frame, animated: true)
                    
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
            self.view.hideLoad()
            if ( error != nil ) {
                self.showAlert(str: (error?.localizedDescription)!)
                return
            }
            self.showAlert(str: response["StatusMessage"]! as! String)
            
            self.idToBeSelected = response["Id"] as! Int
            self.showAlert(str: response["StatusMessage"]! as! String)
            self.clearForm()
            self.addImages(hazardTreeId: self.idToBeSelected)
            
        })
        
    }
    
    private func addImages(hazardTreeId: Int){
        self.view.showLoad()
        
        for img in self.image{
            if ( img.Id == 2 ) {
                //clear old sdbweb cached images 
             //   SDWebImageManager.shared().imageCache?.deleteOldFiles(completionBlock: nil)

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
        self.callApi()
        self.image.removeAll()
        self.addHazardTreeForm.addImageCollView.reloadData()
        self.view.hideLoad()
        
       
    }
    
    
    private func clearForm(){
        for view in addHazardTreeForm.fieldContainers{
            if let txt =  view.subviews[0] as? DropDownField {
                txt.text = ""
            } else if let txt = view.subviews[0] as? UITextView{
                txt.text = "Comment"
            } else {
                let txt = view.subviews[0] as? UITextField
                txt?.text = ""
            }
        }
        
    }
    
    
    //Mark:- submit work order
    @objc private func submitWorkOrder(_sender: UIButton){
        let apiHandler = ApiHandler()
        
        //validate
        if ( unAssignedSelected.count == 0 ) {
            self.showAlert(str: "Please select atleast one hazard tree to add.")
            return
        }
        
        
        var parameters :[String:Any] = [:]
        parameters["WorkOrderId"] = workOrder.WorkOrderId
       
        
        parameters["Status"] = workOrder.Status
        parameters["AssignedTo"] = workOrder.AssignedTo
        
       
        parameters["Comments"] = workOrder.Comments
        parameters["CreatedBy"] = workOrder.CreatedBy
        parameters["HzardTreeids"] = (unAssignedSelected.map{String($0)}).joined(separator: ",")
        
        
        apiHandler.sendPostRequestTypeSecond(url: apiUrl.saveWorkOrderWithHazardTree,parameters:parameters, completionHandler: { response,error in
            print(response)
            self.view.hideLoad()
            
            if ( error != nil ) {
                self.showAlert(str: (error?.localizedDescription)!)
                return
            }
            
            if((response["Status"] as! Int) != 0){
//                self.showAlert(str: response["StatusMessage"]! as! String)
                Toast.showToast(message: response["StatusMessage"]! as! String, position: .BOTTOM, length: .DEFAULT)
                
                self.navigationController?.popToRootViewController(animated: true)
            } else {
                self.showAlert(str: response["StatusMessage"]! as! String)
                self.navigationController?.popToRootViewController(animated: true)
            }
            //self.callApi()
        })
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
                
                    let data = response["KeyValueList"] as! [[String:AnyObject]]
                    self.data.removeAll()
                do{
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
                }
                catch {}
                self.data.sort(by: {
                    let rec1 = DateFormatters.shared.dateFormatterNormal.date(from: $0.CreatedAt!)
                    let rec2 = DateFormatters.shared.dateFormatterNormal.date(from: $1.CreatedAt!)
                    if (rec1!.compare(rec2!) == .orderedDescending){ return true }
                    return false
                })
                    self.reloadUnassignedView()
               
            } else {
                self.showAlert(str: response["StatusMessage"]! as! String)
            }
            
        })
    }
    

    //Mark:- collectionview
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return image.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if(indexPath.row >= image.count){
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "addCell", for: indexPath) as! AddImageCell
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "newlyAddedCell", for: indexPath) as! NewlyAddedImageCell
        if let img = (image[indexPath.row].Name) as? String{
            cell.imgAddImage.image = UIImage(named: img )
        } else {
            cell.imgAddImage.image = (image[indexPath.row].Name) as? UIImage
        }
        cell.lblTitle.text = image[indexPath.row].Title
        cell.btnTouch.addTarget(self, action: #selector(optionsActionOnImageTouch(_:)), for: .touchUpInside)
        cell.btnTouch.tag = indexPath.row
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width:100,height:100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 3)
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
    
    //Mark:- choose picture
    func isRemovePressed(success: Bool) {
        if( success ){
            isImageRemoved = true
            base64String = ""
        }
    }
    
    @objc func optionsActionOnImageTouch(_ sender:UIButton){
        let alert = UIAlertController(title: "", message: "Please choose, what you want to do?", preferredStyle: .actionSheet)
        let alertActionRemove = UIAlertAction(title: "Remove", style: .destructive, handler: {_ in self.removeImage(index: sender.tag)})
        let alertActionView = UIAlertAction(title: "View", style: .default, handler: { _ in self.viewImage(index: sender.tag)})
        alert.addAction(alertActionRemove)
        alert.addAction(alertActionView)
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func btnSendImageWithTitle(_ sender:UIButton){
        let imageData = ImageData(Id: 1, Name: setImageWithTitle.img.image!,Title:self.setImageWithTitle.txtTitle.text!,Location:self.imagePickedlocation)
        self.image.append(imageData)
        self.view.bringSubviewToFront(self.addHazardTreeForm.contentView)
        self.setImageWithTitle.contentView.removeFromSuperview()
        self.addHazardTreeForm.addImageCollView.reloadData()
        
    }
    
    @objc func cancelImageView(_ sender:UIButton){
        self.view.bringSubviewToFront(self.addHazardTreeForm.contentView)
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
        cropViewController.dismiss(animated: true, completion: nil)
    }
    
    func removeImage(index:Int){
        self.image.remove(at: index)
        self.addHazardTreeForm.addImageCollView.reloadData()
    }
    
    func viewImage(index:Int){
        let indexPath = IndexPath(item: index, section: 0)
        let cell = self.addHazardTreeForm.addImageCollView.cellForItem(at: indexPath) as! NewlyAddedImageCell
        self.setImageWithTitle.img.image = cell.imgAddImage.image
        self.view.addSubview(self.setImageWithTitle.contentView)
        self.view.bringSubviewToFront(self.setImageWithTitle.contentView)
        self.setImageWithTitle.txtTitle.text = cell.lblTitle.text!
        self.setImageWithTitle.btnSend.isEnabled = false
        self.setImageWithTitle.btnSend.isHidden = true
    }
}
