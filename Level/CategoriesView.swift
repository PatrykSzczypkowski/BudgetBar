//
//  CategoriesView.swift
//  Level
//
//  Created by Patryk Szczypkowski on 08/02/2022.
//

import SwiftUI
import CoreData
import Foundation

struct CategoriesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Category.name, ascending: true)],
        animation: .default)
    private var categories: FetchedResults<Category>
    
    private let numberFormatter: NumberFormatter
    init() {
        numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.currencyCode = "EUR"
        numberFormatter.maximumFractionDigits = 2
    }
    
    @State private var showAddCategorySheet = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(categories) { category in
                    NavigationLink (
                        destination: {
                            EditCategoryView(category: category)
                        },
                        label: {
                            HStack {
                                Text(category.name!).frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                Text("\(category.budget!, formatter: numberFormatter)").frame(minWidth: 0, maxWidth: .infinity, minHeight: 30, alignment: .trailing).background(Color.green)
                            }
                        }
                    )
                }
                .onDelete(perform: deleteItems)
            }
            .listStyle(PlainListStyle())
            .navigationTitle("Categories")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button (
                        action: {
                            showAddCategorySheet.toggle()
                        },
                        label: {
                            Label("Add Item", systemImage: "plus")
                        }
                    )
                        .sheet(isPresented: $showAddCategorySheet) {
                            AddCategoryView()
                        }
                }
            }
        }
        .tabItem {
            Label("Categories", systemImage: "house")
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { categories[$0] }.forEach(viewContext.delete)

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
    
    private func addItem() {
//        withAnimation {
//            let newCategory = Category(context: viewContext)
//            newCategory.name = "Rent"
//
//            do {
//                try viewContext.save()
//            } catch {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nsError = error as NSError
//                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//            }
//        }
    }
}

struct CategoryView_Previews: PreviewProvider {
    static var previews: some View {
        CategoriesView()
    }
}
