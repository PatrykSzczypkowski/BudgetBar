//
//  EditTransactionView.swift
//  Level
//
//  Created by Patryk Szczypkowski on 24/02/2022.
//

import SwiftUI

struct EditTransactionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    
    @FetchRequest<Category>(
        entity: Category.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Category.userOrder, ascending: true)])
    private var categories: FetchedResults<Category>
    @FetchRequest<Account>(
        entity: Account.entity(),
        sortDescriptors: [])
    private var accounts: FetchedResults<Account>
    
    @State var currentMonth: Month
    
    @ObservedObject private var transaction: Transaction
    
    @State private var amount: Decimal
    @State private var inflow: Bool
    @State private var payee: String
    @State private var category: Category
    @State private var account: Account
    @State private var date: Date
    @State private var notes: String
    
    @State private var categoryString: String = "Category"
    @State private var accountString: String = "Account"
        
    init(transaction: Transaction) {
        self.transaction = transaction
        _amount = State(initialValue: transaction.amount?.decimalValue ?? 0)
        _inflow = State(initialValue: transaction.inflow)
        _payee = State(initialValue: transaction.payee ?? "")
        _category = State(initialValue: transaction.category ?? Category())
        _account = State(initialValue: transaction.account ?? Account())
        _date = State(initialValue: transaction.date ?? Date())
        _notes = State(initialValue: transaction.notes ?? "")
        
        _currentMonth = State(initialValue: transaction.category!.month!)
    }
    
    var body: some View {
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
            Button("Edit transaction") {
                // revert transactions
                transaction.category!.balance! = transaction.category!.balance!.adding(NSDecimalNumber(decimal: !transaction.inflow ? transaction.amount!.decimalValue : -transaction.amount!.decimalValue))
                transaction.account!.balance! = transaction.account!.balance!.adding(NSDecimalNumber(decimal: !transaction.inflow ? transaction.amount!.decimalValue : -transaction.amount!.decimalValue))
                
                // apply new change
                category.balance = category.balance?.adding(NSDecimalNumber(decimal: inflow ? amount : -amount))
                account.balance = account.balance?.adding(NSDecimalNumber(decimal: inflow ? amount : -amount))
                
                
                transaction.amount = NSDecimalNumber(decimal: amount)
                transaction.inflow = inflow
                transaction.payee = payee
                transaction.category = category
                transaction.account = account
                transaction.date = date
                transaction.notes = notes
                
                try? viewContext.save()
                dismiss()
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .foregroundColor(Color.accentColor)
        }
        .listStyle(PlainListStyle())
        .navigationBarTitle("Edit transaction")
        .onAppear(perform: setMonthForCategories)
        .onAppear(perform: setCategoryAndAccountStrings)
    }
    
    private func setMonthForCategories() {
        categories.nsPredicate = NSPredicate(format: "month == %@", currentMonth)
    }
    
    private func setCategoryAndAccountStrings() {
        categoryString = category.name!
        accountString = account.name!
    }
}

//struct EditTransactionView_Previews: PreviewProvider {
//    static var previews: some View {
//        EditTransactionView()
//    }
//}
