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
    @EnvironmentObject var manager: LevelManager
    
    @State private var amount: Decimal = 0.00
    @State private var inflow: Bool = false
    @State private var payee: String = ""
    @State private var category: Category? = nil
    @State private var account: Account = Account()
    @State private var date: Date = Date()
    @State private var notes: String = ""
    
    @State private var categoryString: String = "Required"
    @State private var accountString: String = "Required"
    @State private var shouldAddButtonBeDisabled = true
    
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
                            GeometryReader { geo in
                                Button(action: { inflow.toggle() }) {
                                    HStack {
                                        Spacer()
                                        ZStack {
                                            Rectangle()
                                                .fill(inflow ? Color.accentColor : Color.red)
                                                .frame(width: 40, height: geo.size.height)
                                            Text(inflow ? "+" : "–")
                                                .bold()
                                                .font(.system(size: 20))
                                        }
                                    }
                                }
                            }
                        }
                        Text("Amount")
                            .padding(.leading, 16)
                    }
                    TextField("Required", value: $amount, format: .currency(code: manager.currency))
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.decimalPad)
                        .onChange(of: amount) { newValue in
                            formValidation()
                        }
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
                        .onChange(of: payee) { newValue in
                            formValidation()
                        }
                }
                HStack {
                    Text("Categories")
                    Spacer()
                    Menu(categoryString) {
                        Button("Transfer for account") {
                            self.category = nil
                            self.categoryString = "Transfer for account"
                        }
                        ForEach(manager.categoriesPerMonth) { category in
                            Button(
                                action: {
                                    self.category = category
                                    self.categoryString = category.name!
                                },
                                label: {
                                    Text(category.name!)
                                }
                            )
                            .onChange(of: categoryString) { newValue in
                                formValidation()
                            }
                        }
                    }
                }
                HStack {
                    Text("Accounts")
                    Spacer()
                    Menu(accountString) {
                        ForEach(manager.accounts) { account in
                            Button(
                                action: {
                                    self.account = account
                                    self.accountString = account.name!
                                },
                                label: {
                                    Text(account.name!)
                                }
                            )
                            .onChange(of: accountString) { newValue in
                                formValidation()
                            }
                        }
                    }
                }
                ZStack {
                    DatePicker("Date", selection: $date, displayedComponents: [.date])
                        .onChange(of: date) { newDate in
                            manager.selectedMonth = manager.getMonthForDate(date: newDate)
                            categoryString = "Required"
                            category = nil
                        }
                    if (date.get(.day, .month, .year) == Date().get(.day, .month, .year)) {
                        Spacer()
                        Text("Today")
                        Spacer()
                    }
                }
                VStack {
                    HStack {
                        Text("Notes")
                        Spacer()
                    }
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $notes)
                            .frame(maxWidth: .infinity, minHeight: 100)
                        if (notes == "") {
                            Text("Type notes here...")
                                .foregroundColor(Color.gray)
                                .padding(.top, 8)
                                .padding(.leading, 5)
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        manager.addTransaction(amount: amount, inflow: inflow, payee: payee, category: category, account: account, date: date, notes: notes)
                        dismiss()
                    }
                    .disabled(shouldAddButtonBeDisabled)
                }
            }
            .listStyle(PlainListStyle())
            .navigationBarTitle("Add transaction")
        }
        .tabItem {
            Label("Add transaction", systemImage: "plus")
        }
    }
    
    private func formValidation() {
        if (amount == 0.00 || payee == "" || categoryString == "Required" || accountString == "Required") { shouldAddButtonBeDisabled = true }
        else { shouldAddButtonBeDisabled = false }
    }
}

//struct AddTransactionView_Previews: PreviewProvider {
//    static var previews: some View {
//        AddTransactionView()
//    }
//}
