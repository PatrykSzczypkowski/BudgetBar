//
//  ContentView.swift
//  Level
//
//  Created by Patryk Szczypkowski on 28/01/2022.
//

import SwiftUI
import CoreData
import Foundation

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject var viewModel = LevelViewModel()
    
    @State private var selectedItem = 1
    @State private var shouldShowActionSheet = false
    @State private var oldSelectedItem = 1
    
    var body: some View {
        TabView(selection: $selectedItem) {
            CategoriesView().tag(1).onAppear { self.oldSelectedItem = self.selectedItem }
            AccountsView().tag(2).onAppear { self.oldSelectedItem = self.selectedItem }
            AddTransactionView(currentMonth: $viewModel.currentMonth).tag(3).onAppear {
                self.shouldShowActionSheet.toggle()
                self.selectedItem = self.oldSelectedItem
            }
            ReportsView().tag(4).onAppear { self.oldSelectedItem = self.selectedItem }
            SettingsView().tag(5).onAppear { self.oldSelectedItem = self.selectedItem }
        }
        .environmentObject(viewModel)
        .onAppear(perform: viewModel.setCurrentMonth)
        .onAppear(perform: createMonths)
        .sheet(isPresented: $shouldShowActionSheet) {
            AddTransactionView(currentMonth: $viewModel.currentMonth)
                .environmentObject(viewModel)
        }
    }
    
    private func createMonths() {
        let currentYear = Calendar.current.component(.year, from: Date())
        let currentMonth = Calendar.current.component(.month, from: Date()) - 1
        var yearIncrement = 0
        
        if(viewModel.months.count == 0) {
            for i in 0..<24 {
                let newMonth = Month(context: viewContext)
                if((currentMonth + i) % 12 == 0) {
                    yearIncrement += 1
                }
                newMonth.month = Int16(((currentMonth + i) % 12) + 1)
                newMonth.year = Int16(currentYear + yearIncrement)
            }
            try? viewContext.save()
        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView().preferredColorScheme(.dark).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//    }
//}
