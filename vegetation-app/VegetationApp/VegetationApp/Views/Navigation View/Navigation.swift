//
//  Navigation.swift
//  VegetationApp
//
//  Created by Nitin Bhatia on 26/03/19.
//  Copyright © 2019 Nitin Bhatia. All rights reserved.
//

import UIKit

@IBDesignable
class Navigation: UIView {
    @IBOutlet weak var btnMenu: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var btnRight: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        commonInit()
    }
    
    @IBInspectable
    //newValue is default setter property defined in swift...
    var navigationTitle: String{
        set{
            lblTitle.text = newValue
        }
        get{
            return lblTitle.text!
        }
    }
    
    @IBInspectable
    var showRightButton:Bool = true{
        didSet{
            self.btnRight.isHidden = showRightButton
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit(){
        let view = Bundle.main.loadNibNamed("Navigation", owner: self, options: nil)?[0] as! UIView
        addSubview(view)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight,.flexibleWidth,.flexibleTopMargin]
        self.btnRight.setTitleColor(.lightGray, for: .disabled)
    }

}
