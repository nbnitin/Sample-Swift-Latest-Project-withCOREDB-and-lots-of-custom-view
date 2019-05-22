//
//  Menu.swift
//  VegetationApp
//
//  Created by Nitin Bhatia on 29/03/19.
//  Copyright © 2019 Nitin Bhatia. All rights reserved.
//

import UIKit

class Menu: UITableViewController,subMenuCellDelegate {
    
    
    //variables
    var subMenuSelectedRow : Int = 0
   
    
    //outlets
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblDesgination: UILabel!
    @IBOutlet weak var imgUserProfile: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imgUserProfile.addCornerRadius(corners: .allCorners, radius: 3)
        
        let mcd = MasterDataController()
        
        lblUserName.text = GetSaveUserDetailsFromUserDefault.getDetials()?.FirstName
        lblDesgination.text = mcd.getRecordById(entityName: .UserRole, id: GetSaveUserDetailsFromUserDefault.getDetials()!.Type)["name"] as! String
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        let cell = self.tableView.cellForRow(at: IndexPath(row:1,section:0)) as! MenuTableViewCell
        cell.delegate = self
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.contentInset = UIEdgeInsets(top: -UIApplication.shared.statusBarFrame.size.height, left: 0, bottom: 0, right: 0)
        
    }
    
   
    //Mark:- Table view delegate
     
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if ( indexPath.row == 0 ){
            return 190
        } else if ( indexPath.row == 1 ) {
            return self.view.frame.height - (190 + 115)
        }
        return 115
    }
    
    func cellSelected(row: Int) {
        self.subMenuSelectedRow = row
        
        if ( row == 0 ) {
            performSegue(withIdentifier: "home", sender: self)
        } else if ( row == 1 ) {
            performSegue(withIdentifier: "hazardTree", sender: self)
        } else if ( row == 2 ) {
            performSegue(withIdentifier: "cycleTrim", sender: self)
        } else if ( row == 3 ) {
            //performSegue(withIdentifier: "workOrder", sender: self)
        } else if ( row == 5 ){
            
            let mcd = MasterDataController()
            
            //clearing all stored data
            EntityName.allCases.forEach{
                mcd.deleteData(entityName:$0)
            }
            
            if #available(iOS 11.0, *) {
                UserDefaults.standard.removeObject(forKey: "userDetails")
            } else {
               GetSaveUserDetailsFromUserDefault.removeDataFilePath()
            }
            
           let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateInitialViewController()
            let window = UIWindow()
            window.rootViewController =  vc
            window.makeKeyAndVisible()
            self.present(vc!, animated: false, completion: nil)

        }
    }
    
    
    
    
 }
