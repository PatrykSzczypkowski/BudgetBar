//
//  SettingsView.swift
//  Level
//
//  Created by Patryk Szczypkowski on 08/02/2022.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var manager: LevelManager
    
    var body: some View {
        NavigationView {
            List {
                Stepper(value: $manager.monthsAhead) {
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
                Spacer()
                Text("Author: Patryk Szczypkowski - 18740211")
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
