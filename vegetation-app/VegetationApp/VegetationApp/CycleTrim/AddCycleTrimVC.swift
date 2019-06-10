//
//  AddCycleTrimVC.swift
//  VegetationApp
//
//  Created by Nitin Bhatia on 01/04/19.
//  Copyright © 2019 Nitin Bhatia. All rights reserved.
//

import UIKit
import CoreLocation
import SDWebImage
import CropViewController


class AddCycleTrimVC: UIViewController,UITableViewDataSource,UITableViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UINavigationControllerDelegate,UIImagePickerControllerDelegate,searchCurrentLocation,MapLocationDelegate,UITextFieldDelegate,CropViewControllerDelegate,VCOptionsDelegate {
    
    //variables
    var yAxis = 0
    var treeSpeciesData : [TreeSpeciesPercentage] = []
    var cp : ChoosePicture!
    var imagePickedlocation:String!
    var setImageWithTitle : SetImageWithTitle!
    var image : [ImageData]! = []
    var viewWithError : [UIView] = []
    var getLocation : GetUserLocation!
    var searchLocationDelegate : searchCurrentLocation!
    var currentLocation : CLLocationCoordinate2D!
    var cycleTrimData : CycleTrimModel!
    var cycleTrimId: Int = 0
    let apiHandler : ApiHandler = ApiHandler()
    var isDoneAlready : Bool = false
    let heightOfTreeSpeciesCell : CGFloat = 70.0
    var feederOfRegion : [[String:Any]] = [[String:Any]]()
    let mcd = MasterDataController()

    //outlets
    @IBOutlet weak var navigationBar: Navigation!
    @IBOutlet weak var addCycleTrimForm: AddCycleTrim!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addCycleTrimForm.btnAddTreeSpecies.addTarget(self, action: #selector(addNewTreeSpecies(_:)), for: .touchUpInside)
        addCycleTrimForm.newlyAddedTreeSpeciesTableView.register(UINib(nibName: "NewlyAddedTreeSpecies", bundle: nil), forCellReuseIdentifier: "cell")
        addCycleTrimForm.newlyAddedTreeSpeciesHeightConstraint.constant = 1
        addCycleTrimForm.newlyAddedTreeSpeciesTableView.delegate = self
        addCycleTrimForm.newlyAddedTreeSpeciesTableView.dataSource = self
        
        addCycleTrimForm.addImageCollView.register(UINib(nibName: "AddImageCell", bundle: nil), forCellWithReuseIdentifier: "addCell")
        
        addCycleTrimForm.addImageCollView.register(UINib(nibName: "NewlyAddedImageCell", bundle: nil), forCellWithReuseIdentifier: "newlyAddedCell")
        
        addCycleTrimForm.addImageCollView.delegate = self
        addCycleTrimForm.addImageCollView.dataSource = self
        
        
        let image = UIImage(named: "ico")
        navigationBar.btnMenu.setImage(image, for: .normal)
        navigationBar.btnMenu.addTarget(self, action: #selector(back(_:)), for: .touchUpInside)
        
        addCycleTrimForm.btnSubmit.addTarget(self, action: #selector(addCycleTrim(_:)), for: .touchUpInside)
        
        cp = ChoosePicture()
        
        setImageWithTitle = SetImageWithTitle()
        setImageWithTitle.contentView.frame = self.view.frame
        setImageWithTitle.btnSend.addTarget(self, action: #selector(btnSendImageWithTitle(_:)), for: .touchUpInside)
        setImageWithTitle.btnBack.addTarget(self, action: #selector(cancelImageView(_:)), for: .touchUpInside)
        self.setImageWithTitle.btnShare.isHidden = true
        self.setImageWithTitle.btnShare.isEnabled = false
        self.setImageWithTitle.vc = nil
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
        
        
       
        
       
        //check for is editing
        if ( cycleTrimData != nil ) {
            currentLocation = CLLocationCoordinate2D(latitude: cycleTrimData.geoLat, longitude: cycleTrimData.geoLong)
            
            let location = CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
            self.setCurrentAddress(location: location)
            navigationBar.lblTitle.text = "Edit Cycle Trim"
        } else {
            //set location first time
            getLocation = GetUserLocation()
            getLocation.delegate = self
           
        }
    }
    
//    //Mark:- Set poles according to feeder
//    func setPoleAccordingToFeeder(poles: [[String:Any]],nearestFeederId:Int){
//        for temp in poles{
//            
//            if ( temp["feederId"] as! Int == nearestFeederId ) {
//                addCycleTrimForm.txtPoleOfOrigin.picker1Value.append(temp["id"] as! Int)
//                addCycleTrimForm.txtPoleOfOrigin.picker1Text.append(temp["name"] as! String)
//            }
//        }
//    }
//    
//    
//    func getNearestPole(){
//        
//        if ( cycleTrimData != nil ) {
//            return
//        }
//        
//        let poles = mcd.getData(entityName: "Poles")
//        var finalPoles : [[String:Any]] = [[String:Any]]()
//        addCycleTrimForm.txtPoleOfOrigin.picker1Text.removeAll()
//        addCycleTrimForm.txtPoleOfOrigin.picker1Value.removeAll()
//        
//        for temp in feederOfRegion{
//            for pol in poles{
//                if ( pol["feederId"] as! Int == temp["id"] as! Int ) {
//                    finalPoles.append(pol)
//                }
//            }
//        }
//        
//        finalPoles.sort(by: {
//            let coordinate1 = CLLocation(latitude: $0["geoLat"] as! CLLocationDegrees, longitude: $0["geoLong"] as! CLLocationDegrees)
//            let coordinate2 = CLLocation(latitude: $1["geoLat"] as! CLLocationDegrees, longitude: $1["geoLong"] as! CLLocationDegrees)
//            let xLocation = CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
//            //closest will be at top
//            return coordinate1.distance(from: xLocation) < coordinate2.distance(from:xLocation)
//        })
//        
//        
//        addCycleTrimForm.txtPoleOfOrigin.text = finalPoles[0]["name"] as! String
//        let nearestFeederId = finalPoles[0]["feederId"] as! Int
//        
//        
//        setPoleAccordingToFeeder(poles: poles,nearestFeederId: nearestFeederId)
//        
//        let indexOfFeederId = addCycleTrimForm.txtFeederNo.picker1Value.index(of:nearestFeederId)
//        addCycleTrimForm.txtFeederNo.selectedIndex = indexOfFeederId!
//        addCycleTrimForm.txtFeederNo.text = addCycleTrimForm.txtFeederNo.picker1Text[addCycleTrimForm.txtFeederNo.selectedIndex]
//        
//    }
    
    override func viewDidAppear(_ animated: Bool) {
        if ( !isDoneAlready && cycleTrimData != nil ) {
            setupViewForEditing()
            isDoneAlready = true
        }
    }
    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return false
    }
    
    //Mark:- setup view for editing
    private func setupViewForEditing(){
        addCycleTrimForm.txtTitle.text = cycleTrimData.title
        addCycleTrimForm.txtTitle.superview?.backgroundColor = UIColor.white
        addCycleTrimForm.txtTitle.isEnabled = true
        addCycleTrimForm.setPoleAccordingToFeeder(nearestFeederId: cycleTrimData.feederId)
        
        addCycleTrimForm.txtFeederNo.setText(EntityName: .FeederList, recId: cycleTrimData.feederId)
        
     //   addCycleTrimForm.txtPoleOfOrigin.text = mcd.getRecordById(entityName: .Poles, id: cycleTrimData.poleId ?? 0)["name"] as? String
        addCycleTrimForm.txtTreeDensity.setText(EntityName: .TreeDensity, recId: cycleTrimData.treeDensity)
        addCycleTrimForm.txtLineConstruction.setText(EntityName: .LineConstruction, recId: cycleTrimData.lineContruction!)
        addCycleTrimForm.txtAccessToLine.setText(EntityName: .AccessToLine, recId: cycleTrimData.accessToLine)
        addCycleTrimForm.txtCurrentCondition.setText(EntityName: .CurrentConditionCycleTrim, recId: cycleTrimData.currentCondition)
        
        addCycleTrimForm.txtComment.text = cycleTrimData.comments
        addCycleTrimForm.txtClearance.text = "\(cycleTrimData.clearance)"
        
        if ( addCycleTrimForm.txtComment.text != "" ) {
            addCycleTrimForm.txtComment.textColor = UIColor.black
        }
        
        for data in (cycleTrimData?.rowTreeList)!{
            addNewTreeSpecies(treeSpeciesId: data.speciesId,name: data.speciesName!,percentage: "\(data.percentage)")
        }
        
        let temp = cycleTrimData.rwTreeImages
        if ( temp != nil ) {
            for index in 0 ..< temp!.count{
                let img = temp![index]
                let imageData = ImageData(Id: 1, Name: img.imageFullPath! as Any,Title: img.description ?? "")
                self.image.append(imageData)
            }
            self.addCycleTrimForm.addImageCollView.reloadData()
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
        
//        if ( addCycleTrimForm.txtPoleOfOrigin.text == "" ) {
//           // addCycleTrimForm.getNearestPole(location: location)
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
                    self.addCycleTrimForm.txtLocation.text = placemark.mailingAddress
                    
                }
            }
        }
    }
    
    
    //Mark:- pop to vc
    @objc func back(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
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
        addCycleTrimForm.txtTreeSpecies.selectedId = -1
        addCycleTrimForm.txtTreeSpecies.selectedName = ""
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
        let oldPercentage = treeSpeciesData[indexPath.row].percentage
        
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: { alertAct -> Void in
            
            
            
            let txtPer = alert.textFields![0] as UITextField
            
          
            
                self.treeSpeciesData[indexPath.section].percentage = Int(txtPer.text!)!
                var checkPer = 0
                var flag = false
                for per in self.treeSpeciesData{
                    checkPer += per.percentage
                    
                    if ( checkPer > 100 ) {
                        self.treeSpeciesData[indexPath.row].percentage = oldPercentage
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
            (action : UIAlertAction!) -> Void in
//            self.addCycleTrimForm.newlyAddedTreeSpeciesTableView.reloadRows(at: [indexPath], with: .none)
        })
        
        
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        saveAction.isEnabled = false
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
        cell.btnTouch.tag = indexPath.row
        cell.btnTouch.addTarget(self, action: #selector(optionsActionOnImageTouch(_:)), for: .touchUpInside)
       
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width:120,height:120)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 3)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let _ = collectionView.cellForItem(at: indexPath) as? AddImageCell{
            let vc : UIViewController = self
            cp.vcOption = self
            cp.openActions(vc: vc,target: self)
            //If you want remove photo option
            cp.openActions(vc: self, target: self,removePictureOption: true)
        }
    }
    
    //Mark:- get location of image picked
    
    func optionSelected(_ location: ImagePickedLocationEnum) {
        self.imagePickedlocation = location.rawValue
    }
    
    @objc func btnSendImageWithTitle(_ sender:UIButton){
        let imageData = ImageData(Id: 2, Name: setImageWithTitle.img.image!,Title:self.setImageWithTitle.txtTitle.text!,Location:self.imagePickedlocation)
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
        self.setImageWithTitle.btnShare.isEnabled = false
        self.setImageWithTitle.btnShare.isHidden = true
        cropViewController.dismiss(animated: true, completion: nil)
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
    
    func removeImage(index:Int){
        self.image.remove(at: index - 1)
        self.addCycleTrimForm.addImageCollView.reloadData()
    }
    
    func viewImage(index:Int){
        let indexPath = IndexPath(item: index, section: 0)
        let cell = self.addCycleTrimForm.addImageCollView.cellForItem(at: indexPath) as! NewlyAddedImageCell
       
        if ( image[index - 1].Id as? Int == 1 ) {
            let treeImages = cycleTrimData.rwTreeImages
           
            if ( index - 1 < treeImages!.count ) {
                let imageName = treeImages![index - 1].imageFullPathOriginal!
                let url = URL(string:imageName)
                setImageWithTitle.contentView.showLoadOtherFormat(title: "Please wait...", desc: "Loading high resolution image.")
                self.setImageWithTitle.img.sd_setImage(with: url, completed:  {
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
        
       
        
        
        //let poleOfOrigin = addCycleTrimForm.txtPoleOfOrigin.getData(obj:addCycleTrimForm.txtPoleOfOrigin) as? Int
        let title = addCycleTrimForm.txtTitle.text!
        
        let feederData = addCycleTrimForm.txtFeederNo.selectedId

        let poleOfOrigin = 0

        
        let treeDensity = addCycleTrimForm.txtTreeDensity.selectedId
        
        let lineConstruction = addCycleTrimForm.txtLineConstruction.selectedId
        let accessToLine = addCycleTrimForm.txtAccessToLine.selectedId
        
        let currentCondition = addCycleTrimForm.txtCurrentCondition.selectedId
        
        let clearance = addCycleTrimForm.txtClearance.text!
        
        let comment = addCycleTrimForm.txtComment.textColor == UIColor.lightGray ? "" : addCycleTrimForm.txtComment.text!
        //let location = addCycleTrimForm.txtLocation.text!
       
        
        var parameter : [String:Any] = [:]
        parameter["Title"] = title
        parameter["FeederId"] = feederData
        parameter["TreeDensity"] = treeDensity
        parameter["Comment"] = comment
        parameter["CurrentCondition"] = currentCondition
        parameter["AccessToLine"] = accessToLine
        parameter["LineContruction"] = lineConstruction
        parameter["SpeciesSelected"] = str
        parameter["Clearance"] = clearance
        parameter["PoleId"] = poleOfOrigin
        
        
        parameter["SegamentMiles"] = cycleTrimData == nil ? "1" : cycleTrimData.segamentMiles
        parameter["LocalOffice"] = cycleTrimData == nil ? "1" : cycleTrimData.localOffice
        parameter["Substation"] = cycleTrimData == nil ? "1" : cycleTrimData.substation
        parameter["Growth"] = cycleTrimData == nil ? "1" : cycleTrimData.growth
        parameter["HoursSpent"] = 11.0
        parameter["FeederSubstation"] = "aa"
        parameter["GeoLat"] = currentLocation.latitude
        parameter["GeoLong"] = currentLocation.longitude
        parameter["WeatherData"] = ""
        parameter["Status"] = cycleTrimData == nil ? "1" : cycleTrimData.status
        parameter["AssignedTo"] = cycleTrimData == nil ? "11" : cycleTrimData.assignedTo
        parameter["CreatedBy"] = ((GetSaveUserDetailsFromUserDefault.getDetials())?.UserId)
        parameter["CreatedAt"] = cycleTrimData == nil ? DateFormatters.shared.dateFormatterNormal.string(from: Date()) : cycleTrimData.createdAt
        parameter["LastTrimAt"] = cycleTrimData == nil ? DateFormatters.shared.dateFormatterNormal.string(from: Date()) : cycleTrimData.lastTrimAt
        parameter["NextTrimAt"] = cycleTrimData == nil ? DateFormatters.shared.dateFormatterNormal.string(from: Date()) : cycleTrimData.nextTrimAt
        parameter["LastTrimHeight"] = cycleTrimData == nil ? "11.0" : cycleTrimData.lastTrimHeight
        parameter["OCAssigned"] = cycleTrimData == nil ? "11" : cycleTrimData.ocAssigned
        parameter["FeederSubstation"] = cycleTrimData == nil ? "11" : cycleTrimData.feederSubstation
        parameter["FeederCustomerCount"] = cycleTrimData == nil ? "11" : cycleTrimData.feederCustomerCount
        parameter["DistBrush"] = 0
        parameter["WorkOrderID"] = cycleTrimData == nil ? 0 : cycleTrimData.workOrderId
        parameter["RoWID"] = cycleTrimData == nil ? 0 : cycleTrimData.rowId
        
        if ( image.count <= 0 || image == nil ) {
            let alert = UIAlertController(title: "Confirm?", message: "Are you sure, you want to add Cycle Trim without image ?", preferredStyle: .alert)
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
        
        let apiHandler = ApiHandler()
        
        
        
        apiHandler.sendPostRequestTypeSecond(url: apiUrl.addCycleTrim,parameters:parameters, completionHandler: { response,error in
            
            if ( error != nil ) {
                self.showAlert(str: (error?.localizedDescription)!)
                return
            }
            
            self.clearForm()
            Toast.showToast(message: response["StatusMessage"]! as! String, position: .BOTTOM, length: .DEFAULT)
            self.view.hideLoad()
            self.addImages(cycleTrimId: response["Id"] as! Int)
        })
        
    }
    
    private func addImages(cycleTrimId: Int){
        self.view.showLoad()
        
        for img in self.image{
            if ( img.Id == 2 ) {
                

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
        self.addCycleTrimForm.addImageCollView.reloadData()
        self.view.hideLoad()
        
        if ( self.cycleTrimData == nil ) {
            self.confirmToAddMore()
        } else {
            self.navigationController?.popToRootViewController(animated: true)
        }
        
    }
    
    private func confirmToAddMore(){
        let alert = UIAlertController(title: "Submitted", message: "Do you want to create more?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default, handler:nil)
        let noAciton = UIAlertAction(title: "No", style: .cancel, handler: {(UIAlertAction) in
            self.navigationController?.popToRootViewController(animated: true)
        })
        alert.addAction(yesAction)
        alert.addAction(noAciton)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    private func clearForm(){
        for view in addCycleTrimForm.fieldContainers{
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
        addCycleTrimForm.newlyAddedTreeSpeciesHeightConstraint.constant = 0
        addCycleTrimForm.newlyAddedTreeSpeciesTableView.reloadData()
        
    }
    
  
}

