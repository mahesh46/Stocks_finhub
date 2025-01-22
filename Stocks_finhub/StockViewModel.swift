//
//  StockViewModel.swift
//  Stocks_finhub
//
//  Created by mahesh lad on 08/12/2024.
//

import Combine
import SwiftUI

@MainActor
class StockViewModel: ObservableObject {
    @Published var stocks: [Stock] = []
    @Published var searchText: String = ""
    @Published var symbols: [String] = ["AAPL", "GOOGL", "AMZN", "TSLA", "MSFT", "GOOG", "META", "ASML", "IBM"] // Default symbols
  
    static let host = "finnhub.io"
    nonisolated  static let baseUrl = "/api/v1"
    
    enum Endpoint: String {
        case quote
        
        var path: String {
            switch self {
            case .quote:
                return "\(StockViewModel.baseUrl)/\(self.rawValue)"
            }
        }
    }
    
    /// Fetch stock data for all symbols
    func fetchStockData() async {
        stocks = []
        
        for symbol in symbols {
            if let stock = await fetchStock(for: symbol) {
                stocks.append(stock)
            }
        }
    }
    
    /// Fetch stock data for a single symbol
    private func fetchStock(for symbol: String) async -> Stock? {
          guard let apiKey = ProcessInfo.processInfo.environment["api_key"] else { fatalError("Add API_KEY as an Environment Variable in your app's scheme.")}
        let url = "https://\(StockViewModel.host)\(Endpoint.quote.path)?symbol=\(symbol)&token=\(apiKey)"
        
        guard let requestURL = URL(string: url) else {
            print("Invalid URL for symbol: \(symbol)")
            return nil
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: requestURL)
            if let quoteData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let price = quoteData["c"] as? Double,
               let change = quoteData["dp"] as? Double {
                return Stock(symbol: symbol, currentPrice: price, percentageChange: change)
            }
        } catch {
            print("Error fetching stock data for \(symbol): \(error.localizedDescription)")
        }
        
        return nil
    }
    
    /// Add a new symbol and fetch its stock data
    func addSymbol(_ symbol: String) async {
        let uppercasedSymbol = symbol.uppercased()
        guard !symbols.contains(uppercasedSymbol) else { return }
        
        if let newStock = await fetchStock(for: uppercasedSymbol) {
            symbols.append(uppercasedSymbol)
            stocks.append(newStock)
        } else {
            print("Failed to fetch data for symbol: \(uppercasedSymbol)")
        }
    }
    
    /// Filtered stocks based on the search text
    var filteredStocks: [Stock] {
        if searchText.isEmpty {
            return stocks
        } else {
            return stocks.filter { $0.symbol.lowercased().contains(searchText.lowercased()) }
        }
    }
}
