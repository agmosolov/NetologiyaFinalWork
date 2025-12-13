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
    var progressPercentLabel = UILabel()
    
    let darkGreen = UIColor(red: 0.0, green: 0.39, blue: 0.0, alpha: 1.0)
    let darkYellow = UIColor(red: 0.92, green: 0.74, blue: 0.15, alpha: 1.0)
    
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
        progressPercentLabel.translatesAutoresizingMaskIntoConstraints = false
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
        contentView.addSubview(progressPercentLabel)
        
        // Пример ограничений (адаптируйте под дизайн)
        let padding: CGFloat = 12
        
        NSLayoutConstraint.activate([
            // верхний ряд
            taskNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            taskNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            
            statusLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            statusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            
            progressLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            
            progressView.topAnchor.constraint(equalTo: taskNameLabel.bottomAnchor, constant: padding),
            progressView.leadingAnchor.constraint(equalTo: progressLabel.leadingAnchor, constant: padding * 2),
            progressView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            
            progressLabel.centerYAnchor.constraint(equalTo: progressView.centerYAnchor),
            
            cyclicalityLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: padding),
            cyclicalityLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            
            dateLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: padding),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            
            earnedLabel.centerYAnchor.constraint(equalTo: planValueLabel.centerYAnchor),
            earnedLabel.leadingAnchor.constraint(equalTo: dateLabel.trailingAnchor, constant: padding),
            
            factValueLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: padding),
            factValueLabel.leadingAnchor.constraint(equalTo: earnedLabel.trailingAnchor, constant: padding / 3),
            
            fromLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: padding),
            fromLabel.leadingAnchor.constraint(equalTo: factValueLabel.trailingAnchor, constant: padding / 3),
            
            planValueLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: padding),
            planValueLabel.leadingAnchor.constraint(equalTo: fromLabel.trailingAnchor, constant: padding / 3),
            
            progressPercentLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: padding),
            progressPercentLabel.leadingAnchor.constraint(equalTo: planValueLabel.trailingAnchor, constant: padding / 3),
            
       
            
            // Нижний правый
            contentView.bottomAnchor.constraint(greaterThanOrEqualTo: factValueLabel.bottomAnchor, constant: padding)
        ])
        
        // Настройки стилевых свойств (при желании)
        taskNameLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        dateLabel.font = UIFont.systemFont(ofSize: 10)
        statusLabel.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        cyclicalityLabel.font = UIFont.systemFont(ofSize: 10)
        planValueLabel.font = UIFont.systemFont(ofSize: 10)
        factValueLabel.font = UIFont.systemFont(ofSize: 10)
        earnedLabel.font = UIFont.systemFont(ofSize: 10)
        fromLabel.font = UIFont.systemFont(ofSize: 10)
        progressLabel.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        progressPercentLabel.font = UIFont.systemFont(ofSize: 10)
    }
    
    private func configureDateLabel(for date: Date) {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU") // или Locale.current
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        dateLabel.text = formatter.string(from: date)
    }
    
    func configure(with task: Task, hideLabels: Bool) {
        earnedLabel.isHidden = hideLabels
        factValueLabel.isHidden = hideLabels
        fromLabel.isHidden = hideLabels
        planValueLabel.isHidden = hideLabels
        progressPercentLabel.isHidden = hideLabels
        cyclicalityLabel.isHidden = hideLabels
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
        earnedLabel.text = "Результат:"
        fromLabel.text = "из:"
        
        // Значения
        let plan = max(task.planValue, 1)
        let progressPercentDouble = Double(task.factValue) / Double(plan)
        let progressPercentInt = Int(round(progressPercentDouble * 100))
        factValueLabel.text = "\(task.factValue)"
        planValueLabel.text = "\(task.planValue)"
        progressLabel.text = Arrow.neutral.rawValue
        progressPercentLabel.text = "(\(progressPercentInt)%)"
        
        // Прогресс
        let progress = Double(task.planValue > 0 ? task.factValue : 0) / Double(task.planValue)
        progressView.progress = Float(min(max(progress, 0.0), 1.0))
        updateProgressAppearance(for: task)
        
        switch task.status {
        case TaskStatus.created.rawValue:
            contentView.backgroundColor = UIColor.white.withAlphaComponent(0.10)
        case TaskStatus.launched.rawValue:
            contentView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.10)
        case TaskStatus.run.rawValue:
            contentView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.10)
        case TaskStatus.stopped.rawValue:
            contentView.backgroundColor = UIColor.gray.withAlphaComponent(0.10)
        default:
            contentView.backgroundColor = .white
        }
        
        switch statusLabel.text {
        case TaskStatus.created.rawValue:
            statusLabel.textColor = .black
            taskNameLabel.textColor = .black
        case TaskStatus.run.rawValue, TaskStatus.launched.rawValue:
            statusLabel.textColor = .systemBlue
            taskNameLabel.textColor = .systemBlue
        case TaskStatus.stopped.rawValue:
            statusLabel.textColor = .brown
            taskNameLabel.textColor = .brown
        case TaskStatus.completed.rawValue:
            statusLabel.textColor = .systemBlue
            taskNameLabel.textColor = .systemBlue
        default:
            statusLabel.textColor = .red
        }
    }
    
    
    
    // Функция обновляет цвет progressBar в зависимости от движения баллов, зеленый - баллы нарастают, желтый - баллы убывают, красный - баллы меньше нуля.
    private func updateProgressAppearance(for task: Task) {

        let plan = max(task.planValue, 1)

        let now = Date()
        let deltaSec = now.timeIntervalSince(task.date ?? now)
      
        let deltaInHours = deltaSec / 5    // УСКОРЕНИЕ 60 /3600 - нормальное значение
        let planHours = Double(plan) // УСКОРЕНИЕ: -23.5, НОРМА: БЕЗ ДОПОЛНЕНИЯ
      

        var color: UIColor = .lightGray
        var trackColor: UIColor = UIColor.lightGray.withAlphaComponent(0.2)

        if task.status == TaskStatus.created.rawValue || task.status == TaskStatus.stopped.rawValue || task.status == TaskStatus.completed.rawValue {
            color = .lightGray
            trackColor = UIColor.lightGray.withAlphaComponent(0.2)
            progressLabel.text = Arrow.neutral.rawValue
        } else {
            if deltaInHours <= planHours {
                color = UIColor.systemBlue
                trackColor = UIColor.systemBlue.withAlphaComponent(0.2)
                progressLabel.text = Arrow.forward.rawValue
            } else {
                if deltaInHours >= planHours * 2 {
                    color = .red
                    trackColor = UIColor.red.withAlphaComponent(0.2)
                    progressLabel.text = Arrow.backward.rawValue
                } else {
                    color = darkYellow
                    trackColor = darkYellow.withAlphaComponent(0.2)
                    progressLabel.text = Arrow.backward.rawValue
                }
            }
        }

        progressView.progressTintColor = color
        progressView.trackTintColor = trackColor
    }
}
