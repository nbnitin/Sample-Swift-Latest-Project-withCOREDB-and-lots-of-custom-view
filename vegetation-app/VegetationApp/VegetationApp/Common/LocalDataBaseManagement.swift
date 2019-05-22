//
//  LocalDataBaseManagement.swift
//  VegetationApp
//
//  Created by Nitin Bhatia on 17/04/19.
//  Copyright © 2019 Nitin Bhatia. All rights reserved.
//

import Foundation
import CoreData

class LocalDataBaseManager {
    var appDelegate : AppDelegate!
    var managedContext : NSManagedObjectContext!
    static let sharedLocalDBManager = LocalDataBaseManager()
    
   private init(){
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
    
    public func getObjectOfEntities(entityName:String,dict:[String:Any])->NSManagedObject{
        // 1
        managedContext = appDelegate.persistentContainer.viewContext
        
        
        // 2
        let entity =
            NSEntityDescription.entity(forEntityName: entityName,
                                       in: managedContext)!
        
        
        
//        // 3
//
//
        let ent = NSManagedObject(entity: entity,
                                  insertInto: managedContext)
        
        ent.setValuesForKeys(dict)
        return ent
    }
    
    private func deleteData(entityName:String){
        //        guard let appDelegate =
        //            UIApplication.shared.delegate as? AppDelegate else {
        //                let x : [NSManagedObject] = []
        //                return x
        //        }
        // 1
        let context =
            appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
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
        
        let context =
            appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        var data : [[String:Any]] = [[:]]
        do {
            let results = try context.fetch(fetchRequest) as! [NSManagedObject]
            
           
            
            
            for res in results{
                var temp : [String:Any] = [:]
                let r = res as! CycleTrimEntity
                let p = r.relationship?.allObjects as! [RowTreeListEntity]
                    
                
                for attribute in res.entity.attributesByName{
                    //check if value is present, then add key to dictionary so as to avoid the nil value crash
                    if let value = res.value(forKey: attribute.key) {
                        temp[attribute.key] = value
                    }
                }
                temp["rowTreeList"] = p
                data.append(temp)
            }
            return data
            
        } catch {
            fatalError("Failed to fetch person: \(error)")
        }
    }
    
}

