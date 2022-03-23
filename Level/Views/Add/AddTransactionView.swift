//
//  AddTransactionView.swift
//  Level
//
//  Created by Patryk Szczypkowski on 24/02/2022.
//

import SwiftUI

struct AddTransactionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: LevelViewModel
    
    @Binding var currentMonth: Month
    
    @State private var amount: Decimal = 0.00
    @State private var inflow: Bool = true
    @State private var payee: String = ""
    @State private var category: Category? = nil
    @State private var account: Account = Account()
    @State private var date: Date = Date()
    @State private var notes: String = ""
    
    @State private var categoryString: String = "Category"
    @State private var accountString: String = "Account"
    
    var body: some View {
        NavigationView {
            List {
                HStack {
                    ZStack(alignment: .leading) {
                        ZStack(alignment: .trailing) {
                            if inflow {
                                Color.darkGreen.ignoresSafeArea()
                            }
                            else {
                                Color.darkRed.ignoresSafeArea()
                            }
                            Button(action: { inflow.toggle() }) {
                                ZStack {
                                    Rectangle()
                                    .fill(inflow ? Color.accentColor : Color.red)
                                    .frame(width: 40, height: 44)
                                    Text(inflow ? "+" : "-")
                                        .bold()
                                        .font(.system(size: 16))
                                }
                                    
                            }
                        }
                        Text("Amount")
                            .padding(.leading, 16)
                    }
                    TextField("Required", value: $amount, format: .currency(code: "EUR"))
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.decimalPad)
                        .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)) { obj in
                            if let textField = obj.object as? UITextField {
                                textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
                            }
                        }
                        .padding(.trailing, 16)
                }
                .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                HStack {
                    Text("Payee")
                    TextField("Required", text: $payee)
                        .multilineTextAlignment(.trailing)
                }
                HStack {
                    Text("Categories")
                    Spacer()
                    Menu(categoryString) {
                        Button("Transfer for account") {
                            self.category = nil
                            self.categoryString = "Transfer for account"
                        }
                        ForEach(viewModel.categories) { category in
                            Button(
                                action: {
                                    self.category = category
                                    self.categoryString = category.name!
                                },
                                label: {
                                    Text(category.name!)
                                }
                            )
                        }
                    }
                }
                HStack {
                    Text("Accounts")
                    Spacer()
                    Menu(accountString) {
                        ForEach(viewModel.accounts) { account in
                            Button(
                                action: {
                                    self.account = account
                                    self.accountString = account.name!
                                },
                                label: {
                                    Text(account.name!)
                                }
                            )
                        }
                    }
                }
                HStack {
                    DatePicker("Date", selection: $date, displayedComponents: [.date])
                        .onChange(of: date) { newDate in
                            currentMonth = viewModel.getMonthForDate(date: newDate)
                            categoryString = "Category"
                            category = nil
                        }
                }
                VStack {
                    HStack {
                        Text("Notes")
                        Spacer()
                    }
                    TextEditor(text: $notes)
                        .frame(maxWidth: .infinity, minHeight: 100)
                }
                Spacer()
                Button("Add transaction") {
                    viewModel.addTransaction(amount: amount, inflow: inflow, payee: payee, category: category, account: account, date: date, notes: notes)
                    dismiss()
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .foregroundColor(Color.accentColor)
            }
            .listStyle(PlainListStyle())
            .navigationBarTitle("Add transaction")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .tabItem {
            Label("Add transaction", systemImage: "plus")
        }
    }
}

//struct AddTransactionView_Previews: PreviewProvider {
//    static var previews: some View {
//        AddTransactionView()
//    }
//}
