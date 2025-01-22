//
//  Stocks.swift
//  Stocks_finhub
//
//  Created by mahesh lad on 08/12/2024.
//

import Foundation

struct Stock: Identifiable, Codable {
    let id = UUID()
    let symbol: String
    let currentPrice: Double
    let percentageChange: Double
}
