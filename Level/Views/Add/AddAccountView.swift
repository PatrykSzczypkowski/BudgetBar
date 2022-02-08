//
//  AddAccountView.swift
//  Level
//
//  Created by Patryk Szczypkowski on 08/02/2022.
//

import SwiftUI

struct AddAccountView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var balance: Decimal = 0.00
    
    var body: some View {
        NavigationView {
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
                Button("Add account") {
                    let newAccount = Account(context: viewContext)
                    newAccount.name = name
                    newAccount.balance = NSDecimalNumber(decimal: balance)
                    
                    try? viewContext.save()
                    dismiss()
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .listStyle(PlainListStyle())
            .navigationBarTitle("Add account")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct AddAccountView_Previews: PreviewProvider {
    static var previews: some View {
        AddAccountView()
    }
}
