//
//  ViewController.swift
//  VegetationApp
//
//  Created by Nitin Bhatia on 26/03/19.
//  Copyright © 2019 Nitin Bhatia. All rights reserved.
//

import UIKit

class Login: UIViewController {
    
    //variables
    
    //outlets
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    //Mark:- calls on vc load
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        txtEmail.text = "denenberg.rachel@bcg.com"
        txtPassword.text = "gVsh5Q"
    }
    
    //Mark:- forget password action, navigate to forget password screen
    @IBAction func btnForgetPassword(_ sender: Any) {
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight //from left from bottom and from top also a sub
        self.view.window!.layer.add(transition, forKey: kCATransition)
        let vc = storyboard?.instantiateViewController(withIdentifier: "forgetPassword")
        self.present(vc!, animated: false, completion: nil)
    }
    
    //Mark:- Function helps to take you to home screen
    func showHome(){
        let sb = UIStoryboard(name: "Home", bundle: nil) //Home
        let vc = sb.instantiateInitialViewController()
        
        let window = UIWindow()
        window.makeKey()
        window.rootViewController = vc
        self.present(vc!, animated: false, completion: nil)
    }
    
    func showChangeDefaultPasswordScreen(){
        let sb = self.storyboard
        let vc = sb?.instantiateViewController(withIdentifier: "changePassword") as! ResetPassword
        vc.oldPassword = txtPassword.text!
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight //from left from bottom and from top also a sub
        self.view.window!.layer.add(transition, forKey: kCATransition)
        self.present(vc, animated: false, completion: nil)
    }
    
    //Mark:- submit button action
    @IBAction func btnSubmit(_ sender: Any) {
        self.view.showLoad()
        let apiHandler = ApiHandler()
        var parameters :[String:String] = [:]
        parameters["UserName"] = txtEmail.text!
        parameters["Password"] = txtPassword.text!
        
        
        apiHandler.sendPostRequestTypeSecond(url: apiUrl.login,parameters:parameters, completionHandler: { response,error in
            print(response)
            self.view.hideLoad()
           
            if ( error != nil ) {
                self.showAlert(str: (error?.localizedDescription)!)
                return
            }
            
            if((response["Status"] as! Int) != 0){
                do{
                    let jsonData = try? JSONSerialization.data(withJSONObject: response["logindetail"]!, options: [])

                    let model = try JSONDecoder().decode(User.self, from: jsonData!)
                    //Mark:- Writting to user default via archiving data
                    GetSaveUserDetailsFromUserDefault.saveUserDetails(userTemp: model)
                    NotificationHandler.shared.updateNotificationToken()
                    UserDefaults.standard.setValue(self.txtPassword.text!, forKeyPath: "oldPassword")
                    if ( model.IsDefaultPassword  ) {
                        self.showChangeDefaultPasswordScreen()
                        return
                    }
                    self.showHome()
                } catch{
                    print("json error: \(error)")
                }
            } else {
                self.showAlert(str: response["StatusMessage"]! as! String)
            }
            
        })
    }
    
}

