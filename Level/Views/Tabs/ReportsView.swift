//
//  ReportsView.swift
//  Level
//
//  Created by Patryk Szczypkowski on 08/02/2022.
//

import Charts
import SwiftUI

struct ReportsView: View {
    @EnvironmentObject var viewModel: LevelViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                LineChart(entries: getSpendingsEntries())
            }.frame(height: 400, alignment: .center)
            .navigationTitle("Reports")
        }
        .tabItem {
            Label("Reports", systemImage: "chart.line.uptrend.xyaxis")
        }
    }
    
    func getSpendingsEntries() -> [ChartDataEntry] {
        var entries: [ChartDataEntry] = []
        var counter = 0.0
        for month in viewModel.months {
            if (month.categories!.count != 0) {
                counter += 1
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
            }
        }
        return entries
    }
}

struct LineChart: UIViewRepresentable {
    var entries: [ChartDataEntry]
    
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
        
        chart.data = addData()
        
        chart.xAxis.valueFormatter = IndexAxisValueFormatter(values: ["Jan", "Feb", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"])
        
        return chart
    }
    
    func updateUIView(_ uiView: LineChartView, context: Context) {
        uiView.data = addData()
    }
    
    func addData() -> LineChartData{
        let dataSet = LineChartDataSet(entries: entries, label: "Spendings")
        
        // Data points styling
        dataSet.colors = [NSUIColor.green]
        dataSet.circleColors = [NSUIColor.green]
        
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
