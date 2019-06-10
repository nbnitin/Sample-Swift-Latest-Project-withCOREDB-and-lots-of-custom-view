//
//  WorkOrderApiTableCell.swift
//  VegetationApp
//
//  Created by Nitin Bhatia on 07/06/19.
//  Copyright © 2019 Nitin Bhatia. All rights reserved.
//

import UIKit

class WorkOrderApiTableCell: UITableViewCell {

    @IBOutlet weak var btnDetails: UIButton!
    @IBOutlet weak var btnCheck: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
