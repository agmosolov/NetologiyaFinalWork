//
//  TaskLogCoreDataManager.swift
//  NetologiyaFinalWork
//
//  Created by Александр Мосолов on 06.12.2025.
//

import CoreData

final class TaskLogsCoreDataManager {
    static let shared = TaskLogsCoreDataManager()
    
    private let modelName = "CoreDataModel"
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: modelName)
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    var viewContext: NSManagedObjectContext { persistentContainer.viewContext }
    
    func saveContext() {
        let ctx = viewContext
        if ctx.hasChanges {
            do { try ctx.save() } catch { print("!!!Save error: \(error)") }
        }
    }
    
    // TaskLog specific helpers
    func createLog(from task: Task) {
        let log = TaskLog(context: viewContext)
        log.taskName = task.taskName
        log.cyclicality = task.cyclicality
        log.date = task.date
        log.factValue = task.factValue
        log.planValue = task.planValue
        log.status = task.status
        log.orderIndex = task.orderIndex
        saveContext()
    }
    
    func fetchLogs(predicate: NSPredicate? = nil,
                   sortDescriptors: [NSSortDescriptor]? = nil) -> [TaskLog] {
        let request: NSFetchRequest<TaskLog> = TaskLog.fetchRequest()
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        do {
            return try viewContext.fetch(request)
        } catch {
            print("!!!Fetch logs error: \(error)")
            return []
        }
    }
    
    
    
    func deleteAllLogs() {
        let req: NSFetchRequest<TaskLog> = TaskLog.fetchRequest()
        do {
            let logs = try viewContext.fetch(req)
            for log in logs {
                viewContext.delete(log)
            }
            saveContext()
        } catch {
            print("!!!Delete logs error: \(error)")
        }
    }
    
    func countLogs(withStatuses statuses: [String]) -> Int {
            let ctx = viewContext
            let request: NSFetchRequest<TaskLog> = TaskLog.fetchRequest()
            let pred = NSPredicate(format: "status IN %@", statuses)
            request.predicate = pred
            do {
                let logs = try ctx.fetch(request)
                return logs.count
            } catch {
                print("!!!Fetch logs error: \(error)")
                return 0
            }
        }
    
    func sumFactAndPlanValues() -> (sumFact: Int, sumPlan: Int) {
            let req: NSFetchRequest<TaskLog> = TaskLog.fetchRequest()
            do {
                let logs = try viewContext.fetch(req)
                let sumFact = logs.reduce(0) { $0 + Int($1.factValue) }
                let sumPlan = logs.reduce(0) { $0 + Int($1.planValue) }
                return (sumFact, sumPlan)
            } catch {
                print("!!!Fetch logs error: \(error)")
                return (0, 0)
            }
        }
}
