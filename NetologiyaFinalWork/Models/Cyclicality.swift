//
//  Models.swift
//  NetologiyaFinalWork
//
//  Created by Александр Мосолов on 03.12.2025.
//

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
