//
//  showToast.swift
//
//  Created by Nitin Bhatia on 14/06/17.
//  Copyright © 2017 Nitin Bhatia. All rights reserved.
//
import UIKit

class Toast{
    
    enum Position : Int {
        case TOP = 0
        case MIDDLE = 1
        case BOTTOM = 2
        case DEFAULT = 3
    }
    
    enum Length : Int {
        case LONG = 0
        case SHORT = 1
        case DEFAULT = 3
    }
    
    class public func showToast(message : String,position:Position,length:Length  ){
        
        //let view : UIView = self
        let toastLabel : UITextView
        
        toastLabel   = UITextView(frame: CGRect(x: 0, y: 0, width: 100,  height : 100))
        
        
        
        
        toastLabel.backgroundColor = UIColor.black
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = NSTextAlignment.center;
        toastLabel.font = UIFont.boldSystemFont(ofSize: 17.0)
        toastLabel.text =  message
        toastLabel.textAlignment = .center
        toastLabel.alpha = 0.0
        //toastLabel.lineBreakMode = .byTruncatingTail
        // toastLabel.numberOfLines = 0
        let app : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        
        
        
        
        let size = CGSize(width: 250, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let estimatedFrame = NSString(string: message).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17)], context: nil)
        
        
        
        switch position.rawValue {
            
        case 0:
            toastLabel.frame = CGRect( x: (app.window?.frame.size.width)!/2 - ( estimatedFrame.width/2) , y: 50, width: estimatedFrame.width + 20, height: estimatedFrame.height + 20)
        case 1:
            toastLabel.frame = CGRect(x: (app.window?.frame.size.width)!/2 - (estimatedFrame.width/2), y: (app.window?.frame.size.height)!/2 - (toastLabel.frame.height/2), width: estimatedFrame.width + 20, height: estimatedFrame.height + 20)
        case 2:
            toastLabel.frame = CGRect(x: (app.window?.frame.width)!/2 - (estimatedFrame.width/2), y: (app.window?.frame.height)!-100, width: estimatedFrame.width + 20, height: estimatedFrame.height + 20)
        default:
            toastLabel.frame = CGRect(x: (app.window?.frame.size.width)!/2 - (estimatedFrame.width/2), y: (app.window?.frame.size.height)!/2 - (toastLabel.frame.height/2), width: estimatedFrame.width + 20, height: estimatedFrame.height + 20)
        }
        
        
        app.window?.addSubview(toastLabel)
        
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(0), execute: { () -> Void in
            
            UIView.animate(withDuration: 1.0, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                toastLabel.alpha = 1.0
                
            })
        })
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        
        var yourDelay = 3
        let yourDuration = 1.0
        
        switch length.rawValue {
        case 0:
            yourDelay = 20
        case 1:
            yourDelay = 3
        default:
            yourDelay = 3
        }
        
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(yourDelay), execute: { () -> Void in
            UIView.animate(withDuration: yourDuration, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                toastLabel.alpha = 0.0
                
            })
        })
    }
    
}
