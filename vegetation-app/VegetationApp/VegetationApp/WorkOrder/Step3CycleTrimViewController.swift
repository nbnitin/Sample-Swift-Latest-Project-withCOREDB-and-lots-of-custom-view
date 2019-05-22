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

class Step3CycleTrimViewController : UIViewController,searchCurrentLocation,MapLocationDelegate,UITableViewDataSource,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UITableViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UITextFieldDelegate,CropViewControllerDelegate,VCOptionsDelegate{
    
    
    fileprivate lazy var dateFormatterNormal : DateFormatter =  {
        [unowned self] in
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        df.locale = Locale(identifier: "en_US_POSIX")
        df.timeZone = TimeZone(secondsFromGMT:0)
        return df
        }()
    
    //variables
    let apiHandler = ApiHandler()
    var workOrder:WorkOrderModel!
    var data : [CycleTrimModel] = [CycleTrimModel]()
    var unAssignedSelected : [Int] = []
    var treeSpeciesData : [TreeSpeciesPercentage] = []
    var getLocation : GetUserLocation!
    var searchLocationDelegate : searchCurrentLocation!
    var currentLocation : CLLocationCoordinate2D!
    var viewWithError : [UIView] = []
    var idToBeSelected : Int = 0
    var image : [ImageData]! = []
    var cp : ChoosePicture!
    var imagePickedlocation:String!
    var setImageWithTitle : SetImageWithTitle!
    var oldHeightOfAddForm : CGFloat = 0.0
    var addcycleTrimId = 0
    let heightOfTreeSpeciesCell : CGFloat = 70.0
    
    //outlets
    @IBOutlet weak var addCycleTrimForm: AddCycleTrim!
    @IBOutlet weak var navigationBar: Navigation!
    @IBOutlet weak var addFormHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var lblAddNewTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let image = UIImage(named: "ico")
        navigationBar.btnMenu.setImage(image, for: .normal)
        navigationBar.btnMenu.addTarget(self, action: #selector(back(_:)), for: .touchUpInside)
        //setting buttons action
        addCycleTrimForm.btnNext.addTarget(self, action: #selector(submitWorkOrder(_sender:)), for: .touchUpInside)
        addCycleTrimForm.btnSubmitSecond.addTarget(self, action: #selector(addCycleTrim(_:)), for: .touchUpInside)
        
        
        treeSpeciesData.removeAll()
        
        //set location textbox gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(goToMapView(_:)))
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(goToMapView(_:)))
        addCycleTrimForm.txtLocation.addGestureRecognizer(tapGesture)
        addCycleTrimForm.imgLocation.addGestureRecognizer(tapGesture2)
        
        addCycleTrimForm.txtLocation.isUserInteractionEnabled = true
        addCycleTrimForm.txtLocation.isEnabled = true
        addCycleTrimForm.txtLocation.delegate = self
        addCycleTrimForm.imgLocation.isUserInteractionEnabled = true
        
        //set location first time
        getLocation = GetUserLocation()
        getLocation.delegate = self
        
        
        addCycleTrimForm.btnAddTreeSpecies.addTarget(self, action: #selector(addNewTreeSpecies(_:)), for: .touchUpInside)
        addCycleTrimForm.newlyAddedTreeSpeciesTableView.register(UINib(nibName: "NewlyAddedTreeSpecies", bundle: nil), forCellReuseIdentifier: "cell")
        addCycleTrimForm.newlyAddedTreeSpeciesHeightConstraint.constant = 1
        addCycleTrimForm.newlyAddedTreeSpeciesTableView.delegate = self
        addCycleTrimForm.newlyAddedTreeSpeciesTableView.dataSource = self
        
        addCycleTrimForm.addImageCollView.register(UINib(nibName: "AddImageCell", bundle: nil), forCellWithReuseIdentifier: "addCell")
        addCycleTrimForm.addImageCollView.register(UINib(nibName: "NewlyAddedImageCell", bundle: nil), forCellWithReuseIdentifier: "newlyAddedCell")
        
        addCycleTrimForm.addImageCollView.delegate = self
        addCycleTrimForm.addImageCollView.dataSource = self
        //addCycleTrimForm.addImageCollView.backgroundColor = UIColor.red
        
        
        cp = ChoosePicture()
        
        setImageWithTitle = SetImageWithTitle()
        setImageWithTitle.contentView.frame = self.view.frame
        setImageWithTitle.btnSend.addTarget(self, action: #selector(btnSendImageWithTitle(_:)), for: .touchUpInside)
        setImageWithTitle.btnBack.addTarget(self, action: #selector(cancelImageView(_:)), for: .touchUpInside)
        
        callApi()
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addCycleTrimForm.scrollView.contentSize = CGSize(width: self.view.frame.width, height: (addCycleTrimForm.btnNext.frame.origin.y + addCycleTrimForm.btnNext.frame.height))
    }
    
    private func addNewTreeSpecies(treeSpeciesId:Int,name:String,percentage:String){
        
        let treeSpeciesTempData = TreeSpeciesPercentage(id: treeSpeciesId, name:name + "-" + percentage + " %", percentage: Int(percentage)!)
        self.treeSpeciesData.append(treeSpeciesTempData)
        
        addCycleTrimForm.newlyAddedTreeSpeciesTableView.reloadData()
        addCycleTrimForm.newlyAddedTreeSpeciesHeightConstraint.constant += heightOfTreeSpeciesCell
        addCycleTrimForm.addFormContainerHeightConstaraint.constant += heightOfTreeSpeciesCell
    }
    
   
    
    //Mark:- add new tree species into model and reload collectionview
    @objc private func addNewTreeSpecies(_ sender : UIButton){
        
        if ( addCycleTrimForm.txtTreeSpecies.text == "" || addCycleTrimForm.txtTreeSpeciesPer.text == ""  ) {
            self.showAlert(str: "Please select tree species and enter percentage.")
            return
        }
        
        
        if ( Int(addCycleTrimForm.txtTreeSpeciesPer.text!)! <= 0 ) {
            self.showAlert(str: "Tree percentage can not be zero.")
            return
        }
        
        if (Int(addCycleTrimForm.txtTreeSpeciesPer.text!)! > 100){
            self.showAlert(str: "Tree percentage can not be more than 100")
            return
        }
        
        let treeSpeciesId = addCycleTrimForm.txtTreeSpecies.selectedId
        let treeSpeciesName = addCycleTrimForm.txtTreeSpecies.text!
        let percentage = addCycleTrimForm.txtTreeSpeciesPer.text!
        var additionOfPercentage = Int(percentage)
        
        
        
        addCycleTrimForm.txtTreeSpeciesPer.text = ""
        addCycleTrimForm.txtTreeSpecies.text = ""
        
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
        
        //checking percentage addition should always be upto 100 only.
        if ( isTreeAlreadyAdded ) {
            
            for values in treeSpeciesData {
                additionOfPercentage = additionOfPercentage! + values.percentage
            }
            
            if ( additionOfPercentage! > 100 ) {
                self.showAlert(str: "Tree percentage can not be more than 100")
                return
            }
        } else {
            for values in treeSpeciesData {
                additionOfPercentage = additionOfPercentage! + values.percentage
            }
            
            if ( additionOfPercentage! > 100 ) {
                self.showAlert(str: "Tree percentage can not be more than 100")
                return
            }
            
        }
        
        //update if already exists
        if ( isTreeAlreadyAdded ) {
            additionOfPercentage = 0
            treeSpeciesData[treeFoundAt].percentage = Int(percentage)!
            treeSpeciesData[treeFoundAt].name = treeSpeciesName + "-" + percentage + " %"
            addCycleTrimForm.newlyAddedTreeSpeciesTableView.reloadData()
        } else {
            //insert if not exists
            addNewTreeSpecies(treeSpeciesId: treeSpeciesId!,name: treeSpeciesName,percentage: percentage)
        }
    }
    
    //Mark:- go to map view
    @objc func goToMapView(_ sender:UITapGestureRecognizer){
        let storyBoard = UIStoryboard(name: "Map", bundle: nil)
        let vc = storyBoard.instantiateInitialViewController() as! Map
        vc.mapLocationDelegate = self
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
                    self.addCycleTrimForm.txtLocation.text = placemark.mailingAddress
                    
                }
            }
        }
    }
    
    
    //Mark:- pop to vc
    @objc func back(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    //Mark:- setting signed assgined logic here
    @objc func setUnAssignedData(_ sender:UITapGestureRecognizer){
        let lbl = sender.view as! UILabel
        if ( unAssignedSelected.contains(lbl.tag)  ) {
            setUnassignedViewStatus(status: true, label: lbl)
        } else {
            setUnassignedViewStatus(status: false, label: lbl)
        }
    }
    
    //Mark:- long press gesture action, go to detail view
    @objc func goToDetailView(_ sender:UILongPressGestureRecognizer){
        
        if ( sender.state != .ended ) {
            return
        }
        
        let lbl = sender.view as! UILabel
        let storyBoard = UIStoryboard(name:"CycleTrim",bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "cycleTrimDetailVC") as! CycleTrimDetailVC
        vc.cycleTrimData = self.data[lbl.tag]
        vc.showEditButton = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //Mark:- set view into array
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
        let view = addCycleTrimForm.viewUnAssgined.subviews
        for v in view{
            v.removeFromSuperview()
        }
        addCycleTrimForm.unAssignedHeightConstraint.constant = 0
    }
    
    
    
    private func reloadUnassignedView(){
        var y = 0
        var tag = 0
        let heightOfButton = 40
        var  index = 0
        self.unAssignedSelected.removeAll()
        removeAlreadyAddedSubViews()
        
        for cycleTrimData in data{
            
            tag = index
            index += 1
           
            let v =  UnAssignedButton()
            v.frame = CGRect(x: 0, y: y, width: Int(addCycleTrimForm.viewUnAssgined.frame.width), height: heightOfButton)
            v.contentView.frame = CGRect(x: 0, y: 0, width: Int(addCycleTrimForm.viewUnAssgined.frame.width), height: heightOfButton)
            v.lblTitle.tag = tag
            v.imgStatus.tag = tag
            let touch = UITapGestureRecognizer(target: self, action: #selector(setUnAssignedData(_:)))
            let touch2 = UILongPressGestureRecognizer(target: self, action: #selector(goToDetailView(_:)))
            v.lblTitle.addGestureRecognizer(touch)
            v.lblTitle.addGestureRecognizer(touch2)
            v.lblTitle.isUserInteractionEnabled = true
            
           
            
            v.contentView.backgroundColor = UIColor.white
            v.lblTitle.text = "Cycle Trim -  \(cycleTrimData.rowId)"
            v.lblTitle.textColor = UIColor.black
            addCycleTrimForm.viewUnAssgined.addSubview(v)

            //Mark:- set default selected if added new record
            if ( idToBeSelected > 0 && v.lblTitle.tag == idToBeSelected ) {
                setUnassignedViewStatus(status: false, label: v.lblTitle)
            }
            
            y += (heightOfButton + 10)
        }
        addCycleTrimForm.unAssignedHeightConstraint.constant = CGFloat(y + 10)
        addCycleTrimForm.unassginedLabelHeightConstraint.constant = 40
        addCycleTrimForm.lblUnassignedTitle.text = " Un Assigned Cycle Trim"
        self.view.hideLoad()
    }
    
    //Mark:- submit work order
    @objc private func submitWorkOrder(_sender: UIButton){
        
        //validate
        if ( unAssignedSelected.count == 0 ) {
            self.showAlert(str: "Please select atleast one cycle trim to add.")
            return
        }
        
        
        let apiHandler = ApiHandler()
        
        
        var parameters :[String:Any] = [:]
        parameters["WorkOrderId"] = workOrder.WorkOrderId
        parameters["FeederId"] = workOrder.FeederId

        parameters["GeoLat"] = workOrder.GeoLat

        parameters["GeoLong"] = workOrder.GeoLong

        parameters["Status"] = workOrder.Status
        parameters["AssignedTo"] = workOrder.AssignedTo

        parameters["SegamentMiles"] = workOrder.SegamentMiles

        parameters["LocalOffice"] = workOrder.LocalOffice

        parameters["Substation"] = workOrder.Substation

        parameters["OCID"] = workOrder.OCID
        parameters["Comments"] = workOrder.Comments
        parameters["CreatedBy"] = workOrder.CreatedBy
        parameters["ROWIDs"] = (unAssignedSelected.map{String($0)}).joined(separator: ",")
        
        
        apiHandler.sendPostRequestTypeSecond(url: apiUrl.saveWorkOrderWithCycleTrim,parameters:parameters, completionHandler: { response,error in
            print(response)
            self.view.hideLoad()
            
            if ( error != nil ) {
                self.showAlert(str: (error?.localizedDescription)!)
                return
            }
            
            if((response["Status"] as! Int) != 0){
                
                Toast.showToast(message: response["StatusMessage"]! as! String, position: .BOTTOM, length: .DEFAULT)
                
                self.navigationController?.popToRootViewController(animated: true)
            } else {
                self.showAlert(str: response["StatusMessage"]! as! String)
            }
            //self.callApi()
        })
    }
    
    //Mark:- call api
    private func callApi(){
        let apiHandler = ApiHandler()
        let userData = GetSaveUserDetailsFromUserDefault.getDetials()
        let userId = userData!.UserId
        let url = apiUrl.getCycletrimList + "\(userId)"
        
        apiHandler.sendGetRequest(url: url,  completionHandler: { response,error in
            print(response)
            
            
            
            if ( error != nil ) {
                self.showAlert(str: error!.localizedDescription)
                return
            }
            
            if((response["Status"] as! Int) != 0){
                    let data = response["KeyValueList"] as! [[String:AnyObject]]
                    self.data.removeAll()
                do {
                    for tempData in data{
                        if let id = tempData["WorkOrderId"] as? Int {
                            if ( id <= 0 ) {
                               // self.data.append(tempData["ROWDId"] as! Int)
                                
                                    let jsonData = try? JSONSerialization.data(withJSONObject: tempData, options: [])
                                    let model = try JSONDecoder().decode(CycleTrimModel.self, from: jsonData!)
                                    self.data.append(model)
                            }
                        } else {
                            let jsonData = try? JSONSerialization.data(withJSONObject: tempData, options: [])
                            let model = try JSONDecoder().decode(CycleTrimModel.self, from: jsonData!)
                            self.data.append(model)
                        }
                    }
                } catch {
                    
                }
                        self.data.sort(by: {
                            let rec1 = DateFormatters.shared.dateFormatterNormal.date(from: $0.createdAt!)
                            let rec2 = DateFormatters.shared.dateFormatterNormal.date(from: $1.createdAt!)
                            if (rec1!.compare(rec2!) == .orderedDescending){ return true }
                            return false
                        })
                        self.reloadUnassignedView()
            } else {
                self.showAlert(str: response["StatusMessage"]! as! String)
            }
            
        })
    }
    
    //Mark:- add cycle trim api
    @objc private func addCycleTrim(_ sender:UIButton){
        
        
        if(validateForm()){
            return
        }
        
        if ( currentLocation == nil ) {
            self.showAlertWithSettings()
            return
        }
        
        
        
        var str = ""
        for treeSpeciesName in treeSpeciesData{
            str += "\(treeSpeciesName.id):\(treeSpeciesName.percentage),"
        }
        if(str == ""){
            self.showAlert(str: "Please select atleast one tree species.")
            return
        }
        str = str.substring(to: str.index(before: str.endIndex))
        
        
        
      //  let feederData = addCycleTrimForm.txtFeederNo.getData(obj:addCycleTrimForm.txtFeederNo) as? Int
        
       // let poleOfOrigin = addCycleTrimForm.txtPoleOfOrigin.getData(obj:addCycleTrimForm.txtPoleOfOrigin) as? Int
        let poleOfOrigin = 0
        
        
        
        
        let treeDensity = addCycleTrimForm.txtTreeDensity.selectedId
        
        let lineConstruction = addCycleTrimForm.txtLineConstruction.selectedId
        let accessToLine = addCycleTrimForm.txtAccessToLine.selectedId
        
        let currentCondition = addCycleTrimForm.txtCurrentCondition.selectedId
        
        
        
        let comment = addCycleTrimForm.txtComment.text!
        //let location = addCycleTrimForm.txtLocation.text!
        
        
        
        var parameter : [String:Any] = [:]
        
       // parameter["FeederId"] = feederData
        parameter["TreeDensity"] = treeDensity
        parameter["Comment"] = comment
        parameter["CurrentCondition"] = currentCondition
        parameter["AccessToLine"] = accessToLine
        parameter["LineContruction"] = lineConstruction
        parameter["SpeciesSelected"] = str
        parameter["PoleId"] = poleOfOrigin

        
        
        parameter["SegamentMiles"] = "11"
        parameter["LocalOffice"] = "11"
        parameter["Substation"] = "11"
        parameter["Growth"] = 1
        parameter["HoursSpent"] = 11.0
        parameter["FeederSubstation"] = "aa"
        parameter["FeederCustomerCount"] = "aa"
        parameter["Clearance"] = 11.0
        parameter["GeoLat"] = "11"
        parameter["GeoLong"] = "11"
        parameter["WeatherData"] = ""
        parameter["Status"] = 1
        parameter["AssignedTo"] = 11
        parameter["CreatedBy"] = ((GetSaveUserDetailsFromUserDefault.getDetials())?.UserId)
        parameter["CreatedAt"] = dateFormatterNormal.string(from: Date())
        parameter["LastTrimAt"] = dateFormatterNormal.string(from: Date())
        parameter["NextTrimAt"] = dateFormatterNormal.string(from: Date())
        parameter["LastTrimHeight"] = "11.0"
        parameter["OCAssigned"] = 11
        parameter["FeederSubstation"] = 11
        parameter["FeederCustomerCount"] = 0
        parameter["DistBrush"] = 0
        parameter["WorkOrderID"] = 0
        parameter["RoWID"] = 0
        
        
        if ( image.count <= 0 || image == nil ) {
            let alert = UIAlertController(title: "Cofirm?", message: "Are you sure, you want to add Cycle Trim without image ?", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Continue", style: .default, handler: {(UIAlertAction) in
                self.view.showLoad()
                self.addCycleTrimApi(parameters: parameter)
            })
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        } else {
            self.view.showLoad()
            self.addCycleTrimApi(parameters: parameter)
        }
        
        
        
    }
    
    private func validateForm()->Bool{
        
        addCycleTrimForm.fieldContainers.sort(by: {$0.tag < $1.tag})
        var isError = false
        
        for index in 1...addCycleTrimForm.fieldContainers.count - 1{
            
            let view = self.addCycleTrimForm.fieldContainers[index]
            if(view.tag != 0){
                let txt = view.subviews[0] as! UITextField
                
                if ( txt.text == "" ) {
                    self.showAlert(str: "Please enter "+txt.placeholder!)
                    view.addBorderAround(corners: .allCorners, borderCol: UIColor.red.cgColor,layerName:"error")
                    if(!viewWithError.contains(view)){
                        self.viewWithError.append(view)
                    }
                    self.addCycleTrimForm.scrollView.scrollRectToVisible(view.frame, animated: true)
                    
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
    
    private func addCycleTrimApi(parameters:[String:Any]){
        
        apiHandler.sendPostRequestTypeSecond(url: apiUrl.addCycleTrim,parameters:parameters, completionHandler: { response,error in
            
            self.view.hideLoad()
            
            if ( error != nil ) {
                self.showAlert(str: (error?.localizedDescription)!)
                return
            }
            self.idToBeSelected = response["Id"] as! Int
            self.showAlert(str: response["StatusMessage"]! as! String)
            self.clearForm()
            self.addImages(cycleTrimId: response["Id"] as! Int)

        })
        
    }
    
    //Mark:- upload images
    private func addImages(cycleTrimId: Int){
        self.view.showLoad()
        
        for img in self.image{
            if ( img.Id == 2 ) {
                //clear old sdbweb cached images

                let imageData:NSData = (img.Name as! UIImage).jpegData(compressionQuality: 0.7)! as NSData
                
                var parameter : [String:Any] = [:]
                parameter["ROWId"] = cycleTrimId
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
                parameter["ImageText"] = imageData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
                parameter["FileExtensionWithoutDot"] = "jpg"

                apiHandler.sendPostRequestTypeSecond(url: apiUrl.addImageToCycleTrim,parameters:parameter, completionHandler: { response,error in
                    print(response)
                    
                    if ( error != nil ) {
                        self.showAlert(str: (error?.localizedDescription)!)
                        return
                    }
                    
                    
                })
            }
        }
        self.image.removeAll()
        self.callApi()
        self.addCycleTrimForm.addImageCollView.reloadData()
        self.view.hideLoad()
        
        
    }
    
    //Mark:- clears the form
    private func clearForm(){
        for view in addCycleTrimForm.fieldContainers{
            if let txt =  view.subviews[0] as? DropDownField {
                txt.text = ""
            } else if let txt = view.subviews[0] as? UITextView{
                txt.text = "Comment"
            } else {
                let txt = view.subviews[0] as? UITextField
                txt?.text = ""
            }
        }
        treeSpeciesData.removeAll()
        addCycleTrimForm.newlyAddedTreeSpeciesHeightConstraint.constant = 0
        addCycleTrimForm.newlyAddedTreeSpeciesTableView.reloadData()
        
    }
    
    //Mark:- remove tree species
    @objc private func removeNewTreeSpecies(_ sender : UIButton){
        treeSpeciesData.remove(at: sender.tag)
        addCycleTrimForm.newlyAddedTreeSpeciesHeightConstraint.constant -= heightOfTreeSpeciesCell
        addCycleTrimForm.addFormContainerHeightConstaraint.constant -= heightOfTreeSpeciesCell
        addCycleTrimForm.newlyAddedTreeSpeciesTableView.reloadData()
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: "Edit Percentage", message: "You are about to edit pecentage of \(treeSpeciesData[indexPath.section].name)", preferredStyle: .alert)
        alert.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "Enter new percentage"
            textField.keyboardType = .numberPad
            textField.addTarget(alert, action: #selector(alert.textDidChangeInLoginAlert), for: .editingChanged)
        })
        let oldPercentage = treeSpeciesData[indexPath.section].percentage
        
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: { alertAct -> Void in
            let txtPer = alert.textFields![0] as UITextField
            
            self.treeSpeciesData[indexPath.row].percentage = Int(txtPer.text!)!
            var checkPer = 0
            var flag = false
            for per in self.treeSpeciesData{
                checkPer += per.percentage
                
                if ( checkPer > 100 ) {
                    self.treeSpeciesData[indexPath.section].percentage = oldPercentage
                    self.showAlert(str: "Percentage can not be more than 100")
                    flag = true
                    break
                }
            }
            
            if (!flag) {
                let name = self.treeSpeciesData[indexPath.section].name.split(separator: "-")
                self.treeSpeciesData[indexPath.section].name = name[0] + "-" + txtPer.text! + " %"
            }
            self.addCycleTrimForm.newlyAddedTreeSpeciesTableView.reloadRows(at: [indexPath], with: .fade)
            
        })
        let cancelAction = UIAlertAction(title: "Cancel", style:.cancel, handler: {
            (action : UIAlertAction!) -> Void in })
        
        
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        saveAction.isEnabled = true
        self.present(alert, animated: true, completion: nil)
        
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
    
    //Mark:- collection view
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
        cell.btnTouch.tag = indexPath.row
        cell.btnTouch.addTarget(self, action: #selector(optionsActionOnImageTouch(_:)), for: .touchUpInside)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width:90,height:90)
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
        }
    }
    
    //Mark:- get location of image picked
    
    func optionSelected(_ location: ImagePickedLocationEnum) {
        self.imagePickedlocation = location.rawValue
    }
    
    //Mark:- image actions
    @objc func btnSendImageWithTitle(_ sender:UIButton){
        let imageData = ImageData(Id: 1, Name: setImageWithTitle.img.image!,Title:self.setImageWithTitle.txtTitle.text!,Location:self.imagePickedlocation)
        self.image.append(imageData)
        self.view.bringSubviewToFront(self.addCycleTrimForm.contentView)
        self.setImageWithTitle.contentView.removeFromSuperview()
        self.addCycleTrimForm.addImageCollView.reloadData()
    }
    
    @objc func cancelImageView(_ sender:UIButton){
        self.view.bringSubviewToFront(self.addCycleTrimForm.contentView)
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
    
    @objc func optionsActionOnImageTouch(_ sender:UIButton){
        let alert = UIAlertController(title: "", message: "Please choose, what you want to do?", preferredStyle: .actionSheet)
        let alertActionRemove = UIAlertAction(title: "Remove", style: .destructive, handler: {_ in self.removeImage(index: sender.tag)})
        let alertActionView = UIAlertAction(title: "View", style: .default, handler: { _ in self.viewImage(index: sender.tag)})
        alert.addAction(alertActionRemove)
        alert.addAction(alertActionView)
        self.present(alert, animated: true, completion: nil)
    }
    
    func removeImage(index:Int){
        self.image.remove(at: index)
        self.addCycleTrimForm.addImageCollView.reloadData()
    }
    
    func viewImage(index:Int){
        let indexPath = IndexPath(item: index, section: 0)
        let cell = self.addCycleTrimForm.addImageCollView.cellForItem(at: indexPath) as! NewlyAddedImageCell
        self.setImageWithTitle.img.image = cell.imgAddImage.image
        self.view.addSubview(self.setImageWithTitle.contentView)
        self.view.bringSubviewToFront(self.setImageWithTitle.contentView)
        self.setImageWithTitle.txtTitle.text = cell.lblTitle.text!
        self.setImageWithTitle.btnSend.isEnabled = false
        self.setImageWithTitle.btnSend.isHidden = true
    }
    

    
}
