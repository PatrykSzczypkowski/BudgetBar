//
//  TransactionsPerAccount.swift
//  Level
//
//  Created by Patryk Szczypkowski on 24/02/2022.
//

import SwiftUI

struct TransactionsPerAccountView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var viewModel: LevelViewModel
    
    @ObservedObject var account: Account

    @State private var searchString: String = ""
    
    var body: some View {
        List {
            ForEach(viewModel.transactionsPerAccount) { transaction in
                NavigationLink(destination: EditTransactionView(transaction: transaction)) {
                    HStack {
                        VStack(spacing: 0) {
                            Text(transaction.payee!)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text(DateFormatter.localizedString(from: transaction.date!, dateStyle: .short, timeStyle: .none))
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                .foregroundColor(.gray)
                                .font(.system(size: 12))
                        }
                        Spacer()
                        Text(transaction.amount!.decimalValue, format: .currency(code: "EUR"))
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 30, alignment: .trailing)
                            .foregroundColor(transaction.inflow ? Color.accentColor : Color.red)
                    }
                }
            }
            .onDelete(perform: { index in
                viewModel.deleteTransaction(offsets: index)
                viewModel.setTransactionsPerAccount(account: account)
            })
        }
        .onAppear(perform: { viewModel.setTransactionsPerAccount(account: account) })
        .searchable(text: $searchString, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search amount, payees or category")
        .onChange(of: searchString) { newString in
            viewModel.setTransactionsPerAccount(account: account, predicate: newString)
        }
        .navigationTitle(account.name!)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
            ToolbarItem {
                NavigationLink(destination: EditAccountView(account: account)) {
                    Label("Edit account", systemImage: "square.and.pencil")
                }
            }
        }
    }
}


//struct TransactionsPerAccountView_Previews: PreviewProvider {
//    static var previews: some View {
//        let viewContext = PersistenceController.preview.container.viewContext
//        let transaction = Transaction(context: viewContext)
//        transaction.amount = 400
//        transaction.inflow = false
//        transaction.payee = "Aldi"
//        transaction.date = Date()
//
//        return TransactionLabelView(transaction: transaction)
//    }
//}
