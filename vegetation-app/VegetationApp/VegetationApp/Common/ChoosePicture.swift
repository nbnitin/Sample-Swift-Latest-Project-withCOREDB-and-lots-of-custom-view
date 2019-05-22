
//
//  ChooseImageExtension.swift
//  
//
//  Created by Nitin Bhatia on 28/04/17.
//  Copyright © 2017 Nitin Bhatia. All rights reserved.
//
import Foundation
import UIKit

enum ImagePickedLocationEnum : String {
    case gallery
    case camera
    
    var rawValue : String {
        switch self {
            case .gallery: return "gallery"
            case .camera: return "camera"
        }
    }
}

enum UIUserInterfaceIdiom : Int {
    case unspecified
    
    case phone // iPhone and iPod touch style UI
    case pad // iPad style UI
}

protocol VCOptionsDelegate {
    func optionSelected(_ location:ImagePickedLocationEnum)
}

 protocol removeDelegate{
     func isRemovePressed(success:Bool)
}

class ChoosePicture :UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    var delegate : removeDelegate!
    var vcOption : VCOptionsDelegate!
    
    func openActions(vc : UIViewController,target : Any,removePictureOption:Bool=false){
        
        
        let vc : UIViewController = vc
        
        let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .actionSheet)
        
        // 2
        let galleryAction = UIAlertAction(title: "Gallery", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.openGallery(vc: vc,target: target)
        })
        let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.openCamera(vc: vc,target: target)
        })
        
        let removeAction = UIAlertAction(title: "Remove Photo", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.delegate.isRemovePressed(success: true)
        })
        
        //
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        
        
        // 4
        optionMenu.addAction(galleryAction)
        optionMenu.addAction(cameraAction)
        optionMenu.addAction(cancelAction)
        
        if( removePictureOption ) {
            optionMenu.addAction(removeAction)
            delegate = vc as? removeDelegate
        }
        
        
        switch UIDevice.current.userInterfaceIdiom {
        case .phone: break
        // It's an iPhone
        case .pad:
            // It's an iPad
            optionMenu.popoverPresentationController?.sourceView = vc.view
            optionMenu.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection()
            optionMenu.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            break
        case .unspecified: break
        // Uh, oh! What could it be?
        default:break
        }
        
        // 5
        vc.present(optionMenu, animated: true, completion: nil)
        
        
        
    }
    
    func openGallery(vc : UIViewController,target : Any){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = target as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary;
        imagePicker.allowsEditing = false
        
        vcOption.optionSelected(ImagePickedLocationEnum.gallery)
        vc.present(imagePicker, animated: true, completion: nil)
    }
    
    func openCamera(vc : UIViewController,target : Any){
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = target as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
            imagePicker.sourceType = UIImagePickerController.SourceType.camera;
            imagePicker.allowsEditing = false
            vcOption.optionSelected(ImagePickedLocationEnum.camera)
            vc.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController,                           didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
    }
    
    func convertToBase64(image : UIImage) -> String {
        let imageData = image.jpegData(compressionQuality: 0.6)
        
        return (imageData?.base64EncodedString(options: NSData.Base64EncodingOptions.init(rawValue: 0)))!
    }
    
}
