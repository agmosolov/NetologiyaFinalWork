//
//  TasksTableViewController.swift
//  NetologiyaFinalWork
//
//  Created by Александр Мосолов on 02.12.2025.
//

import UIKit
import CoreData

class TasksTableViewController: UITableViewController {
    private var tasks: [Task] = []
    private var isBatchEditingEnabled = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        tableView.register(TaskTableViewCell.self, forCellReuseIdentifier: "TaskTableViewCell")
        
        fetchTasks()
        updateFactValueForAllActivities()
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
        
        navigationItem.leftBarButtonItem = deleteTaskBarButton
    }
    
    
    private func fetchTasks() {
        let context = CoreDataManager.shared.viewContext
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        do {
            tasks = try context.fetch(request)
            tableView.reloadData()
            print(tasks)
        } catch {
            print("Failed to fetch tasks: \(error)")
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
        let context = CoreDataManager.shared.viewContext
        let newTask = Task(context: context)
        newTask.taskName = name.isEmpty ? "Без названия" : name
        newTask.cyclicality = cyclicality.rawValue
        newTask.status = "Созданный"
        newTask.planValue = 0
        newTask.factValue = 0
        newTask.date = Date()
        CoreDataManager.shared.saveContext()
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
    
    
    
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int { 1 }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TaskTableViewCell",
                                                       for: indexPath) as? TaskTableViewCell else {
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
        let context = CoreDataManager.shared.viewContext
        context.delete(taskToDelete)
        CoreDataManager.shared.saveContext()
        tasks.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let taskToDelete = tasks[indexPath.row]
            let context = CoreDataManager.shared.viewContext
            context.delete(taskToDelete)
            CoreDataManager.shared.saveContext()
            tasks.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        presentStatusActionAlert(for: indexPath)
    }
    
    private func presentStatusActionAlert(for indexPath: IndexPath) {
        let task = tasks[indexPath.row]
        
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
    
    
    private func tapExecuteTask(for indexPath: IndexPath) {
        self.updateStatusToActive(for: indexPath)
        self.updateDateToCurrent(for: indexPath)
        self.updatePlanValueToCyclicality(for: indexPath)
        self.updateFactValue(for: indexPath)
        fetchTasks()
    }
    
    
    private func tapStopTask(for indexPath: IndexPath) {
        self.updateStatusToPassive(for: indexPath)
        self.updateDateToCurrent(for: indexPath)
        self.updatePlanValueToZero(for: indexPath)
        self.updateFactValueToZero(for: indexPath)
        fetchTasks()
    }
    
    
    private func updateDateToCurrent(for indexPath: IndexPath) {
        let task = tasks[indexPath.row]
//        let context = CoreDataManager.shared.viewContext
        task.date = Date()
        CoreDataManager.shared.saveContext()
    }
    
    private func updateStatusToActive(for indexPath: IndexPath) {
        let task = tasks[indexPath.row]
//        let context = CoreDataManager.shared.viewContext
        task.status = TaskStatus.active.rawValue
        CoreDataManager.shared.saveContext()
    }
    
    private func updateStatusToPassive(for indexPath: IndexPath) {
        let task = tasks[indexPath.row]
//        let context = CoreDataManager.shared.viewContext
        task.status = TaskStatus.passive.rawValue
        CoreDataManager.shared.saveContext()
    }
    
    private func updateStatusToCreated(for indexPath: IndexPath) {
        let task = tasks[indexPath.row]
//        let context = CoreDataManager.shared.viewContext
        task.status = TaskStatus.created.rawValue
        CoreDataManager.shared.saveContext()
    }
    
    private func updatePlanValueToCyclicality(for indexPath: IndexPath) {
        let task = tasks[indexPath.row]
        
        guard let status = Cyclicality(rawValue: task.cyclicality ?? "") else { return }
        
        if let value = planValueForCyclecycle[Cyclicality(rawValue: status.rawValue) ?? .error] {
            task.planValue = Int64(value)
            CoreDataManager.shared.saveContext()
            fetchTasks()
        }
    }
    
    private func updatePlanValueToZero(for indexPath: IndexPath) {
        let task = tasks[indexPath.row]
//        let context = CoreDataManager.shared.viewContext
        task.planValue = 0
        CoreDataManager.shared.saveContext()
    }
    
    private func updateFactValue(for indexPath: IndexPath) {
        let task = tasks[indexPath.row]
        
        guard let taskDate = task.date else { return }

        if task.status == TaskStatus.active.rawValue {
            // текущее время в секундах
            let now = Date()
            // разница в секундах
            let diffSec = now.timeIntervalSince(taskDate)
            // переводим в часы, округляем вниз
            let hours = Int64(diffSec / 60)
            
            // плановое значение
            let plan = task.planValue
            
            // ваша логика
            let result: Int64
            if plan >= hours {
                result = hours
            } else {
                result = plan * 2 - hours
            }
            
            task.factValue = result
            
            CoreDataManager.shared.saveContext()
            fetchTasks()
        } else {
            task.factValue = 0
        }
    }
    
    
    private func updateFactValueForAllActivities() {
        for (index, _) in tasks.enumerated() {
            let indexPath = IndexPath(row: index, section: 0)
            updateFactValue(for: indexPath)
        }
        // таблица может обновиться внутри updateFactValue, но на всякий случай:
        tableView.reloadData()
    }
    
    private func updateFactValueToZero(for indexPath: IndexPath) {
        let task = tasks[indexPath.row]
//        let context = CoreDataManager.shared.viewContext
        task.factValue = 0
        CoreDataManager.shared.saveContext()
    }
    
    private func progressBar(for indexPath: IndexPath) {
        
        
    }
    
    
    
    
    
}
