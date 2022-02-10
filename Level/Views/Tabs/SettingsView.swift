//
//  SettingsView.swift
//  Level
//
//  Created by Patryk Szczypkowski on 08/02/2022.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationView {
            List {}
            .navigationTitle("Settings")
        }
        .tabItem {
            Label("Settings", systemImage: "gear")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
