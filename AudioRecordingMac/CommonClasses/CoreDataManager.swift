//
//  CoreDataManager.swift
//  AudioRecordingMac
//
//  Created by Mohar on 24/04/25.
//

import CoreData

class CoreDataManager {
    static var shared =  CoreDataManager()
    
    let persistenceController = PersistenceController.shared
    let managedContext : NSManagedObjectContext?
    private init() {
        managedContext =  persistenceController.container.viewContext
    }
    
    func saveContext() {
        do {
            try managedContext?.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    func createItemFor(title : String) -> Item? {
        if var managedContext = managedContext {
            let newItem = Item(context: managedContext)
            newItem.timestamp = Date()
            newItem.title = title
            
            do {
                try managedContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
            
            return newItem
        }
        
        return nil
    }
}
