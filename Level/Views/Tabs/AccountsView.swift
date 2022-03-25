//
//  AccountsView.swift
//  Level
//
//  Created by Patryk Szczypkowski on 08/02/2022.
//

import SwiftUI

struct AccountsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var viewModel: LevelViewModel
    
    @State private var showAddAccountSheet = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.accounts) { account in
                    NavigationLink (destination: TransactionsPerAccountView(account: account))
                    {
                        HStack {
                            Text(account.name!)
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            Text(account.balance!.decimalValue, format: .currency(code: "EUR"))
                                .foregroundColor(account.balance!.decimalValue >= 0.0 ? Color.green : Color.red)
                                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 30, alignment: .trailing)
                        }
                    }
                }
                .onDelete(perform: viewModel.deleteAccount)
            }
            .navigationTitle("Accounts")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button (action: { showAddAccountSheet.toggle() }) {
                        Label("Add Item", systemImage: "plus")
                    }
                    .sheet(isPresented: $showAddAccountSheet) {
                        AddAccountView()
                    }
                }
            }
        }
        .tabItem {
            Label("Accounts", systemImage: "list.bullet")
        }
    }
}

//struct AccountsView_Previews: PreviewProvider {
//    static var previews: some View {
//        AccountsView().preferredColorScheme(.dark).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//    }
//}
