//
//  CoreDataStack.swift
//  Subzillo
//
//  Created by Ratna Kavya on 08/12/25.
//

import CoreData

final class CoreDataStack {
    
    static let shared = CoreDataStack()
    
    private let context = PersistenceController.shared.context
    
    private init() {}
    
    // MARK: CREATE
    func create(object: NSManagedObject) {
        saveContext()
    }
    
    // MARK: UPDATE
    func update(object: NSManagedObject) {
        saveContext()
    }
    
    // MARK: FETCH
    func fetch<T: NSManagedObject>(_ request: NSFetchRequest<T>) -> [T] {
        do {
            return try context.fetch(request)
        } catch {
            print("Fetch error: \(error.localizedDescription)")
            return []
        }
    }
    
    // MARK: DELETE
    func delete<T: NSManagedObject>(_ request: NSFetchRequest<T>) {
        do {
            let objects = try context.fetch(request)
            objects.forEach { context.delete($0) }
            saveContext()
        } catch {
            print("Delete fetch error: \(error.localizedDescription)")
        }
    }
    func deleteAll<T: NSManagedObject>(of entity: T.Type) {
        let request = NSFetchRequest<T>(entityName: String(describing: entity))
        
        do {
            let objects = try context.fetch(request)
            objects.forEach { context.delete($0) }
            saveContext()
            print("All \(entity) records deleted")
        } catch {
            print("Delete all \(entity) error: \(error.localizedDescription)")
        }
    }
    
    // MARK: Save
    private func saveContext() {
        do {
            if context.hasChanges {
                try context.save()
            }
        } catch {
            print("Save error: \(error.localizedDescription)")
        }
    }
}
