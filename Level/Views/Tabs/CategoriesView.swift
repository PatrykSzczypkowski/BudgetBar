//
//  CategoriesView.swift
//  Level
//
//  Created by Patryk Szczypkowski on 08/02/2022.
//

import SwiftUI

struct CategoriesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Month.year, ascending: true),
                          NSSortDescriptor(keyPath: \Month.month, ascending: true)])
    private var months: FetchedResults<Month>
    
    @FetchRequest<Category>(
        entity: Category.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Category.userOrder, ascending: true)])
    private var categories: FetchedResults<Category>
    
    @Binding var currentMonth: Month
    
    @State private var showAddCategorySheet = false
    @State private var monthString = "Feb 2022"
    
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
                                Text(category.budget!.decimalValue, format: .currency(code: "EUR")).frame(minWidth: 0, maxWidth: .infinity, minHeight: 30, alignment: .trailing).background(Color.green)
                            }
                        }
                    )
                }
                .onDelete(perform: deleteItems)
                .onMove(perform: move)
            }
            .listStyle(PlainListStyle())
            .navigationTitle("Categories")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu (monthString) {
                        ForEach(months, id: \.self) { month in
                            Button(
                                action: {
                                    currentMonth = month
                                    setMonthForCategories()
                                },
                                label: {
                                    Text(verbatim: "\(DateFormatter().standaloneMonthSymbols[Int(month.month) - 1]) \(month.year)")
                                }
                            )
                        }
                    }
                }
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
                            AddCategoryView(month: $currentMonth)
                        }
                }
            }
        }
        .tabItem {
            Label("Categories", systemImage: "house")
        }
        .onAppear(perform: setMonthForCategories)
    }
    
    private func move(from source: IndexSet, to destination: Int) {
        var revisedItems: [Category] = categories.map{ $0 }
        
        revisedItems.move(fromOffsets: source, toOffset: destination)
        
        for reverseIndex in stride(from: revisedItems.count - 1, through: 0, by: -1) {
            revisedItems[reverseIndex].userOrder = Int16(reverseIndex)
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
    
    private func setMonthForCategories() {
        monthString = "\(DateFormatter().shortStandaloneMonthSymbols[Int(currentMonth.month) - 1]) \(currentMonth.year)"
        categories.nsPredicate = NSPredicate(format: "month == %@", currentMonth)
    }
}

//struct CategoryView_Previews: PreviewProvider {
//    static var previews: some View {
//        CategoriesView().preferredColorScheme(.dark).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//    }
//}
