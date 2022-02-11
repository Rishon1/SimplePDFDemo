//
//  PieChartsViewController.swift
//  FIHSimplePDF
//
//  Created by FIH on 2022/2/10.
//

import UIKit
import Charts

class PieChartsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Pie Charts"
        self.view.backgroundColor = .white
        
        let datas = [1.222131222,74.0112311231,35.2311]
        let titles = ["Pie1","Pie2","Pie3"]
        var array:[PieChartDataEntry] = []
        for (i, item) in datas.enumerated() {
            let entry = PieChartDataEntry(value: item, label: titles[i])
            entry.x = Double(i)
            array.append(entry)
        }
        
        let pieSet = PieChartDataSet(entries: array, label: "")
        //颜色(每个扇形区域可以单独设置颜色)
        pieSet.colors = [.red, .blue, .cyan]
        pieSet.entryLabelFont = .systemFont(ofSize:15)
        pieSet.entryLabelColor = .white
        pieSet.drawIconsEnabled = false
        pieSet.drawValuesEnabled = true
        pieSet.valueFont = .systemFont(ofSize: 15)
        pieSet.valueColors = [.black, .black, .black]
        pieSet.yValuePosition = .outsideSlice
        pieSet.valueLineColor = .black
        //指示折线样式
        pieSet.valueLinePart1OffsetPercentage = 0.8 //折线中第一段起始位置相对于区块的偏移量, 数值越大, 折线距离区块越远
        pieSet.valueLinePart1Length = 0.3 //折线中第一段长度占比
        pieSet.valueLinePart2Length = 0.4 //折线中第二段长度最大占比
        pieSet.valueLineWidth = 1 //折线的粗细
        
        //格式化
//        let pFormatter = NumberFormatter()
//        pFormatter.numberStyle = .percent
//        pFormatter.maximumFractionDigits = 1
//        pFormatter.multiplier = 1.0
//        pFormatter.percentSymbol = " %"
//        pieSet.valueFormatter = DefaultValueFormatter(formatter: pFormatter)
        let pFormatter = VDPieChartAxisValueFormatter(datas as NSArray, titles as NSArray)
        pieSet.valueFormatter = pFormatter
        
        //相邻区块之间的间距
        pieSet.sliceSpace = 0
        //扇形区域放大范围
        pieSet.selectionShift = 8
        
        //动画开始的角度
        let data = PieChartData(dataSet: pieSet)
        pieChartView.data = data
        //动画开启
        pieChartView.animate(xAxisDuration: 2.0, easingOption: .easeOutExpo)
        
        pieChartView.delegate = self 
        self.view.addSubview(pieChartView)
    }
    
    lazy var pieChartView: PieChartView = {
        let _pieChartView = PieChartView.init(frame: CGRect.init(x: 0, y: 100, width: 400, height: 350))
        _pieChartView.backgroundColor = UIColor(red: 242/255.0, green: 242/255.0, blue: 242/255.0, alpha: 1.0)
        _pieChartView.setExtraOffsets(left: 10, top: 10, right: 30, bottom: 0)//设置这块饼的位置
        _pieChartView.chartDescription?.enabled = false
        _pieChartView.chartDescription?.text = "饼状图示例"//描述文字
        _pieChartView.chartDescription?.font = .systemFont(ofSize: 12.0)//字体
        _pieChartView.chartDescription?.textColor = .black//颜色
        
        _pieChartView.usePercentValuesEnabled = true//转化为百分比
        _pieChartView.dragDecelerationEnabled = false//我把拖拽效果关了
        _pieChartView.drawEntryLabelsEnabled = true//显示区块文本
        _pieChartView.entryLabelFont = .systemFont(ofSize: 10)//区块文本的字体
        _pieChartView.entryLabelColor = .white
        _pieChartView.drawSlicesUnderHoleEnabled = true
        
        //空心饼状图样式  hole 洞，空心
        _pieChartView.drawHoleEnabled = true//这个饼是空心的
        _pieChartView.holeRadiusPercent = 0.382//空心半径黄金比例
        _pieChartView.holeColor = .white//空心颜色设置为白色
        _pieChartView.transparentCircleRadiusPercent = 0.0//半透明空心半径
        
        _pieChartView.drawCenterTextEnabled = false//显示中心文本
        _pieChartView.centerText = "饼状图"//设置中心文本,你也可以设置富文本`centerAttributedText`
        
        //图例样式设置
        _pieChartView.legend.maxSizePercent = 1//图例的占比
        _pieChartView.legend.form = .circle//图示：原、方、线
        _pieChartView.legend.formSize = 8//图示大小
        _pieChartView.legend.formToTextSpace = 4//文本间隔
        _pieChartView.legend.font = .systemFont(ofSize: 8)
        _pieChartView.legend.textColor = .gray
        _pieChartView.legend.horizontalAlignment = .center
        
        _pieChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0, easingOption: .easeInBack)
        
        return _pieChartView
    }()

}

extension PieChartsViewController: ChartViewDelegate {
    
    func showMarkerView(_ pieEntry: PieChartDataEntry) {
        let marker = MarkerView(frame: CGRect.init(x: 20, y: 20, width: 60, height: 40))
        marker.chartView = pieChartView
        marker.backgroundColor = .white.withAlphaComponent(0.7)
        marker.layer.borderWidth = 1
        marker.layer.borderColor = (pieChartView.data?.dataSets.first?.colors[Int(pieEntry.x)] ?? .white).cgColor
        marker.layer.shadowColor = UIColor.black.cgColor
        //阴影偏移量
        marker.layer.shadowOffset=CGSize(width:0, height:1)
        //定义view的阴影宽度，模糊计算的半径
        marker.layer.shadowRadius = 6
        //定义view的阴影透明度，注意:如果view没有设置背景色阴影也是不会显示的
        marker.layer.shadowOpacity = 0.9
        
        let label = UILabel(frame: CGRect.init(x: 5, y: 0, width: marker.bounds.width - 10, height: 20))
        label.text = pieEntry.label
        label.textColor = .black
        label.font = .systemFont(ofSize: 12)
        label.textAlignment = .left
        
        marker.addSubview(label)
        
        let circleView = UIView(frame: CGRect(x: 5, y: 28, width: 5, height: 5))
        circleView.layer.cornerRadius = 2.5
        circleView.backgroundColor = (pieChartView.data?.dataSets.first?.colors[Int(pieEntry.x)] ?? .black)
        marker.addSubview(circleView)
        
        let valuesLabel = UILabel(frame: CGRect.init(x: 12, y: 20, width: marker.bounds.width - 10, height: 20))
        let str = "時間:\(pieEntry.value)"
        valuesLabel.text = str
        valuesLabel.textColor = .black
        valuesLabel.font = .systemFont(ofSize: 12)
        valuesLabel.textAlignment = .left
        let size = (str as NSString).boundingRect(with: CGSize(width: 200, height: 20), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12)], context: nil)
        label.frame = CGRect(origin: label.frame.origin, size: CGSize(width: size.width + 5, height: 20))
        valuesLabel.frame = CGRect(origin: valuesLabel.frame.origin, size: CGSize(width: size.width + 12 + 5, height: 20))
        marker.frame = CGRect(origin: marker.frame.origin, size: CGSize(width: size.width + 12 + 5, height: 40))
        
        marker.addSubview(valuesLabel)
        
        pieChartView.marker = marker
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        
        if entry is PieChartDataEntry {
            let pieEntry = entry as! PieChartDataEntry
            self.showMarkerView(pieEntry)
        }
        
    }
}


class VDPieChartAxisValueFormatter: NSObject,IValueFormatter {
    
    var values:NSArray?
    var titles:NSArray?
    override init() {
        super.init()
    }
    init(_ values: NSArray, _ titles: NSArray) {
        super.init()
        self.values = values
        self.titles = titles
    }
    
    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        NSLog("___________\(dataSetIndex)")
        NSLog("+++++++++++\(value)")
        if entry is PieChartDataEntry {
            let pieEntry = entry as! PieChartDataEntry
            if values == nil{
                return "\(value)"
            }
            
            if dataSetIndex < 0 || dataSetIndex > values!.count - 1 {
                return ""
            }
            
            var v = 0.0
            values?.forEach({ val in
                v += val as! Double
            })
            
            let divisor = pow(10.0, Double(1))
            return "\(round(pieEntry.value/v * 100 * divisor) / divisor) %"
        }
        return ""
    }
}
