//
//  PieChartViewController.swift
//  FIHSimplePDF
//
//  Created by FIH on 2022/2/17.
//

import UIKit

class PieChartViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Simple Pie Chart"
        self.view.backgroundColor = .white
        
        self.view.addSubview(charts)
        self.view.addSubview(bottomLabel)
        
        let data = [10,20,30,60]
        var datas:[(x: Double, y: Double)] = []
        for (index, item) in data.enumerated() {
            datas.append((x: Double(index), y: Double(item)))
        }
        let series = ChartSeries(data: datas)
        series.pieColors = [.red, .yellow, .purple, .blue, .black]
        series.pieLabelColor = .black
        charts.xLabelsData = ["BG", "BW", "跑步", "测试22222"]
        
        charts.chartType(.pie)
            .radius((view.bounds.width - 10) * 0.3)
            .drawHoleEnabled(true)
            .holeRadiusPercent(0.6)
            .holeColor(.white)
            .drawCenterTextEnabled(true)
            .pieLabelTextFont(.systemFont(ofSize: 10))
            .centerText("50\n分鐘", textColor: .black)
            .usePercentValuesEnabled(true)
            .animateType(.easeInEaseOut)
            .add(series)
    }

    lazy var charts: Chart = {
        let chart = Chart(frame: CGRect(x: 5, y: 100, width: view.bounds.width - 10, height: 300))
        chart.delegate = self
        return chart
    }()
    
    lazy var bottomLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 5, y: 420, width: 360, height: 20))
        return label
    }()
    
}

extension PieChartViewController: ChartDelegate {
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
