//
//  MasterDataController.swift
//  VegetationApp
//
//  Created by Nitin Bhatia on 03/04/19.
//  Copyright © 2019 Nitin Bhatia. All rights reserved.
//

import Foundation
import  CoreData

class MasterDataController {
    
    var appDelegate : AppDelegate!
    var managedContext : NSManagedObjectContext!
    static var shared = MasterDataController()
    
    init(){
        appDelegate =  UIApplication.shared.delegate as? AppDelegate
        managedContext = appDelegate.persistentContainer.viewContext
    }
    
    //Mark:- search record on the basis of id key
    func getRecordById(entityName:EntityName,id:Int)->[String:Any]{
        let context =
            appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName.rawValue)
        // create an NSPredicate to get the instance you want to make change
        let predicate = NSPredicate(format: "id = %d", id) //%@ for string
        fetchRequest.predicate = predicate
        
        
            do {
                let results = try context.fetch(fetchRequest) as! [NSManagedObject]
                for res in results{
                    var temp : [String:Any] = [:]
                    for attribute in res.entity.attributesByName{
                        //check if value is present, then add key to dictionary so as to avoid the nil value crash
                        if let value = res.value(forKey: attribute.key) {
                            temp[attribute.key] = value
                        }
                    }
                    return temp as [String : Any]
                }
                return ["id":-1,"name":"N/A"]
                
            } catch {
                fatalError("Failed to fetch person: \(error)")
            }
        
    }
    
    //Mark:- search record on the basis of region key
    func getRecordOfStringColumn(entityName:EntityName,keyToSearch:String,value:String)->[[String:Any]]{
        let context =
            appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName.rawValue)
        // create an NSPredicate to get the instance you want to make change
        
        
        let predicate = NSPredicate(format: "\(keyToSearch) = %@", value) //%@ for string
        fetchRequest.predicate = predicate
        var data : [[String:Any]] = [[String:Any]]()

        
        do {
            let results = try context.fetch(fetchRequest) as! [NSManagedObject]
            for res in results{
                var temp : [String:Any] = [:]
                for attribute in res.entity.attributesByName{
                    //check if value is present, then add key to dictionary so as to avoid the nil value crash
                    if let value = res.value(forKey: attribute.key) {
                        temp[attribute.key] = value
                    }
                }
                data.append(temp)
            }
            return data
        } catch {
            fatalError("Failed to fetch person: \(error)")
        }
        
    }
    
    func getPolesAccordingToFeeder(entityName:EntityName = .Poles,keyToSearch:String = "feederId",value:[Int])->[[String:Any]]{
        let context =
            appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName.rawValue)
        // create an NSPredicate to get the instance you want to make change
        
        
        let predicate = NSPredicate(format: "\(keyToSearch) IN  %@", value) //%@ for string
        fetchRequest.predicate = predicate
        var data : [[String:Any]] = [[String:Any]]()
        
        
        do {
            let results = try context.fetch(fetchRequest) as! [NSManagedObject]
            for res in results{
                var temp : [String:Any] = [:]
                for attribute in res.entity.attributesByName{
                    //check if value is present, then add key to dictionary so as to avoid the nil value crash
                    if let value = res.value(forKey: attribute.key) {
                        temp[attribute.key] = value
                    }
                }
                data.append(temp)
            }
            return data
        } catch {
            fatalError("Failed to fetch person: \(error)")
        }
        
    }
    
    
    
    func getRecordOfIntColumn(entityName:EntityName,keyToSearch:String,value:Int)->[[String:Any]]{
        let context =
            appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName.rawValue)
        // create an NSPredicate to get the instance you want to make change
        
        
        let predicate = NSPredicate(format: "\(keyToSearch) = %@", value) //%@ for string
        fetchRequest.predicate = predicate
        var data : [[String:Any]] = [[String:Any]]()
        
        
        do {
            let results = try context.fetch(fetchRequest) as! [NSManagedObject]
            for res in results{
                var temp : [String:Any] = [:]
                for attribute in res.entity.attributesByName{
                    //check if value is present, then add key to dictionary so as to avoid the nil value crash
                    if let value = res.value(forKey: attribute.key) {
                        temp[attribute.key] = value
                    }
                }
                data.append(temp)
            }
            return data
        } catch {
            fatalError("Failed to fetch person: \(error)")
        }
        
    }
    
    
    
    

    
    
    
    //Mark:- save into core data
    func saveIntoCoreData(entityName:String,dict:[String:Any]){
        
        
        // 1
        managedContext = appDelegate.persistentContainer.viewContext

        
        // 2
        let entity =
            NSEntityDescription.entity(forEntityName: entityName,
                                       in: managedContext)!
        
        
        
        // 3
        
        
        let ent = NSManagedObject(entity: entity,
                                  insertInto: managedContext)
        
        ent.setValuesForKeys(dict)
//        DispatchQueue.main.async {
        // 4
        do {
            
                try self.managedContext.save()
                // self.clear()
                // people.append(person)
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
//        }
        
    }
    
    func deleteData(entityName:EntityName){
        //        guard let appDelegate =
        //            UIApplication.shared.delegate as? AppDelegate else {
        //                let x : [NSManagedObject] = []
        //                return x
        //        }
        // 1
        let context =
            appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName.rawValue)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print ("There was an error")
        }
    
//        do {
//            let results = try context.fetch(fetchRequest) as! [NSManagedObject]
//            for data in results{
//                context.delete(data)
//            }
//
//            do {
//                try context.save()
//                print("saved!")
//            } catch let error as NSError  {
//                print("Could not save \(error), \(error.userInfo)")
//            } catch {
//
//            }
//        } catch {
//            fatalError("Failed to fetch person: \(error)")
//        }
    
    }
    
    func getData(entityName:String)->[[String:Any]]{ //[NSManagedObject]
//        guard let appDelegate =
//            UIApplication.shared.delegate as? AppDelegate else {
//                let x : [NSManagedObject] = []
//                return x
//        }
        // 1
        let context =
            appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        var data : [[String:Any]] = []
        do {
            let results = try context.fetch(fetchRequest) as! [NSManagedObject]
            for res in results{
                var temp : [String:Any] = [:]
                for attribute in res.entity.attributesByName{
                    //check if value is present, then add key to dictionary so as to avoid the nil value crash
                    if let value = res.value(forKey: attribute.key) {
                        temp[attribute.key] = value
                    }
                }
                data.append(temp)
            }
            return data
        } catch {
            fatalError("Failed to fetch person: \(error)")
        }
    }
    
    func callApi(completionHandler: @escaping (_ response : String,_ error : Error?) -> Void){
        
        let group = DispatchGroup()
        group.enter()
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
//        let updateGetAccessToTreeTemp = BlockOperation {
//            let group = DispatchGroup()
//            group.enter()
//            self.getAccessToTree(completionHandler: { response,error in
//                group.leave()
//            })
//
//            group.wait()
//            print("updateA done")
//        }
//        queue.addOperation(updateGetAccessToTreeTemp)
        
//        self.deleteData(entityName: "TreeSpecies")
//        self.deleteData(entityName: "AccessToTree")
//        self.deleteData(entityName: "CurrentConditionHazardTree")
//        self.deleteData(entityName: "CurrentConditionCycleTrim")
//        self.deleteData(entityName: "Prescription")
//        self.deleteData(entityName: "DiameterAtBreastHeight")
//        self.deleteData(entityName: "LineConstruction")
//        self.deleteData(entityName: "TreeDensity")

        if( self.getData(entityName: "AccessToTree").count > 0 ){
            completionHandler("true",nil)
            return
        }
        
        
        //making block operations
        let updateGetTreeSpecies = BlockOperation {
            let group = DispatchGroup()
            group.enter()
            self.getTreeSpecies(completionHandler: { response,error in
                group.leave()
            })
            
            group.wait()
            print("updateA done")
        }
        queue.addOperation(updateGetTreeSpecies)
        
        
        let updateGetHazardTreeCondition = BlockOperation {
            let group = DispatchGroup()
            group.enter()
            self.getHazardTreeCondition(completionHandler: { response,error in
                group.leave()
            })
            
            group.wait()
            print("updateA done")
        }
        queue.addOperation(updateGetHazardTreeCondition)
        
        let updateGetCycleTrimCondition = BlockOperation {
            let group = DispatchGroup()
            group.enter()
            self.getCycleTrimCondition(completionHandler: { response,error in
                group.leave()
            })
            
            group.wait()
            print("updateA done")
        }
        queue.addOperation(updateGetCycleTrimCondition)
        
        let updateGetPrescription = BlockOperation {
            let group = DispatchGroup()
            group.enter()
            self.getPrescription(completionHandler: { response,error in
                group.leave()
            })
            
            group.wait()
            print("updateA done")
        }
        queue.addOperation(updateGetPrescription)
        
        let updateGetAccessToTree = BlockOperation {
            let group = DispatchGroup()
            group.enter()
            self.getAccessToTree(completionHandler: { response,error in
                group.leave()
            })
            
            group.wait()
            print("updateA done")
        }
        queue.addOperation(updateGetAccessToTree)
        
        let updateGetDiameter = BlockOperation {
            let group = DispatchGroup()
            group.enter()
            self.getDiameterAtBreastHeight(completionHandler: { response,error in
                group.leave()
            })
            
            group.wait()
            print("updateA done")
        }
        queue.addOperation(updateGetDiameter)
        
        let updateGetLineConstruction = BlockOperation {
            let group = DispatchGroup()
            group.enter()
            self.getLineConstruction(completionHandler: { response,error in
                group.leave()
            })
            
            group.wait()
            print("updateA done")
        }
        queue.addOperation(updateGetLineConstruction)
        
        let updateGetTreeDensity = BlockOperation {
            let group = DispatchGroup()
            group.enter()
            self.getTreeDensity(completionHandler: { response,error in
                group.leave()
            })
            
            group.wait()
            print("updateA done")
        }
        queue.addOperation(updateGetTreeDensity)
        
        let updateGetFeederList = BlockOperation {
            let group = DispatchGroup()
            group.enter()
            self.getFeeder(completionHandler: { response,error in
                group.leave()
            })
            
            group.wait()
            print("updateA done")
        }
        queue.addOperation(updateGetFeederList)
        
        let updateGetRiskLevel = BlockOperation {
            let group = DispatchGroup()
            group.enter()
            self.getRiskLevel(completionHandler: { response,error in
                group.leave()
            })
            
            group.wait()
            print("updateA done")
        }
        queue.addOperation(updateGetRiskLevel)

        let updateGetAccessToLine = BlockOperation {
            let group = DispatchGroup()
            group.enter()
            self.getAccessToLine(completionHandler: { response,error in
                group.leave()
            })
            
            group.wait()
            print("updateA done")
        }
        queue.addOperation(updateGetAccessToLine)
        
        //making block operations
        let updateGetStatus = BlockOperation {
            let group = DispatchGroup()
            group.enter()
            self.getStatus(completionHandler: { response,error in
                group.leave()
            })
            
            group.wait()
            print("updateA done")
        }
        queue.addOperation(updateGetStatus)
        
        //making block operations
        let updateGetUserRole = BlockOperation {
            let group = DispatchGroup()
            group.enter()
            self.getUserRole(completionHandler: { response,error in
                group.leave()
            })
            
            group.wait()
            print("updateA done")
        }
        queue.addOperation(updateGetUserRole)
        
        let updateGetPoles = BlockOperation {
            let group = DispatchGroup()
            group.enter()
            self.getPoles(completionHandler: { response,error in
                group.leave()
            })
            
            group.wait()
            print("updateA done")
        }
        queue.addOperation(updateGetPoles)


        let masterDataSet = BlockOperation {
            print("all Set")
            completionHandler("true",nil)
        }
        //adding dependency
        masterDataSet.addDependency(updateGetTreeSpecies)
        masterDataSet.addDependency(updateGetHazardTreeCondition)
        masterDataSet.addDependency(updateGetCycleTrimCondition)
        masterDataSet.addDependency(updateGetPrescription)
        masterDataSet.addDependency(updateGetAccessToTree)
        masterDataSet.addDependency(updateGetTreeDensity)
        masterDataSet.addDependency(updateGetLineConstruction)
        masterDataSet.addDependency(updateGetDiameter)
        masterDataSet.addDependency(updateGetFeederList)
        masterDataSet.addDependency(updateGetRiskLevel)
        masterDataSet.addDependency(updateGetAccessToLine)
        masterDataSet.addDependency(updateGetStatus)
        masterDataSet.addDependency(updateGetUserRole)
        masterDataSet.addDependency(updateGetPoles)

        
        //adding masterdataset to queue
        queue.addOperation(masterDataSet)
       // queue.waitUntilAllOperationsAreFinished()
        
    }
    
    //Mark:- master data
    
    
    private func getFeeder(completionHandler: @escaping (_ response : String,_ error : Error?) -> Void){
        
        let apiHandler = ApiHandler()
        let url = apiUrl.getFeederList
        apiHandler.sendGetRequest(url: url,  completionHandler: { response,error in
            print(response)
            
            if((response["Status"] as! Int) != 0){
                    let data = response["KeyValueList"] as! [[String:AnyObject]]
                    for tempData in data{
                        var geoLat : Double = 0.0
                        if let lat = tempData["GeoLat"] as? Double {
                            geoLat = lat
                        }
                        
                        var geoLng : Double = 0.0
                        if let lng = tempData["GeoLong"] as? Double {
                            geoLng = lng
                        } 
                        
                        let dict = ["id":tempData["FidderId"] as! Int,"name":tempData["Identifier"] as! String,"geoLat":geoLat,"geoLng":geoLng,"oc":tempData["OC"] as! Int,"distributionRegion":tempData["DistributionRegion"] as? String ?? "","localOffice":tempData["LocalOffice"] as? String ?? "","countryParish":tempData["CountyParish"] as? String ?? "","substation":tempData["Substation"] as? String ?? "","region":tempData["Region"] as? String ?? ""] as [String : Any]
                        self.saveIntoCoreData(entityName: "FeederList",dict: dict)
                    }
                    completionHandler("true",nil)
               
            } else {
                // self.showAlert(str: response["StatusMessage"]! as! String)
            }
            
        })
    }
    
    private func getRiskLevel(completionHandler: @escaping (_ response : String,_ error : Error?) -> Void){
        let apiHandler = ApiHandler()
        let url = apiUrl.getRiskLevel
        apiHandler.sendGetRequest(url: url,  completionHandler: { response,error in
            print(response)
            
            if (( response["Status"] as! Int) != 0 ) {
               
                let data = response["KeyValueList"] as! [[String:AnyObject]]
                
                for tempData in data{
                    let dict = ["id":tempData["Id"] as! Int,"name":tempData["Name"] as! String] as [String : Any]
                    self.saveIntoCoreData(entityName: "RiskLevel",dict: dict)
                }
                completionHandler("true",nil)
                
            } else {
                // self.showAlert(str: response["StatusMessage"]! as! String)
            }
            
        })
    }
    
    
    
    
    
    private func getTreeSpecies(completionHandler: @escaping (_ response : String,_ error : Error?) -> Void){
        let apiHandler = ApiHandler()
        
        
        
        apiHandler.sendGetRequest(url: apiUrl.getTreeSpeciesList, completionHandler: { response,error in
            print(response)
            
            if (( response["Status"] as! Int) != 0 ) {
                let data = response["KeyValueList"] as! [[String:AnyObject]]
                for tempData in data {
                    let dict = ["id":tempData["Id"] as! Int,"name":tempData["Name"] as! String] as [String : Any]
                    self.saveIntoCoreData(entityName: "TreeSpecies",dict: dict)
                }
                    print("i m finished")
                    completionHandler("true",nil)
            }
        })
    }
    
    private func getHazardTreeCondition(completionHandler: @escaping (_ response : String,_ error : Error?) -> Void){
        let apiHandler = ApiHandler()
        
        
        
        apiHandler.sendGetRequest(url: apiUrl.getHazardTreeCondition, completionHandler: { response,error in
            print(response)
            
            if (( response["Status"] as! Int) != 0 ) {
                
                let data = response["KeyValueList"] as! [[String:AnyObject]]
                
                for tempData in data {
                    let dict = ["id":tempData["Id"] as! Int,"name":tempData["Name"] as! String] as [String : Any]
                    self.saveIntoCoreData(entityName: "CurrentConditionHazardTree",dict: dict)
                }
                print("i m finished")
                completionHandler("true",nil)
            }
        })
    }
    
    private func getCycleTrimCondition(completionHandler: @escaping (_ response : String,_ error : Error?) -> Void){
        
//        var x : [[String:Any]] = []
//
//        let dict = ["id":1,"name":"1 (Imminent outage)"] as [String : Any]
//        let dict2 = ["id":2,"name":"2 (Within 10 days)"] as [String : Any]
//        let dict3 = ["id":3,"name":"3 (>10 days)"] as [String : Any]
//        x.append(dict)
//        x.append(dict2)
//        x.append(dict3)
//
//        for dictTemp in x{
//            self.saveIntoCoreData(entityName: "CurrentConditionCycleTrim",dict: dictTemp)
//        }
//
//        completionHandler("true",nil)
        
        
        
        let apiHandler = ApiHandler()



        apiHandler.sendGetRequest(url: apiUrl.getCycleTrimCondition, completionHandler: { response,error in
            print(response)

            if((response["Status"] as! Int) != 0){

                let data = response["KeyValueList"] as! [[String:AnyObject]]
                for tempData in data {
                    let dict = ["id":tempData["Id"] as! Int,"name":tempData["Name"] as! String] as [String : Any]
                    self.saveIntoCoreData(entityName: "CurrentConditionCycleTrim",dict: dict)
                }
                print("i m finished")
                completionHandler("true",nil)
            }
        })
    }
    
    private func getPrescription(completionHandler: @escaping (_ response : String,_ error : Error?) -> Void){
//        var x : [[String:Any]] = []
//
//
//        let dict = ["id":1,"name":"Skyline"] as [String : Any]
//        let dict2 = ["id":2,"name":"Cut & remove"] as [String : Any]
//        let dict3 = ["id":3,"name":"Cut & chip"] as [String : Any]
//        let dict4 = ["id":4,"name":"Cut & leave"] as [String : Any]
//        x.append(dict)
//        x.append(dict2)
//        x.append(dict3)
//        x.append(dict4)
//
//        for tempDict in x{
//            self.saveIntoCoreData(entityName: "Prescription",dict: tempDict)
//        }
//        completionHandler("true",nil)
        
        
        
        let apiHandler = ApiHandler()



        apiHandler.sendGetRequest(url: apiUrl.getPrescription, completionHandler: { response,error in
            print(response)

            if((response["Status"] as! Int) != 0){

                let data = response["KeyValueList"] as! [[String:AnyObject]]
                for tempData in data {
                    let dict = ["id":tempData["Id"] as! Int,"name":tempData["Name"] as! String,"type":tempData["Type"] as! String] as [String : Any]
                    self.saveIntoCoreData(entityName: "Prescription",dict: dict)
                }
                print("i m finished")
                completionHandler("true",nil)
            }
        })
    }
    
    private func getAccessToTree(completionHandler: @escaping (_ response : String,_ error : Error?) -> Void){
        
//        var x : [[String:Any]] = []
//
//        let dict = ["id":1,"name":"Bucket"] as [String : Any]
//        let dict2 = ["id":2,"name":"Manual"] as [String : Any]
//        let dict3 = ["id":3,"name":"Specialized Equipment (leave comment)"] as [String : Any]
//
//        x.append(dict)
//        x.append(dict2)
//        x.append(dict3)
//        for tempDict in x{
//            self.saveIntoCoreData(entityName: "AccessToTree",dict: tempDict)
//        }
//        completionHandler("true",nil)
        
        
        
        
        let apiHandler = ApiHandler()
        
        
        
        apiHandler.sendGetRequest(url: apiUrl.getAccessToTree, completionHandler: { response,error in
            print(response)

            if((response["Status"] as! Int) != 0){

                let data = response["KeyValueList"] as! [[String:AnyObject]]
                for tempData in data {
                    let dict = ["id":tempData["Id"] as! Int,"name":tempData["Name"] as! String] as [String : Any]
                    self.saveIntoCoreData(entityName: "AccessToTree",dict: dict)
                }
                print("i m finished")
                completionHandler("true",nil)
            }
        })
    }
    
    
    private func getAccessToLine(completionHandler: @escaping (_ response : String,_ error : Error?) -> Void){
        
//        var x : [[String:Any]] = []
//
//        let dict = ["id":1,"name":"01"] as [String : Any]
//        let dict2 = ["id":2,"name":"02"] as [String : Any]
//        let dict3 = ["id":3,"name":"03"] as [String : Any]
//
//        x.append(dict)
//        x.append(dict2)
//        x.append(dict3)
//        for tempDict in x{
//            self.saveIntoCoreData(entityName: "AccessToLine",dict: tempDict)
//        }
//        completionHandler("true",nil)
        
        
        
        
         let apiHandler = ApiHandler()
        
        
        
                apiHandler.sendGetRequest(url: apiUrl.getAccessToLine, completionHandler: { response,error in
                    print(response)
        
                    if((response["Status"] as! Int) != 0){
        
                        let data = response["KeyValueList"] as! [[String:AnyObject]]
                        for tempData in data {
                            let dict = ["id":tempData["Id"] as! Int,"name":tempData["Name"] as! String] as [String : Any]
                            self.saveIntoCoreData(entityName: "AccessToLine",dict: dict)
                        }
                        print("i m finished")
                        completionHandler("true",nil)
                    }
                })
    }
    
    
    private func getDiameterAtBreastHeight(completionHandler: @escaping (_ response : String,_ error : Error?) -> Void){
        
//        var x : [[String:Any]] = []
//
//
//        let dict = ["id":1,"name":"1.0"] as [String : Any]
//        let dict2 = ["id":2,"name":"2.0"] as [String : Any]
//        let dict3 = ["id":3,"name":"3.0"] as [String : Any]
//
//        x.append(dict)
//        x.append(dict2)
//        x.append(dict3)
//
//        for tempDict in x{
//            self.saveIntoCoreData(entityName: "DiameterAtBreastHeight",dict: tempDict)
//        }
//        completionHandler("true",nil)
        
        
        
        
        let apiHandler = ApiHandler()



        apiHandler.sendGetRequest(url: apiUrl.getDiameterAtBreastHeight, completionHandler: { response,error in
            print(response)

            if((response["Status"] as! Int) != 0){

                let data = response["KeyValueList"] as! [[String:AnyObject]]
                for tempData in data {
                    let dict = ["id":tempData["Id"] as! Int,"name":tempData["Name"] as! String,"min":tempData["Min"] as! Double,"max":tempData["Max"] as! Double] as [String : Any]
                    self.saveIntoCoreData(entityName: "DiameterAtBreastHeight",dict: dict)
                }
                print("i m finished")
                completionHandler("true",nil)
            }
        })
    }
    
    private func getLineConstruction(completionHandler: @escaping (_ response : String,_ error : Error?) -> Void){
        
//        var x : [[String:Any]] = []
//        let dict = ["id":1,"name":"Vertical"] as [String : Any]
//        let dict2 = ["id":2,"name":"Horizontal"] as [String : Any]
//        let dict3 = ["id":3,"name":"Single phase"] as [String : Any]
//
//        x.append(dict)
//        x.append(dict2)
//        x.append(dict3)
//
//        for tempDict in x{
//            self.saveIntoCoreData(entityName: "LineConstruction",dict: tempDict)
//        }
//
//        completionHandler("true",nil)
        
        
        
        let apiHandler = ApiHandler()



        apiHandler.sendGetRequest(url: apiUrl.getLineConstruction, completionHandler: { response,error in
            print(response)

            if((response["Status"] as! Int) != 0){

                let data = response["KeyValueList"] as! [[String:AnyObject]]
                for tempData in data {
                    let dict = ["id":tempData["Id"] as! Int,"name":tempData["Name"] as! String] as [String : Any]
                    self.saveIntoCoreData(entityName: "LineConstruction",dict: dict)
                }
                print("i m finished")
                completionHandler("true",nil)
            }
        })
    }
    
    private func getTreeDensity(completionHandler: @escaping (_ response : String,_ error : Error?) -> Void){
        
//        var x : [[String:Any]] = []
//        let dict = ["id":1,"name":"Low (0-25% density)"] as [String : Any]
//        let dict2 = ["id":2,"name":"Medium low (25%-50%)"] as [String : Any]
//        let dict3 = ["id":3,"name":"Medium (50%-75%)"] as [String : Any]
//        let dict4 = ["id":4,"name":"high (75%+)"] as [String : Any]
//
//        x.append(dict)
//        x.append(dict2)
//        x.append(dict3)
//        x.append(dict4)
//
//        for tempDict in x{
//            self.saveIntoCoreData(entityName: "TreeDensity",dict: tempDict)
//        }
//                        completionHandler("true",nil)

        
        
        
        
        let apiHandler = ApiHandler()



        apiHandler.sendGetRequest(url: apiUrl.getTreeDensity, completionHandler: { response,error in
            print(response)

            if((response["Status"] as! Int) != 0){

                let data = response["KeyValueList"] as! [[String:AnyObject]]
                for tempData in data {
                    let dict = ["id":tempData["Id"] as! Int,"name":tempData["Name"] as! String] as [String : Any]
                    self.saveIntoCoreData(entityName: "TreeDensity",dict: dict)
                }
                print("i m finished")
                completionHandler("true",nil)
            }
        })
    }
    
    private func getStatus(completionHandler: @escaping (_ response : String,_ error : Error?) -> Void){
        
        //        var x : [[String:Any]] = []
        //        let dict = ["id":1,"name":"Low (0-25% density)"] as [String : Any]
        //        let dict2 = ["id":2,"name":"Medium low (25%-50%)"] as [String : Any]
        //        let dict3 = ["id":3,"name":"Medium (50%-75%)"] as [String : Any]
        //        let dict4 = ["id":4,"name":"high (75%+)"] as [String : Any]
        //
        //        x.append(dict)
        //        x.append(dict2)
        //        x.append(dict3)
        //        x.append(dict4)
        //
        //        for tempDict in x{
        //            self.saveIntoCoreData(entityName: "TreeDensity",dict: tempDict)
        //        }
        //                        completionHandler("true",nil)
        
        
        
        
        
        let apiHandler = ApiHandler()
        
        
        
        apiHandler.sendGetRequest(url: apiUrl.getStatus, completionHandler: { response,error in
            print(response)
            
            if((response["Status"] as! Int) != 0){
                
                let data = response["KeyValueList"] as! [[String:AnyObject]]
                for tempData in data {
                    let dict = ["id":tempData["Id"] as! Int,"name":tempData["Name"] as! String,"status":tempData["Status"] as! Int,"sortOrder":tempData["SortOrder"] as! Int] as [String : Any]
                    self.saveIntoCoreData(entityName: "Status",dict: dict)
                }
                print("i m finished")
                completionHandler("true",nil)
            }
        })
    }
    
    private func getUserRole(completionHandler: @escaping (_ response : String,_ error : Error?) -> Void){
        
        //        var x : [[String:Any]] = []
        //        let dict = ["id":1,"name":"Low (0-25% density)"] as [String : Any]
        //        let dict2 = ["id":2,"name":"Medium low (25%-50%)"] as [String : Any]
        //        let dict3 = ["id":3,"name":"Medium (50%-75%)"] as [String : Any]
        //        let dict4 = ["id":4,"name":"high (75%+)"] as [String : Any]
        //
        //        x.append(dict)
        //        x.append(dict2)
        //        x.append(dict3)
        //        x.append(dict4)
        //
        //        for tempDict in x{
        //            self.saveIntoCoreData(entityName: "TreeDensity",dict: tempDict)
        //        }
        //                        completionHandler("true",nil)
        
        
        
        
        
        let apiHandler = ApiHandler()
        
        
        
        apiHandler.sendGetRequest(url: apiUrl.getUserRole, completionHandler: { response,error in
            print(response)
            
            if((response["Status"] as! Int) != 0){
                
                let data = response["KeyValueList"] as! [[String:AnyObject]]
                for tempData in data {
                    let dict = ["id":tempData["Id"] as! Int,"name":tempData["Name"] as! String,"status":tempData["Status"] as! Int,"sortOrder":tempData["SortOrder"] as! Int] as [String : Any]
                    self.saveIntoCoreData(entityName: "UserRole",dict: dict)
                }
                print("i m finished")
                completionHandler("true",nil)
            }
        })
    }
    
    private func getPoles(completionHandler: @escaping (_ response : String,_ error : Error?) -> Void){
        
        //        var x : [[String:Any]] = []
        //        let dict = ["id":1,"name":"Low (0-25% density)"] as [String : Any]
        //        let dict2 = ["id":2,"name":"Medium low (25%-50%)"] as [String : Any]
        //        let dict3 = ["id":3,"name":"Medium (50%-75%)"] as [String : Any]
        //        let dict4 = ["id":4,"name":"high (75%+)"] as [String : Any]
        //
        //        x.append(dict)
        //        x.append(dict2)
        //        x.append(dict3)
        //        x.append(dict4)
        //
        //        for tempDict in x{
        //            self.saveIntoCoreData(entityName: "TreeDensity",dict: tempDict)
        //        }
        //                        completionHandler("true",nil)
        
        
        
        
        
        let apiHandler = ApiHandler()
        
        
        
        apiHandler.sendGetRequest(url: apiUrl.getPoles, completionHandler: { response,error in
            
           
            
            if((response["Status"] as! Int) != 0){
                
                let data = response["KeyValueList"] as! [[String:AnyObject]]
                for tempData in data {
                    let dict = ["id":tempData["Id"] as! Int,"gisPoleId":tempData["GisPoleId"] as! String,"feederId":tempData["FeederId"] as! Int,"geoLat":tempData["GeoLat"] as! Double,"geoLong":tempData["GeoLong"] as! Double,"customerCount":tempData["CustomerCount"] as! Int,"localOffice":tempData["LocalOffice"] as! String,"name":tempData["GisPoleId"]] as [String : Any]
                    self.saveIntoCoreData(entityName: "Poles",dict: dict)
                }
                print("i m finished")
                completionHandler("true",nil)
            }
        })
    }
}
