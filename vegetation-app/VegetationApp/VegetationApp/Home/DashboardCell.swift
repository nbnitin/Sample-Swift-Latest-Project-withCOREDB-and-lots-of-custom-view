//
//  DashboardCell.swift
//  VegetationApp
//
//  Created by Nitin Bhatia on 27/03/19.
//  Copyright © 2019 Nitin Bhatia. All rights reserved.
//
import UIKit

protocol ExpandedCellDelegate:NSObjectProtocol{
    func topButtonTouched(indexPath:IndexPath)
}

class DashboardCell: UICollectionViewCell {
    
    //variables
    var oldConstant : CGFloat = 0.0
    weak var delegate:ExpandedCellDelegate?
    public var indexPath:IndexPath!
    @IBOutlet weak var imgChevron: UIImageView!
    
    @IBOutlet weak var lowerContainerView: UIView!
    @IBOutlet weak var lblRiskLevel: UILabel!
    @IBOutlet weak var lblFeadrer: UILabel!
    @IBOutlet weak var lblCount: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblViewStatus: UILabel!
    @IBOutlet weak var imgCell: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(tapView(_:)))
         let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapView(_:)))
        lblViewStatus.addGestureRecognizer(tapGesture)
        lblViewStatus.isUserInteractionEnabled = true
        
        imgChevron.addGestureRecognizer(tapGesture1)
        imgChevron.isUserInteractionEnabled = true
    }
    
    @objc func tapView(_ sender: UITapGestureRecognizer) {
       
        if let delegate = self.delegate{
            delegate.topButtonTouched(indexPath: indexPath)
        }
    }
    
    
}
