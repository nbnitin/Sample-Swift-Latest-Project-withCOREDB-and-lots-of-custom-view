//
//  ForgetPassword.swift
//  VegetationApp
//
//  Created by Nitin Bhatia on 26/03/19.
//  Copyright © 2019 Nitin Bhatia. All rights reserved.
//

import Foundation
import UIKit

class ForgetPassword: UIViewController{
    
    //variables
    
    //outlets
    @IBOutlet weak var txtEmail: UITextField!
    
    //Mark:- calls on vc load
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //Mark:- back button action
    @IBAction func btnBack(_ sender: Any) {
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft //from left from bottom and from top also a sub
        self.view.window!.layer.add(transition, forKey: kCATransition)
        let vc = storyboard?.instantiateViewController(withIdentifier: "login")
        self.present(vc!, animated: false, completion: nil)
    }
    
    //Mark:- continue button action
    @IBAction func btnContinue(_ sender: Any) {
        self.view.showLoad()
        let apiHandler = ApiHandler()
        var parameters :[String:String] = [:]
        parameters["Email"] = txtEmail.text!
        
        
        apiHandler.sendPostRequestTypeSecond(url: apiUrl.forgotPassword,parameters:parameters, completionHandler: { response,error in
            print(response)
            self.view.hideLoad()
            
            if ( error != nil ) {
                self.showAlert(str: (error?.localizedDescription)!)
                return
            }
            
            if((response["Status"] as! Int) != 0){
                do{
                } catch{
                    print("json error: \(error)")
                }
            } else {
                self.showAlert(str: response["StatusMessage"]! as! String)
            }
            
        })
    }

}

