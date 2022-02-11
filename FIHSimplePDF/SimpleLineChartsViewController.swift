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
        let data = [
            //(x: 0, y: 0),
            (x: 3, y: 2.5),
            (x: 6, y: 10),
            (x: 9, y: 2.3),
            (x: 15, y: 3)
        ]
        let series = ChartSeries(data: data)
        series.color = .blue
        charts.yLabels = [0.0, 3.0, 6.0, 9.0, 12.0]
        //charts.xLabels = [3, 0, 9, 6, 12, 15, 18]
        charts.xLabelsData = ["周日", "周一", "周二", "周三", "周四", "周五", "周六"]
        charts.xLabelsFormatter = {String(Int(round($1)))}
        charts.yLabelsFormatter = {String(Float(round($1)))}
        
        charts.xLabelsTextAlignment(.left)
            .showYLabelsAndGrid(true)
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
        NSLog("=======================\(data)")
    }
}
