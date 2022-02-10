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
        sortDescriptors: [NSSortDescriptor(keyPath: \Category.userOrder, ascending: true)],
        animation: .default)
    private var categories: FetchedResults<Category>
    
    @FetchRequest(sortDescriptors: []) private var months: FetchedResults<Month>
    
//    @State private var months = ["Feb 2022", "Mar 2022", "Apr 2022", "May 2022", "Jun 2022", "Jul 2022", "Aug 2022", "Sep 2022", "Oct 2022", "Nov 2022", "Dec 2022", "Jan 2023", "Feb 2024", "Feb 2024", "Feb 2024", "Feb 2024", "Feb 2024", "Feb 2024", "Feb 2024", "Feb 2024", "Feb 2024", "Feb 2024", "Feb 2024", "Feb 2024", "Feb 2024", "Feb 2024", "Feb 2024", "Feb 2024", "Feb 2024", "Feb 2024", "Feb 2024"]
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
                    Menu ("Feb 2022") {
                        ForEach(months, id: \.self) { month in
//                            Button(month) { }
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
                            AddCategoryView()
                        }
                }
            }
        }
        .tabItem {
            Label("Categories", systemImage: "house")
        }
//        .onAppear(perform: createMonths)
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
    
    private func createMonths() {
        let year = Calendar.current.component(.year, from: Date())
        let month = Calendar.current.component(.month, from: Date())
        
        if(months.count == 0) {
            for i in 0..<24 {
                let newMonth = Month()
                newMonth.year = Int16(year)
                newMonth.month = Int16(month)
//                newMonth.category = categories
            }
        }
    }
}

struct CategoryView_Previews: PreviewProvider {
    static var previews: some View {
        CategoriesView()
    }
}
