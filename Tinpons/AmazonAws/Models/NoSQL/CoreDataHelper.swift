//
//  CoreDataHelper.swift
//  Tinpons
//
//  Created by Dirk Hornung on 12/7/17.
//
//

import UIKit
import CoreData

func resetAllRecords(in entity : String) {
    
    let context = ( UIApplication.shared.delegate as! AppDelegate ).persistentContainer.viewContext
    let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
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
