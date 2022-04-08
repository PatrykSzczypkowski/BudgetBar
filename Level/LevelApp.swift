//
//  LevelApp.swift
//  Level
//
//  Created by Patryk Szczypkowski on 28/01/2022.
//

import SwiftUI

@main
struct LevelApp: App {
    let persistenceController = PersistenceController.shared
    let manager = LevelManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(manager)
        }
    }
}
