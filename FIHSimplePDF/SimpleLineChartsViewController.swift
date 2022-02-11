//
//  SimpleLineChartsViewController.swift
//  FIHSimplePDF
//
//  Created by FIH on 2022/2/11.
//

import UIKit

class SimpleLineChartsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Simple Line Chart"
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
        series.color = .blue
        charts.yLabels = [0.0, 3.0, 6.0, 9.0, 12.0]
        charts.xLabels = [0, 1, 2, 3, 4, 5, 6]
        let xLabelsData = ["周日", "周一", "周二", "周三", "周四", "周五", "周六"]
        charts.xLabelsFormatter = { (labelIndex: Int, labelValue: Double) -> String in
            return xLabelsData[labelIndex]
        }
        charts.yLabelsFormatter = {String(Float(round($1)))}
        
        charts.xLabelsTextAlignment(.left)
            .showYLabelsAndGrid(true)
            .xLineEndSpace(20.0)
            .yLineStartSpace(true)
            .xLabelShowMiddle(true)
            .yLabelShowMiddle(true)
            .setPointViewSize(CGSize(width: 16, height: 16))
            .showYGridLine(false)
            .xLabelsSkipLast(false)
            .hideHighlightLineOnTouchEnd(true)
            .hideAroundLine()
            .hideTouchLine(true)
            .showPointView(true)
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

extension SimpleLineChartsViewController: ChartDelegate {
    
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
    
    func pointViwDidClick(_ data: (x: Double, y: Double)) {
        //NSLog("=======================\(data)")
        NSLog("=========\(xLabelList[Int(data.x)])========value:\(data.y)")
        
        self.bottomLabel.text = "\(xLabelList[Int(data.x)])========value:\(data.y)"
    }
}
