//
//  ContentView.swift
//  Stocks_finhub
//
//  Created by mahesh lad on 08/12/2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = StockViewModel()
    @State private var newSymbol: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                // Search bar for filtering
                SearchBar(text: $viewModel.searchText)
                
                // Add Symbol input field and button
                HStack {
                    TextField("Add Symbol (e.g., NFLX)", text: $newSymbol)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.allCharacters)
                    
                    Button("Add") {
                        Task {
                            await viewModel.addSymbol(newSymbol)
                            newSymbol = "" // Clear input after adding
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(newSymbol.isEmpty) // Disable button when input is empty
                }
                .padding()
                
                // List of filtered stocks
                List(viewModel.filteredStocks) { stock in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(stock.symbol)
                                .font(.headline)
                            Text("\(String(format: "%.2f", stock.percentageChange))%")
                                .foregroundColor(stock.percentageChange >= 0 ? .green : .red)
                        }
                        Spacer()
                        Text("$\(String(format: "%.2f", stock.currentPrice))")
                            .bold()
                    }
                }
                .onAppear {
                    Task {
                        await viewModel.fetchStockData() // Load default symbols on launch
                    }
                }
                .navigationTitle("Stocks")
            }
            .padding()
        }
    }
}


struct SearchBar: UIViewRepresentable {
    @Binding var text: String
    
    class Coordinator: NSObject, UISearchBarDelegate {
        @Binding var text: String
        
        init(text: Binding<String>) {
            _text = text
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }
    
    func makeUIView(context: Context) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        return searchBar
    }
    
    func updateUIView(_ uiView: UISearchBar, context: Context) {
        uiView.text = text
    }
}

#Preview {
    ContentView()
}
