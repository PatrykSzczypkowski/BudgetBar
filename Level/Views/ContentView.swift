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
    var body: some View {
        TabView {
            CategoriesView()
            AccountsView()
            AddTransactionView()
            ReportsView()
            SettingsView()
        }
    }
}

//private let itemFormatter: DateFormatter = {
//    let formatter = DateFormatter()
//    formatter.dateStyle = .short
//    formatter.timeStyle = .medium
//    return formatter
//}()

//private let currencyFormatter: NumberFormatter = {
//    let formatter = NumberFormatter()
//    formatter.numberStyle = .currency
//    return formatter
//}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().preferredColorScheme(.dark).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}


struct AddTransactionView: View {
    var body: some View {
        NavigationView {
            List {
                
            }
        }
        .tabItem {
            Label("Add transaction", systemImage: "plus")
        }
    }
}
