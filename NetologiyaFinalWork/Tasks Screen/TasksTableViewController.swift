//
//  TasksTableViewController.swift
//  NetologiyaFinalWork
//
//  Created by Александр Мосолов on 02.12.2025.
//

import Foundation
import UIKit
import CoreData

class TasksTableViewController: UITableViewController {
    private var tasks: [Task] = []
    private var isBatchEditingEnabled = false
    private var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        title = "Мои задачи"
        
        tableView.register(TasksTableViewCell.self, forCellReuseIdentifier: "TaskTableViewCell")
        
        fetchTasks()
        updateFactValueForAllTasks()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateFactValueForAllTasks()
        fetchTasks()
        startTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        stopTimer()
    }
    
    
    private func setupUI() {
        view.backgroundColor = .white
            
        // Добавил кнопку добавления (плюс)
        let addNewTaskBarButton =
        UIBarButtonItem(barButtonSystemItem: .add,
                        target: self,
                        action: #selector(didTapAddNewTaskBarButton))
        
        navigationItem.rightBarButtonItem = addNewTaskBarButton
        
        // Добавил кнопку удаления (корзины)
        let deleteTaskBarButton =
        UIBarButtonItem(barButtonSystemItem: .trash,
                        target: self,
                        action: #selector(didTapDeleteTasksBarButton))
        
        let sortTasksBarButton =
        UIBarButtonItem(barButtonSystemItem: .refresh,
                        target: self,
                        action: #selector(didTapSortTasksBarButton))
        
        navigationItem.leftBarButtonItems = [deleteTaskBarButton, sortTasksBarButton]
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] _ in
            self?.updateFactValueForAllTasks()
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    
    private func fetchTasks() {
        
        let context = TaskCoreDataManager.shared.viewContext
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        do {
            tasks = try context.fetch(request)
            tableView.reloadData()
        } catch {
            print("!!!Failed to fetch tasks: \(error)")
        }
    }
    
    
    private func fetchAndSortTasks() {
        // загрузить
        let context = TaskCoreDataManager.shared.viewContext
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        // можно добавить базовую сортировку по дате, если нужно
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        do {
            tasks = try context.fetch(request)
            // доп сортировка по кастомной лексике
            tasks.sort(by: sortDescriptorForTasks())
            tableView.reloadData()
        } catch {
            print("!!!Fetch tasks error: \(error)")
        }
    }
    
    @objc private func didTapAddNewTaskBarButton() {
        let alert = UIAlertController(title: "Новая задача", message: "Введите название и выберите цикличность", preferredStyle: .alert)
        
        alert.addTextField { tf in
            tf.placeholder = "Название задачи"
        }
        
        // выбор цикличности через action sheet внутри alert
        for cycle in Cyclicality.allCases {
            alert.addAction(UIAlertAction(title: cycle.rawValue, style: .default, handler: { [weak self] _ in
                self?.createTask(withName: alert.textFields?.first?.text ?? "", cyclicality: cycle)
            }))
        }
        
        // кнопка отмены
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        
        // если пользователь ввёл текст и нажал один из вариантов цикла, обработчик создаёт задачу
        present(alert, animated: true, completion: nil)
    }
    
    private func createTask(withName name: String, cyclicality: Cyclicality) {
        let context = TaskCoreDataManager.shared.viewContext
        let newTask = Task(context: context)
        newTask.taskName = name.isEmpty ? "Без названия" : name
        newTask.cyclicality = cyclicality.rawValue
        newTask.status = TaskStatus.created.rawValue
        newTask.planValue = 0
        newTask.factValue = 0
        newTask.date = Date()
        TaskCoreDataManager.shared.saveContext()
        // Create log
        TaskLogsCoreDataManager.shared.createLog(from: newTask)
        fetchTasks()
    }
    
    @objc private func didTapDeleteTasksBarButton() {
        isBatchEditingEnabled.toggle()
        // Включаем/выключаем редактирование таблицы
        tableView.setEditing(isBatchEditingEnabled, animated: true)
        // Обновляем нав. кнопку, чтобы пользователь понял текущее состояние
        navigationItem.leftBarButtonItem?.style = isBatchEditingEnabled ? .plain : .plain
        // При желании скрыть стандартные кнопки редактирования
    }
    
    
    @objc private func didTapSortTasksBarButton() {
        fetchTasks()
    }
    
    private func presentStatusActionAlert(for indexPath: IndexPath) {
        //        let task = tasks[indexPath.row]
        
        let alert = UIAlertController(title: "Выберете действие",
                                      message: nil,
                                      preferredStyle: .alert)
        
        // Выполнить
        alert.addAction(UIAlertAction(title: "Выполнить",
                                      style: .default,
                                      handler: { [weak self] _ in
            self?.tapExecuteTask(for: indexPath)
        }))
        
        // Деактивировать
        alert.addAction(UIAlertAction(title: "Остановить", style: .destructive, handler: { [weak self] _ in
            self?.tapStopTask(for: indexPath)
        }))
        
        // Отменить
        alert.addAction(UIAlertAction(title: "Выйти",
                                      style: .cancel,
                                      handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    
    
    @objc private func tapExecuteTask(for indexPath: IndexPath) {
        
        let task = tasks[indexPath.row]
        let currentFactValue = task.factValue
        let currentStatus = task.status
        updateDateToCurrent(for: indexPath)
        updatePlanValueBasedOnCyclicality(for: indexPath)
        updateFactValueForTask(for: indexPath)
        
        let updatedTask = tasks[indexPath.row]
        
        
        
        updatedTask.status = updateStatusBasedOnPreviousForLogs(from: (TaskStatus(rawValue: currentStatus!) ?? .completed).rawValue)
        task.status = updateStatusBasedOnPreviousExecuteTap(from: currentStatus ?? "error")
        
        
        updatedTask.planValue = updatePlanValueBasedOnPreviousTaskStatusExecuteTap(from: currentStatus ?? "", and: indexPath)
        
        
        updatedTask.factValue = updateFactValueBasedOnPreviousTaskStatusExecuteTap(from: currentStatus ?? "", and: indexPath, with: currentFactValue)
        
        
        TaskLogsCoreDataManager.shared.createLog(from: updatedTask)
        
        task.status = updateStatusBasedOnPreviousExecuteTap(from: currentStatus ?? "error")
        
        
        updateFactValueForAllTasks()
        restartTimer()
    }
    
    
    private func tapStopTask(for indexPath: IndexPath) {
        
//        let task = tasks[indexPath.row]
        
        self.updateStatusToStopped(for: indexPath)
        self.updateDateToCurrent(for: indexPath)
        self.updatePlanValueToZero(for: indexPath)
        self.updateFactValueToZero(for: indexPath)
        
        let newLog = tasks[indexPath.row]
        TaskLogsCoreDataManager.shared.createLog(from: newLog)
        
        self.updatePlanValueToZero(for: indexPath)
        
        updateFactValueForAllTasks()
    }
    
    
    
    
    private func updateStatusBasedOnPreviousForLogs(from oldStatus: String) -> String {
        
        switch oldStatus {
        case TaskStatus.created.rawValue:
            return TaskStatus.launched.rawValue
        case TaskStatus.run.rawValue:
            return TaskStatus.completed.rawValue
        case TaskStatus.completed.rawValue:
            return TaskStatus.error.rawValue
        case TaskStatus.stopped.rawValue:
            return TaskStatus.launched.rawValue
        default:
            return TaskStatus.error.rawValue
        }
    }
    
    private func updateStatusBasedOnPreviousExecuteTap(from previousStatus: String) -> String {
        
        switch previousStatus {
        case TaskStatus.created.rawValue:
            return TaskStatus.launched.rawValue
        case TaskStatus.launched.rawValue:
            return TaskStatus.run.rawValue
        case TaskStatus.run.rawValue:
            return TaskStatus.run.rawValue
        case TaskStatus.stopped.rawValue:
            return TaskStatus.launched.rawValue
        default:
            return TaskStatus.error.rawValue
        }
    }
    
    
    private func updatePlanValueBasedOnPreviousTaskStatusExecuteTap(from previousStatus: String, and indexPath: IndexPath) -> Int64 {
        
        switch previousStatus {
        case TaskStatus.created.rawValue:
            return 0
        case TaskStatus.launched.rawValue:
            return getPlanValueBasedOnCyclicality(for: indexPath)
        case TaskStatus.run.rawValue:
            return getPlanValueBasedOnCyclicality(for: indexPath)
        case TaskStatus.stopped.rawValue:
            return getPlanValueBasedOnCyclicality(for: indexPath)
        case TaskStatus.completed.rawValue:
            return 404001
        default:
            return 404002
        }
    }
    
    private func updateFactValueBasedOnPreviousTaskStatusExecuteTap(from previousStatus: String, and indexPath: IndexPath, with currentFactValue: Int64) -> Int64 {
        
        switch previousStatus {
        case TaskStatus.created.rawValue:
            return 0
        case TaskStatus.launched.rawValue:
            return currentFactValue
        case TaskStatus.run.rawValue:
            return currentFactValue
        case TaskStatus.stopped.rawValue:
            return 0
        case TaskStatus.completed.rawValue:
            return 404003
        default:
            return 404004
        }
    }
    
    private func updateDateToCurrent(for indexPath: IndexPath) {
        let task = tasks[indexPath.row]
        task.date = Date()
        TaskCoreDataManager.shared.saveContext()
    }
    
    private func updateStatusToCreated(for indexPath: IndexPath) {
        let task = tasks[indexPath.row]
        task.status = TaskStatus.created.rawValue
        TaskCoreDataManager.shared.saveContext()
    }
    
    private func updateStatusToCompleted(for indexPath: IndexPath) {
        let task = tasks[indexPath.row]
        task.status = TaskStatus.completed.rawValue
        TaskCoreDataManager.shared.saveContext()
    }
    
    
    private func updateStatusToRun(for indexPath: IndexPath) {
        let task = tasks[indexPath.row]
        task.status = TaskStatus.run.rawValue
        TaskCoreDataManager.shared.saveContext()
    }
    
    private func updateStatusToStopped(for indexPath: IndexPath) {
        let task = tasks[indexPath.row]
        task.status = TaskStatus.stopped.rawValue
        TaskCoreDataManager.shared.saveContext()
    }
    
    
    private func updatePlanValueBasedOnCyclicality(for indexPath: IndexPath) {
        let task = tasks[indexPath.row]
        
        guard let status = Cyclicality(rawValue: task.cyclicality ?? "") else { return }
        
        if let value = planValueForCyclecycle[Cyclicality(rawValue: status.rawValue) ?? .error] {
            task.planValue = Int64(value)
            TaskCoreDataManager.shared.saveContext()
            fetchTasks()
        }
    }
    
    private func getPlanValueBasedOnCyclicality(for indexPath: IndexPath) -> Int64 {
        let task = tasks[indexPath.row]
        guard let cycle = Cyclicality(rawValue: task.cyclicality ?? "") else { return 0 }
        if let value = planValueForCyclecycle[cycle] {
            return Int64(value)
        }
        return 0
    }
    
    private func updatePlanValueToZero(for indexPath: IndexPath) {
        let task = tasks[indexPath.row]
        task.planValue = 0
        TaskCoreDataManager.shared.saveContext()
    }
    
    private func updateFactValueToZero(for indexPath: IndexPath) {
        let task = tasks[indexPath.row]
        task.factValue = 0
        TaskCoreDataManager.shared.saveContext()
    }
    
    
    private func updateFactValueForTask(for indexPath: IndexPath) {
        let task = tasks[indexPath.row]
        guard let taskDate = task.date else { return }
        
        if (task.status != nil) {
            let now = Date()
            let diffSec = now.timeIntervalSince(taskDate)
            let hours = Int64(diffSec / 60) // 3600 часы
            
            let plan = task.planValue
            
            let result: Int64
            if plan > 0 {
                if plan >= hours {
                    result = hours
                } else {
                    result = plan * 2 - hours
                }
            } else {
                result = 0
            }
            
            task.factValue = result
            
            TaskCoreDataManager.shared.saveContext()
            fetchTasks()
            tableView.reloadData()
        } else {
            task.factValue = 0
            TaskCoreDataManager.shared.saveContext()
            fetchTasks()
            tableView.reloadData()
        }
    }
    
    
    private func getFactValueForTask(for indexPath: IndexPath) -> Int64 {
        let task = tasks[indexPath.row]
        
        guard let taskDate = task.date else { return 0 }
        if (task.status != nil) {
            let now = Date()
            let diffSec = now.timeIntervalSince(taskDate)
            let hours = Int64(diffSec / 60) // 60 часы
            
            let plan = task.planValue
            let result: Int64
            if plan > 0 {
                if plan >= hours {
                    result = hours
                } else {
                    result = plan * 2 - hours
                }
            } else {
                result = 0
            }
            
            task.factValue = result
            return result
        } else {
            return 0
        }
    }
    
    private func updateFactValueForAllTasks() {
        for (index, _) in tasks.enumerated() {
            let indexPath = IndexPath(row: index, section: 0)
            updateFactValueForTask(for: indexPath)
        }
        // таблица может обновиться внутри updateFactValue, но на всякий случай:
        tableView.reloadData()
    }
    
    
    private func restartTimer() {
        stopTimer()
        startTimer()
    }
    
    
    private func sortDescriptorForTasks() -> ((Task, Task) -> Bool) {
        // приоритет: launched, run (периодические состояния), затем stopped, затем created
        func priority(_ status: String?) -> Int {
            switch status {
            case TaskStatus.launched.rawValue, TaskStatus.run.rawValue:
                return 0
            case TaskStatus.stopped.rawValue:
                return 1
            case TaskStatus.created.rawValue:
                return 2
            default:
                return 3
            }
        }
        return { (a, b) in
            let pa = priority(a.status)
            let pb = priority(b.status)
            if pa == pb {
                // второстепенно можно сортировать по дате или имени
                if let da = a.date, let db = b.date {
                    return da > db
                }
                return false
            }
            return pa < pb
        }
    }
    
    
    
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int { 1 }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TaskTableViewCell",
                                                       for: indexPath) as? TasksTableViewCell else {
            return UITableViewCell(style: .default, reuseIdentifier: "TaskTableViewCell")
        }
        let task = tasks[indexPath.row]
        cell.configure(with: task)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { [weak self] (action, view, completion) in
            self?.deleteTask(at: indexPath)
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return nil
    }
    
    private func deleteTask(at indexPath: IndexPath) {
        let taskToDelete = tasks[indexPath.row]
        let context = TaskCoreDataManager.shared.viewContext
        context.delete(taskToDelete)
        TaskCoreDataManager.shared.saveContext()
        tasks.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let taskToDelete = tasks[indexPath.row]
            let context = TaskCoreDataManager.shared.viewContext
            context.delete(taskToDelete)
            TaskCoreDataManager.shared.saveContext()
            tasks.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        presentStatusActionAlert(for: indexPath)
    }
    
}
