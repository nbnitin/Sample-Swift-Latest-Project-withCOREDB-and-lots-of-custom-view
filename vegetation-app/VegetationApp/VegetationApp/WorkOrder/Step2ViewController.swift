//
//  Step2ViewController.swift
//  VegetationApp
//
//  Created by Nitin Bhatia on 12/04/19.
//  Copyright © 2019 Nitin Bhatia. All rights reserved.
//

import UIKit

class Step2ViewController: UIViewController {

    @IBOutlet weak var navigationBar: Navigation!
    var workOrder : WorkOrderModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let image = UIImage(named: "ico")
        navigationBar.btnMenu.setImage(image, for: .normal)
        navigationBar.btnMenu.addTarget(self, action: #selector(back(_:)), for: .touchUpInside)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? Step3CycleTrimViewController {
            vc.workOrder = self.workOrder
        } else {
          let vc = segue.destination as! Step3HazardTreeViewController
            vc.workOrder = self.workOrder
        }
        
    }
    
    //Mark:- pop to vc
    @objc func back(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
   

}
