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
    let earnedLabel = UILabel()
    let fromLabel = UILabel()
    let planValueLabel = UILabel()
    let factValueLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        [taskNameLabel, statusLabel, dateLabel, cyclicalityLabel, planValueLabel, factValueLabel, earnedLabel, fromLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        let padding: CGFloat = 12

        NSLayoutConstraint.activate([
    
            taskNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            taskNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            
            cyclicalityLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            cyclicalityLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            
            statusLabel.topAnchor.constraint(equalTo: taskNameLabel.bottomAnchor, constant: padding),
            statusLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            
            dateLabel.topAnchor.constraint(equalTo: taskNameLabel.bottomAnchor, constant: padding),
            dateLabel.leadingAnchor.constraint(equalTo: statusLabel.trailingAnchor, constant: padding),

            earnedLabel.topAnchor.constraint(equalTo: taskNameLabel.bottomAnchor, constant: padding),
            earnedLabel.leadingAnchor.constraint(equalTo: dateLabel.trailingAnchor, constant: padding),
            
            factValueLabel.topAnchor.constraint(equalTo: taskNameLabel.bottomAnchor, constant: padding),
            factValueLabel.leadingAnchor.constraint(equalTo: earnedLabel.trailingAnchor, constant: padding),
            
            
            fromLabel.topAnchor.constraint(equalTo: taskNameLabel.bottomAnchor, constant: padding),
            fromLabel.leadingAnchor.constraint(equalTo: factValueLabel.trailingAnchor, constant: padding),

            planValueLabel.topAnchor.constraint(equalTo: taskNameLabel.bottomAnchor, constant: padding),
            planValueLabel.leadingAnchor.constraint(equalTo: fromLabel.trailingAnchor, constant: padding),

            // и другие по дизайну
            contentView.bottomAnchor.constraint(greaterThanOrEqualTo: factValueLabel.bottomAnchor, constant: padding)
        ])

        // стиль
        taskNameLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        dateLabel.font = UIFont.systemFont(ofSize: 10)
        statusLabel.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        cyclicalityLabel.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        planValueLabel.font = UIFont.systemFont(ofSize: 10)
        factValueLabel.font = UIFont.systemFont(ofSize: 10)
        earnedLabel.font = UIFont.systemFont(ofSize: 10)
        fromLabel.font = UIFont.systemFont(ofSize: 10)
        
        earnedLabel.text = "Начислено:"
        fromLabel.text = "из:"
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
        
        switch log.status {
        case TaskStatus.created.rawValue:
            contentView.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        case TaskStatus.launched.rawValue:
            contentView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        case TaskStatus.run.rawValue:
            contentView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        case TaskStatus.stopped.rawValue:
            contentView.backgroundColor = UIColor.gray.withAlphaComponent(0.1)
        default:
            contentView.backgroundColor = .white
        }
    }
}

