//
//  GetSaveUserDetailsFromUserDefault.swift
//  VegetationApp
//
//  Created by Nitin Bhatia on 02/04/19.
//  Copyright © 2019 Nitin Bhatia. All rights reserved.
//

import Foundation
class GetSaveUserDetailsFromUserDefault{
    
    //Mark:- Get user details saved in user default
    class func getDetials()->User?{
         if #available(iOS 11.0, *) {
            if let data = UserDefaults.standard.value(forKey: "userDetails") as? NSData {
                do {
                    guard let array = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data as Data)  else {
                        fatalError("loadWidgetDataArray - Can't get Array")
                    }
                    return array as! User
                } catch {
                    fatalError("loadWidgetDataArray - Can't encode data: \(error)")
                }
            }
         } else {
            let filePath = getDataFilePath()
           if let dataArray = NSKeyedUnarchiver.unarchiveObject(withFile: filePath)
            as? User {
                return dataArray
           } else {
            
                return nil
            }
        }
        return nil
    }
    
    //Mark:- Saving user details into UserDefault in archive form
    //Mark:- Writting to user default via archiving data
    class func saveUserDetails(userTemp:User){
        do{
            
            if #available(iOS 11.0, *) {
                let encodedData: Data = try NSKeyedArchiver.archivedData(withRootObject: userTemp, requiringSecureCoding: false)
                UserDefaults.standard.set(encodedData, forKey: "userDetails")
                UserDefaults.standard.synchronize()
            } else {
                // Fallback on earlier versions
                NSKeyedArchiver.archiveRootObject(userTemp,
                                                  toFile: getDataFilePath())
            }
            
        } catch{
            
        }
    }
    
    @available (iOS 10,*)
   class func getDataFilePath()->String{
        let filemgr = FileManager.default
        let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .allDomainsMask, true)
//            NSSearchPathForDirectoriesInDomains(.DocumentDirectory,
//                                                .UserDomainMask, true)
        
        var docsDir = dirPaths[0] as! String
        let dataFilePath = URL(string:docsDir)!.appendingPathComponent("data.archive")
        return dataFilePath.absoluteString
    }
    
    @available (iOS 10,*)
    class func removeDataFilePath(){
        let filePath = getDataFilePath()
        let filemgr = FileManager.default
        do{
            try filemgr.removeItem(atPath: filePath)
        } catch{
            print(exception.self)
        }
    }
}
