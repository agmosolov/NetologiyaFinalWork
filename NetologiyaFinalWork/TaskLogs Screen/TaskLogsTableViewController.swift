//
//  TaskLogsTableViewController.swift
//  NetologiyaFinalWork
//
//  Created by Александр Мосолов on 06.12.2025.
//

import Foundation
import UIKit
import CoreData

class TaskLogsTableViewController: UITableViewController {
    
    private var logs: [TaskLog] = []
    private var isAlphabetSortEnabled = false
    private var isDateSortEnabled = false
    
    
    var deleteTaskBarButton = UIBarButtonItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        tableView.register(TaskLogTableViewCell.self, forCellReuseIdentifier: "TaskLogCell")
        fetchLogs()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchLogs()
        tableView.reloadData()
    }
    
    private func setupUI() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        title = "История"
        navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
        
        // Кнопка удаления слева (чистый левый свайп)
        deleteTaskBarButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(didTapDeleteTasksBarButton))
        navigationItem.rightBarButtonItem = deleteTaskBarButton
        
        let alphabetButton = UIBarButtonItem(
            image: UIImage(systemName: "textformat.abc"),
            style: .plain,
            target: self,
            action: #selector(sortByAlphabet)
        )
        
        let dateButton = UIBarButtonItem(
            image: UIImage(systemName: "calendar"),
            style: .plain,
            target: self,
            action: #selector(sortByDate)
        )
        
        navigationItem.leftBarButtonItems = [alphabetButton, dateButton]
        
    }
    
    
    @objc private func sortByAlphabet() {
        isAlphabetSortEnabled.toggle()
        if isAlphabetSortEnabled {
            logs.sort { ($0.taskName ?? "") < ($1.taskName ?? "") }
        } else {
            logs.sort { $0.orderIndex < $1.orderIndex }
        }
        for (idx, log) in logs.enumerated() { log.orderIndex = Int64(idx) }
        TaskLogsCoreDataManager.shared.saveContext()
        tableView.reloadData()
    }

    
    @objc private func sortByDate() {
        isDateSortEnabled.toggle()
        if isDateSortEnabled {
            logs.sort { ($0.date ?? Date.distantPast) > ($1.date ?? Date.distantPast) }
        } else {
            // вернуть к orderIndex
            logs.sort { $0.orderIndex < $1.orderIndex }
        }
        // сохранить новый порядок
        for (idx, log) in logs.enumerated() {
            log.orderIndex = Int64(idx)
        }
        TaskLogsCoreDataManager.shared.saveContext()
        fetchLogs()
        tableView.reloadData()
    }
    
    
    
    @objc private func didTapDeleteTasksBarButton() {
        let alert = UIAlertController(title: "Удалить всю историю",
                                      message: "Вы уверены, что хотите удалить всю историю?",
                                      preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Удалить", style: .destructive, handler: { [weak self] _ in
            TaskLogsCoreDataManager.shared.deleteAllLogs()
            self?.fetchLogs()
            self?.tableView.reloadData()
        }))
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Data
    private func fetchLogs() {
        let request: NSFetchRequest<TaskLog> = TaskLog.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        do {
            logs = try TaskLogsCoreDataManager.shared.viewContext.fetch(request)
            tableView.reloadData()
        } catch {
            print("!!!Fetch logs error: \(error)")
        }
    }
    
    
    
    // MARK: - Present edit options for log
    private func presentLogEditOptions(for indexPath: IndexPath) {
        _ = logs[indexPath.row]
        let alert = UIAlertController(title: "Изменить запись",
                                      message: nil,
                                      preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Изменить факт", style: .default, handler: { [weak self] _ in
            self?.promptUpdateFact(for: indexPath)
        }))
        
        alert.addAction(UIAlertAction(title: "Изменить план", style: .default, handler: { [weak self] _ in
            self?.promptUpdatePlan(for: indexPath)
        }))
        
        alert.addAction(UIAlertAction(title: "Изменить статус", style: .default, handler: { [weak self] _ in
            self?.changeLogStatus(for: indexPath)
        }))
        
        alert.addAction(UIAlertAction(title: "Удалить", style: .destructive, handler: { [weak self] _ in
            self?.deleteLog(for: indexPath)
        }))
        
        alert.addAction(UIAlertAction(title: "Выйти без изменений", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    
    @objc private func changeLogStatus(for indexPath: IndexPath) {
        let log = logs[indexPath.row]

        let alert = UIAlertController(title: "Изменить статус", message: nil, preferredStyle: .actionSheet)

        let statuses: [String] =
            [TaskStatus.created.rawValue,
            TaskStatus.launched.rawValue,
            TaskStatus.run.rawValue,
            TaskStatus.stopped.rawValue]
        

        for s in statuses {
            alert.addAction(UIAlertAction(title: s, style: .default, handler: { [weak self] _ in
                log.status = s
                TaskLogsCoreDataManager.shared.saveContext()
                self?.fetchLogs()
                self?.tableView.reloadData()
            }))
        }

        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))

        // Для iPad задайте попап-подсказку
        if let popover = alert.popoverPresentationController, let cell = tableView.cellForRow(at: indexPath) {
            popover.sourceView = cell
            popover.sourceRect = cell.bounds
            popover.permittedArrowDirections = .any
        }

        present(alert, animated: true, completion: nil)
    }
    
    // 3) Ввод изменений
    private func promptUpdateFact(for indexPath: IndexPath) {
        let log = logs[indexPath.row]
        let ac = UIAlertController(title: "Изменить факт",
                                   message: nil,
                                   preferredStyle: .alert)
        ac.addTextField { tf in
            tf.keyboardType = .numberPad
            tf.text = "\(log.factValue)"
        }
        ac.addAction(UIAlertAction(title: "Сохранить", style: .default, handler: { [weak self] _ in
            if let text = ac.textFields?.first?.text, let newVal = Int64(text) {
                log.factValue = newVal
                TaskLogsCoreDataManager.shared.saveContext()
                self?.fetchLogs()
            }
        }))
        ac.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        present(ac, animated: true, completion: nil)
    }
    
    private func promptUpdatePlan(for indexPath: IndexPath) {
        let log = logs[indexPath.row]
        let ac = UIAlertController(title: "Изменить план",
                                   message: nil,
                                   preferredStyle: .alert)
        ac.addTextField { tf in
            tf.keyboardType = .numberPad
            tf.text = "\(log.planValue)"
        }
        ac.addAction(UIAlertAction(title: "Сохранить", style: .default, handler: { [weak self] _ in
            if let text = ac.textFields?.first?.text, let newVal = Int64(text) {
                log.planValue = newVal
                TaskLogsCoreDataManager.shared.saveContext()
                self?.fetchLogs()
            }
        }))
        ac.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        present(ac, animated: true, completion: nil)
    }
    
    private func deleteLog(for indexPath: IndexPath) {
        let log = logs[indexPath.row]
        TaskLogsCoreDataManager.shared.viewContext.delete(log)
        TaskLogsCoreDataManager.shared.saveContext()
        logs.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        fetchLogs()
    }
    
    // Helpers
    private func updateAllStats() {}
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return logs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TaskLogCell", for: indexPath) as? TaskLogTableViewCell else {
            return UITableViewCell(style: .default, reuseIdentifier: "TaskLogCell")
        }
        let log = logs[indexPath.row]
        cell.configure(with: log)
        return cell
    }
    
    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        presentLogEditOptions(for: indexPath)
    }
    
    // MARK: - Leading swipe (изменение/редактирование слева)
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(style: .normal, title: "Изменить") { [weak self] _, _, completion in
            self?.presentLogEditOptions(for: indexPath)
            completion(true)
        }
        editAction.backgroundColor = .systemGreen
        return UISwipeActionsConfiguration(actions: [editAction])
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { [weak self] _, _, completion in
            self?.deleteLog(for: indexPath)
            completion(true)
        }
        deleteAction.backgroundColor = .systemRed
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
