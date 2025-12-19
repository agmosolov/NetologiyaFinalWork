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
    let resultTextLabel = UILabel()
    let fromTextLabel = UILabel()
    let progressLabel = UILabel()
    var progressPercentLabel = UILabel()
    
    let darkYellow = UIColor(red: 0.92, green: 0.74, blue: 0.15, alpha: 1.0)
    
    override init(style: UITableViewCell.CellStyle, 
                  reuseIdentifier: String?) {
        super.init(style: style, 
                   reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        
        let uiLabels = [taskNameLabel, cyclicalityLabel, statusLabel, dateLabel, planValueLabel, factValueLabel, resultTextLabel, fromTextLabel, progressLabel, progressPercentLabel]
        
        for l in uiLabels {
            l.translatesAutoresizingMaskIntoConstraints = false
            l.font = UIFont.systemFont(ofSize: 10)
            contentView.addSubview(l)
        }
        
        progressView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(progressView)
        
        taskNameLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        statusLabel.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        progressLabel.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        
        let padding: CGFloat = 12
        
        NSLayoutConstraint.activate([
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
            
            resultTextLabel.centerYAnchor.constraint(equalTo: planValueLabel.centerYAnchor),
            resultTextLabel.leadingAnchor.constraint(equalTo: dateLabel.trailingAnchor, constant: padding),
            
            factValueLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: padding),
            factValueLabel.leadingAnchor.constraint(equalTo: resultTextLabel.trailingAnchor, constant: padding / 3),
            
            fromTextLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: padding),
            fromTextLabel.leadingAnchor.constraint(equalTo: factValueLabel.trailingAnchor, constant: padding / 3),
            
            planValueLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: padding),
            planValueLabel.leadingAnchor.constraint(equalTo: fromTextLabel.trailingAnchor, constant: padding / 3),
            
            progressPercentLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: padding),
            progressPercentLabel.leadingAnchor.constraint(equalTo: planValueLabel.trailingAnchor, constant: padding / 3),
            
            contentView.bottomAnchor.constraint(greaterThanOrEqualTo: factValueLabel.bottomAnchor, constant: padding)
        ])
    }
    
    
    func configure(with task: Task, hideLabels: Bool) {
        resultTextLabel.isHidden = hideLabels
        factValueLabel.isHidden = hideLabels
        fromTextLabel.isHidden = hideLabels
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
        
        resultTextLabel.text = "Результат:"
        fromTextLabel.text = "из:"
        
        let plan = max(task.planValue, 1)
        let progressPercentDouble = Double(task.factValue) / Double(plan)
        let progressPercentInt = Int(round(progressPercentDouble * 100))
        factValueLabel.text = "\(task.factValue)"
        planValueLabel.text = "\(task.planValue)"
        progressLabel.text = Arrow.neutral.rawValue
        progressPercentLabel.text = "(\(progressPercentInt)%)"
        
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
    
    
    private func configureDateLabel(for date: Date) {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        dateLabel.text = formatter.string(from: date)
    }
    
    // Функция которая обновляет цветовое выделение progressBar в зависимости от текущего результата и направления движения progressBar'а
    private func updateProgressAppearance(for task: Task) {

        let plan = max(task.planValue, 1)

        let now = Date()
        let deltaSec = now.timeIntervalSince(task.date ?? now)
      
        // УСКОРЕНИЕ: 5...60, НОРМА: 3600
        let deltaInHours = deltaSec / 3600
        // УСКОРЕНИЕ: -23.5, НОРМА: БЕЗ ДОПОЛНЕНИЯ
        let planHours = Double(plan)

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
