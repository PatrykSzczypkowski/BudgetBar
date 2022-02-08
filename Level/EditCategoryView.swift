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
    @State private var name = ""
    @State private var budget: Decimal = 0.00
    
    init(category: Category) {
        self.category = category
        self.name = category.name ?? "test"
        self.budget = category.budget?.decimalValue ?? 1000
    }
    
    var body: some View {
        NavigationView {
            List {
                HStack {
                    Text("Name")
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
                Button("Edit category") {
                    category.name = name
                    category.budget = NSDecimalNumber(decimal: budget)
                    
                    try? viewContext.save()
                    dismiss()
                }
            }
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
