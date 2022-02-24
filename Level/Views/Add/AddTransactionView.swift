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
    
    @FetchRequest<Category>(
        entity: Category.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Category.userOrder, ascending: true)])
    private var categories: FetchedResults<Category>
    @FetchRequest<Account>(entity: Account.entity(), sortDescriptors: []) private var accounts: FetchedResults<Account>
    
    @Binding var currentMonth: Month
    
    @State private var amount: Decimal = 0.00
    @State private var inflow: Bool = true
    @State private var payee: String = ""
    @State private var category: Category = Category()
    @State private var account: Account = Account()
    @State private var date: Date = Date()
    @State private var notes: String = ""
    
    @State private var categoryString: String = "Category"
    @State private var accountString: String = "Account"
    
    var body: some View {
        NavigationView {
            List {
                HStack {
                    Text("Amount")
                    Toggle(" ", isOn: $inflow)
                        .toggleStyle(.button)
                        .tint(Color.accentColor)
                        .background(.red)
                        .cornerRadius(5)
                    TextField("Required", value: $amount, format: .currency(code: "EUR"))
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.decimalPad)
                        .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)) { obj in
                            if let textField = obj.object as? UITextField {
                                textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
                            }
                        }
                }
                HStack {
                    Text("Payee")
                    TextField("Required", text: $payee)
                        .multilineTextAlignment(.trailing)
                }
                HStack {
                    Text("Categories")
                    Spacer()
                    Menu(categoryString) {
                        ForEach(categories) { category in
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
                        ForEach(accounts) { account in
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
                    let newTransaction = Transaction(context: viewContext)
                    newTransaction.amount = NSDecimalNumber(decimal: amount)
                    newTransaction.inflow = inflow
                    newTransaction.payee = payee
                    newTransaction.category = category
                    newTransaction.account = account
                    newTransaction.date = date
                    newTransaction.notes = notes
                    
                    category.addToTransactions(newTransaction)
                    category.balance = category.balance?.adding(NSDecimalNumber(decimal: inflow ? amount : -amount))
                    account.addToTransactions(newTransaction)
                    account.balance = account.balance?.adding(NSDecimalNumber(decimal: inflow ? amount : -amount))
                    
                    
                    try? viewContext.save()
                    dismiss()
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .foregroundColor(Color.accentColor)
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
        .onAppear(perform: setMonthForCategories)
        .tabItem {
            Label("Add transaction", systemImage: "plus")
        }
    }
    
    private func setMonthForCategories() {
        categories.nsPredicate = NSPredicate(format: "month == %@", currentMonth)
    }
}

//struct AddTransactionView_Previews: PreviewProvider {
//    static var previews: some View {
//        AddTransactionView()
//    }
//}
