//
//  CoreDataHelper.swift
//  Tinpons
//
//  Created by Dirk Hornung on 12/7/17.
//
//

import UIKit
import CoreData

class SwipedTinponsCore: NSManagedObject {
    static func resetAllRecords() {
        let entityName = "SwipedTinponsCore"
        let context = AppDelegate.viewContext
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        do
        {
            try context.execute(deleteRequest)
            try context.save()
        }
        catch
        {
            print ("There was an error")
        }
    }
    
    static func fetchData() -> [SwipedTinponsCore]? {
        let context = AppDelegate.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SwipedTinponsCore")
        
        do {
            let results = try context.fetch(fetchRequest)
            return results as? [SwipedTinponsCore]
        }catch let err as NSError {
            print(err.debugDescription)
            return nil
        }
        
    }
    
    static func save(swipedTinpon swipedTinpon: SwipedTinpon) {
        let context = AppDelegate.viewContext
        let swipedTinponCore = SwipedTinponsCore(context: context)
        swipedTinponCore.tinponId = swipedTinpon.tinponId
        swipedTinponCore.userId = swipedTinpon.userId
        AppDelegate.sharedDelegate.saveContext()
    }
}

