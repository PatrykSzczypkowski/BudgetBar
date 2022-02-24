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
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Month.year, ascending: true),
                          NSSortDescriptor(keyPath: \Month.month, ascending: true)])
    private var months: FetchedResults<Month>
    
    @State private var selectedItem = 1
    @State private var shouldShowActionSheet = false
    @State private var oldSelectedItem = 1
    @State private var currentMonth = Month()
    
    var body: some View {
        TabView(selection: $selectedItem) {
            CategoriesView(currentMonth: $currentMonth).tag(1).onAppear { self.oldSelectedItem = self.selectedItem }
            AccountsView().tag(2).onAppear { self.oldSelectedItem = self.selectedItem }
            AddTransactionView(currentMonth: $currentMonth).tag(3).onAppear {
                self.shouldShowActionSheet.toggle()
                self.selectedItem = self.oldSelectedItem
            }
            ReportsView().tag(4).onAppear { self.oldSelectedItem = self.selectedItem }
            SettingsView().tag(5).onAppear { self.oldSelectedItem = self.selectedItem }
        }
        .onAppear(perform: setCurrentMonth)
        .onAppear(perform: createMonths)
        .sheet(isPresented: $shouldShowActionSheet) {
            AddTransactionView(currentMonth: $currentMonth)
        }
    }
    
    private func setCurrentMonth() {
        let year = Calendar.current.component(.year, from: Date())
        let month = Calendar.current.component(.month, from: Date())
        
        for m in months {
            if(m.month == month && m.year == year) {
                currentMonth = m
                print("\(currentMonth.month) \(currentMonth.year)")
                break
            }
        }
    }
    
    private func createMonths() {
        let currentYear = Calendar.current.component(.year, from: Date())
        let currentMonth = Calendar.current.component(.month, from: Date()) - 1
        var yearIncrement = 0
        
        if(months.count == 0) {
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().preferredColorScheme(.dark).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
