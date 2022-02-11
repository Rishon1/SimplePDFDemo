//
//  LineChartsViewController.swift
//  FIHSimplePDF
//
//  Created by FIH on 2022/2/9.
//

import UIKit
import Charts

class LineChartsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Line Chart"
        self.view.backgroundColor = .white
        
        let xValues = ["x1", "x2", "x3", "x4", "x1", "x2", "x3", "x4"]
              
        
        let yDataArray1:[Float] = [-1.0, 20.0, 30.0, -1.0, -1.0, 20.0, 30.0, -1.0]
        //86,216,254
        let lineChartView = BHSChartsUtils.drawLineChartView(frame: CGRect.init(x: 0, y: 80, width: 300, height: 300), backgroundColor: UIColor(red: 242/255.0, green: 242/255.0, blue: 242/255.0, alpha: 1), yData: yDataArray1, xData: xValues, legendTitle: "体重")
        self.view.addSubview(lineChartView)
        
//        self.view.addSubview(lineChartView)
//        self.drawLineChart()
    }
    
    func addLimitLine(_ value:Double, _ desc:String) {
        let limitLine = ChartLimitLine.init(limit: value, label: desc)
        //线
        limitLine.lineWidth = 1
        limitLine.lineColor = UIColor.red
        limitLine.lineDashLengths = [2.0,2.0]
        //文字
        limitLine.valueFont = UIFont.systemFont(ofSize: 10.0)
        limitLine.valueTextColor = UIColor.black
        limitLine.labelPosition = .bottomRight
        lineChartView.leftAxis.addLimitLine(limitLine)
    }
    
    func drawLineChart(){
        let xValues = ["x1","x2","x3","x4","x5","x6","x7", "x8", "x9", "x10"]
        lineChartView.xAxis.valueFormatter = VDChartAxisValueFormatter.init(xValues as NSArray)
        lineChartView.leftAxis.valueFormatter = VDChartAxisValueFormatter.init()
        
        var yDataArray1 = [ChartDataEntry]()
        for i in 0...xValues.count-1 {
            let y = arc4random()%500
            let entry = ChartDataEntry.init(x: Double(i), y: Double(y))
            
            yDataArray1.append(entry)
        }
        let set1 = LineChartDataSet(entries: yDataArray1, label: "体重")
        set1.colors = [UIColor.orange]
        set1.circleColors = [UIColor.orange]
        set1.drawValuesEnabled = false
        set1.circleHoleRadius = 0.0
        set1.circleRadius = 5
        set1.lineWidth = 1.0
        
        let data = LineChartData(dataSets: [set1])
        
        lineChartView.data = data
        lineChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0, easingOption: .linear)
    }
    
    lazy var lineChartView:LineChartView = {
        let _lineChartView = LineChartView(frame: CGRect.init(x: 0, y: 80, width: 300, height: 300))
        _lineChartView.backgroundColor = UIColor(red: 242/255.0, green: 242/255.0, blue: 242/255.0, alpha: 1)
        _lineChartView.doubleTapToZoomEnabled = false
        _lineChartView.scaleXEnabled = false
        _lineChartView.scaleYEnabled = false
        _lineChartView.legend.enabled = true //是否显示 图例 举例
        _lineChartView.legend.form = .circle
        _lineChartView.legend.horizontalAlignment = .center
        _lineChartView.highlightPerTapEnabled = false//高亮点击
        _lineChartView.highlightPerDragEnabled = false//高亮拖拽
        _lineChartView.chartDescription?.text = ""//设置为""隐藏描述文字
        
        _lineChartView.noDataText = "暂无数据"
        _lineChartView.noDataTextColor = UIColor.gray
        _lineChartView.noDataFont = UIFont.boldSystemFont(ofSize: 14)
        
        //y轴
        _lineChartView.rightAxis.enabled = false
        let leftAxis = _lineChartView.leftAxis
        leftAxis.labelCount = 10
        leftAxis.forceLabelsEnabled = false
        leftAxis.axisLineColor = .white
        leftAxis.labelTextColor = UIColor.black
        leftAxis.labelFont = UIFont.systemFont(ofSize: 10)
        leftAxis.labelPosition = .outsideChart
        leftAxis.gridAntialiasEnabled = false//抗锯齿
        leftAxis.drawGridLinesEnabled = false
//        leftAxis.axisMaximum = 500//最大值
        leftAxis.axisMinimum = 0
        leftAxis.xOffset = 10
        leftAxis.labelCount = 11//多少等分
        
        //x轴
        let xAxis = _lineChartView.xAxis
        xAxis.granularityEnabled = true
        xAxis.labelTextColor = UIColor.black
        xAxis.labelFont = UIFont.systemFont(ofSize: 10.0)
        xAxis.labelPosition = .bottom
        xAxis.gridColor = .gray  //网格线颜色
        xAxis.gridLineWidth = 1.0  //网格线宽
        xAxis.axisLineColor = .clear
        xAxis.labelCount = 10
        return _lineChartView
    }()
}
