//
//  SettingsTableViewController.swift
//  NetologiyaFinalWork
//
//  Created by Александр Мосолов on 02.12.2025.
//

import UIKit



class SettingsTableViewController: UITableViewController {
    
    private var backButton: UIBarButtonItem!
    
    
    
    // Поля ввода
    private let activeTasksToWinField = UITextField()
    private let completedTasksToWinField = UITextField()
    private let collectedPointsToWinField = UITextField()
    private let regimeComplianceToWinField = UITextField()
    
    // Оригинальные значения для сравнения
    private var originalActiveTasksToWin: String?
    private var originalCompletedTasksToWin: String?
    private var originalCollectedPointsToWin: String?
    private var originalRegimeComplianceToWin: String?
    
    private var saveButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        
        setupUI()
        loadSettingsDefaults()
        updateSaveButtonState()
        
       
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        title = "Настройки"
        navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        // кнопка сохранения в navigation bar
        saveButton = UIBarButtonItem(
            title: "Сохранить",
            style: .done,
            target: self,
            action: #selector(saveSettingsButtonTapped))
        saveButton.isEnabled = false
        
        navigationItem.rightBarButtonItem = saveButton
        
        // левая кнопка возврата
        backButton = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = backButton
        
        // скрыть клавиатуру по тапу на фон
        let tap = UITapGestureRecognizer(target: self, action: #selector(endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        // стиль полей ввода
        [activeTasksToWinField, completedTasksToWinField, collectedPointsToWinField, regimeComplianceToWinField].forEach { tf in
            tf.borderStyle = .roundedRect
            tf.keyboardType = .numberPad
            tf.textAlignment = .center
            let fontSize = tf.font?.pointSize ?? 10
            tf.font = .systemFont(ofSize: fontSize, weight: .bold)
            tf.textColor = .systemBlue
            tf.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
            tf.delegate = self
        }
        

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
        loadSettingsDefaults()
    }
    
    @objc private func textFieldDidBeginEditing( textField: UITextField) {
        textField.text = ""
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func backButtonTapped() {
        view.endEditing(true)
        loadSettingsDefaults()
        tabBarController?.selectedIndex = 0
    }
    
    @objc private func textFieldDidChange( textField: UITextField) {
        updateSaveButtonState()
    }
    
    
    
    // MARK: - Data
    
    override func numberOfSections(in tableView: UITableView) -> Int { 1 }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 4 }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Достижения"
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Активные задачи"
            addTextField(activeTasksToWinField, to: cell)
        case 1:
            cell.textLabel?.text = "Выполненные повторения"
            addTextField(completedTasksToWinField, to: cell)
        case 2:
            cell.textLabel?.text = "Набранные баллы"
            addTextField(collectedPointsToWinField, to: cell)
        case 3:
            cell.textLabel?.text = "% в режиме"
            addTextField(regimeComplianceToWinField, to: cell)
        default:
            break
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let footer = UIView()
        footer.backgroundColor = .clear
        
        let label = UILabel()
        label.text = "Достижения"
        label.font = UIFont.systemFont(ofSize: 25, weight: .bold)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false

        footer.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: footer.topAnchor, constant: 8),
            label.leadingAnchor.constraint(equalTo: footer.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: footer.trailingAnchor, constant: -16),
            label.bottomAnchor.constraint(equalTo: footer.bottomAnchor, constant: -8)
        ])

        return footer
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = UIView()
        footer.backgroundColor = .clear

        let label = UILabel()
        label.text = "Установите пороговые значения для достижений и сохраните изменения."
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false

        footer.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: footer.topAnchor, constant: 8),
            label.leadingAnchor.constraint(equalTo: footer.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: footer.trailingAnchor, constant: -16),
            label.bottomAnchor.constraint(equalTo: footer.bottomAnchor, constant: -8)
        ])

        return footer
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        switch indexPath.row {
        case 0:
            activeTasksToWinField.becomeFirstResponder()
        case 1:
            completedTasksToWinField.becomeFirstResponder()
        case 2:
            collectedPointsToWinField.becomeFirstResponder()
        case 3:
            regimeComplianceToWinField.becomeFirstResponder()
        default:
            break
        }
    }
    
    private func addTextField(_ textField: UITextField, to cell: UITableViewCell) {
        textField.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addSubview(textField)
        NSLayoutConstraint.activate([
            textField.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
            textField.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
            textField.widthAnchor.constraint(equalToConstant: 120)
        ])
    }
    
    // Сохранение
    @objc private func saveSettingsButtonTapped() {
        view.endEditing(true)
        saveSettingsToDefaults()
        loadSettingsDefaults()
        NotificationCenter.default.post(name: NSNotification.Name("SettingsDidChange"), object: nil)
        updateSaveButtonState()
        tabBarController?.selectedIndex = 0
    }
    
    
    
    // MARK: - Helpers
    
    private func saveSettingsToDefaults() {
        let defaults = UserDefaults.standard
        defaults.set(Int(activeTasksToWinField.text ?? "") ?? 0, forKey: "activeTasksToWin")
        defaults.set(Int(completedTasksToWinField.text ?? "") ?? 0, forKey: "completedTasksToWin")
        defaults.set(Int(collectedPointsToWinField.text ?? "") ?? 0, forKey: "collectedPointsToWin")
        defaults.set(Int(regimeComplianceToWinField.text ?? "") ?? 0, forKey: "regimeComplianceToWin")
        defaults.synchronize()
        NotificationCenter.default.post(name: NSNotification.Name("SettingsDidChange"), object: nil)
    }
    
    private func loadSettingsDefaults() {
        let defaults = UserDefaults.standard
        activeTasksToWinField.text = defaults.string(forKey: "activeTasksToWin")
        completedTasksToWinField.text = defaults.string(forKey: "completedTasksToWin")
        collectedPointsToWinField.text = defaults.string(forKey: "collectedPointsToWin")
        regimeComplianceToWinField.text = defaults.string(forKey: "regimeComplianceToWin")
        
        // сохранить оригинальные значения
        originalActiveTasksToWin = activeTasksToWinField.text
        originalCompletedTasksToWin = completedTasksToWinField.text
        originalCollectedPointsToWin = collectedPointsToWinField.text
        originalRegimeComplianceToWin = regimeComplianceToWinField.text
    }
    
    // ... доп коды (endEditing, textFieldDidChange, updateSaveButtonState) как ранее
    
    @objc private func endEditing() {
        view.endEditing(true)
    }
    
    private func updateSaveButtonState() {
        let identical =
        activeTasksToWinField.text == originalActiveTasksToWin &&
        completedTasksToWinField.text == originalCompletedTasksToWin &&
        collectedPointsToWinField.text == originalCollectedPointsToWin &&
        regimeComplianceToWinField.text == originalRegimeComplianceToWin
        
        saveButton.isEnabled = !identical
        saveButton.tintColor = saveButton.isEnabled ? UIColor.systemBlue : UIColor.systemGray
    }
}

extension SettingsTableViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // если текущее содержимое пустое и пользователь добавляет первый символ, ничего не удаляем
        // но нам нужно очистить до ввода, так что возвращаем true и предварительно очистим
        if textField.text?.isEmpty == true && string.count == 1 {
            textField.text = ""
        }
        return true
    }
}


