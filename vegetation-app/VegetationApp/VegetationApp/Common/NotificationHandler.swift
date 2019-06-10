//
//  NotificationHandler.swift
//  VegetationApp
//
//  Created by Nitin Bhatia on 04/06/19.
//  Copyright © 2019 Nitin Bhatia. All rights reserved.
//

import Foundation
import Firebase
import FirebaseMessaging

class NotificationHandler : NSObject {
    static var shared = NotificationHandler()
    
    func updateWorkOrder(status:Int, workOrderId:Int , assignTo:Int,completionHandler: @escaping (_ response : [String : AnyObject],_ error : Error?) -> Void  ){
        let apiHandler = ApiHandler()
        
        
        
        let userData = GetSaveUserDetailsFromUserDefault.getDetials()
        let userId = userData!.UserId
        var parameters :[String:Any] = [:]
        parameters["WorkOrderId"] = workOrderId
        parameters["Status"] = status
        parameters["AssignedTo"] = assignTo
        parameters["UserId"] = userId
        
        
        apiHandler.sendPostRequestTypeSecond(url: apiUrl.editWorkOrder,parameters:parameters, completionHandler: { response,error in
            print(response)
            
            if ( error != nil ) {
                completionHandler([:],error)
            } else {
                completionHandler(response,nil)
            }
        })
    }
    
    
    private func doFinalUpdateToken(parameter:[String:String]){
        let apiHandler = ApiHandler()
        apiHandler.sendPostRequestTypeSecond(url: apiUrl.updateNotificationToken,parameters:parameter, completionHandler: { response,error in
            print(response, "I m token response")
            
            if ( error != nil ) {
                return
            }
            
            //            if((response["Status"] as! Int) != 0){
            //                do{
            //
            //                } catch{
            //                    print("json error: \(error)")
            //                }
            //            } else {
            //
            //            }
            
        })
    }
    
    //Mark:- update notification token in db
    func updateNotificationToken(){
        var parameters :[String:String] = [:]
        let userData = GetSaveUserDetailsFromUserDefault.getDetials()
        let userId = userData!.UserId
        parameters["UserId"] = "\(userId)"
        parameters["OSType"] = "iOS"
        
        if let token = UserDefaults.standard.value(forKey: "token") {
            
            parameters["TokenId"] = token as! String
            doFinalUpdateToken(parameter: parameters)
        } else {
            
            InstanceID.instanceID().instanceID { (result, error) in
                if let error = error {
                    print("Error fetching remote instance ID: \(error)")
                } else if let result = result {
                    print("Remote instance ID token: \(result.token)")
                    parameters["TokenId"] = result.token
                    self.doFinalUpdateToken(parameter: parameters)
                }
            }
        }
    }
    
    func getData(type:Int,id:Int,completionHandler: @escaping (_ response : Any,_ error : Error?) -> Void ){
        let apiHandler = ApiHandler()
        var url = ""
        var parameter : [String:String] = [:]
        switch type {
        case ModuleType.HAZARDTREE.rawValue:
            url = apiUrl.getHazardTreeSearch
            parameter["HazardTreeID"] = "\(id)"
            parameter["FeederID"] = "0"
            parameter["RiskLavel"] = ""
            parameter["TreeCondiTion"] = ""
            parameter["Prescription"] = ""
            parameter["Status"] = ""
            parameter["Date"] = ""
            parameter["OrderBy"] = ""
            parameter["OrderBYDirection"] = ""
            break
        case ModuleType.CYCLETRIM.rawValue:
            url = apiUrl.getCycleTrimSearch
            parameter["RowId"] = "\(id)"
            parameter["FeederID"] = "0"
            parameter["Clearance"] = ""
            parameter["CreateDate"] = ""
            parameter["Status"] = ""
            parameter["OrderBy"] = ""
            parameter["OrderBYDirection"] = ""
            break
        case ModuleType.HOTSPOT.rawValue:
            url = apiUrl.getHotSpotSearch
            parameter["HotSpotID"] = "\(id)"
            break
        
        default:
            url = apiUrl.getWorkOrderSearch
            parameter["WorkOrderID"] = "\(id)"
            parameter["FeederID"] = "0"
            parameter["AssignedID"] = "0"
            parameter["Status"] = "0"
            parameter["CreateDate"] = "0"
            parameter["OrderBy"] = "0"
            parameter["OrderBYDirection"] = "0"
            break
        }
        
        
        parameter["PageNo"] = "1"
        parameter["PageSize"] = "1"
        
        apiHandler.sendPostRequestTypeSecond(url: url,parameters: parameter  ,completionHandler: { response,error in
            print(response)
            
            if ( error != nil  ) {
                completionHandler("",error)
                return
            }
            
            if( (response["Status"] as! Int) != 0 ) {
                do{
                    let data = response["KeyValueList"] as! [[String:AnyObject]]
                    
                    
                    let jsonData = try? JSONSerialization.data(withJSONObject: data[0], options: [])
                    
                    switch type {
                        case ModuleType.HAZARDTREE.rawValue:
                            completionHandler(try JSONDecoder().decode(HazardTreeModel.self, from: jsonData!),nil)
                            break
                        case ModuleType.CYCLETRIM.rawValue:
                            completionHandler(try JSONDecoder().decode(CycleTrimModel.self, from: jsonData!),nil)
                            break
                        case ModuleType.HOTSPOT.rawValue:
                            completionHandler(try JSONDecoder().decode(HotSpotModel.self, from: jsonData!),nil)
                            break
                            
                        default:
                            completionHandler(try JSONDecoder().decode(WorkOrderModel.self, from: jsonData!),nil)
                            break
                    }
                    
                } catch{
                    print("json error: \(error)")
                }
            }
            
        })
    }
    
}
