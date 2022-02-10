//
//  ReportsView.swift
//  Level
//
//  Created by Patryk Szczypkowski on 08/02/2022.
//

import SwiftUI

struct ReportsView: View {
    var body: some View {
        NavigationView {
            List {}
            .navigationTitle("Reports")
        }
        .tabItem {
            Label("Reports", systemImage: "chart.line.uptrend.xyaxis")
        }
    }
}

struct ReportsView_Previews: PreviewProvider {
    static var previews: some View {
        ReportsView()
    }
}
