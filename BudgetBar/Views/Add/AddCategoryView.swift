//
//  AddCategoryView.swift
//  BudgetBar
//
//  Created by Patryk Szczypkowski on 08/02/2022.
//

import SwiftUI

struct AddCategoryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var manager: BudgetBarManager
    
    @State private var name = ""
    @State private var budget: Decimal = 0.00
    
    var body: some View {
        NavigationView {
            List {
                HStack {
                    Text("Category name")
                    TextField("Required", text: $name)
                        .multilineTextAlignment(.trailing)
                }
                HStack {
                    Text("Budget")
                    TextField("Required", value: $budget, format: .currency(code: manager.currency))
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.decimalPad)
                    // small UIKit code to autoselect text when entering category balance
                        .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)) { obj in
                            if let textField = obj.object as? UITextField {
                                textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
                            }
                        }
                }
            }
            .listStyle(PlainListStyle())
            .navigationBarTitle("Add category")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        manager.addCategory(name: name, budget: budget)
                        dismiss()
                    }
                }
            }
        }
    }
}

struct AddCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        let persistenceController = PersistenceController.shared
        let manager = BudgetBarManager()
        
        AddCategoryView()
            .preferredColorScheme(.dark)
        .environment(\.managedObjectContext, persistenceController.container.viewContext)
        .environmentObject(manager)
    }
}
