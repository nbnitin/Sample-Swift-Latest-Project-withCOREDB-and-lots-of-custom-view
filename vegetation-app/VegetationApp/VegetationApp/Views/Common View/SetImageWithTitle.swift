//
//  SetImageWithTitle.swift
//  VegetationApp
//
//  Created by Nitin Bhatia on 05/04/19.
//  Copyright © 2019 Nitin Bhatia. All rights reserved.
//

import Foundation

class SetImageWithTitle : UIView,UIScrollViewDelegate{
    
    var vc : UIViewController!
    
    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var loadingContainer: UIView!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var btnShare: UIButton!
    override init(frame: CGRect) {
        super.init(frame:frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
   
    
    private func commonInit(){
        let view = Bundle.main.loadNibNamed("SetImageWithTitle", owner: self, options: nil)?[0] as! UIView
        addSubview(view)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight,.flexibleWidth,.flexibleTopMargin]
       // let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(scaleImage(_:)))
        scrollView.delegate = self
       // scrollView.addGestureRecognizer(pinchGesture)
        scrollView.isUserInteractionEnabled = true
        
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 10.0
      
        //scrollView.contentInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        //scrollView.contentInset = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        
//        let subView = scrollView.subviews[0] // get the image view
//        let offsetX = max((scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5, 0.0)
//        let offsetY = max((scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5, 0.0)
//        // adjust the center of image view
//       
//       subView.center = CGPoint(x:scrollView.contentSize.width * 0.5 + offsetX, y:scrollView.contentSize.height * 0.5 + offsetY)
//        //scrollView.contentSize.height = img.frame.origin.y + img.frame.height
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return img
    }
    
    
  
    @IBAction func btnShareAction(_ sender: Any) {
        // image to share
        let image = self.img
        
        // set up activity view controller
        let imageToShare = [ image?.image ]
        let activityViewController = UIActivityViewController(activityItems: imageToShare as [Any], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self // so that iPads won't crash
        
        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
        
        // present the view controller
        
        vc.present(activityViewController, animated: true, completion: nil)
    }
    
}
