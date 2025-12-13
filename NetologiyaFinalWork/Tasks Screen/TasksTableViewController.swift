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
    private var originalTaskName: String?
    private var isAlphabetSortEnabled = false
    private var complexAlphabetSortEnabled = false
    private var isManualSortEnabled = false
    var isEditingActive = false
    
    var editOrderButton: UIBarButtonItem!
    var addNewTaskBarButton: UIBarButtonItem!
    var sortByAlphaButton: UIBarButtonItem!
    var sortComplexButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        title = "Задачи"
        navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
        
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
        
        addNewTaskBarButton =
        UIBarButtonItem(barButtonSystemItem: .add,
                        target: self,
                        action: #selector(didTapAddNewTaskBarButton))
        addNewTaskBarButton.tintColor = .systemBlue
        
        sortComplexButton = UIBarButtonItem(
            image: UIImage(systemName: "tray.2"),
            style: .plain,
            target: self,
            action: #selector(sortByComplexAlphabet))
        sortComplexButton.tintColor = .systemBlue
        
        
        
        sortByAlphaButton = UIBarButtonItem(
            image: UIImage(systemName: "textformat.abc"),
            style: .plain,
            target: self,
            action: #selector(sortByAlphabet))
        sortByAlphaButton.tintColor = .systemBlue
    
        
        editOrderButton = UIBarButtonItem(
            image: UIImage(systemName: "shuffle"),
            style: .plain,
            target: self,
            action: #selector(toggleReorder)
        )
        editOrderButton.tintColor = .black
        
        
        navigationItem.leftBarButtonItems = [sortByAlphaButton, sortComplexButton]
        navigationItem.rightBarButtonItems = [addNewTaskBarButton, editOrderButton]
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

    }
    
    
    
    @objc private func toggleReorder() {
        tableView.setEditing(!isEditingActive, animated: true)
        isEditingActive = tableView.isEditing
        editOrderButton.tintColor = isEditingActive ? .systemBlue : .black
        tableView.reloadData()
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    // Установка таймера в секундах (УСКОРЕНИЕ)
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
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
        // пример сортировки по полю orderIndex
        request.sortDescriptors = [NSSortDescriptor(key: "orderIndex", ascending: true)]
        do {
            tasks = try context.fetch(request)
            tableView.reloadData()
        } catch {
            print("!!!Failed to fetch tasks: \(error)")
        }
    }
    
    @objc private func sortByAlphabet() {
        isAlphabetSortEnabled.toggle()
        tasks.sort { ($0.taskName ?? "") < ($1.taskName ?? "") }

        // обновляем orderIndex согласно новом порядке
        for (idx, task) in tasks.enumerated() {
            task.orderIndex = Int64(idx)
        }

        TaskCoreDataManager.shared.saveContext()
        fetchTasks()
        tableView.reloadData()
    }
    
    @objc private func sortByComplexAlphabet() {
        complexAlphabetSortEnabled.toggle()
        if complexAlphabetSortEnabled {
            tasks.sort { (a, b) -> Bool in
                // приоритет статусов
                let orderA = sortPriorityForStatus(status: a.status)
                let orderB = sortPriorityForStatus(status: b.status)
                if orderA != orderB { return orderA < orderB }
                // внутри launched/run: по иконке
                if a.status == TaskStatus.launched.rawValue || a.status == TaskStatus.run.rawValue {
                    let iconA = iconPriority(t: a)
                    let iconB = iconPriority(t: b)
                    if iconA != iconB { return iconA < iconB }
                    // если одинаковы, можно по date или taskName
                    return (a.taskName ?? "") < (b.taskName ?? "")
                }
                // внутри stopped/created: алфавитный порядок
                if a.status == TaskStatus.stopped.rawValue || a.status == TaskStatus.created.rawValue {
                    return (a.taskName ?? "") < (b.taskName ?? "")
                }
                return false
            }
        } else {
            // вернуть обратно к текущей обычной сортировке, если нужно
            // например сорт по orderIndex
            tasks.sort { ($0.orderIndex) < ($1.orderIndex) }
        }
        // сохраняем новый порядок
        for (idx, t) in tasks.enumerated() {
            t.orderIndex = Int64(idx)
        }
        TaskCoreDataManager.shared.saveContext()
        fetchTasks()
        tableView.reloadData()
    }

    
    private func sortPriorityForStatus( status: String?) -> Int {
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
    
    private func iconPriority( t: Task) -> Int {
        // 0 - arrow.minus, 1 - arrow.backward, 2 - arrow.forward
        // предполагаем, что есть поле cyclicality или другой маркер иконки
        // простейшая заглушка:
        // если у вас есть очередность в вашем коде, верните соответствующий приоритет
        return 0
    }

    
    @objc private func didTapAddNewTaskBarButton() {
        let alert = UIAlertController(title: "Новая задача", message: "Введите название и выберите цикличность", preferredStyle: .alert)
        
        alert.addTextField { tf in
            tf.placeholder = "Название задачи"
        }
        
        // выбор цикличности через action sheet внутри alert
        let allCycles: [Cyclicality] = Cyclicality.allCases.filter { $0 != .error }

        for cycle in allCycles {
            alert.addAction(UIAlertAction(title: cycle.rawValue, style: .default, handler: { [weak self] _ in
                self?.createTask(withName: alert.textFields?.first?.text ?? "", cyclicality: cycle)
            }))
        }
        
        // кнопка отмены
        alert.addAction(UIAlertAction(title: "Отмена", style: .destructive, handler: nil))
        
        // если пользователь ввёл текст и нажал один из вариантов цикла, обработчик создаёт задачу
        present(alert, animated: true, completion: nil)
    }
    
    private func createTask(withName name: String, cyclicality: Cyclicality) {
        let context = TaskCoreDataManager.shared.viewContext
        let trimmedName = (name).trimmingCharacters(in: .whitespacesAndNewlines)
        let finalName = trimmedName.isEmpty ? "Без названия" : trimmedName

        if isTaskNameExists(name: finalName) {
            showNameExistsAlert(for: finalName)
            return
        }
        

        let newTask = Task(context: context)
        newTask.taskName = finalName
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
    
    private func isTaskNameExists( name: String) -> Bool {
        let context = TaskCoreDataManager.shared.viewContext
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        request.predicate = NSPredicate(format: "taskName == %@", name)
        do {
            let count = try context.count(for: request)
            return count > 0
        } catch {
            print("!!!Check name exists error: \(error)")
            return false
        }
    }
    
    private func showNameExistsAlert(for name: String) {
        let alert = UIAlertController(title: "Ошибка",
                                      message: "Задача с таким именем уже существует. Введите уникальное название.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: { [weak self] _ in
            self?.didTapAddNewTaskBarButton()}))
        present(alert, animated: true, completion: nil)
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
                                      preferredStyle: .actionSheet)
        
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
        
        
        alert.addAction(UIAlertAction(title: "Переименовать",style: .default, handler: { [weak self] _ in
            self?.tapRenameTask(for: indexPath)
        }))
        
        alert.addAction(UIAlertAction(title: "Изменить цикличность", style: .default, handler: { [weak self] _ in
            self?.tapChangeCyclicality(for: indexPath)
        }))
        
        alert.addAction(UIAlertAction(title: "Удалить", style: .destructive, handler: { [weak self] _ in
            self?.confirmDeleteTaskAndAllLogs(for: indexPath)
        }))
        
        // Отменить
        alert.addAction(UIAlertAction(title: "Выйти без изменений",
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
        
        let task = tasks[indexPath.row]
        guard let previousStatus = task.status else { return }
        
        self.updateStatusToStopped(for: indexPath)
        self.updateDateToCurrent(for: indexPath)
        task.factValue = updateFactValueBasedOnPreviousTaskStatusStopTap(from: previousStatus, and: indexPath)
        self.updatePlanValueToZero(for: indexPath)
        
        let newLog = tasks[indexPath.row]
        newLog.planValue = updatePlanValueBasedOnPreviousTaskStatusForTaskLogStopTap(from: previousStatus, and: indexPath)
        TaskLogsCoreDataManager.shared.createLog(from: newLog)
        
        updateFactValueForAllTasks()
        updatePlanValueForAllTasksBasedOnCurrentStatus()
    }
    
    @objc private func tapRenameTask(for indexPath: IndexPath) {
        let task = tasks[indexPath.row]
        let currentName = task.taskName ?? ""
        let alert = UIAlertController(title: "Переименовать задачу", message: nil, preferredStyle: .alert)
        alert.addTextField { tf in
            tf.text = currentName
            tf.placeholder = "Новое имя"
        }
        alert.addAction(UIAlertAction(title: "Сохранить", style: .default, handler: { [weak self] _ in
            if let newName = alert.textFields?.first?.text, !newName.isEmpty {
                self?.renameTask(at: indexPath, to: newName)
            }
        }))
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        present(alert, animated: true)
    }

    private func renameTask(at indexPath: IndexPath, to newName: String) {
        let task = tasks[indexPath.row]
        let oldName = task.taskName
        task.taskName = newName
        // обновление логов, если нужно: сменить или сохранить новое имя в связанных TaskLog
        let logs = TaskLogsCoreDataManager.shared.fetchLogs(predicate: NSPredicate(format: "taskName == %@", oldName ?? ""))
        for log in logs {
            log.taskName = newName
        }
        TaskCoreDataManager.shared.saveContext()
        fetchTasks()
    }
    
    
    @objc private func tapChangeCyclicality(for indexPath: IndexPath) {
        let task = tasks[indexPath.row]
        let alert = UIAlertController(title: "Изменить цикличность, задача будет остановлена", message: nil, preferredStyle: .actionSheet)
        let allCycles: [Cyclicality] = [.daily, .weekly, .monthly, .biMonthly, .quarterly, .biQuarterly, .yearly, .biYearly]

        // сначала можно остановить задачу здесь, если нужно до смены цикла
        // но мы хотим делать это после выбора цикла
        for cycle in allCycles {
            alert.addAction(UIAlertAction(title: cycle.rawValue, style: .default, handler: { [weak self] _ in
                // 1) сначала применяем остановку до смены цикла, если это часть логики
                self?.tapStopTask(for: indexPath)

                // 2) затем меняем цикличность и сохраняем
                task.cyclicality = cycle.rawValue
                TaskCoreDataManager.shared.saveContext()
                self?.fetchTasks()
            }))
        }
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        present(alert, animated: true)
    }


    private func updateLogsForTaskName(_ newName: String, from oldName: String?) {
        guard let old = oldName else { return }
        let logs = TaskLogsCoreDataManager.shared.fetchLogs(predicate: NSPredicate(format: "taskName == %@", old))
        for log in logs {
            log.taskName = newName
        }
    }
    
    
    
    
    private func updateDateToCurrent(for indexPath: IndexPath) {
        let task = tasks[indexPath.row]
        task.date = Date()
        TaskCoreDataManager.shared.saveContext()
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
    
    
    private func updatePlanValueBasedOnPreviousTaskStatusExecuteTap(from previousStatus: String, and indexPath: IndexPath) -> Int64 {
        
        switch previousStatus {
        case TaskStatus.completed.rawValue:
            return 404001
        default:
            return getPlanValueBasedOnCyclicality(for: indexPath)
        }
    }
    
    private func updatePlanValueBasedOnPreviousTaskStatusForTaskStopTap(from previousStatus: String, and indexPath: IndexPath) -> Int64 {
        
        switch previousStatus {
        
        case TaskStatus.completed.rawValue:
            return 404002
        default:
            return 0
        }
    }
    
    private func updatePlanValueBasedOnPreviousTaskStatusForTaskLogStopTap(from previousStatus: String, and indexPath: IndexPath) -> Int64 {
        
        switch previousStatus {
        
        case TaskStatus.completed.rawValue:
            return 404002
        case TaskStatus.run.rawValue, TaskStatus.launched.rawValue:
            return getPlanValueBasedOnCyclicality(for: indexPath) * -1
        default:
            return 0
        }
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
    
    private func updatePlanValueForTaskBasedCurrentStatus(for indexPath: IndexPath) {
        
        let task = tasks[indexPath.row]
        
        switch task.status {
        case TaskStatus.created.rawValue, TaskStatus.stopped.rawValue:
            return task.planValue = 0
        default:
            task.planValue = getPlanValueBasedOnCyclicality(for: indexPath)
        }
        
        TaskCoreDataManager.shared.saveContext()
        fetchTasks()
        tableView.reloadData()
        
    }
    
    private func updatePlanValueForAllTasksBasedOnCurrentStatus() {
        for (index, _) in tasks.enumerated() {
            let indexPath = IndexPath(row: index, section: 0)
            updatePlanValueForTaskBasedCurrentStatus(for: indexPath)
        }
        // таблица может обновиться внутри updateFactValue, но на всякий случай:
        tableView.reloadData()
    }
    
    
    private func updateFactValueBasedOnPreviousTaskStatusStopTap(from previousStatus: String, and indexPath: IndexPath) -> Int64 {
        
        switch previousStatus {
        
        case TaskStatus.completed.rawValue:
            return 404005
        case TaskStatus.run.rawValue, TaskStatus.launched.rawValue:
            return getPlanValueBasedOnCyclicality(for: indexPath) * -1
        default:
            return 0
        }
    
    }
    
    private func updateFactValueBasedOnPreviousTaskStatusExecuteTap(from previousStatus: String, and indexPath: IndexPath, with currentFactValue: Int64) -> Int64 {
        
        switch previousStatus {
        case TaskStatus.created.rawValue:
            return getPlanValueBasedOnCyclicality(for: indexPath)
        case TaskStatus.launched.rawValue:
            return currentFactValue
        case TaskStatus.run.rawValue:
            return currentFactValue
        case TaskStatus.stopped.rawValue:
            return getPlanValueBasedOnCyclicality(for: indexPath)
        case TaskStatus.completed.rawValue:
            return 404003
        default:
            return 404004
        }
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
            let hours = Int64(diffSec / 5) // УСКОРЕНИЕ 60 - минуты, 3600 - часы
            
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TaskTableViewCell", for: indexPath) as? TasksTableViewCell else {
            return UITableViewCell(style: .default, reuseIdentifier: "TaskTableViewCell")
        }
        let task = tasks[indexPath.row]
        cell.configure(with: task, hideLabels: isEditingActive)
        return cell
    }

    
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(style: .normal, title: "Изменить") { [weak self] action, view, completion in
            self?.presentStatusActionAlert(for: indexPath) // или ваш метод редактирования
            
            completion(true)
        }
        editAction.backgroundColor = .systemGreen
        return UISwipeActionsConfiguration(actions: [editAction])
    }
    
    private func confirmDeleteTaskAndAllLogs(for indexPath: IndexPath) {
        let task = tasks[indexPath.row]
        let alert = UIAlertController(title: "Удалить задачу и историю",
                                      message: "Вы действительно хотите удалить \"\(task.taskName ?? "")\"\n и всю историю задачи?",
                                      preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Удалить", style: .destructive, handler: { [weak self] _ in
            self?.deleteAllLogs(forTaskName: task.taskName)
            self?.deleteTask(at: indexPath)
        }))
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    private func deleteAllLogs(forTaskName name: String?) {
        guard let name = name else { return }
        let logs = TaskLogsCoreDataManager.shared.fetchLogs(predicate: NSPredicate(format: "taskName == %@", name))
        for log in logs {
            TaskLogsCoreDataManager.shared.viewContext.delete(log)
        }
        TaskLogsCoreDataManager.shared.saveContext()
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { [weak self] _, _, completion in
            self?.confirmDeleteTaskAndAllLogs(for: indexPath)
            completion(true)
        }
        deleteAction.backgroundColor = .systemRed
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    private func deleteTask(at indexPath: IndexPath) {
        let taskToDelete = tasks[indexPath.row]
        let context = TaskCoreDataManager.shared.viewContext
        context.delete(taskToDelete)
        TaskCoreDataManager.shared.saveContext()
        tasks.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }

    
    override func tableView( _ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            confirmDeleteTaskAndAllLogs(for: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        presentStatusActionAlert(for: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool { true }

    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let moved = tasks.remove(at: sourceIndexPath.row)
        tasks.insert(moved, at: destinationIndexPath.row)

        // обновляем orderIndex в каждом элементе в новой последовательности
        for (idx, task) in tasks.enumerated() {
            task.orderIndex = Int64(idx)
        }

        TaskCoreDataManager.shared.saveContext()
        fetchTasks() // если нужен повторный рендер
    }
}
