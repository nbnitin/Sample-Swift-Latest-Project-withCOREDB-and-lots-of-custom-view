//
//  CycleTrim.swift
//  VegetationApp
//
//  Created by Nitin Bhatia on 27/03/19.
//  Copyright © 2019 Nitin Bhatia. All rights reserved.
//

import UIKit

class CycleTrim: UIView {

    @IBOutlet weak var lblRecId: UILabel!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var lblFeeder: UILabel!
    @IBOutlet weak var lblTreeSpecies: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblClearance: UILabel!
    @IBOutlet weak var lblNetwork: UILabel!
    
    @IBOutlet weak var clickToNavigateView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit(){
        let view = Bundle.main.loadNibNamed("CycleTrim", owner: self, options: nil)?[0] as! UIView
        addSubview(view)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight,.flexibleWidth,.flexibleTopMargin]
        
    }

    
}
