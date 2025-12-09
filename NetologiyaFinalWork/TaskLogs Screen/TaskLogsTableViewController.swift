//
//  TaskLogsTableViewController.swift
//  NetologiyaFinalWork
//
//  Created by Александр Мосолов on 06.12.2025.
//

import Foundation
import UIKit


class TaskLogsTableViewController: UITableViewController {
    
    private var logs: [TaskLog] = []


    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        tableView.register(TaskLogTableViewCell.self, forCellReuseIdentifier: "TaskLogCell")
        fetchLogs()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        fetchLogs()
        tableView.reloadData()
    }
    
    private func setupUI() {
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always // или .automatic
        title = "Журнал"
        
        // Добавил кнопку удаления (корзины)
        let deleteTaskBarButton =
        UIBarButtonItem(barButtonSystemItem: .trash,
                        target: self,
                        action: #selector(didTapDeleteTasksBarButton))
        
        navigationItem.leftBarButtonItem = deleteTaskBarButton
    }
    
    @objc private func didTapDeleteTasksBarButton() {
        let alert = UIAlertController(title: "Удалить историю",
                                      message: "Вы уверены, что хотите удалить всю историю?",
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Удалить", style: .destructive, handler: { [weak self] _ in
            TaskLogsCoreDataManager.shared.deleteAllLogs()
            self?.fetchLogs()
            self?.tableView.reloadData()
        }))

        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))

        present(alert, animated: true, completion: nil)
    }
    

    private func fetchLogs() {
        let descriptor = NSSortDescriptor(key: "date", ascending: false)
        logs = TaskLogsCoreDataManager.shared.fetchLogs(predicate: nil, sortDescriptors: [descriptor])
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        logs.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TaskLogCell", for: indexPath) as? TaskLogTableViewCell else {
            return UITableViewCell(style: .default, reuseIdentifier: "TaskLogCell")
        }
        let log = logs[indexPath.row]
        cell.configure(with: log)
        return cell
    }
}

