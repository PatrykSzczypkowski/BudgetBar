//
//  CategoriesView.swift
//  Level
//
//  Created by Patryk Szczypkowski on 08/02/2022.
//

import SwiftUI

struct CategoriesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var manager: LevelManager
    
    @State private var showAddCategorySheet = false
    
    var body: some View {
        NavigationView {
            List {
                // display if there are no categories for selected month
                if (manager.categoriesPerMonth.count == 0) {
                    VStack {
                        Spacer()
                        Text("""
                        Follow these steps to add your first budgeting category:
                        
                        1. Tap on \(Image(systemName: "plus")) in the top-right corner of your screen
                        
                        2. Enter your category name and its budget for the whole month
                        
                        3. Tap on the Add button in the top-right corner
                        
                        """)
                        Spacer()
                        Spacer()
                    }
                }
                else {
                    ForEach(manager.categoriesPerMonth) { category in
                        CategoryRowView(category: category)
                    }
                    .onDelete(perform: manager.deleteCategory)
                    .onMove(perform: manager.moveCategories)
                    Spacer()
                    MonthBalanceBar(sums: getSumsOfAllCategories(month: manager.selectedMonth))
                }
            }
            .listStyle(PlainListStyle())
            .navigationTitle("Categories")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu (manager.monthString) {
                        Button("Add month before") {
                            manager.addMonthBefore()
                        }
                        Picker(manager.monthString, selection: $manager.selectedMonth) {
                            ForEach(manager.months, id: \.self) { month in
                                Text(verbatim: "\(DateFormatter().standaloneMonthSymbols[Int(month.month) - 1]) \(month.year)")
                            }
                        }
                        Button("Add month after") {
                            manager.addMonthAfter()
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button (action: { showAddCategorySheet.toggle() })
                    {
                        Label("Add Item", systemImage: "plus")
                    }
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
    
    struct CategoryRowView: View {
        @EnvironmentObject var manager: LevelManager
        @StateObject var category: Category
        
        var body: some View {
            if category.name != nil && category.budget != nil && category.balance != nil {
                ZStack {
                    NavigationLink (destination: EditCategoryView(category: category)) {
                        EmptyView()
                    }
                    HStack {
                        Text(category.name!).frame(minWidth: 0, maxWidth: .infinity, alignment: .leading).padding(.leading, 16)
                        ZStack(alignment: .trailing) {
                            if category.balance!.doubleValue >= 0 {
                                Color.darkGreen.ignoresSafeArea()
                            }
                            else {
                                Color.darkRed.ignoresSafeArea()
                            }
                            GeometryReader { geo in
                                Rectangle()
                                    .fill(Color.accentColor)
                                    .frame(width: geo.size.width * (category.balance!.doubleValue / category.budget!.doubleValue), height: geo.size.height, alignment: .trailing)
                            }
                            HStack {
                                Text(category.balance!.decimalValue, format: .currency(code: manager.currency)).padding(.leading, 5)
                                Text(category.budget!.decimalValue, format: .currency(code: manager.currency)).frame(maxWidth: .infinity, minHeight: 30, alignment: .trailing).padding(.trailing, 5)
                            }
                        }
                    }
                }
                .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                .listRowSeparator(.hidden)
            }
        }
    }
    
    struct MonthBalanceBar: View {
        @EnvironmentObject var manager: LevelManager
        var balance: Decimal
        var budget: Decimal
        
        init (sums: (balance: Decimal, budget: Decimal)) {
            self.balance = sums.balance
            self.budget = sums.budget
        }
        
        var body: some View {
            VStack {
                Text("This months budget").frame(alignment: .center).font(.system(size: 14)).foregroundColor(.gray)
                HStack {
                    ZStack(alignment: .trailing) {
                        if balance >= 0 {
                            Color.darkGreen.ignoresSafeArea()
                        }
                        else {
                            Color.darkRed.ignoresSafeArea()
                        }
                        GeometryReader { geo in
                            Rectangle()
                                .fill(Color.accentColor)
                                .frame(width: geo.size.width * (NSDecimalNumber(decimal: balance).doubleValue / NSDecimalNumber(decimal: budget).doubleValue), height: geo.size.height, alignment: .trailing)
                        }
                        HStack {
                            Text(balance, format: .currency(code: manager.currency)).padding(.leading, 5)
                            Text(budget, format: .currency(code: manager.currency)).frame(maxWidth: .infinity, minHeight: 30, alignment: .trailing).padding(.trailing, 5)
                        }
                    }
                }
            }
            .listRowInsets(.init(top: 10, leading: 0, bottom: 10, trailing: 0))
            .listRowSeparator(.hidden)
        }
    }
    
    func getSumsOfAllCategories(month: Month) -> (balance: Decimal, budget: Decimal) {
        var balance: Decimal = 0.00
        var budget: Decimal = 0.00
        
        if (month.categories?.count ?? 0 > 0) {
            for category in month.categories!.array as! [Category] {
                balance += category.balance!.decimalValue
                budget += category.budget!.decimalValue
            }
        }
        
        return (balance, budget)
    }
}

extension Color {
    static let darkGreen = Color("DarkGreenAccent")
    static let darkRed = Color("DarkRedAccent")
}

//struct CategoryView_Previews: PreviewProvider {
//    static var previews: some View {
//        CategoriesView().preferredColorScheme(.dark).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//    }
//}

