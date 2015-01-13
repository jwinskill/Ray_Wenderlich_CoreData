//
//  CoreDataStack.swift
//  Dog Walk
//
//  Created by Joshua Winskill on 12/31/14.
//  Copyright (c) 2014 Razeware. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    let context: NSManagedObjectContext!
    let psc: NSPersistentStoreCoordinator!
    let model: NSManagedObjectModel!
    let store: NSPersistentStore?
    
    init() {
        // 1. Load the managed object model from disk into a NSManagedObjectModel object
        let bundle = NSBundle.mainBundle()
        let modelURL = bundle.URLForResource("Dog Walk", withExtension: "momd")
        self.model = NSManagedObjectModel(contentsOfURL: modelURL!)
        
        // 2. Initiliaze a perisistent store coordinator using the managed object model previously created
        self.psc = NSPersistentStoreCoordinator(managedObjectModel: self.model)
        
        // 3. Initialize a managed object context, and set its persistent store coordinator
        self.context = NSManagedObjectContext()
        self.context.persistentStoreCoordinator = self.psc
        
        // 4. Set the persistent store with coordinator's addPersistentStoreWithType method
        let documentsURL = applicationsDocumentDirectory()
        let storeURL = documentsURL.URLByAppendingPathComponent("Dog Walk")
        
        let options = [NSMigratePersistentStoresAutomaticallyOption: true]
        
        var error: NSError?
        self.store = self.psc.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: options, error: &error)
        
        if self.store == nil {
            println("error adding persistent store: \(error?.localizedDescription)")
            abort()
        }
    }
    
    func saveContext() {
        var error: NSError?
        if self.context.hasChanges && !self.context.save(&error) {
            println("Context could not be saved: \(error!.localizedDescription)")
        }
    }
    
    // MARK: - Helper methods
    
    func applicationsDocumentDirectory() -> NSURL {
        let fileManager = NSFileManager.defaultManager()
        
        let urls = fileManager.URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask) as [NSURL]
        
        return urls[0]
    }
}
