//
//  NewlyAddedTreeSpecies.swift
//  VegetationApp
//
//  Created by Nitin Bhatia on 01/04/19.
//  Copyright © 2019 Nitin Bhatia. All rights reserved.
//

import UIKit

class NewlyAddedTreeSpecies: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var lblTreeSpeciesName: UILabel!
    
    @IBOutlet weak var btnDelete: UIButton!
   
    override init(frame: CGRect) {
        super.init(frame:frame)
        commonInit()
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit(){
        let view = Bundle.main.loadNibNamed("NewlyAddedTreeSpecies", owner: self, options: nil)?[0] as! UIView
        addSubview(view)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight,.flexibleWidth,.flexibleTopMargin]
        
    }
}
