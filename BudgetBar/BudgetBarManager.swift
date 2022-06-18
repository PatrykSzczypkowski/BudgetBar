//
//  BudgetBarViewModel.swift
//  BudgetBar
//
//  Created by Patryk Szczypkowski on 20/03/2022.
//

import Foundation
import CoreData

class BudgetBarManager: ObservableObject {
    // arrays of all stored objects
    @Published var months: [Month] = []
    @Published var accounts: [Account] = []
    @Published var transactions: [Transaction] = []

    // state arrays of objects
    @Published var categoriesPerMonth: [Category] = []
    @Published var transactionsPerAccount: [Transaction] = []
    
    @Published var monthsAhead: Int = UserDefaults.standard.integer(forKey: "monthsAhead") {
        didSet {
            UserDefaults.standard.set(monthsAhead, forKey: "monthsAhead")
            appendMonths()
        }
    }
    @Published var currency: String = UserDefaults.standard.string(forKey: "currency") ?? "EUR" {
        didSet {
            UserDefaults.standard.set(currency, forKey: "currency")
        }
    }
    
    let context = PersistenceController.shared.container.viewContext
    let categoriesRequest = Category.fetchRequest()
    let monthsRequest = Month.fetchRequest()
    let accountsRequest = Account.fetchRequest()
    let transactionsRequest = Transaction.fetchRequest()
    
    var selectedMonth = Month() {
        didSet {
            setMonthForCategories()
        }
    }
    private(set) var monthString = "Feb 2022"
    
    init() {
        monthsRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Month.year, ascending: true), NSSortDescriptor(keyPath: \Month.month, ascending: true)]
        categoriesRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Category.userOrder, ascending: true)]
        accountsRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Account.name, ascending: true)]
        transactionsRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)]
        
        do {
            try months = context.fetch(monthsRequest)
            initializeMonths()
            
            try accounts = context.fetch(accountsRequest)
            try transactions = context.fetch(transactionsRequest)
            try categoriesPerMonth = context.fetch(categoriesRequest)
        } catch {
            print(error)
        }
        setCurrentMonth()
    }
    
    func addMonthBefore() {
        if (months.count > 0) {
            let calendar = Calendar.current

            var dateComponents = DateComponents()
            // set components of the first month in store
            dateComponents.month = Int(months.first!.month)
            dateComponents.year = Int(months.first!.year)
            
            // move starting date to the date of the first month in array
            var nextDate = calendar.date(from: dateComponents)!
            nextDate = calendar.date(byAdding: .month, value: -1, to: nextDate)!
            let components = nextDate.get(.month, .year)
            
            let newMonth = Month(context: context)
            newMonth.month = Int16(components.month!)
            newMonth.year = Int16(components.year!)
            
            try? context.save()
            try? months = context.fetch(monthsRequest)
        }
    }
    
    func addMonthAfter() {
        if (months.count > 0) {
            let calendar = Calendar.current

            var dateComponents = DateComponents()
            // set components of the first month in store
            dateComponents.month = Int(months.last!.month)
            dateComponents.year = Int(months.last!.year)
            
            // move starting date to the date of the first month in array
            var nextDate = calendar.date(from: dateComponents)!
            nextDate = calendar.date(byAdding: .month, value: 1, to: nextDate)!
            let components = nextDate.get(.month, .year)
            
            let newMonth = Month(context: context)
            newMonth.month = Int16(components.month!)
            newMonth.year = Int16(components.year!)
            
            try? context.save()
            try? months = context.fetch(monthsRequest)
        }
    }
    
    func initializeMonths() {
        // only run if there were no months initialized (the assumption is the app was ran for the first time)
        if(months.count == 0) {
            monthsAhead = 3
            // create current month + number of monthsAhead
            let calendar = Calendar.current
            
            for i in 0 ... monthsAhead {
                var nextDate = Date()
                nextDate = calendar.date(byAdding: .month, value: i, to: nextDate)!
                let components = nextDate.get(.month, .year)
                
                let newMonth = Month(context: context)
                newMonth.month = Int16(components.month!)
                newMonth.year = Int16(components.year!)
            }
            
            try? context.save()
            try? months = context.fetch(monthsRequest)
        }
    }
    
    func appendMonths() {
        // create months if there are less months ahead than expected
        if (months.count > 0) {
            let calendar = Calendar.current
            let currentMonthIndex = months.firstIndex(of: getCurrentMonth())
            let lastMonthIndex = months.firstIndex(of: months.last!)
            let difference = lastMonthIndex! - currentMonthIndex!
            
            if(difference < monthsAhead) {
                let monthsToCreate = monthsAhead - difference
                for i in 1 ...  monthsToCreate {
                    var dateComponents = DateComponents()
                    // set components of the last month in store
                    dateComponents.month = Int(months.last!.month)
                    dateComponents.year = Int(months.last!.year)
                    
                    // move starting date to the date of the last month in array
                    var nextDate = calendar.date(from: dateComponents)!
                    nextDate = calendar.date(byAdding: .month, value: i, to: nextDate)!
                    let components = nextDate.get(.month, .year)
                    
                    let newMonth = Month(context: context)
                    newMonth.month = Int16(components.month!)
                    newMonth.year = Int16(components.year!)
                }
            }
            
            try? context.save()
            try? months = context.fetch(monthsRequest)
        }
    }
    
    func getCurrentMonth() -> Month {
        let year = Calendar.current.component(.year, from: Date())
        let month = Calendar.current.component(.month, from: Date())
        
        for m in months {
            if(m.month == month && m.year == year) {
                return m
            }
        }
        
        // if current month is not found then create one and save it
        let components = Date().get(.month, .year)
        
        let newMonth = Month(context: context)
        newMonth.month = Int16(components.month!)
        newMonth.year = Int16(components.year!)
        
        try? context.save()
        try? months = context.fetch(monthsRequest)
        
        return newMonth
    }
    
    func setCurrentMonth() {
        let year = Calendar.current.component(.year, from: Date())
        let month = Calendar.current.component(.month, from: Date())
        
        for m in months {
            if(m.month == month && m.year == year) {
                selectedMonth = m
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
    
    func getDateForMonth(month: Month) -> Date {
        var components = DateComponents()
        components.month = Int(month.month)
        components.year = Int(month.year)
        
        return Calendar.current.date(from: components)!
    }
    
    func addCategory(name: String, budget: Decimal) {
        let monthIndex = months.firstIndex(of: selectedMonth)
        for index in (monthIndex ?? 0)..<months.count {
            let newCategory = Category(context: context)
            newCategory.name = name
            newCategory.budget = NSDecimalNumber(decimal: budget)
            newCategory.balance = NSDecimalNumber(decimal: budget)
            months[index].addToCategories(newCategory)
        }
        
        try? context.save()
        try? categoriesPerMonth = context.fetch(categoriesRequest)
    }
    
    func editCategory(category: Category, name: String, budget: Decimal) {
        let startIndex = months.firstIndex(of: category.month!)
        for month in months.dropFirst(startIndex!) {
            for cat in month.categories!.array as! [Category] {
                if (cat.name == category.name) {
                    cat.name = name
                    // update balance by the difference of the changed budget: balance = balance + (newBudget - oldBudget)
                    cat.balance = cat.balance!.adding(NSDecimalNumber(decimal: budget).subtracting(cat.budget!))
                    cat.budget = NSDecimalNumber(decimal: budget)
                }
            }
        }
        
        try? context.save()
        try? categoriesPerMonth = context.fetch(categoriesRequest)
    }
    
    func moveCategories(from source: IndexSet, to destination: Int) {
        var revisedItems: [Category] = categoriesPerMonth.map{ $0 }
        
        revisedItems.move(fromOffsets: source, toOffset: destination)
        
        for reverseIndex in stride(from: revisedItems.count - 1, through: 0, by: -1) {
            revisedItems[reverseIndex].userOrder = Int16(reverseIndex)
        }
        
        try? categoriesPerMonth = context.fetch(categoriesRequest)
    }
    
    func deleteCategory(offsets: IndexSet) {
        offsets.map { categoriesPerMonth[$0] }.forEach(context.delete)

        try? context.save()
        try? categoriesPerMonth = context.fetch(categoriesRequest)
    }
    
    func setMonthForCategories() {
        monthString = "\(DateFormatter().shortStandaloneMonthSymbols[Int(selectedMonth.month) - 1]) \(selectedMonth.year)"
        categoriesRequest.predicate = NSPredicate(format: "month == %@", selectedMonth)
        
        try? categoriesPerMonth = context.fetch(categoriesRequest)
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
        
        try? context.save()
        try? accounts = context.fetch(accountsRequest)
    }
    
    func addTransaction(amount: Decimal, inflow: Bool, payee: String, category: Category?, account: Account, date: Date, notes: String) {
        let newTransaction = Transaction(context: context)
        newTransaction.amount = NSDecimalNumber(decimal: amount)
        newTransaction.inflow = inflow
        newTransaction.payee = payee
        newTransaction.category = category
        newTransaction.account = account
        newTransaction.date = date
        newTransaction.month = getMonthForDate(date: date)
        newTransaction.notes = notes
        
        if (category != nil) {
            category!.addToTransactions(newTransaction)
            // update category balance: categoryBalance = categoryBalance +/- transaction
            category!.balance = category!.balance?.adding(NSDecimalNumber(decimal: inflow ? amount : -amount))
        }
        account.addToTransactions(newTransaction)
        // update account balance: accountBalance = accountBalance +/- transaction
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
        transaction.month = getMonthForDate(date: date)
        transaction.notes = notes
        
        try? context.save()
        try? transactions = context.fetch(transactionsRequest)
    }
    
    func deleteTransaction(offsets: IndexSet) {
        for index in offsets {
            // update the account balance: account_balance = account_balance +/- transaction
            transactionsPerAccount[index].account!.balance! = transactionsPerAccount[index].account!.balance!.adding( !transactionsPerAccount[index].inflow ? transactionsPerAccount[index].amount! : transactionsPerAccount[index].amount!.multiplying(by: -1))
            if (transactionsPerAccount[index].category != nil) {
                // update the category balance: categoryBalance = categoryBalance +/- transaction
                transactionsPerAccount[index].category!.balance! = transactionsPerAccount[index].category!.balance!.adding( !transactionsPerAccount[index].inflow ? transactionsPerAccount[index].amount! : transactionsPerAccount[index].amount!.multiplying(by: -1))
            }
        }
        offsets.map { transactionsPerAccount[$0] }.forEach(context.delete)

        try? context.save()
        try? transactions = context.fetch(transactionsRequest)
        // transactionPerAccount could be refreshed here if problems occurTOD
    }
    
    func setTransactionsPerAccount(account: Account) {
        transactionsPerAccount = transactions.filter { $0.account == account }
    }
    
    func setTransactionsPerAccount(account: Account, predicate: String) {
        if (predicate == "") {
            transactionsPerAccount = transactions.filter { $0.account == account }
        }
        // Filtering transactions for search bar in TransactionsPerAccountView (can search for amount, payee and categories)
        transactionsPerAccount = transactions.filter { $0.account == account && ($0.amount?.stringValue == predicate || $0.payee!.lowercased().hasPrefix(predicate.lowercased()) || ($0.category != nil ? $0.category!.name!.lowercased().hasPrefix(predicate.lowercased()) : false)) }
    }
    
    func wipeAllData() {
        let persistentContainer = PersistenceController.shared.container
        let url: URL = {
            let url = FileManager.default.urls(
                for: .applicationSupportDirectory,
                in: .userDomainMask
            )[0].appendingPathComponent("\("BudgetBar").\("sqlite")")
            assert(FileManager.default.fileExists(atPath: url.path))

            return url
        }()
        // destroy existing store
        try! persistentContainer.persistentStoreCoordinator.destroyPersistentStore(at: url, ofType: "sqlite", options: nil)
        
        // load new store
        persistentContainer.loadPersistentStores(completionHandler: { nsPersistentStoreDescription, error in
            guard let error = error else {
                return
            }
            fatalError(error.localizedDescription)
        })
        
        try? months = context.fetch(monthsRequest)
        initializeMonths()
        
        try? accounts = context.fetch(accountsRequest)
        try? transactions = context.fetch(transactionsRequest)
        try? categoriesPerMonth = context.fetch(categoriesRequest)
        
        setCurrentMonth()
    }
}

// extension allowing to break a Date() object into seperate Int components for day/month/year
extension Date {
    func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
        return calendar.dateComponents(Set(components), from: self)
    }

    func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: self)
    }
}
