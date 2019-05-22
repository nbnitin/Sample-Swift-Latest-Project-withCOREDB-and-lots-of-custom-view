//
//  UnAssignedTableCell.swift
//  VegetationApp
//
//  Created by Nitin Bhatia on 10/04/19.
//  Copyright © 2019 Nitin Bhatia. All rights reserved.
//

import Foundation

class UnAssignedButton : UIView{
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgStatus: UIImageView!
    
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        commonInit()
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit(){
        let view = Bundle.main.loadNibNamed("UnAssignedButton", owner: self, options: nil)?[0] as! UIView
        addSubview(view)
        
        contentView.frame = self.bounds
        
        contentView.autoresizingMask = [.flexibleHeight,.flexibleWidth,.flexibleTopMargin]
        
    }
    
}
