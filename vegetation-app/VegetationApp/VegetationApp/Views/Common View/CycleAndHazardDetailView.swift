//
//  CycleAndHazardDetailView.swift
//  VegetationApp
//
//  Created by Nitin Bhatia on 28/03/19.
//  Copyright © 2019 Nitin Bhatia. All rights reserved.
//

import UIKit

class CycleAndHazardDetailView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblValue: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        commonInit()
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit(){
        let view = Bundle.main.loadNibNamed("CycleAndHazardDetailView", owner: self, options: nil)?[0] as! UIView
        addSubview(view)
       
        circleView.addShadowWithCornerRadius(offset: CGSize(width:5,height:5), radiusForCorner: Float(circleView.frame.width/2))
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight,.flexibleWidth,.flexibleTopMargin]
        
    }

}
