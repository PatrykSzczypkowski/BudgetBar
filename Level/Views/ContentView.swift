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
    
    @State private var selectedItem = 1
    @State private var shouldShowActionSheet = false
    @State private var oldSelectedItem = 1
    
    var body: some View {
        TabView(selection: $selectedItem) {
            CategoriesView().tag(1).onAppear { self.oldSelectedItem = self.selectedItem }
            AccountsView().tag(2).onAppear { self.oldSelectedItem = self.selectedItem }
            AddTransactionView().tag(3).onAppear {
                self.shouldShowActionSheet.toggle()
                self.selectedItem = self.oldSelectedItem
            }
            ReportsView().tag(4).onAppear { self.oldSelectedItem = self.selectedItem }
            SettingsView().tag(5).onAppear { self.oldSelectedItem = self.selectedItem }
        }
        .sheet(isPresented: $shouldShowActionSheet) {
            AddTransactionView()
        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView().preferredColorScheme(.dark).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//    }
//}
