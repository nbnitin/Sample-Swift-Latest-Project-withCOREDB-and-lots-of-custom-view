//
//  ApiHandler.swift
//  VegetationApp
//
//  Created by Nitin Bhatia on 26/03/19.
//  Copyright © 2019 Nitin Bhatia. All rights reserved.
//

import Foundation
import Alamofire

class ApiHandler{
    
    func sendPostRequest(url : String, parameters : Parameters, completionHandler: @escaping (_ response : [String : AnyObject],_ error : Error?) -> Void)  {
        
        //Mark:- This below request format sends json data with headers
        
        let headers: HTTPHeaders = [
            "Content-Type":"application/json",
            "Accept": "application/json"
        ]
    
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON(completionHandler: { response in
            
            //debugPrint(response)
            if((response.result.value) != nil) {
                
                // 2. now pass your variable / result to completion handler
                completionHandler(response.result.value as! [String:AnyObject],nil)
                
            } else {
                //response.error and response.result.error both are same
                completionHandler([:],response.error)
            }
        })
        
        //Mark:- Uncomment below part if in case you dont want to send json data with headers
        
        
        //        Alamofire.request(url,method:.post,parameters: parameters,encoding:URLEncoding.httpBody)
        //            .responseJSON(completionHandler: { response in
        //
        //                //
        //                //                debugPrint(response)
        //                //
        //                if((response.result.value) != nil) {
        //
        //
        //
        //                    // 2. now pass your variable / result to completion handler
        //                    completionHandler(response.result.value as! [String:AnyObject],nil)
        //
        //
        //                } else {
        //                    //response.error and response.result.error both are same
        //                    completionHandler([:],response.error)
        //                }
        //            })
        
        
        
        
    }
    
    func sendPostRequestTypeSecond(url : String, parameters : Parameters, completionHandler: @escaping (_ response : [String : AnyObject],_ error : Error?) -> Void)  {
        
        
        
        AF.request(url,method:.post,parameters: parameters,encoding:URLEncoding.httpBody)
            .responseJSON(completionHandler: { response in
                
                //
                //                debugPrint(response)
                //
                if((response.result.value) != nil) {
                    
                    
                    
                    // 2. now pass your variable / result to completion handler
                   
                    completionHandler(response.result.value as! [String:AnyObject],nil)
                    
                    
                    
                } else {
                    //response.error and response.result.error both are same
                    completionHandler([:],response.error!)
                }
            })
        
        
    }
    
    
    func makeParameters (data : [String:AnyObject]) -> Parameters{
        return data as Parameters
    }
    
    func makeParameters (data : [String:Any]) -> Parameters{
        return data as Parameters
    }
    
    
    func sendPostRequest(url : String,  completionHandler: @escaping (_ response : [String : AnyObject],_ error : Error?) -> Void)  {
        
        AF.request(url,method:.post)
            .responseJSON(completionHandler: { response in
                
                
                
                if((response.result.value) != nil) {
                    
                    
                    
                    // 2. now pass your variable / result to completion handler
                    completionHandler(response.result.value as! [String:AnyObject],nil)
                    
                    
                } else {
                    //response.error and response.result.error both are same
                    completionHandler([:],response.error)
                }
            })
        
        
    }
    
    func sendPostRequestWithJsonBody (url:String,parameters : Parameters, completionHandler: @escaping (_ response : [String : AnyObject?],_ error: Error?) -> Void){
        
        let url = URL(string: url)!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        
        print(parameters)
        
        do {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            // No-op
        }
        
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        
        AF.request(urlRequest).responseJSON(completionHandler: {response in
            
            if((response.result.value) != nil) {
                
                
                
                // 2. now pass your variable / result to completion handler
                completionHandler(response.result.value as! [String:AnyObject?],nil)
                
                
            } else {
                completionHandler([:],response.error)
            }
            
            
        })
        
    }
    
    func sendGetRequest(url : String, completionHandler: @escaping (_ response : [String : AnyObject],_ error:Error?) -> Void)  {
        
        
        
        AF.request(url,method:.get,encoding:URLEncoding.httpBody)
            .responseJSON(completionHandler: { response in
                
                //
                //                debugPrint(response)
                //
                if((response.result.value) != nil) {
                    
                    
                    
                    // 2. now pass your variable / result to completion handler
                    completionHandler(response.result.value as! [String:AnyObject],nil)
                    
                    
                } else {
                    completionHandler([:],response.error)
                }
            })
        
        
    }
    
    func GetResponseWithoutJSON(url : String, completionHandler: @escaping (_ response : String,_ error:Error?) -> Void)  {
        
        
        
        AF.request(url,method:.get,encoding:URLEncoding.httpBody)
            .responseString(completionHandler: { response in
                
                //
                //                debugPrint(response)
                //
                if((response.result.value) != nil) {
                    
                    
                    
                    // 2. now pass your variable / result to completion handler
                    completionHandler(response.result.value!,nil)
                    
                    
                } else {
                    completionHandler("",response.error)
                }
            })
        
        
    }
    
    
    
    
    
}
