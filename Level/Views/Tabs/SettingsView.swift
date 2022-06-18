//
//  SettingsView.swift
//  Level
//
//  Created by Patryk Szczypkowski on 08/02/2022.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var manager: LevelManager
    
    @State var confirmationShown = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Stepper(value: $manager.monthsAhead, in: 0...12) {
                        HStack {
                            Text("Generate months ahead: ")
                            Spacer()
                            Text("\(manager.monthsAhead)")
                        }
                    }
                    HStack {
                        Text("Currency")
                        Spacer()
                        Picker(selection: $manager.currency, label: Text("Currency")) {
                            ForEach(Locale.isoCurrencyCodes, id: \.self) {
                                Text($0)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    Button("Start over", role: .destructive) {
                        confirmationShown = true
                    }
                    .confirmationDialog("Are you sure? All app data will be deleted and unrecoverable.", isPresented: $confirmationShown, titleVisibility: .visible) {
                        Button("Yes", role: .destructive) {
                            manager.wipeAllData()
                        }
                    }
                } footer: {
                    Text("Author: Patryk Szczypkowski - 18740211")
                }
            }
            .navigationTitle("Settings")
        }
        .tabItem {
            Label("Settings", systemImage: "gear")
        }
    }
}

//struct SettingsView_Previews: PreviewProvider {
//    static var previews: some View {
//        SettingsView()
//    }
//}
