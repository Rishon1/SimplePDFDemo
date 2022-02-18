//
//  ColumnViewController.swift
//  FIHSimplePDF
//
//  Created by FIH on 2022/2/17.
//

import UIKit

class ColumnViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "柱状图"
        self.view.backgroundColor = .white
        
        self.view.addSubview(charts)
        self.view.addSubview(bottomLabel)
        let data = [
            //(x: 0, y: 0),
            (x: 1, y: 3.0),
            (x: 2, y: 10),
            (x: 4, y: 3.0),
            (x: 6, y: 6.0)
        ]
        let series = ChartSeries(data: data)
        // 86,216,254
        series.color = UIColor(red: 86/255.0, green: 216/255.0, blue: 254/255.0, alpha: 1.0)
        series.area = true
        charts.yLabels = [0.0, 3.0, 6.0, 9.0, 12.0]
        charts.xLabels = [0, 1, 2, 3, 4, 5, 6, 7]
        let xLabelsData = ["14時", "15時", "16時", "17時", "18時", "19時", "20時", "21時"]
        charts.xLabelsFormatter = { (labelIndex: Int, labelValue: Double) -> String in
            return xLabelsData[labelIndex]
        }
        charts.yLabelsFormatter = {String(Float(round($1)))}
        
        charts.xLabelsTextAlignment(.center)
            .chartType(.column)
            .showYLabelsAndGrid(true)
            .xLineEndSpace(20.0)
            .yLineStartSpace(true)
            .xLabelShowMiddle(true)
            .yLabelShowMiddle(true)
            .setPointViewSize(CGSize(width: 16, height: 16))
            .showYGridLine(false)
            .xLabelsSkipLast(false)
            .hideHighlightLineOnTouchEnd(true)
            .isHiddenFirstYLabel(false)
            .hideAroundLine(bottom: false)
            .hideTouchLine(true)
            .showPointView(true)
            .columnSelectColor(UIColor(red: 86/255.0, green: 244/255.0, blue: 254/255.0, alpha: 1.0))
            .add(series)
    }
    
    
    lazy var charts: Chart = {
        let chart = Chart(frame: CGRect(x: 5, y: 100, width: 360, height: 300))
        chart.delegate = self
        return chart
    }()
    
    lazy var xLabelList: [String] = {
        let xLabelsData = ["2022-02-06", "2022-02-07", "2022-02-08", "2022-02-09", "2022-02-10", "2022-02-11", "2022-02-12"]
        return xLabelsData
    }()
    
    
    lazy var bottomLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 5, y: 420, width: 360, height: 20))
        return label
    }()


}


extension ColumnViewController: ChartDelegate {
    func pointViwDidClick(_ data: (x: Double, y: Double), xLabelsData: [String], seriesIndex: Int) {
        //NSLog("=======================\(data)")
        NSLog("=========\(Int(data.x))========value:\(data.y)")
        
        self.bottomLabel.text = "\(data.x)========value:\(data.y)"
    }
    
    
    // Chart delegate
    func didTouchChart(_ chart: Chart, indexes: Array<Int?>, x: Double, left: CGFloat) {
        for (seriesIndex, dataIndex) in indexes.enumerated() {
            if let value = chart.valueForSeries(seriesIndex, atIndex: dataIndex) {
                print("Touched series: \(seriesIndex): data index: \(dataIndex!); series value: \(value); x-axis value: \(x) (from left: \(left))")
            }
        }
    }
    
    func didFinishTouchingChart(_ chart: Chart) {
        
    }
    
    func didEndTouchingChart(_ chart: Chart) {
        
    }
}
