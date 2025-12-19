//
//  TaskTableViewCell.swift
//  NetologiyaFinalWork
//
//  Created by Александр Мосолов on 02.12.2025.
//

import UIKit



class TasksTableViewCell: UITableViewCell {
    
    let taskNameLabel = UILabel()
    let cyclicalityLabel = UILabel()
    let progressView = UIProgressView(progressViewStyle: .default)
    let statusLabel = UILabel()
    let dateLabel = UILabel()
    let factValueLabel = UILabel()
    let planValueLabel = UILabel()
    let earnedLabel = UILabel()
    let fromLabel = UILabel()
    let progressLabel = UILabel()
    
    // Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        
        // Добавление subviews
        taskNameLabel.translatesAutoresizingMaskIntoConstraints = false
        cyclicalityLabel.translatesAutoresizingMaskIntoConstraints = false
        progressView.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        planValueLabel.translatesAutoresizingMaskIntoConstraints = false
        factValueLabel.translatesAutoresizingMaskIntoConstraints = false
        earnedLabel.translatesAutoresizingMaskIntoConstraints = false
        fromLabel.translatesAutoresizingMaskIntoConstraints = false
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(taskNameLabel)
        contentView.addSubview(progressLabel)
        contentView.addSubview(cyclicalityLabel)
        contentView.addSubview(progressView)
        contentView.addSubview(statusLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(earnedLabel)
        contentView.addSubview(factValueLabel)
        contentView.addSubview(fromLabel)
        contentView.addSubview(planValueLabel)
        
        // Пример ограничений (адаптируйте под дизайн)
        let padding: CGFloat = 12
        
        NSLayoutConstraint.activate([
            // верхний ряд
            taskNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            taskNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            
            cyclicalityLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            cyclicalityLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            taskNameLabel.centerYAnchor.constraint(equalTo: cyclicalityLabel.centerYAnchor),
            
            progressView.topAnchor.constraint(equalTo: taskNameLabel.bottomAnchor, constant: padding),
            progressView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            progressView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            
            statusLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: padding),
            statusLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            
            dateLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: padding),
            dateLabel.leadingAnchor.constraint(equalTo: statusLabel.trailingAnchor, constant: padding),
            
            earnedLabel.centerYAnchor.constraint(equalTo: planValueLabel.centerYAnchor),
            earnedLabel.leadingAnchor.constraint(equalTo: dateLabel.trailingAnchor, constant: padding),
            
            factValueLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: padding),
            factValueLabel.leadingAnchor.constraint(equalTo: earnedLabel.trailingAnchor, constant: padding),
            
            fromLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: padding),
            fromLabel.leadingAnchor.constraint(equalTo: factValueLabel.trailingAnchor, constant: padding),
            
            planValueLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: padding),
            planValueLabel.leadingAnchor.constraint(equalTo: fromLabel.trailingAnchor, constant: padding),
            
            progressLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: padding),
            progressLabel.leadingAnchor.constraint(equalTo: planValueLabel.trailingAnchor, constant: padding),
            progressLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            
            // Нижний правый
            contentView.bottomAnchor.constraint(greaterThanOrEqualTo: factValueLabel.bottomAnchor, constant: padding)
        ])
        
        // Настройки стилевых свойств (при желании)
        taskNameLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        dateLabel.font = UIFont.systemFont(ofSize: 10)
        statusLabel.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        cyclicalityLabel.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        planValueLabel.font = UIFont.systemFont(ofSize: 10)
        factValueLabel.font = UIFont.systemFont(ofSize: 10)
        earnedLabel.font = UIFont.systemFont(ofSize: 10)
        fromLabel.font = UIFont.systemFont(ofSize: 10)
        progressLabel.font = UIFont.systemFont(ofSize: 10, weight: .bold)
    }
    
    private func configureDateLabel(for date: Date) {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU") // или Locale.current
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        dateLabel.text = formatter.string(from: date)
    }
    
    func configure(with task: Task) {
        taskNameLabel.text = task.taskName
        statusLabel.text = task.status
        if let date = task.date {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ru_RU")
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            dateLabel.text = formatter.string(from: date)
        } else {
            dateLabel.text = "-"
        }
        
        cyclicalityLabel.text = task.cyclicality
        
        // Новые подписи
        earnedLabel.text = "Начислено:"
        fromLabel.text = "из:"
        
        // Значения
        factValueLabel.text = "\(task.factValue)"
        planValueLabel.text = "\(task.planValue)"
        
        progressLabel.text = "XXX %"
        
        // Прогресс
        let progress = Double(task.planValue > 0 ? task.factValue : 0) / Double(task.planValue)
        progressView.progress = Float(min(max(progress, 0.0), 1.0))
        updateProgressAppearance(for: task)
        
    }
    
    private func updateProgressAppearance(for task: Task) {
        let plan = max(task.planValue, 1) // чтобы избежать деления на ноль
        let progressValue = max(0.0, min(1.0, Double(task.factValue) / Double(plan)))
        progressView.progress = Float(progressValue)

        // цвет в зависимости от условий
        if task.factValue < 0 {
            progressView.progressTintColor = .red
            progressView.trackTintColor = .red.withAlphaComponent(0.3)
        } else if progressValue < 0.25 {
            progressView.progressTintColor = .gray
            progressView.trackTintColor = UIColor.gray.withAlphaComponent(0.2)
        } else if progressValue < 0.75 {
            progressView.progressTintColor = .yellow
            progressView.trackTintColor = UIColor.yellow.withAlphaComponent(0.2)
        } else {
            progressView.progressTintColor = .green
            progressView.trackTintColor = UIColor.green.withAlphaComponent(0.2)
        }
    }
}
