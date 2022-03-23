//
//  CategoriesView.swift
//  Level
//
//  Created by Patryk Szczypkowski on 08/02/2022.
//

import SwiftUI

struct CategoriesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var viewModel: LevelViewModel
    
    @State private var showAddCategorySheet = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.categories) { category in
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
                                    Text(category.balance!.decimalValue, format: .currency(code: "EUR")).padding(.leading, 5)
                                    Text(category.budget!.decimalValue, format: .currency(code: "EUR")).frame(maxWidth: .infinity, minHeight: 30, alignment: .trailing).padding(.trailing, 5)
                                }
                            }
                        }
                    }
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .listRowSeparator(.hidden)
                }
                .onDelete(perform: viewModel.deleteCategory)
                .onMove(perform: viewModel.moveCategories)
            }
            .listStyle(PlainListStyle())
            .navigationTitle("Categories")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu (viewModel.monthString) {
                        Picker(viewModel.monthString, selection: $viewModel.currentMonth) {
                            ForEach(viewModel.months, id: \.self) { month in
                                Text(verbatim: "\(DateFormatter().standaloneMonthSymbols[Int(month.month) - 1]) \(month.year)")
                            }
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
    
//    struct CategoryRowView: View {
//        @StateObject var category: Category
//        
//        var body: some View {
//            HStack {
//                Text(category.name!).frame(minWidth: 0, maxWidth: .infinity, alignment: .leading).padding(.leading, 16)
//                ZStack(alignment: .trailing) {
//                    Color.darkGreen.ignoresSafeArea()
//                    GeometryReader { geo in
//                        Rectangle()
//                            .fill(Color.accentColor)
//                            .frame(width: geo.size.width * (category.balance!.doubleValue / category.budget!.doubleValue), height: geo.size.height, alignment: .trailing)
//                    }
//                    HStack {
//                        Text(category.balance!.decimalValue, format: .currency(code: "EUR")).padding(.leading, 5)
//                        Text(category.budget!.decimalValue, format: .currency(code: "EUR")).frame(maxWidth: .infinity, minHeight: 30, alignment: .trailing).padding(.trailing, 5)
//                    }
//                }
//            }
//        }
//    }
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

