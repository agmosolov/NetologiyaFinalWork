//
//  CoreDataManager.swift
//  NetologiyaFinalWork
//
//  Created by Александр Мосолов on 02.12.2025.
//

import CoreData

final class TaskCoreDataManager {
    
    static let shared = TaskCoreDataManager()
    
    private let modelName = "CoreDataModel"
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: modelName)
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                // Обработка ошибок конфигурации хранилища
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: - Saving support
    
    func saveContext () {
        let context = viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Замена на безопасную обработку ошибок в продакшне
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - Convenience fetch helper
    
    func fetchRequest<T: NSManagedObject>(ofType type: T.Type,
                                          predicate: NSPredicate? = nil,
                                          sortDescriptors: [NSSortDescriptor]? = nil) -> NSFetchRequest<T> {
        let request = NSFetchRequest<T>(entityName: String(describing: type))
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        return request
    }
    
    // MARK: - Generic fetch with completion
    
    func fetchEntities<T: NSManagedObject>(_ type: T.Type,
                                           predicate: NSPredicate? = nil,
                                           sortDescriptors: [NSSortDescriptor]? = nil,
                                           limit: Int? = nil,
                                           context: NSManagedObjectContext? = nil) -> [T] {
        let context = context ?? viewContext
        let request = fetchRequest(ofType: type, predicate: predicate, sortDescriptors: sortDescriptors)
        if let limit = limit {
            request.fetchLimit = limit
        }
        do {
            return try context.fetch(request)
        } catch {
            print("!!!Fetch error: \(error)")
            return []
        }
    }
    
    
    
    
    // MARK: - Create helper
    
    func createTaskEntity() -> Task {
        let context = viewContext
        return Task(context: context)
    }
}
