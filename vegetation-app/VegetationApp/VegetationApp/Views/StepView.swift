//
//  StepView.swift
//  VegetationApp
//
//  Created by Nitin Bhatia on 01/04/19.
//  Copyright © 2019 Nitin Bhatia. All rights reserved.
//

import UIKit
@IBDesignable

class StepView: UIView {
    
    @IBOutlet weak var imageContainerView: UIView!
    @IBOutlet weak var imgStep1: UIImageView!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var imgStep3: UIImageView!
    @IBOutlet weak var imgStep2: UIImageView!
    var step1Image : UIImage!
    var step2Image : UIImage!
    var step3Image : UIImage!
    
    var step1LineColor : UIColor!
    var step2LineColor : UIColor!

    
    override init(frame: CGRect) {
        super.init(frame:frame)
        commonInit()
    }
    
    override func draw(_ rect: CGRect) {
        imgStep1.image = Step1CheckedImage
        imgStep2.image = Step2CheckedImage
        imgStep3.image = Step3CheckedImage
        
        let startPoint = CGPoint(x: (imgStep1.frame.width + imgStep1.frame.origin.x - 2), y: imgStep1.frame.origin.y + (imgStep1.frame.height/2))
        let endPoint = CGPoint(x: (imgStep2.frame.origin.x + 3 ), y: imgStep1.frame.origin.y + (imgStep1.frame.height/2))
        drawLine(start: startPoint, end: endPoint,lineColor: Step1LineColor)
        
        let startPoint1 = CGPoint(x: (imgStep2.frame.width + imgStep2.frame.origin.x - 2), y: imgStep2.frame.origin.y + (imgStep2.frame.height/2))
        let endPoint1 = CGPoint(x: (imgStep3.frame.origin.x + 3 ), y: imgStep3.frame.origin.y + (imgStep3.frame.height/2))
        drawLine(start: startPoint1, end: endPoint1,lineColor: Step2LineColor)
    }
    
    @IBInspectable
    //newValue is default setter property defined in swift...
    var Step1LineColor: UIColor{
        set{
            step1LineColor = newValue
        }
        get{
            guard let _ = step1LineColor else {
                return UIColor.gray
            }
            return step1LineColor
        }
    }
    
    @IBInspectable
    //newValue is default setter property defined in swift...
    var Step2LineColor: UIColor{
        set{
            step2LineColor = newValue
        }
        get{
            guard let _ = step2LineColor else {
                return UIColor.gray
            }
            return step2LineColor
        }
    }
    
    @IBInspectable
    //newValue is default setter property defined in swift...
    var Step1CheckedImage: UIImage{
        set{
            step1Image = newValue
        }
        get{
            guard let _ = step1Image else {
                return imgStep1.image!
            }
            return step1Image
        }
    }
    
    @IBInspectable
    //newValue is default setter property defined in swift...
    var Step2CheckedImage: UIImage{
        set{
            step2Image = newValue
        }
        get{
            guard let _ = step2Image else {
                return imgStep2.image!
            }
            return step2Image
        }
    }
    
    @IBInspectable
    //newValue is default setter property defined in swift...
    var Step3CheckedImage: UIImage{
        set{
            step3Image = newValue
        }
        get{
            guard let _ = step3Image else {
                return imgStep3.image!
            }
            return step3Image
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit(){
        let view = Bundle.main.loadNibNamed("StepView", owner: self, options: nil)?[0] as! UIView
        addSubview(view)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight,.flexibleWidth,.flexibleTopMargin]
        
    }

    private func drawLine(start:CGPoint,end:CGPoint,lineColor:UIColor){
        let line = CAShapeLayer()
        let linePath = UIBezierPath()
        linePath.move(to: start)
        linePath.addLine(to: end)
        line.path = linePath.cgPath
        line.strokeColor = lineColor.cgColor
        line.lineWidth = 1
        line.lineJoin = CAShapeLayerLineJoin.round
        imageContainerView.layer.addSublayer(line)
    }
}
