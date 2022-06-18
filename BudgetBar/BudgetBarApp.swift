//
//  BudgetBarApp.swift
//  BudgetBar
//
//  Created by Patryk Szczypkowski on 28/01/2022.
//

import SwiftUI

@main
struct BudgetBarApp: App {
    let persistenceController = PersistenceController.shared
    let manager = BudgetBarManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(manager)
        }
    }
}
