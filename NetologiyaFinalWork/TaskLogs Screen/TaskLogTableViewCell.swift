//
//  TaskLogTableViewCell.swift
//  NetologiyaFinalWork
//
//  Created by Александр Мосолов on 06.12.2025.
//

import UIKit



class TaskLogTableViewCell: UITableViewCell {
    let taskNameLabel = UILabel()
    let statusLabel = UILabel()
    let dateLabel = UILabel()
    let cyclicalityLabel = UILabel()
    let resultTextLabel = UILabel()
    let fromTextLabel = UILabel()
    let planValueLabel = UILabel()
    let factValueLabel = UILabel()
    var progressPercentLabel = UILabel()

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
        
        [taskNameLabel, statusLabel, dateLabel, cyclicalityLabel, planValueLabel, factValueLabel, resultTextLabel, fromTextLabel, progressPercentLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.font = UIFont.systemFont(ofSize: 10)
            contentView.addSubview($0)
        }
        
        taskNameLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        statusLabel.font = UIFont.systemFont(ofSize: 10, weight: .bold)

        let padding: CGFloat = 12

        NSLayoutConstraint.activate([
    
            taskNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            taskNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            
            statusLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            statusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            
            dateLabel.topAnchor.constraint(equalTo: taskNameLabel.bottomAnchor, constant: padding),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),

            resultTextLabel.topAnchor.constraint(equalTo: taskNameLabel.bottomAnchor, constant: padding),
            resultTextLabel.leadingAnchor.constraint(equalTo: dateLabel.trailingAnchor, constant: padding),
            
            factValueLabel.topAnchor.constraint(equalTo: taskNameLabel.bottomAnchor, constant: padding),
            factValueLabel.leadingAnchor.constraint(equalTo: resultTextLabel.trailingAnchor, constant: padding),
            
            fromTextLabel.topAnchor.constraint(equalTo: taskNameLabel.bottomAnchor, constant: padding),
            fromTextLabel.leadingAnchor.constraint(equalTo: factValueLabel.trailingAnchor, constant: padding / 3),

            planValueLabel.topAnchor.constraint(equalTo: taskNameLabel.bottomAnchor, constant: padding),
            planValueLabel.leadingAnchor.constraint(equalTo: fromTextLabel.trailingAnchor, constant: padding / 3),

            progressPercentLabel.topAnchor.constraint(equalTo: taskNameLabel.bottomAnchor, constant: padding),
            progressPercentLabel.leadingAnchor.constraint(equalTo: planValueLabel.trailingAnchor, constant: padding / 3),
            
            cyclicalityLabel.topAnchor.constraint(equalTo: taskNameLabel.bottomAnchor, constant: padding),
            cyclicalityLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            
            contentView.bottomAnchor.constraint(greaterThanOrEqualTo: factValueLabel.bottomAnchor, constant: padding)
        ])

        resultTextLabel.text = "Результат:"
        fromTextLabel.text = "из:"
    }

    
    func configure(with log: TaskLog) {
        
        taskNameLabel.text = log.taskName
        statusLabel.text = log.status
        
        if let date = log.date {
            let df = DateFormatter()
            df.locale = Locale(identifier: "ru_RU")
            df.dateStyle = .short
            df.timeStyle = .short
            dateLabel.text = df.string(from: date)
        } else {
            dateLabel.text = "-"
        }
        
        cyclicalityLabel.text = log.cyclicality
        planValueLabel.text = "\(log.planValue)"
        factValueLabel.text = "\(log.factValue)"
        
        let plan = max(log.planValue, 1)
        let progressPercentDouble = Double(log.factValue) / Double(plan)
        let progressPercentInt = Int(round(progressPercentDouble * 100))
        
        progressPercentLabel.text = "(\(progressPercentInt)%)"
        
        switch log.status {
        
        case TaskStatus.created.rawValue:
            contentView.backgroundColor = UIColor.white.withAlphaComponent(0.1)
            statusLabel.textColor = .darkGray
        
        case TaskStatus.launched.rawValue:
            contentView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
            taskNameLabel.textColor = .systemBlue
            statusLabel.textColor = .systemBlue
        
        case TaskStatus.run.rawValue:
            contentView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
            taskNameLabel.textColor = .systemBlue
            statusLabel.textColor = .systemBlue
        
        case TaskStatus.stopped.rawValue:
            contentView.backgroundColor = UIColor.gray.withAlphaComponent(0.1)
            taskNameLabel.textColor = .brown
            statusLabel.textColor = .brown
            progressPercentLabel.text = "(-)"
        
        default:
            contentView.backgroundColor = .white
        }
    }
    
}

