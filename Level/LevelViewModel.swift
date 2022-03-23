//
//  LevelViewModel.swift
//  Level
//
//  Created by Patryk Szczypkowski on 20/03/2022.
//

import Foundation
import CoreData

class LevelViewModel: ObservableObject {
    @Published var categories: [Category] = []
    @Published var months: [Month] = []
    @Published var accounts: [Account] = []
    @Published var transactions: [Transaction] = []
    @Published var transactionsPerAccount: [Transaction] = []
    
    let context = PersistenceController.shared.container.viewContext
    
    let categoriesRequest = Category.fetchRequest()
    let monthsRequest = Month.fetchRequest()
    let accountsRequest = Account.fetchRequest()
    let transactionsRequest = Transaction.fetchRequest()
    
    var currentMonth = Month() {
        didSet {
            setMonthForCategories()
        }
    }
    var monthString = "Feb 2022"
    
    init() {
        monthsRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Month.year, ascending: true), NSSortDescriptor(keyPath: \Month.month, ascending: true)]
        categoriesRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Category.userOrder, ascending: true)]
        accountsRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Account.name, ascending: true)]
        transactionsRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Transaction.date, ascending: true)]
        
        do {
            try categories = context.fetch(categoriesRequest)
            try months = context.fetch(monthsRequest)
            try accounts = context.fetch(accountsRequest)
            try transactions = context.fetch(transactionsRequest)
        } catch {
            print(error)
        }
        setCurrentMonth()
    }
    
    func setCurrentMonth() {
        let year = Calendar.current.component(.year, from: Date())
        let month = Calendar.current.component(.month, from: Date())
        
        for m in months {
            if(m.month == month && m.year == year) {
                currentMonth = m
                print("\(currentMonth.month) \(currentMonth.year)")
                break
            }
        }
    }
    
    func getMonthForDate(date: Date) -> Month {
        let components = date.get(.month, .year)
        for month in months {
            if (month.month == components.month! && month.year == components.year!) {
                return month
            }
        }
        
        let newMonth = Month(context: context)
        newMonth.month = Int16(components.month!)
        newMonth.year = Int16(components.year!)
        
        try? context.save()
        
        return newMonth
    }
    
    func addCategory(name: String, budget: Decimal) {
        // TODO: add categories to future months
        let monthIndex = months.firstIndex(of: currentMonth)
        for index in (monthIndex ?? 0)..<months.count {
            let newCategory = Category(context: context)
            newCategory.name = name
            newCategory.budget = NSDecimalNumber(decimal: budget)
            newCategory.balance = NSDecimalNumber(decimal: budget)
            months[index].addToCategories(newCategory)
        }
        
        try? context.save()
        
        do {
            try categories = context.fetch(categoriesRequest)
        } catch {
            print(error)
        }
        
    }
    
    func editCategory(category: Category, name: String, budget: Decimal) {
        category.name = name
        // update balance by the difference of the changed budget: balance = balance + (newBudget - oldBudget)
        category.balance =  category.balance!.adding(NSDecimalNumber(decimal: budget).subtracting(category.budget!))
        category.budget = NSDecimalNumber(decimal: budget)
        
        try? context.save()
        try? categories = context.fetch(categoriesRequest)
    }
    
    func moveCategories(from source: IndexSet, to destination: Int) {
        var revisedItems: [Category] = categories.map{ $0 }
        
        revisedItems.move(fromOffsets: source, toOffset: destination)
        
        for reverseIndex in stride(from: revisedItems.count - 1, through: 0, by: -1) {
            revisedItems[reverseIndex].userOrder = Int16(reverseIndex)
        }
        
        do {
            try categories = context.fetch(categoriesRequest)
        } catch {
            print(error)
        }
    }
    
    func deleteCategory(offsets: IndexSet) {
        offsets.map { categories[$0] }.forEach(context.delete)

        do {
            try context.save()
            try categories = context.fetch(categoriesRequest)
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    func setMonthForCategories() {
        monthString = "\(DateFormatter().shortStandaloneMonthSymbols[Int(currentMonth.month) - 1]) \(currentMonth.year)"
        categoriesRequest.predicate = NSPredicate(format: "month == %@", currentMonth)
        do {
            try categories = context.fetch(categoriesRequest)
        } catch {
            print(error)
        }
    }
    
    func addAccount(name: String, balance: Decimal) {
        let newAccount = Account(context: context)
        newAccount.name = name
        newAccount.balance = NSDecimalNumber(decimal: balance)
        
        try? context.save()
        try? accounts = context.fetch(accountsRequest)
    }
    
    func editAccount(account: Account, name: String, balance: Decimal) {
        account.name = name
        account.balance = NSDecimalNumber(decimal: balance)
        
        try? context.save()
        try? accounts = context.fetch(accountsRequest)
    }
    
    func deleteAccount(offsets: IndexSet) {
        offsets.map { accounts[$0] }.forEach(context.delete)

        do {
            try context.save()
            try accounts = context.fetch(accountsRequest)
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    func addTransaction(amount: Decimal, inflow: Bool, payee: String, category: Category?, account: Account, date: Date, notes: String) {
        let newTransaction = Transaction(context: context)
        newTransaction.amount = NSDecimalNumber(decimal: amount)
        newTransaction.inflow = inflow
        newTransaction.payee = payee
        newTransaction.category = category
        newTransaction.account = account
        newTransaction.date = date
        newTransaction.notes = notes
        
        if (category != nil) {
            category!.addToTransactions(newTransaction)
            category!.balance = category!.balance?.adding(NSDecimalNumber(decimal: inflow ? amount : -amount))
        }
        account.addToTransactions(newTransaction)
        account.balance = account.balance?.adding(NSDecimalNumber(decimal: inflow ? amount : -amount))
        
        if (transactionsPerAccount.first?.account == account) {
            transactionsPerAccount.append(newTransaction)
        }
        
        
        try? context.save()
        try? transactions = context.fetch(transactionsRequest)
    }
    
    func editTransaction(transaction: Transaction, amount: Decimal, inflow: Bool, payee: String, category: Category?, account: Account, date: Date, notes: String) {
        // revert transactions
        transaction.category!.balance! = transaction.category!.balance!.adding(NSDecimalNumber(decimal: !transaction.inflow ? transaction.amount!.decimalValue : -transaction.amount!.decimalValue))
        transaction.account!.balance! = transaction.account!.balance!.adding(NSDecimalNumber(decimal: !transaction.inflow ? transaction.amount!.decimalValue : -transaction.amount!.decimalValue))
        
        // apply new change
        if (category != nil) {
            category?.balance = category?.balance?.adding(NSDecimalNumber(decimal: inflow ? amount : -amount))
        }
        account.balance = account.balance?.adding(NSDecimalNumber(decimal: inflow ? amount : -amount))
        
        
        transaction.amount = NSDecimalNumber(decimal: amount)
        transaction.inflow = inflow
        transaction.payee = payee
        transaction.category = category
        transaction.account = account
        transaction.date = date
        transaction.notes = notes
        
        try? context.save()
        try? transactions = context.fetch(transactionsRequest)
    }
    
    func deleteTransaction(offsets: IndexSet) {
        // TODO: add comment for the complicated looking calculations
        for index in offsets {
            transactionsPerAccount[index].account!.balance! = transactionsPerAccount[index].account!.balance!.adding( !transactionsPerAccount[index].inflow ? transactionsPerAccount[index].amount! : transactionsPerAccount[index].amount!.multiplying(by: -1))
            transactionsPerAccount[index].category!.balance! = transactionsPerAccount[index].category!.balance!.adding( !transactionsPerAccount[index].inflow ? transactionsPerAccount[index].amount! : transactionsPerAccount[index].amount!.multiplying(by: -1))
        }
        offsets.map { transactionsPerAccount[$0] }.forEach(context.delete)

        do {
            try context.save()
            try transactions = context.fetch(transactionsRequest)
            // TODO: transactionsPerAccount should be refreshed in some way
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    func setTransactionsPerAccount(account: Account) {
        transactionsPerAccount = transactions.filter { $0.account == account }
    }
    
    func setTransactionsPerAccount(account: Account, predicate: String) {
        if (predicate == "") {
            transactionsPerAccount = transactions.filter { $0.account == account }
        }
        transactionsPerAccount = transactions.filter { $0.account == account && ($0.amount?.stringValue == predicate || $0.payee!.lowercased().hasPrefix(predicate.lowercased()) || $0.category!.name!.lowercased().hasPrefix(predicate.lowercased())) }
    }
}

extension Date {
    func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
        return calendar.dateComponents(Set(components), from: self)
    }

    func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: self)
    }
}
