//
//  FilterVC.swift
//  VegetationApp
//
//  Created by Nitin Bhatia on 24/05/19.
//  Copyright © 2019 Nitin Bhatia. All rights reserved.
//

import UIKit

protocol HotSpotSortFilterDelegate{
    func setSortFilterValue(data:[String:Any])
}

class FilterVCHotSpot: UIViewController {
    
    //variables
    var filterFieldDelegate : HotSpotSortFilterDelegate!
    
    //outlets
    @IBOutlet weak var btnSort: UIButton!
    @IBOutlet var containerView: [UIView]!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var txtSortField: UITextField!
    @IBOutlet weak var txtFilterFeederId: UITextField!
    @IBOutlet weak var txtFilterTreeSpecies: UITextField!
    @IBOutlet weak var txtFilterNetwork: UITextField!
    @IBOutlet weak var txtFilterClearance: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnSubmit.addTarget(self, action: #selector(doneFiltering(_:)), for: .touchUpInside)
        btnSort.addTarget(self,action:#selector(sortIt(_:)),for:.touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.scrollView.contentSize = CGSize(width: self.scrollView.frame.width, height: btnSubmit.frame.origin.y+btnSubmit.frame.height + 20/*for margin*/)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        for views in containerView{
            views.addCornerRadius(corners: .allCorners, radius: 5)
            views.addBorderAround(corners: .allCorners)
        }
    }
    
    @objc private func doneFiltering(_ sender : UIButton){
        let data = ["feederId":txtFilterFeederId.text!,"clearance":txtFilterClearance.text!,"network":txtFilterNetwork.text!]
        self.filterFieldDelegate.setSortFilterValue(data: data)
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func sortIt(_ sender:UIButton){
        
        if ( sender.currentImage == UIImage(named:"a-z") ) {
            sender.setImage(UIImage(named:"z-a"), for: .normal)
        } else {
            sender.setImage(UIImage(named:"a-z"), for: .normal)
        }
        
    }
    
    
}
