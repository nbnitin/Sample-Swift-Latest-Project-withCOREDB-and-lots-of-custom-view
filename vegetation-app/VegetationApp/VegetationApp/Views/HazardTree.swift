//
//  HazardTree.swift
//  VegetationApp
//
//  Created by Nitin Bhatia on 29/03/19.
//  Copyright © 2019 Nitin Bhatia. All rights reserved.
//

import UIKit

class HazardTree: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var lblFeeder: UILabel!
    @IBOutlet weak var lblRiskLevel: UILabel!
    
    @IBOutlet weak var clickToNavigateView: UIView!
    @IBOutlet weak var lblRecId: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblPrescription: UILabel!
    @IBOutlet weak var lblCurrentCondition: UILabel!
    @IBOutlet weak var lblCycleTrim: UILabel!
    
    
    @IBOutlet weak var imgView: UIImageView!
    override init(frame: CGRect) {
        super.init(frame:frame)
        commonInit()
    }
    
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit(){
        let view = Bundle.main.loadNibNamed("HazardTree", owner: self, options: nil)?[0] as! UIView
        addSubview(view)
        
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight,.flexibleWidth,.flexibleTopMargin]
        
    }
    
}
