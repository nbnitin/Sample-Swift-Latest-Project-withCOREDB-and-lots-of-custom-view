//
//  HazardTree.swift
//  VegetationApp
//
//  Created by Nitin Bhatia on 29/03/19.
//  Copyright © 2019 Nitin Bhatia. All rights reserved.
//

import UIKit

class WorkOrder: UIView {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var lblFeeder: UILabel!
    @IBOutlet weak var lblWorkOrder: UILabel!
    
    @IBOutlet weak var lblAssginedTo
    : UILabel!
    @IBOutlet weak var lblSegment: UILabel!
    
    @IBOutlet weak var lblNoOfHazardTree: UILabel!
    @IBOutlet weak var lblCycleHazardNoTitle: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        commonInit()
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit(){
        let view = Bundle.main.loadNibNamed("WorkOrder", owner: self, options: nil)?[0] as! UIView
        addSubview(view)
        
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight,.flexibleWidth,.flexibleTopMargin]
        
    }
    
}
