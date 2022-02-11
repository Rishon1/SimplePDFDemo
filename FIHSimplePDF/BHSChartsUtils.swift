//
//  BHSChartsUtils.swift
//  FIHSimplePDF
//
//  Created by FIH on 2022/2/9.
//

import Foundation
import Charts
import UIKit

class BHSChartsUtils: NSObject {
    
    fileprivate static func createLineChartView(_ frame: CGRect, backgroundColor: UIColor) -> LineChartView {
        let _lineChartView = LineChartView(frame: frame)
        _lineChartView.backgroundColor = backgroundColor
        _lineChartView.doubleTapToZoomEnabled = false
        _lineChartView.scaleXEnabled = false
        _lineChartView.scaleYEnabled = false
        //图例相关设置
        _lineChartView.legend.enabled = true //是否显示 图例 举例
        _lineChartView.legend.form = .circle
        _lineChartView.legend.horizontalAlignment = .center
        _lineChartView.highlightPerTapEnabled = false//高亮点击
        _lineChartView.highlightPerDragEnabled = false//高亮拖拽
        _lineChartView.chartDescription?.text = ""//设置为""隐藏描述文字
        
        _lineChartView.noDataText = "暂无数据"
        _lineChartView.noDataTextColor = UIColor.gray
        _lineChartView.noDataFont = UIFont.boldSystemFont(ofSize: 14)
        return _lineChartView
    }
    
    public static func drawLineChartView(frame: CGRect, backgroundColor: UIColor, yData:[Float], xData:[String], legendTitle: String) -> LineChartView {
        
        let _lineChartView = createLineChartView(frame,backgroundColor: backgroundColor)
        
        //y轴
        _lineChartView.rightAxis.enabled = false
        let leftAxis = _lineChartView.leftAxis
        leftAxis.forceLabelsEnabled = false
        leftAxis.axisLineColor = .white
        leftAxis.labelTextColor = UIColor.black
        leftAxis.labelFont = UIFont.systemFont(ofSize: 14)
        leftAxis.labelPosition = .outsideChart
        leftAxis.gridAntialiasEnabled = false//抗锯齿
        leftAxis.drawGridLinesEnabled = false
//        leftAxis.axisMaximum = 500//最大值
        leftAxis.axisMinimum = 0
        leftAxis.labelCount = yData.count + 1//多少等分
        
        //x轴
        let xAxis = _lineChartView.xAxis
        xAxis.granularityEnabled = true
        xAxis.labelTextColor = UIColor.black
        xAxis.labelFont = UIFont.systemFont(ofSize: 14.0)
        xAxis.labelPosition = .bottom
        xAxis.gridColor = .gray  //网格线颜色
        xAxis.gridLineWidth = 1.0  //网格线宽
        xAxis.axisLineColor = .clear
        xAxis.labelCount = xData.count
        _lineChartView.xAxis.valueFormatter = VDChartAxisValueFormatter.init(xData as NSArray)
        _lineChartView.leftAxis.valueFormatter = VDChartAxisValueFormatter.init()
        
        var yDataArray1 = [ChartDataEntry]()
        for (i, item) in yData.enumerated() {
            if item >= 0.0 {
                let entry = ChartDataEntry(x: Double(i), y: Double(item))
                yDataArray1.append(entry)
            }
        }
        let set1 = LineChartDataSet(entries: yDataArray1, label: legendTitle)
        set1.colors = [UIColor(red: 86/255.0, green: 216/255.0, blue: 254/255.0, alpha: 1.0)]
        set1.circleColors = [UIColor(red: 86/255.0, green: 216/255.0, blue: 254/255.0, alpha: 1.0)]
        set1.drawValuesEnabled = false
        set1.circleHoleRadius = 0.0
        set1.circleRadius = 5
        set1.lineWidth = 1.0
        
        let data = LineChartData(dataSets: [set1])
        
        _lineChartView.data = data
        
        _lineChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0, easingOption: .linear)
        
        return _lineChartView
    }
    
}

class VDChartAxisValueFormatter: NSObject,IAxisValueFormatter {
    var values:NSArray?
    override init() {
        super.init()
    }
    init(_ values: NSArray) {
        super.init()
        self.values = values
    }
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        
        if values == nil {
            return "\(value)"
        }
        
        return values![Int(value) % values!.count] as! String
    }
}
