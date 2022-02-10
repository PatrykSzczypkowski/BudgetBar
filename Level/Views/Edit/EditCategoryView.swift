//
//  EditCategoryView.swift
//  Level
//
//  Created by Patryk Szczypkowski on 08/02/2022.
//

import SwiftUI

struct EditCategoryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject private var category: Category
    @State private var name: String
    @State private var budget: Decimal
        
    init(category: Category) {
        self.category = category
        _name = State(initialValue: category.name ?? "")
        _budget = State(initialValue: category.budget?.decimalValue ?? 0)
    }
    
    var body: some View {
        List {
            HStack {
                Text("Category name")
                TextField("Required", text: $name)
                    .multilineTextAlignment(.trailing)
            }
            HStack {
                Text("Budget")
                TextField("Required", value: $budget, format: .currency(code: "EUR"))
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.decimalPad)
                    .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)) { obj in
                        if let textField = obj.object as? UITextField {
                            textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
                        }
                    }
            }
            Spacer()
            Button("Edit category") {
                category.name = name
                category.budget = NSDecimalNumber(decimal: budget)
                
                try? viewContext.save()
                dismiss()
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .foregroundColor(Color.accentColor)
        }
        .listStyle(PlainListStyle())
        .navigationBarTitle("Edit category")
    }
}

struct EditCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = PersistenceController.preview.container.viewContext
        let category = Category(context: viewContext)
        category.name = "Test"
        category.budget = 1000.00
        
        return EditCategoryView(category: category)
    }
}
