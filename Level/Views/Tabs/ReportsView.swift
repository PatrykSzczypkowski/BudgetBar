//
//  ReportsView.swift
//  Level
//
//  Created by Patryk Szczypkowski on 08/02/2022.
//

import Charts
import SwiftUI

struct ReportsView: View {
    @EnvironmentObject var manager: LevelManager
    
    var body: some View {
        NavigationView {
            List {
                if (showReports()) {
                    VStack {
                        Text("Spending").font(.title2)
                        LineChart(entries: getSpending().entries, months: getSpending().months, label: "Spending", color: UIColor.red)
                            .frame(height: 250, alignment: .center)
                    }
                    VStack {
                        Text("Income").font(.title2)
                        LineChart(entries: getIncome().entries, months: getIncome().months, label: "Income", color: UIColor.green)
                            .frame(height: 250, alignment: .center)
                    }
                }
                // show if there is less than 3 months worth of data available for reports
                else {
                    Text("You need at least 3 months of data for the reports to show.")
                }
            }
            .navigationTitle("Reports")
            .listStyle(.plain)
        }
        .tabItem {
            Label("Reports", systemImage: "chart.line.uptrend.xyaxis")
        }
    }
    
    // function that checks if there is at least "minimumMonths" worth of data to show reports
    func showReports() -> Bool {
        let minimumMonths = 3
        let indexOfCurrentMonth = manager.months.firstIndex(of: manager.getMonthForDate(date: Date()))
        
        var startIndex = 0
        var counter = 0
        
        if (indexOfCurrentMonth != nil) {
            startIndex = max(indexOfCurrentMonth! - 6, 0)
        }
        let relevantMonths = Array(manager.months[startIndex...(indexOfCurrentMonth ?? 0)])
        
        if (relevantMonths.count < minimumMonths) { return false }
                
        for month in relevantMonths {
            if (month.transactions!.count > 0) {
                counter += 1
            }
        }
        
        if (counter < minimumMonths) { return false }
        
        return true
    }
    
    func getSpending() -> (entries: [ChartDataEntry], months: [String]) {
        var entries: [ChartDataEntry] = []
        var months: [String] = []
        var counter = 0.0
        
        var relevantMonths = manager.months
        var startIndex = 0
        let indexOfCurrentMonth = relevantMonths.firstIndex(of: manager.getMonthForDate(date: Date()))
        
        if (indexOfCurrentMonth != nil) {
            startIndex = max(indexOfCurrentMonth! - 6, 0)
        }
        
        relevantMonths = Array(relevantMonths[startIndex...(indexOfCurrentMonth ?? 0)])
        
        for month in relevantMonths {
            if (month.categories!.count != 0) {
                var monthlySpendings: Decimal = 0.0
                
                for transaction in month.transactions!.allObjects as! [Transaction] {
                    if (!transaction.inflow) {
                        monthlySpendings += transaction.amount!.decimalValue
                    }
                }
                entries.append(ChartDataEntry(x: counter, y: (monthlySpendings as NSDecimalNumber).doubleValue))
                months.append(DateFormatter().shortStandaloneMonthSymbols[Int(month.month) - 1])
                
                counter += 1
            }
        }
        return (entries, months)
    }
    
    func getIncome() -> (entries: [ChartDataEntry], months: [String]) {
        var entries: [ChartDataEntry] = []
        var months: [String] = []
        var counter = 0.0
        
        var relevantMonths = manager.months
        var startIndex = 0
        let indexOfCurrentMonth = relevantMonths.firstIndex(of: manager.getMonthForDate(date: Date()))
        
        if (indexOfCurrentMonth != nil) {
            startIndex = max(indexOfCurrentMonth! - 6, 0)
        }
        
        relevantMonths = Array(relevantMonths[startIndex...(indexOfCurrentMonth ?? 0)])
        
        for month in relevantMonths {
            if (month.transactions!.count != 0) {
                var monthlyIncome: Decimal = 0.0
                
                for transaction in month.transactions!.allObjects as! [Transaction] {
                    if (transaction.inflow) {
                        monthlyIncome += transaction.amount!.decimalValue
                    }
                }
                entries.append(ChartDataEntry(x: counter, y: (monthlyIncome as NSDecimalNumber).doubleValue))
                months.append(DateFormatter().shortStandaloneMonthSymbols[Int(month.month) - 1])
                
                counter += 1
            }
        }
        return (entries, months)
    }
}

struct LineChart: UIViewRepresentable {
    var entries: [ChartDataEntry]
    var months: [String]
    var label: String
    var color: UIColor
    
    func makeUIView(context: Context) -> LineChartView {
        let chart = LineChartView()
        
        // Y-Axis styling
        chart.leftAxis.axisMinimum = 0
        chart.rightAxis.enabled = false
        
        // X-Axis styling
        chart.xAxis.axisMinimum = 0
        chart.xAxis.labelPosition = XAxis.LabelPosition.bottom
        chart.xAxis.drawGridLinesEnabled = false
        chart.xAxis.granularity = 1.0
        chart.xAxis.valueFormatter = IndexAxisValueFormatter(values: months)
        
        chart.doubleTapToZoomEnabled = false
        chart.setScaleEnabled(false)
        chart.pinchZoomEnabled = false
        chart.legend.enabled = false
        
        chart.data = addData()
        
        return chart
    }
    
    func updateUIView(_ uiView: LineChartView, context: Context) {
        uiView.data = addData()
    }
    
    func addData() -> LineChartData{
        let dataSet = LineChartDataSet(entries: entries, label: label)
        
        // Data points styling
        dataSet.colors = [color]
        dataSet.circleColors = [color]
        
        dataSet.valueFont = NSUIFont.systemFont(ofSize: 10)
        dataSet.drawCircleHoleEnabled = false
        dataSet.circleRadius = 2
        dataSet.lineWidth = 2
        dataSet.setDrawHighlightIndicators(false)
        
        return LineChartData(dataSet: dataSet)
    }
    
    typealias UIViewType = LineChartView
}

struct ReportsView_Previews: PreviewProvider {
    static var previews: some View {
        let persistenceController = PersistenceController.shared
        let manager = LevelManager()
        
        ReportsView()
        .preferredColorScheme(.dark)
        .environment(\.managedObjectContext, persistenceController.container.viewContext)
        .environmentObject(manager)
    }
}
