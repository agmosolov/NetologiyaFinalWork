//
//  SettingsTableViewController.swift
//  NetologiyaFinalWork
//
//  Created by Александр Мосолов on 02.12.2025.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    // Пример простых полей: 5 пороговых значений
    private let activeTasksToWinField = UITextField()
    private let completedTasksToWinField = UITextField()
    private let collectedPointsToWinField = UITextField()
    private let regimeComplianceToWinField = UITextField()
    private let countOfAchievmentsToWinField = UITextField()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Настройки"
        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        setupUI()
        loadSettingsDefaults()
    }

    private func setupUI() {
        view.backgroundColor = .white
        // отключаем автоматическую раскладку текста в клетке
        // Размещаем поля в секциях
    }

    // MARK: - Data

    override func numberOfSections(in tableView: UITableView) -> Int { 1 }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 6 }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        // Конфигурация ячеек по порядку
        // 0: активных
        // 1: выполнено задач
        // 2: суммарные очки
        // 3: режим комплаенс
        // 4: count of achievements
        // 5: кнопка сохранения

        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Active tasks to win"
            configureTextField(activeTasksToWinField, inCell: cell, placeholder: "Введите число")
        case 1:
            cell.textLabel?.text = "Completed tasks to win"
            configureTextField(completedTasksToWinField, inCell: cell, placeholder: "Введите число")
        case 2:
            cell.textLabel?.text = "Collected points to win"
            configureTextField(collectedPointsToWinField, inCell: cell, placeholder: "Введите число")
        case 3:
            cell.textLabel?.text = "Regime compliance to win"
            configureTextField(regimeComplianceToWinField, inCell: cell, placeholder: "Введите число")
        case 4:
            cell.textLabel?.text = "Count of achievements to win"
            configureTextField(countOfAchievmentsToWinField, inCell: cell, placeholder: "Введите число")
        case 5:
            let btn = UIButton(type: .system)
            btn.setTitle("Сохранить", for: .normal)
            btn.addTarget(self, action: #selector(saveSettingsButtonTapped), for: .touchUpInside)
            btn.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.addSubview(btn)
            NSLayoutConstraint.activate([
                btn.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor),
                btn.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
            ])
            // очистим текстовую метку ячейки
            cell.textLabel?.text = ""
        default:
            break
        }

        return cell
    }

    private func configureTextField(_ textField: UITextField, inCell cell: UITableViewCell, placeholder: String) {
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = placeholder
        textField.keyboardType = .numberPad
        // вставим текстовое поле справа от текста ячейки
        cell.contentView.addSubview(textField)
        NSLayoutConstraint.activate([
            textField.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
            textField.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
            textField.widthAnchor.constraint(equalToConstant: 120)
        ])
    }

    @objc private func saveSettingsButtonTapped() {
        saveSettingsToDefaults()
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Helpers

    private func saveSettingsToDefaults() {
        let defaults = UserDefaults.standard
        defaults.set(Int(activeTasksToWinField.text ?? "") ?? 0, forKey: "activeTasksToWin")
        defaults.set(Int(completedTasksToWinField.text ?? "") ?? 0, forKey: "completedTasksToWin")
        defaults.set(Int(collectedPointsToWinField.text ?? "") ?? 0, forKey: "collectedPointsToWin")
        defaults.set(Int(regimeComplianceToWinField.text ?? "") ?? 0, forKey: "regimeComplianceToWin")
        defaults.set(Int(countOfAchievmentsToWinField.text ?? "") ?? 0, forKey: "countOfAchievmentsToWin")
        defaults.synchronize()
        // можно уведомить об изменении
        NotificationCenter.default.post(name: NSNotification.Name("SettingsDidChange"), object: nil)
    }

    private func loadSettingsDefaults() {
        let defaults = UserDefaults.standard
        activeTasksToWinField.text = defaults.string(forKey: "activeTasksToWin")
        completedTasksToWinField.text = defaults.string(forKey: "completedTasksToWin")
        collectedPointsToWinField.text = defaults.string(forKey: "collectedPointsToWin")
        regimeComplianceToWinField.text = defaults.string(forKey: "regimeComplianceToWin")
        countOfAchievmentsToWinField.text = defaults.string(forKey: "countOfAchievmentsToWin")
    }
}
