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
                .navigationTitle("Reports")
            }
            .listStyle(.plain)
        }
        .tabItem {
            Label("Reports", systemImage: "chart.line.uptrend.xyaxis")
        }
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
                
                for category in month.categories!.array as! [Category] {
                    for transaction in category.transactions!.array as! [Transaction] {
                        if (!transaction.inflow) {
                            monthlySpendings += transaction.amount!.decimalValue
                        }
                    }
                }
                print("\(month.month).\(month.year): \(monthlySpendings)")
                //            let x = "\(DateFormatter().standaloneMonthSymbols[Int(month.month) - 1]) \(month.year)"
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
            if (month.categories!.count != 0) {
                var monthlyIncome: Decimal = 0.0
                
                for category in month.categories!.array as! [Category] {
                    for transaction in category.transactions!.array as! [Transaction] {
                        if (transaction.inflow) {
                            monthlyIncome += transaction.amount!.decimalValue
                        }
                    }
                }
                print("\(month.month).\(month.year): \(monthlyIncome)")
                //            let x = "\(DateFormatter().standaloneMonthSymbols[Int(month.month) - 1]) \(month.year)"
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
        
        chart.doubleTapToZoomEnabled = false
        chart.setScaleEnabled(false)
        chart.pinchZoomEnabled = false
        chart.legend.enabled = false
        
        chart.data = addData()
        chart.xAxis.valueFormatter = IndexAxisValueFormatter(values: months)
        print(months)
        
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
        
        return LineChartData(dataSet: dataSet)
    }
    
    typealias UIViewType = LineChartView
}

//struct ReportsView_Previews: PreviewProvider {
//    static var previews: some View {
//        ReportsView()
//    }
//}
