//
//  AddCategoryView.swift
//  Level
//
//  Created by Patryk Szczypkowski on 08/02/2022.
//

import SwiftUI

struct AddCategoryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    
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
                    TextField("Required", value: $budget, format: .number)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.decimalPad)
                }
                Spacer()
                Button("Add category") {
                    let newCategory = Category(context: viewContext)
                    newCategory.name = name
                    newCategory.budget = NSDecimalNumber(decimal: budget)
                    
                    try? viewContext.save()
                    dismiss()
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            
            .listStyle(PlainListStyle())
            .navigationBarTitle("Add category")
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

struct AddCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        AddCategoryView()
    }
}
