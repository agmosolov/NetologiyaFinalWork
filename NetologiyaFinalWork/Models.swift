//
//  Models.swift
//  NetologiyaFinalWork
//
//  Created by Александр Мосолов on 03.12.2025.
//

import Foundation

enum Cyclicality: String, CaseIterable {
    case daily = "Ежедневно"
    case weekly = "Еженедельно"
    case monthly = "Ежемесячно"
    case biMonthly = "Раз в два месяца"
    case quarterly = "Ежеквартально"
    case biQuarterly = "Раз в полгода"
    case yearly = "Ежегодно"
    case biYearly = "Раз в два года"
    case error = "Неопределено"
}

enum TaskStatus: String {
    case created = "Созданный"
    case active = "Активный"
    case passive = "Пассивный"
}

let planValueForCyclecycle: [Cyclicality: Int] = [
    .daily: 24,
    .weekly: 168,
    .monthly: 731,
    .biMonthly: 1462,
    .quarterly: 2193,
    .biQuarterly: 4386,
    .yearly: 8766,
    .biYearly: 17532,
    .error: 0
]
