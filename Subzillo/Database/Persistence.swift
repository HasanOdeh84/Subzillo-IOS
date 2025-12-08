//
//  Persistence.swift
//  Subzillo
//
//  Created by Ratna Kavya on 08/12/25.
//

import CoreData

final class PersistenceController {
    
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    var context: NSManagedObjectContext {
        container.viewContext
    }
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "SubzilloModel") // your xcdatamodeld name
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                print("❌ Unresolved Core Data error: \(error), \(error.userInfo)")
            }
        }
        
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
}

