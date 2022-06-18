//
//  AddAccountView.swift
//  BudgetBar
//
//  Created by Patryk Szczypkowski on 08/02/2022.
//

import SwiftUI

struct AddAccountView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var manager: BudgetBarManager
    
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
                    TextField("Required", value: $balance, format: .currency(code: manager.currency))
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.decimalPad)
                        .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)) { obj in
                            if let textField = obj.object as? UITextField {
                                textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
                            }
                        }
                }
            }
            .listStyle(PlainListStyle())
            .navigationBarTitle("Add account")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        manager.addAccount(name: name, balance: balance)
                        dismiss()
                    }
                }
            }
        }
    }
}

//struct AddAccountView_Previews: PreviewProvider {
//    static var previews: some View {
//        AddAccountView()
//    }
//}
