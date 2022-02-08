//
//  EditAccountView.swift
//  Level
//
//  Created by Patryk Szczypkowski on 08/02/2022.
//

import SwiftUI

struct EditAccountView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject private var account: Account
    @State private var name: String
    @State private var balance: Decimal
    
    init(account: Account) {
        self.account = account
        _name = State(initialValue: account.name ?? "test")
        _balance = State(initialValue: account.balance?.decimalValue ?? 0)
    }
    
    var body: some View {
            List {
                HStack {
                    Text("Account name")
                    TextField("Required", text: $name)
                        .multilineTextAlignment(.trailing)
                }
                HStack {
                    Text("Current balance")
                    TextField("Required", value: $balance, format: .number)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.decimalPad)
                }
                Spacer()
                Button("Edit account") {
                    account.name = name
                    account.balance = NSDecimalNumber(decimal: balance)
                    
                    try? viewContext.save()
                    dismiss()
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .listStyle(PlainListStyle())
            .navigationBarTitle("Edit account")
    }
}

struct EditAccountView_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = PersistenceController.preview.container.viewContext
        let account = Account(context: viewContext)
        account.name = "Test"
        account.balance = 1000.00
        
        return EditAccountView(account: account)
    }
}
