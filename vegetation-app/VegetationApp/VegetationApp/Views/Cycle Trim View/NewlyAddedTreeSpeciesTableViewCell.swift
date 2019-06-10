//
//  NewlyAddedTreeSpeciesTableViewCell.swift
//  VegetationApp
//
//  Created by Nitin Bhatia on 01/04/19.
//  Copyright © 2019 Nitin Bhatia. All rights reserved.
//

import UIKit

class NewlyAddedTreeSpeciesTableViewCell: UITableViewCell {

    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var lblTreeSpeciesName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
