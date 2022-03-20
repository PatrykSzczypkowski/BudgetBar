//
//  TransactionsPerAccount.swift
//  Level
//
//  Created by Patryk Szczypkowski on 24/02/2022.
//

import SwiftUI

struct TransactionsPerAccountView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest<Transaction>(
        entity: Transaction.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Transaction.date, ascending: true)])
    private var transactions: FetchedResults<Transaction>
    
    @ObservedObject var account: Account
    
    @State private var searchString: String = ""
    
    var body: some View {
        List {
            ForEach(transactions) { transaction in
                NavigationLink(
                    destination: {
                        EditTransactionView(transaction: transaction)
                    },
                    label: {
                        TransactionLabelView(transaction: transaction)
                    }
                )
            }
            .onDelete(perform: deleteItems)
        }
        .searchable(text: $searchString, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search amount, payees or category")
        .onChange(of: searchString) { newString in
            transactions.nsPredicate = searchPredicate(query: newString)
        }
        .navigationTitle(account.name!)
        .onAppear(perform: setAccountForTransactions)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
            ToolbarItem {
                NavigationLink(
                    destination: {
                        EditAccountView(account: account)
                    },
                    label: {
                        Label("Edit account", systemImage: "square.and.pencil")
                    }
                )
            }
        }
    }

    struct TransactionLabelView: View {
        var transaction: Transaction
        
        var body: some View {
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
                Text(transaction.amount!.decimalValue, format: .currency(code: "EUR")).frame(minWidth: 0, maxWidth: .infinity, minHeight: 30, alignment: .trailing).foregroundColor(transaction.inflow ? Color.accentColor : Color.red)
            }
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        for index in offsets {
            transactions[index].account!.balance! = transactions[index].account!.balance!.adding( !transactions[index].inflow ? transactions[index].amount! : transactions[index].amount!.multiplying(by: -1))
            transactions[index].category!.balance! = transactions[index].category!.balance!.adding( !transactions[index].inflow ? transactions[index].amount! : transactions[index].amount!.multiplying(by: -1))
        }
        withAnimation {
            offsets.map { transactions[$0] }.forEach(viewContext.delete)

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
    
    private func searchPredicate(query: String) -> NSPredicate? {
        if query == "" { return NSPredicate(format: "account == %@", account) }
        return NSPredicate(format: "account == %@ AND (amount == %@ OR payee BEGINSWITH[cd] %@ OR category.name BEGINSWITH[cd] %@)", account, NSDecimalNumber(string: query), query, query)
    }
    
    private func setAccountForTransactions() {
        transactions.nsPredicate = NSPredicate(format: "account == %@", account)
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
