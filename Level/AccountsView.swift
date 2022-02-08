//
//  AccountsView.swift
//  Level
//
//  Created by Patryk Szczypkowski on 08/02/2022.
//

import SwiftUI

struct AccountsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Account.name, ascending: true)],
        animation: .default)
    private var accounts: FetchedResults<Account>
    
    private let numberFormatter: NumberFormatter
    init() {
        numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.currencyCode = "EUR"
        numberFormatter.maximumFractionDigits = 2
    }
    
    @State private var showAddAccountSheet = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(accounts) { account in
                    NavigationLink (
                        destination: {
                            EditAccountView(account: account)
                        },
                        label: {
                            HStack {
                                Text(account.name!).frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                Text("\(account.balance!, formatter: numberFormatter)").foregroundColor(Color.green).frame(minWidth: 0, maxWidth: .infinity, minHeight: 30, alignment: .trailing)
                            }
                        }
                    )
                }
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("Accounts")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button (
                        action: {
                            showAddAccountSheet.toggle()
                        },
                        label: {
                            Label("Add Item", systemImage: "plus")
                        }
                    )
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
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { accounts[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct AccountsView_Previews: PreviewProvider {
    static var previews: some View {
        AccountsView().preferredColorScheme(.dark).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
