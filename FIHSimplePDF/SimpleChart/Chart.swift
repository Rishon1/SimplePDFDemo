//
//  Chart.swift
//
//
//  Created by bo.rong on 2022/2/14.
//  Copyright © 2022 FIH. All rights reserved.
//
    

import UIKit

public protocol ChartDelegate: NSObjectProtocol {

    /**
    Tells the delegate that the specified chart has been touched.

    - parameter chart: The chart that has been touched.
    - parameter indexes: Each element of this array contains the index of the data that has been touched, one for each
      series. If the series hasn't been touched, its index will be nil.
    - parameter x: The value on the x-axis that has been touched.
    - parameter left: The distance from the left side of the chart.

    */
    func didTouchChart(_ chart: Chart, indexes: [Int?], x: Double, left: CGFloat)

    /**
    Tells the delegate that the user finished touching the chart. The user will
    "finish" touching the chart only swiping left/right outside the chart.

    - parameter chart: The chart that has been touched.

    */
    func didFinishTouchingChart(_ chart: Chart)
    /**
     Tells the delegate that the user ended touching the chart. The user
     will "end" touching the chart whenever the touchesDidEnd method is
     being called.
     
     - parameter chart: The chart that has been touched.
     
     */
    func didEndTouchingChart(_ chart: Chart)
    
    
    /// 数据点位点击回传
    func pointViwDidClick(_ data: (x: Double, y: Double), xLabelsData:[String], seriesIndex: Int)
}

/**
Represent the x- and the y-axis values for each point in a chart series.
*/
typealias ChartPoint = (x: Double, y: Double)

/**
Set the a x-label orientation.
*/
public enum ChartLabelOrientation {
    case horizontal
    case vertical
}

/**
 set zhe chart type
 */
public enum ChartType {
    case line
    case column
    case pie
}


@IBDesignable
open class Chart: UIControl {

    // MARK: Options

    @IBInspectable
    open var identifier: String?

    /**
    Series to display in the chart.
    */
    open var series: [ChartSeries] = [] {
      didSet {
        DispatchQueue.main.async {
          self.setNeedsDisplay()
        }
      }
    }

    /**
    The values to display as labels on the x-axis. You can format these values  with the `xLabelFormatter` attribute.
    As default, it will display the values of the series which has the most data.
    */
    open var xLabels: [Double]?
    
    open var xLabelsData: [String]?

    /**
    Formatter for the labels on the x-axis. `index` represents the `xLabels` index, `value` its value.
    */
    open var xLabelsFormatter = { (labelIndex: Int, labelValue: Double) -> String in
        
        //String(xLabelsData?[labelIndex] ?? "")
        String(Int(labelValue))
    }

    /**
    Text alignment for the x-labels.
    */
    open var xLabelsTextAlignment: NSTextAlignment = .left

    /**
    Orientation for the x-labels.
    */
    open var xLabelsOrientation: ChartLabelOrientation = .horizontal

    /**
    Skip the last x-label. Setting this to false may make the label overflow the frame width.
    */
    open var xLabelsSkipLast: Bool = true

    /**
    Values to display as labels of the y-axis. If not specified, will display the lowest, the middle and the highest
    values.
    */
    open var yLabels: [Double]?

    /**
    Formatter for the labels on the y-axis.
    */
    open var yLabelsFormatter = { (labelIndex: Int, labelValue: Double) -> String in
        String(Int(labelValue))
    }

    /**
    Displays the y-axis labels on the right side of the chart.
    */
    open var yLabelsOnRightSide: Bool = false

    /**
    Font used for the labels.
    */
    open var labelFont: UIFont? = UIFont.systemFont(ofSize: 12)

    /**
    The color used for the labels.
    */
    @IBInspectable
    open var labelColor: UIColor = UIColor.black

    /**
    Color for the axes.
    */
    @IBInspectable
    open var axesColor: UIColor = UIColor.gray.withAlphaComponent(0.3)

    /**
    Color for the grid.
    */
    @IBInspectable
    open var gridColor: UIColor = UIColor.gray.withAlphaComponent(0.3)
    
    /**
     LineWidth for the grid.
     */
    open var gridLineWidth = 0.5
    
    /**
    Enable the lines for the labels on the x-axis
    */
    open var showXLabelsAndGrid: Bool = true
    /**
    Enable the lines for the labels on the y-axis
    */
    open var showYLabelsAndGrid: Bool = true

    /**
    Enable the lines for the labels on the y-axis
    */
    open var showYGridLine: Bool = true
    
    /**
    Height of the area at the bottom of the chart, containing the labels for the x-axis.
    */
    open var bottomInset: CGFloat = 20

    /**
    Height of the area at the top of the chart, acting a padding to make place for the top y-axis label.
    */
    open var topInset: CGFloat = 20

    /**
    Width of the chart's lines.
    */
    @IBInspectable
    open var lineWidth: CGFloat = 2

    /**
    Delegate for listening to Chart touch events.
    */
    weak open var delegate: ChartDelegate?

    /**
    Custom minimum value for the x-axis.
    */
    open var minX: Double?

    /**
    Custom minimum value for the y-axis.
    */
    open var minY: Double?

    /**
    Custom maximum value for the x-axis.
    */
    open var maxX: Double?

    /**
    Custom maximum value for the y-axis.
    */
    open var maxY: Double?

    /**
    Color for the highlight line.
    */
    open var highlightLineColor = UIColor.gray

    /**
    Width for the highlight line.
    */
    open var highlightLineWidth: CGFloat = 0.5

    /**
    Hide the highlight line when touch event ends, e.g. when stop swiping over the chart
    */
    open var hideHighlightLineOnTouchEnd = false

    /// hide  touch line
    open var hideTouchLine = false
    
    // MARK: Private variables
    /// 图表类型
    fileprivate var chartType: ChartType = .line
    
    fileprivate var yLabelMaxWidth = 0.0
    /// y 轴 文字是否与 竖线对齐
    fileprivate var yLabelShowMiddle = false
    /// x 轴 文字是否与 竖线对齐
    fileprivate var xLabelShowMiddle = false
    
    /// x轴 文字在 两条 竖线中间展示
    fileprivate var xLabelShowLinesMiddle = false

    /// x 轴竖线 底部偏移量
    fileprivate var xLineEndSpace = 0.0
    
    /// y 轴横线 左边偏移量
    fileprivate var yLineStartSpace = false
    
    /// 表格线条是否实线，默认 false ,  showYGridLine 为ture 时，虚线，设置此属性 可以改变为实线
    fileprivate var showSolidLine = false
        
    /// 表格x轴竖线间隔宽度（柱状图使用）
    fileprivate var columnWidthSpace = 0.0
    
    /// hide  top line
    fileprivate var hideTopLine = false
    /// hide  bottom line
    fileprivate var hideBottomLine = false
    /// hide  right line
    fileprivate var hideRightLine = false
    /// hide  left line
    fileprivate var hideLeftLine = false
    /**
    Alpha component for the area color.
    */
    fileprivate var areaAlphaComponent: CGFloat = 0.1
    
    /// 是否显示折线数据点
    fileprivate var showPointView = false
    /// 数据点 圆点的尺寸
    fileprivate var pointSize: CGSize = CGSize(width: 12.0, height: 12.0)

    /// x轴label是否旋转展示
    fileprivate var xLabelsTranform = false
    
    /// x轴是否添加点位, 默认添加
    fileprivate var xZeroLinePoint = true
    
    /// y 为 0时 是否显示 横线，默认显示
    fileprivate var yZeroLineShow = true
    
    /// y轴第一个刻度是否展示，默认隐藏
    fileprivate var isHiddenFirstYLabel = true
    
    /// 柱狀圖點擊後顏色
    fileprivate var columnSelectColor: UIColor = .blue
    
    /// 柱狀圖y軸最大label值， 設置完此屬性 可以不用設置yLabels
    fileprivate var yAxisMaxValue: Double? = 0.0
    /// x轴2个竖线直线存在的柱状图个数（用于计算柱状图宽度）,默认一半宽度
    fileprivate var singleSpaceColumCount: Int = 1
    
    fileprivate var pointViewArr: [ChartPointView] = []

    fileprivate var highlightShapeLayer: CAShapeLayer!
    fileprivate var layerStore: [CAShapeLayer] = []

    fileprivate var drawingHeight: CGFloat!
    fileprivate var drawingWidth: CGFloat!

    // Minimum and maximum values represented in the chart
    fileprivate var min: ChartPoint!
    fileprivate var max: ChartPoint!

    // Represent a set of points corresponding to a segment line on the chart.
    typealias ChartLineSegment = [ChartPoint]

    // 🔥🔥🔥🔥🔥🔥Pie 相关属性💧💧💧💧💧💧💧
    private var radius:CGFloat = 0
    private var centerPoint:CGPoint = .zero
    private var distance:CGFloat = 10
    
    private var usePercentValuesEnabled = true
    
    private var pieLabelTextFont:UIFont = .systemFont(ofSize: 11)
    /// 是否为空心圆
    private var drawHoleEnabled = false
    /// 空心半径黄金比例
    private var holeRadiusPercent = 0.5
    /// 空心圆的颜色
    private var holeColor: UIColor = .white
    
    /// 是否显示中心文字
    private var drawCenterTextEnabled = false
    /// 中心文案
    private var centerText: String = ""
    private var centerTextFont: UIFont = .systemFont(ofSize: 15)
    private var centerTextColor: UIColor = .black
    
    private var selectedLayer:CAShapeLayer?//选中的layer临时变量
    private var lineDistance:CGFloat = 10
    /// 動畫執行方式
    private var animateType: CAMediaTimingFunctionName = .easeInEaseOut
    
    
    // MARK: initializations

    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    convenience public init() {
        self.init(frame: .zero)
        commonInit()
    }

    private func commonInit() {
        backgroundColor = UIColor.clear
        contentMode = .redraw // redraw rects on bounds change
    }

    override open func draw(_ rect: CGRect) {
        #if TARGET_INTERFACE_BUILDER
            drawIBPlaceholder()
            #else
            drawChart()
        #endif
    }

    /**
    Adds a chart series.
    */
    open func add(_ series: ChartSeries) {
        self.series.append(series)
    }

    /**
    Adds multiple chart series.
    */
    open func add(_ series: [ChartSeries]) {
        for s in series {
            add(s)
        }
    }

    /**
    Remove the series at the specified index.
    */
    open func removeSeriesAt(_ index: Int) {
        series.remove(at: index)
    }

    /**
    Remove all the series.
    */
    open func removeAllSeries() {
        series = []
    }

    /**
    Return the value for the specified series at the given index.
    */
    open func valueForSeries(_ seriesIndex: Int, atIndex dataIndex: Int?) -> Double? {
        if dataIndex == nil { return nil }
        let series = self.series[seriesIndex] as ChartSeries
        return series.data[dataIndex!].y
    }

    fileprivate func drawIBPlaceholder() {
        let placeholder = UIView(frame: self.frame)
        placeholder.backgroundColor = UIColor(red: 0.93, green: 0.93, blue: 0.93, alpha: 1)
        let label = UILabel()
        label.text = "Chart"
        label.font = UIFont.systemFont(ofSize: 28)
        label.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
        label.sizeToFit()
        label.frame.origin.x += frame.width/2 - (label.frame.width / 2)
        label.frame.origin.y += frame.height/2 - (label.frame.height / 2)

        placeholder.addSubview(label)
        addSubview(placeholder)
    }

    fileprivate func drawChart() {
        
        if chartType == .pie {
            
            for view in self.subviews {
                view.removeFromSuperview()
            }
            for layer in layerStore {
                layer.removeFromSuperlayer()
            }
            layerStore.removeAll()
            
            //1.计算半径
            if bounds.width < radius*2 {
                self.radius = bounds.width/2
            }
            //2.计算中心点
            self.centerPoint = CGPoint(x: bounds.width/2, y: bounds.height/2)
            
            //3. 开始绘制
            if !self.series.isEmpty {
                drawPieChart()
            }
            
        }
        else {
            drawingHeight = bounds.height - bottomInset - topInset
            drawingWidth = bounds.width

            let minMax = getMinMax()
            min = minMax.min
            max = minMax.max

            highlightShapeLayer = nil

            // Remove things before drawing, e.g. when changing orientation

            for view in self.subviews {
                view.removeFromSuperview()
            }
            for layer in layerStore {
                layer.removeFromSuperlayer()
            }
            layerStore.removeAll()
            pointViewArr.removeAll()
            
            //先绘制 Y轴
            if showYLabelsAndGrid && (yLabels != nil || series.count > 0) {
                drawLabelsAndGridOnYAxis()
            }
            //绘制边框
            drawAxes()
            
            //绘制 x轴
            if showXLabelsAndGrid && (xLabels != nil || series.count > 0) {
                drawLabelsAndGridOnXAxis()
            }
            
            // Draw content
            for (index, series) in self.series.enumerated() {

                // Separate each line in multiple segments over and below the x axis
                let segments = Chart.segmentLine(series.data as ChartLineSegment, zeroLevel: series.colors.zeroLevel, xZeroLinePoint: xZeroLinePoint)

                segments.forEach({ segment in
                    let scaledXValues = scaleValuesOnXAxis( segment.map { $0.x } )
                    let scaledYValues = scaleValuesOnYAxis( segment.map { $0.y } )
                    
                    //柱状图
                    if chartType == .column {
                        drawColumn(scaledXValues, yValues: scaledYValues, seriesIndex: index)
                    }
                    else {
                        //默认折线图
                        if series.line {
                            drawLine(scaledXValues, yValues: scaledYValues, seriesIndex: index, pointType: series.pointType)
                        }
                        if series.area {
                            drawArea(scaledXValues, yValues: scaledYValues, seriesIndex: index)
                        }
                    }
                })
            }
        }

    }
}

// MARK: 🔥🔥🔥🔥🔥🔥Utilities💧💧💧💧💧💧💧
extension Chart {

    fileprivate func valueFromPointAtX(_ x: CGFloat) -> Double {
        let value = ((max.x-min.x) / Double(drawingWidth)) * Double(x) + min.x
        return value
    }

    fileprivate func valueFromPointAtY(_ y: CGFloat) -> Double {
        let value = ((max.y - min.y) / Double(drawingHeight)) * Double(y) + min.y
        return -value
    }

    fileprivate class func findClosestInValues(
        _ values: [Double],
        forValue value: Double
    ) -> (
            lowestValue: Double?,
            highestValue: Double?,
            lowestIndex: Int?,
            highestIndex: Int?
        ) {
        var lowestValue: Double?, highestValue: Double?, lowestIndex: Int?, highestIndex: Int?

        values.enumerated().forEach { (i, currentValue) in

            if currentValue <= value && (lowestValue == nil || lowestValue! < currentValue) {
                lowestValue = currentValue
                lowestIndex = i
            }
            if currentValue >= value && (highestValue == nil || highestValue! > currentValue) {
                highestValue = currentValue
                highestIndex = i
            }

        }
        return (
            lowestValue: lowestValue,
            highestValue: highestValue,
            lowestIndex: lowestIndex,
            highestIndex: highestIndex
        )
    }

    /**
    Segment a line in multiple lines when the line touches the x-axis, i.e. separating
    positive from negative values.
    */
    fileprivate class func segmentLine(_ line: ChartLineSegment, zeroLevel: Double, xZeroLinePoint: Bool) -> [ChartLineSegment] {
        var segments: [ChartLineSegment] = []
        var segment: ChartLineSegment = []

        line.enumerated().forEach { (i, point) in
            segment.append(point)
            if i < line.count - 1 {
                let nextPoint = line[i+1]
                if xZeroLinePoint && (point.y >= zeroLevel && nextPoint.y < zeroLevel || point.y < zeroLevel && nextPoint.y >= zeroLevel) {
                    // The segment intersects zeroLevel, close the segment with the intersection point
                    let closingPoint = Chart.intersectionWithLevel(point, and: nextPoint, level: zeroLevel)
                    segment.append(closingPoint)
                    segments.append(segment)
                    // Start a new segment
                    segment = [closingPoint]
                }
            } else {
                // End of the line
                segments.append(segment)
            }
        }
        return segments
    }

    /**
    Return the intersection of a line between two points and 'y = level' line
    */
    fileprivate class func intersectionWithLevel(_ p1: ChartPoint, and p2: ChartPoint, level: Double) -> ChartPoint {
        let dy1 = level - p1.y
        let dy2 = level - p2.y
        return (x: (p2.x * dy1 - p1.x * dy2) / (dy1 - dy2), y: level)
    }
}


// MARK: 🔥🔥🔥🔥🔥🔥Scaling💧💧💧💧💧💧💧
extension Chart {

    fileprivate func getMinMax() -> (min: ChartPoint, max: ChartPoint) {
        // Start with user-provided values

        var min = (x: minX, y: minY)
        var max = (x: maxX, y: maxY)

        // Check in datasets

        for series in self.series {
            let xValues =  series.data.map { $0.x }
            let yValues =  series.data.map { $0.y }

            let newMinX = xValues.minOrZero()
            let newMinY = yValues.minOrZero()
            let newMaxX = xValues.maxOrZero()
            let newMaxY = yValues.maxOrZero()

            if min.x == nil || newMinX < min.x! { min.x = newMinX }
            if min.y == nil || newMinY < min.y! { min.y = newMinY }
            if max.x == nil || newMaxX > max.x! { max.x = newMaxX }
            if max.y == nil || newMaxY > max.y! { max.y = newMaxY }
        }

        // Check in labels

        if let xLabels = self.xLabels {
            let newMinX = xLabels.minOrZero()
            let newMaxX = xLabels.maxOrZero()
            if min.x == nil || newMinX < min.x! { min.x = newMinX }
            if max.x == nil || newMaxX > max.x! { max.x = newMaxX }
        }

        if let yLabels = self.yLabels {
            let newMinY = yLabels.minOrZero()
            let newMaxY = yLabels.maxOrZero()
            if min.y == nil || newMinY < min.y! { min.y = newMinY }
            if max.y == nil || newMaxY > max.y! { max.y = newMaxY }
        }

        if min.x == nil { min.x = 0 }
        if min.y == nil { min.y = 0 }
        if max.x == nil { max.x = 0 }
        if max.y == nil { max.y = 0 }

        return (min: (x: min.x!, y: min.y!), max: (x: max.x!, max.y!))
    }

    fileprivate func scaleValuesOnXAxis(_ values: [Double]) -> [Double] {
        let width = Double(drawingWidth - self.yLabelMaxWidth - 5.0)

        var factor: Double
        if max.x - min.x == 0 {
            factor = 0
        } else {
            factor = width / (max.x - min.x)
        }

        let scaled = values.map { factor * ($0 - self.min.x) }
        return scaled
    }

    fileprivate func scaleValuesOnYAxis(_ values: [Double]) -> [Double] {
        let height = Double(drawingHeight)
        var factor: Double
        if max.y - min.y == 0 {
            factor = 0
        } else {
            factor = height / (max.y - min.y)
        }

        let scaled = values.map { Double(self.topInset) + height - factor * ($0 - self.min.y) }

        return scaled
    }

    fileprivate func scaleValueOnYAxis(_ value: Double) -> Double {
        let height = Double(drawingHeight)
        var factor: Double
        if max.y - min.y == 0 {
            factor = 0
        } else {
            factor = height / (max.y - min.y)
        }

        let scaled = Double(self.topInset) + height - factor * (value - min.y)
        return scaled
    }

    fileprivate func getZeroValueOnYAxis(zeroLevel: Double) -> Double {
        if min.y > zeroLevel {
            return scaleValueOnYAxis(min.y)
        } else {
            return scaleValueOnYAxis(zeroLevel)
        }
    }
}

// MARK: 🔥🔥🔥🔥🔥🔥Drawing💧💧💧💧💧💧💧
extension Chart {
    
    /// 添加数据点
    /// - Parameters:
    ///   - frame: 尺寸
    ///   - tag: tag
    ///   - seriesIndex: 数据index
    ///   - backColor: 背景se
    /// - Returns: 点
    fileprivate func addPointView(_ frame: CGRect, tag: Int, seriesIndex: Int, backColor: UIColor, pointType: ChartSeriesPointType) -> ChartPointView {
        let pointView = ChartPointView(frame: frame)
        
        //传递 图表类型
        pointView.chartType = chartType
        
        if pointType == .circle {
            pointView.layer.cornerRadius = frame.size.width / 2.0
        }
        
        let tap = UITapGestureRecognizer(target:self, action:#selector(tapClick(tap:)))
        pointView.isUserInteractionEnabled=true
        pointView.tag = tag
        pointView.seriesIndex = seriesIndex
        //给view添加事件
        pointView.addGestureRecognizer(tap)
        pointView.backgroundColor = backColor
        return pointView
    }
    
    
    fileprivate func drawLine(_ xValues: [Double], yValues: [Double], seriesIndex: Int, pointType: ChartSeriesPointType) {
        // YValues are "reverted" from top to bottom, so 'above' means <= level
        let isAboveZeroLine = yValues.max()! <= self.scaleValueOnYAxis(series[seriesIndex].colors.zeroLevel)
        let path = CGMutablePath()
        
        path.move(to: CGPoint(x: CGFloat(xValues.first!) + self.yLabelMaxWidth, y: CGFloat(yValues.first!)))
        
        let space = pointSize.width / 2.0
        if showPointView {
            let pointView = addPointView(CGRect(origin: CGPoint(x: CGFloat(xValues.first!)-space + self.yLabelMaxWidth, y: CGFloat(yValues.first!)-space), size: pointSize), tag: 0, seriesIndex: seriesIndex, backColor: series[seriesIndex].colors.above, pointType: pointType)
            self.addSubview(pointView)
            
            self.pointViewArr.append(pointView)
        }
        
        for i in 1..<yValues.count {
            let y = yValues[i]
        
            path.addLine(to: CGPoint(x: CGFloat(xValues[i]) + self.yLabelMaxWidth, y: CGFloat(y)))
            
            if showPointView {
                let pointView = addPointView(CGRect(origin: CGPoint(x: CGFloat(xValues[i])-space + self.yLabelMaxWidth, y: CGFloat(y)-space), size: pointSize), tag: i, seriesIndex: seriesIndex, backColor: series[seriesIndex].colors.above, pointType: pointType)
                self.addSubview(pointView)
                self.pointViewArr.append(pointView)
            }
        }

        let lineLayer = CAShapeLayer()
        lineLayer.frame = self.bounds
        lineLayer.path = path

        if isAboveZeroLine {
            lineLayer.strokeColor = series[seriesIndex].colors.above.cgColor
        } else {
            lineLayer.strokeColor = series[seriesIndex].colors.below.cgColor
        }
        lineLayer.fillColor = nil
        lineLayer.lineWidth = lineWidth
        lineLayer.lineJoin = CAShapeLayerLineJoin.bevel

        self.layer.addSublayer(lineLayer)

        layerStore.append(lineLayer)
    }

    fileprivate func drawArea(_ xValues: [Double], yValues: [Double], seriesIndex: Int) {
        // YValues are "reverted" from top to bottom, so 'above' means <= level
        let isAboveZeroLine = yValues.max()! <= self.scaleValueOnYAxis(series[seriesIndex].colors.zeroLevel)
        let area = CGMutablePath()
        let zero = CGFloat(getZeroValueOnYAxis(zeroLevel: series[seriesIndex].colors.zeroLevel))

        area.move(to: CGPoint(x: CGFloat(xValues[0]), y: zero))
        for i in 0..<xValues.count {
            area.addLine(to: CGPoint(x: CGFloat(xValues[i]), y: CGFloat(yValues[i])))
        }
        area.addLine(to: CGPoint(x: CGFloat(xValues.last!), y: zero))
        let areaLayer = CAShapeLayer()
        areaLayer.frame = self.bounds
        areaLayer.path = area
        areaLayer.strokeColor = nil
        if isAboveZeroLine {
            areaLayer.fillColor = series[seriesIndex].colors.above.withAlphaComponent(areaAlphaComponent).cgColor
        } else {
            areaLayer.fillColor = series[seriesIndex].colors.below.withAlphaComponent(areaAlphaComponent).cgColor
        }
        areaLayer.lineWidth = 0

        self.layer.addSublayer(areaLayer)

        layerStore.append(areaLayer)
    }

    fileprivate func drawAxes() {
        let context = UIGraphicsGetCurrentContext()!
        context.setStrokeColor(gridColor.cgColor)
        context.setLineWidth(0.5)

        // horizontal axis at the bottom
        if !hideBottomLine {
            context.move(to: CGPoint(x: CGFloat(self.yLabelMaxWidth), y: drawingHeight + topInset))
            context.addLine(to: CGPoint(x: CGFloat(drawingWidth), y: drawingHeight + topInset))
            context.strokePath()
        }
        
        // horizontal axis at the top
        
        if !hideTopLine {
            context.move(to: CGPoint(x: CGFloat(self.yLabelMaxWidth), y: CGFloat(0)))
            context.addLine(to: CGPoint(x: CGFloat(drawingWidth), y: CGFloat(0)))
            context.strokePath()
        }
        

        // horizontal axis when y = 0
        if min.y < 0 && max.y > 0 && yZeroLineShow {
            let y = CGFloat(getZeroValueOnYAxis(zeroLevel: 0))
            context.move(to: CGPoint(x: CGFloat(self.yLabelMaxWidth), y: y))
            context.addLine(to: CGPoint(x: CGFloat(drawingWidth), y: y))
            context.strokePath()
        }

        // vertical axis on the left
        if !hideLeftLine {
            context.move(to: CGPoint(x: CGFloat(self.yLabelMaxWidth), y: CGFloat(0)))
            context.addLine(to: CGPoint(x: CGFloat(self.yLabelMaxWidth), y: drawingHeight + topInset))
            context.strokePath()
        }

        // vertical axis on the right
        if !hideRightLine {
            context.move(to: CGPoint(x: CGFloat(drawingWidth), y: CGFloat(0)))
            context.addLine(to: CGPoint(x: CGFloat(drawingWidth), y: drawingHeight + topInset))
            context.strokePath()
        }
    }

    fileprivate func drawLabelsAndGridOnXAxis() {
        let context = UIGraphicsGetCurrentContext()!
        context.setStrokeColor(gridColor.cgColor)
        context.setLineWidth(gridLineWidth)

        var labels: [Double]
        if xLabels == nil {
            // Use labels from the first series
            labels = series[0].data.map({ (point: ChartPoint) -> Double in
                return point.x})
        } else {
            labels = xLabels!
        }

        let scaled = scaleValuesOnXAxis(labels)
        let padding: CGFloat = 5.0
        
        //竖线间隙（宽度）
        let lineSpace = scaled[1]
        columnWidthSpace = lineSpace
        
        scaled.enumerated().forEach { (i, value) in
            let x = CGFloat(value)
            let isLastLabel = x == drawingWidth

            // Add vertical grid for each label, except axes on the left and right

            let originX = self.yLabelMaxWidth + x
            context.move(to: CGPoint(x: originX, y: CGFloat(0)))
            context.addLine(to: CGPoint(x:originX, y: bounds.height - xLineEndSpace))
            context.strokePath()
            
            if xLabelsSkipLast && isLastLabel {
                // Do not add label at the most right position
                return
            }

            // Add label
            let label = UILabel(frame: CGRect(x: self.yLabelMaxWidth + x - (i == 0 ? padding : 0.0), y: drawingHeight + 5.0, width: 0, height: 0))
            label.font = labelFont
            label.text = xLabelsFormatter(i, labels[i])
            label.textColor = labelColor

            // Set label size
            label.sizeToFit()
            // Center label vertically
            label.frame.origin.y += topInset
            if xLabelsOrientation == .horizontal {
                // Add left padding
                label.frame.origin.y -= (label.frame.height - bottomInset) / 2
    
                if xLabelShowMiddle {
                    label.frame.origin.x -= label.frame.size.width/2.0
                    
                    label.frame.origin.x += (i == 0 ? padding : 0.0)
                }
                else if xLabelShowLinesMiddle {
                    
                    let leftSpace = (lineSpace - label.frame.width) / 2.0
                    label.frame.origin.x = originX + (leftSpace < 0.0 ? 0.0 : leftSpace)
                }
                
                // Set label's text alignment
                //label.frame.size.width = (drawingWidth / CGFloat(labels.count)) - padding * 2
                label.textAlignment = xLabelsTextAlignment
            } else {
                label.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))

                // Adjust vertical position according to the label's height
                label.frame.origin.y += label.frame.size.height / 2

                // Adjust horizontal position as the series line
                label.frame.origin.x = x
                if xLabelsTextAlignment == .center {
                    // Align horizontally in series
                    label.frame.origin.x += ((drawingWidth / CGFloat(labels.count)) / 2) - (label.frame.size.width / 2)
                } else {
                    // Give some space from the vertical line
                    label.frame.origin.x += padding
                }
            }
            
            if xLabelsTranform {
                label.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi / 4))
            }
            
            self.addSubview(label)
        }
    }

    fileprivate func drawLabelsAndGridOnYAxis() {
        let context = UIGraphicsGetCurrentContext()!
        context.setStrokeColor(gridColor.cgColor)
        context.setLineWidth(0.5)

        var labels: [Double]
        if yLabels == nil {
            labels = [(min.y + max.y) / 2, max.y]
            if yLabelsOnRightSide || min.y != 0 {
                labels.insert(min.y, at: 0)
            }
        } else {
            labels = yLabels!
        }

        //计算y轴上最大宽度
        var maxWidth = 0.0
        labels.forEach { item in
            let size = (String(Float(item)) as NSString).boundingRect(with: CGSize(width: 200, height: labelFont!.pointSize), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : labelFont!], context: nil)
            if maxWidth < size.width {
                maxWidth = size.width
            }
        }
        
        self.yLabelMaxWidth = maxWidth + (xLabelShowMiddle ? 5.0 : 0.0)
        
        let scaled = scaleValuesOnYAxis(labels)
        let padding: CGFloat = 5
        let zero = CGFloat(getZeroValueOnYAxis(zeroLevel: 0))

        scaled.enumerated().forEach { (i, value) in

            let y = CGFloat(value)

            // Add horizontal grid for each label, but not over axes
            if y != drawingHeight + topInset && y != zero && showYGridLine{

                context.move(to: CGPoint(x: CGFloat(0) + (yLineStartSpace ? maxWidth + (xLabelShowMiddle ? padding : 0.0) : 0.0), y: y))
                context.addLine(to: CGPoint(x: self.bounds.width, y: y))
                if labels[i] != 0 && !showSolidLine {
                    // Horizontal grid for 0 is not dashed
                    context.setLineDash(phase: CGFloat(0), lengths: [CGFloat(5)])
                } else {
                    context.setLineDash(phase: CGFloat(0), lengths: [])
                }
                context.strokePath()
            }
            
            //第0个不要展示
            if i == 0 && isHiddenFirstYLabel{
                return
            }

            //不需要间隙
            let label = UILabel(frame: CGRect(x: 0, y: y, width: maxWidth, height: 0))
            label.font = labelFont
            label.text = yLabelsFormatter(i, labels[i])
            label.textColor = labelColor
            label.sizeToFit()

            if yLabelsOnRightSide {
                label.frame.origin.x = drawingWidth
                label.frame.origin.x -= label.frame.width + padding
                
            }
            else {
                label.textAlignment = .right
                label.frame.size.width = maxWidth
            }

            // Labels should be placed above the horizontal grid
            label.frame.origin.y -= (yLabelShowMiddle ? label.frame.height / 2.0 : label.frame.height)

            self.addSubview(label)
        }
        UIGraphicsEndImageContext()
    }
    
    // 🔥🔥🔥🔥🔥🔥绘制柱状图💧💧💧💧💧💧💧
    fileprivate func drawColumn(_ xValues: [Double], yValues: [Double], seriesIndex: Int) {
        
        // YValues are "reverted" from top to bottom, so 'above' means <= level
        let isAboveZeroLine = yValues.max()! <= self.scaleValueOnYAxis(series[seriesIndex].colors.zeroLevel)
        
        for i in 0..<yValues.count {
            let y = yValues[i]
            var width = columnWidthSpace / 2.0
            
            if singleSpaceColumCount != 1 {
                width = (columnWidthSpace - 1.0*Double((singleSpaceColumCount + 1))) / Double(singleSpaceColumCount)
            }
            
            let viewX = CGFloat(xValues[i]) + self.yLabelMaxWidth + (singleSpaceColumCount == 1 ? width/2.0 : 1.0)
            let viewY = CGFloat(y)
            let height = bounds.height - xLineEndSpace - viewY
            
            var backColor = series[seriesIndex].colors.above
            if !isAboveZeroLine {
                backColor = series[seriesIndex].colors.below
            }
            
            let columnView = addPointView(CGRect(x: viewX, y: viewY, width: width, height: height), tag: i, seriesIndex: seriesIndex, backColor: backColor, pointType: .square)
            self.addSubview(columnView)
            self.pointViewArr.append(columnView)
        }
    }
    
    // 🔥🔥🔥🔥🔥🔥绘制饼状图💧💧💧💧💧💧💧
    fileprivate func drawPieChart() {
        var start = -CGFloat.pi/2
        var end = start
        //计算比例
        let datas = self.series.first!.data.map({$0.y})
        let sums = datas.reduce(0) { $0+$1}
        for index in 0 ..< datas.count {
            let pieLayer = ChartPieLayer()
            pieLayer.curIndex = index
            end = start + CGFloat.pi * 2.0 * CGFloat(datas[index]/sums)
            let piePath = UIBezierPath()
            piePath.move(to: centerPoint)
            piePath.addArc(withCenter:centerPoint, radius: radius, startAngle: start, endAngle: end, clockwise: true)
            
            let pieFillColor = series.first!.pieColors![index].cgColor
            pieLayer.fillColor = pieFillColor
            pieLayer.path = piePath.cgPath
            
            pieLayer.startAngle = start
            pieLayer.endAngle = end
            start = end
            layer.addSublayer(pieLayer)
            layerStore.append(pieLayer)
            
            //添加指向线
            let middleAngle = (pieLayer.startAngle+pieLayer.endAngle)/2
            let newPosition = CGPoint(x: centerPoint.x + (radius)*cos(middleAngle), y: centerPoint.y + (radius)*sin(middleAngle))

            //划折线
            let pointLayer = ChartPieLayer()
            pointLayer.lineCap = .round
            pointLayer.lineJoin = .round
            let pointPath = UIBezierPath()
            pointPath.move(to: newPosition)
            var firstLinePoint = CGPoint.zero
            if newPosition.x >= centerPoint.x {
                if newPosition.y >= centerPoint.y {
                    //第一像限
                    firstLinePoint = CGPoint.init(x: newPosition.x + lineDistance*cos(CGFloat.pi/8), y: newPosition.y + lineDistance*sin(CGFloat.pi*7/32))
                }else {
                    //第四象限
                    firstLinePoint = CGPoint.init(x: newPosition.x + lineDistance*cos(CGFloat.pi/6 + CGFloat.pi/4), y: newPosition.y + lineDistance*sin(CGFloat.pi*3/2 + CGFloat.pi/4))
                }
            }else {
                if newPosition.y > centerPoint.y {
                    firstLinePoint = CGPoint.init(x: newPosition.x + lineDistance*cos(CGFloat.pi*0.75), y: newPosition.y + lineDistance*sin(CGFloat.pi*0.75))
                }else {
                    firstLinePoint = CGPoint.init(x: newPosition.x + lineDistance*cos(CGFloat.pi*1.25), y: newPosition.y + lineDistance*sin(CGFloat.pi*1.25))
                }
            }
            pointPath.addLine(to: firstLinePoint)
            let x:CGFloat = firstLinePoint.x > centerPoint.x ? 40 : -40
            let secondPoint = CGPoint(x: firstLinePoint.x + x, y: firstLinePoint.y)
            pointPath.addLine(to: secondPoint)
            pointLayer.strokeColor = series.first!.pieLabelColor == nil ? pieFillColor : series.first!.pieLabelColor!.cgColor
            pointLayer.lineWidth = 1
            pointLayer.fillColor = UIColor.clear.cgColor
            pointLayer.path = pointPath.cgPath
            layer.addSublayer(pointLayer)
            layerStore.append(pointLayer)
            
            var value = "\(datas[index])"
            
            if usePercentValuesEnabled {
                let percent = datas[index] / datas.reduce(0, +) * 100.0
                value = "\(String(format: "%.1f", percent))%"
            }
            if !xLabelsData!.isEmpty && index < xLabelsData!.count{
                value = "\(xLabelsData![index])\n(\(value))"
            }
            
            let str:String = value
            let size = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
            let rect = str.boundingRect(with: size, options: [.usesLineFragmentOrigin], attributes: [.font: pieLabelTextFont, .foregroundColor:pieFillColor], context: nil)
            addTextLayer(str, frame: CGRect(x: secondPoint.x - rect.width/2, y: secondPoint.y-rect.height - 2.0, width: rect.width, height: rect.height), font: pieLabelTextFont, color:pieFillColor)
        }
        
        createAnimatedMaskLayer()
        
        let view = UIView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: radius * 2.0 * holeRadiusPercent, height: radius * 2.0 * holeRadiusPercent)))
        view.center = self.centerPoint
        view.backgroundColor = .white
        view.isUserInteractionEnabled = false
        view.layer.cornerRadius = radius * 2.0 * holeRadiusPercent / 2.0
        self.addSubview(view)
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [self] in
            
            let centerLabel = UILabel()
            centerLabel.text = centerText
            centerLabel.font = centerTextFont
            centerLabel.textColor = centerTextColor
            centerLabel.textAlignment = .center
            centerLabel.numberOfLines = 0
            centerLabel.sizeToFit()
            centerLabel.center = self.centerPoint
            self.addSubview(centerLabel)
        }
        
    }
    
    fileprivate func addTextLayer(_ text:String, frame:CGRect, font:UIFont, color:CGColor?) {
        let textLayer = CATextLayer()
        textLayer.string = text
        textLayer.alignmentMode = .center
        textLayer.fontSize = font.pointSize
        textLayer.foregroundColor = color
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.isWrapped = false
        textLayer.frame = frame
        layer.addSublayer(textLayer)
    }
    
    fileprivate func createAnimatedMaskLayer() {
        let maskLayer = CAShapeLayer()
        let maskPath = UIBezierPath(arcCenter: centerPoint, radius: radius/2 + distance/2 + 50, startAngle: -CGFloat.pi/2, endAngle: CGFloat.pi * 1.5, clockwise: true)
        //lineWidth属性, 它有一半的宽度是超出path所包住的范围
        maskLayer.lineWidth = radius + distance + 100
        ////设置边框颜色为不透明，则可以通过边框的绘制来显示整个视图 任意颜色
        maskLayer.strokeColor = UIColor.white.cgColor
        maskLayer.strokeEnd = 0
        maskLayer.path = maskPath.cgPath
        //设置填充颜色为透明，可以通过设置半径来设置中心透明范围
        maskLayer.fillColor = UIColor.clear.cgColor
        layer.mask = maskLayer
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = 1
        animation.fromValue = 0
        animation.toValue = 1
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        animation.timingFunction = CAMediaTimingFunction(name: animateType)
        maskLayer.add(animation, forKey: nil)
    }
    
}

// MARK: 🔥🔥🔥🔥🔥🔥Touch events💧💧💧💧💧💧💧
extension Chart {
    
    //事件点击
    @objc func tapClick(tap: UITapGestureRecognizer) {
        
        if tap.view is ChartPointView {
            let pointView = tap.view as! ChartPointView
            
            if pointView.chartType == .line {
                self.pointViewArr.forEach { pv in
                    if pv.isScaleBig {
                        var transform = pv.transform
                        transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                        pv.transform = transform
                        pv.isScaleBig = false
                    }
                }
                
                //NSLog("--------\(series[pointView.seriesIndex!].data[pointView.tag])")
                
                var transform = pointView.transform
                transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                pointView.transform = transform
                pointView.isScaleBig = true
            }
            else if pointView.chartType == .column {
                self.pointViewArr.forEach { pv in
                    if pv.isScaleBig {
                        pv.backgroundColor = series[pointView.seriesIndex!].color
                        pv.isScaleBig = false
                    }
                    
                }
                pointView.isScaleBig = true
                pointView.backgroundColor = columnSelectColor
            }
            
            delegate?.pointViwDidClick(series[pointView.seriesIndex!].data[pointView.tag], xLabelsData: xLabelsData ?? [""], seriesIndex: pointView.seriesIndex!)
            
        }
    }
    
    fileprivate func drawHighlightLineFromLeftPosition(_ left: CGFloat) {
        if let shapeLayer = highlightShapeLayer {
            // Use line already created
            let path = CGMutablePath()

            path.move(to: CGPoint(x: left, y: 0))
            path.addLine(to: CGPoint(x: left, y: drawingHeight + topInset))
            shapeLayer.path = path
        } else {
            // Create the line
            let path = CGMutablePath()

            path.move(to: CGPoint(x: left, y: CGFloat(0)))
            path.addLine(to: CGPoint(x: left, y: drawingHeight + topInset))
            let shapeLayer = CAShapeLayer()
            shapeLayer.frame = self.bounds
            shapeLayer.path = path
            shapeLayer.strokeColor = highlightLineColor.cgColor
            shapeLayer.fillColor = nil
            shapeLayer.lineWidth = highlightLineWidth

            highlightShapeLayer = shapeLayer
            layer.addSublayer(shapeLayer)
            layerStore.append(shapeLayer)
        }
    }

    func handleTouchEvents(_ touches: Set<UITouch>, event: UIEvent!) {
        let point = touches.first!
        let left = point.location(in: self).x
        let x = valueFromPointAtX(left)

        if left < 0 || left > (drawingWidth as CGFloat) {
            // Remove highlight line at the end of the touch event
            if let shapeLayer = highlightShapeLayer {
                shapeLayer.path = nil
            }
            delegate?.didFinishTouchingChart(self)
            return
        }

        drawHighlightLineFromLeftPosition(left)

        if delegate == nil {
            return
        }

        var indexes: [Int?] = []

        for series in self.series {
            var index: Int? = nil
            let xValues = series.data.map({ (point: ChartPoint) -> Double in
                return point.x })
            let closest = Chart.findClosestInValues(xValues, forValue: x)
            if closest.lowestIndex != nil && closest.highestIndex != nil {
                // Consider valid only values on the right
                index = closest.lowestIndex
            }
            indexes.append(index)
        }
        delegate!.didTouchChart(self, indexes: indexes, x: x, left: left)
    }

    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if chartType == .pie {
            pieUpdateLayer(point: touches.first!.location(in: self))
        }
        else {
            if !hideTouchLine {
                handleTouchEvents(touches, event: event)
            }
        }
    }
    
    fileprivate func pieUpdateLayer(point: CGPoint) {
        if let layers = layer.sublayers {
            for layer in layers {
                if layer is ChartPieLayer {
                    let curLayer = layer as! ChartPieLayer
                    if curLayer.path!.contains(point){
                        if selectedLayer != curLayer {
                            let currPos = layer.position
                            let middleAngle = (curLayer.startAngle + curLayer.endAngle)/2
                            let newPos = CGPoint(x:currPos.x + distance * cos(middleAngle), y:currPos.y + distance * sin(middleAngle))
                            layer.position = newPos
                            if selectedLayer != nil {
                                selectedLayer?.position = .zero
                            }
                            selectedLayer = curLayer
                            
                            //NSLog("========\(curLayer.curIndex)")
                            delegate?.pointViwDidClick((series.first?.data[curLayer.curIndex])!, xLabelsData: xLabelsData!, seriesIndex: 0)
                            
                        }else {
                            selectedLayer?.position = .zero
                            selectedLayer = nil
                        }
                        break
                    }
                }
            }
        }
    }

    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if chartType == .pie {
            return
        }
        
        self.pointViewArr.forEach { pv in
            if pv.isScaleBig {
                if chartType == .line {
                    var transform = pv.transform
                    transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                    pv.transform = transform
                }
                else if chartType == .column {
                    pv.backgroundColor = series[pv.seriesIndex!].color
                }
                pv.isScaleBig = false
            }
        }
        
        if !hideTouchLine {
            
            handleTouchEvents(touches, event: event)
            if self.hideHighlightLineOnTouchEnd {
                if let shapeLayer = highlightShapeLayer {
                    shapeLayer.path = nil
                }
            }
            delegate?.didEndTouchingChart(self)
        }
        
        
    }

    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if chartType == .pie {
            return
        }
        
        if !hideTouchLine {
            handleTouchEvents(touches, event: event)
        }
        
        
    }
}

// MARK: - 🔥🔥🔥🔥🔥扩展功能链式编程设置属性🔥🔥🔥🔥🔥🔥
extension Chart {
    @discardableResult
    public func chartType(_ prop: ChartType) -> Chart {
        chartType = prop
        return self
    }
    
    @discardableResult
    public func xLabelsTextAlignment(_ prop: NSTextAlignment) -> Chart {
        xLabelsTextAlignment = prop
        return self
    }
    
    @discardableResult
    public func showYLabelsAndGrid(_ prop: Bool) -> Chart {
        showYLabelsAndGrid = prop
        return self
    }
    
    @discardableResult
    public func showYGridLine(_ prop: Bool) -> Chart {
        showYGridLine = prop
        return self
    }
    
    @discardableResult
    public func xLabelsSkipLast(_ prop: Bool) -> Chart {
        xLabelsSkipLast = prop
        return self
    }
    
    @discardableResult
    public func hideHighlightLineOnTouchEnd(_ prop: Bool) -> Chart {
        hideHighlightLineOnTouchEnd = prop
        return self
    }
    
    @discardableResult
    public func hideTopLine(_ prop: Bool) -> Chart {
        hideTopLine = prop
        return self
    }
    
    @discardableResult
    public func hideBottomLine(_ prop: Bool) -> Chart {
        hideBottomLine = prop
        return self
    }
    
    @discardableResult
    public func hideRightLine(_ prop: Bool) -> Chart {
        hideRightLine = prop
        return self
    }
    
    @discardableResult
    public func hideLeftLine(_ prop: Bool) -> Chart {
        hideLeftLine = prop
        return self
    }
    
    @discardableResult
    public func hideTouchLine(_ prop: Bool) -> Chart {
        hideTouchLine = prop
        return self
    }
    
    /// 隐藏四周线条（默认全部隐藏）
    /// - Parameters:
    ///   - left: 左边
    ///   - right: 右边
    ///   - top: 上边
    ///   - bottom: 下边
    /// - Returns: 对象
    @discardableResult
    public func hideAroundLine(_ left: Bool = true, right: Bool = true, top: Bool = true, bottom: Bool = true) -> Chart {
        hideLeftLine = left
        hideTopLine = top
        hideRightLine = right
        hideBottomLine = bottom
        return self
    }
    
    @discardableResult
    public func showPointView(_ prop: Bool) -> Chart {
        showPointView = prop
        return self
    }
    
    @discardableResult
    public func setPointViewSize(_ prop: CGSize) -> Chart {
        pointSize = prop
        return self
    }
    
    @discardableResult
    public func yLabelShowMiddle(_ prop: Bool) -> Chart {
        yLabelShowMiddle = prop
        return self
    }
    
    @discardableResult
    public func xLabelShowMiddle(_ prop: Bool) -> Chart {
        xLabelShowMiddle = prop
        return self
    }
    
    @discardableResult
    public func xLabelShowLinesMiddle(_ prop: Bool) -> Chart {
        xLabelShowLinesMiddle = prop
        if prop {
            xLabelShowMiddle = false
        }
        return self
    }
    
    @discardableResult
    public func xLineEndSpace(_ prop: Double) -> Chart {
        xLineEndSpace = prop
        return self
    }
    
    @discardableResult
    public func yLineStartSpace(_ prop: Bool) -> Chart {
        yLineStartSpace = prop
        return self
    }
    
    
    @discardableResult
    public func showSolidLine(_ prop: Bool) -> Chart {
        showSolidLine = prop
        return self
    }
    
    @discardableResult
    public func xLabelsTranform(_ prop: Bool) -> Chart {
        xLabelsTranform = prop
        return self
    }

    @discardableResult
    public func xZeroLinePoint(_ prop: Bool) -> Chart {
        xZeroLinePoint = prop
        return self
    }
    
    @discardableResult
    public func yZeroLineShow(_ prop: Bool) -> Chart {
        yZeroLineShow = prop
        return self
    }
    
    @discardableResult
    public func isHiddenFirstYLabel(_ prop: Bool) -> Chart {
        isHiddenFirstYLabel = prop
        return self
    }
    
    @discardableResult
    public func columnSelectColor(_ prop: UIColor) -> Chart {
        columnSelectColor = prop
        return self
    }
    
    @discardableResult
    public func yAxisLabelMaxValue(_ prop: Double) -> Chart {
        yAxisMaxValue = prop
        
        if prop > 3000.0 {
            yLabels = [0.0, 1000.0, 2000.0, 3000.0, 4000.0, 5000.0]
        }
        else if prop > 1500.0 {
            yLabels = [0.0, 600.0, 1200.0, 1800.0, 2400.0, 3000.0]
        }
        else if prop > 1000.0 {
            yLabels = [0.0, 300.0, 600.0, 900.0, 1200.0, 1500.0]
        }
        else if prop > 500 {
            yLabels = [0.0, 200.0, 400.0, 600.0, 800.0, 1000.0]
        }
        else if prop > 200 {
            yLabels = [0.0, 100.0, 200.0, 300.0, 400.0, 500.0]
        }
        else if prop > 100 {
            yLabels = [0.0, 50.0, 100.0, 150.0, 200.0]
        }
        else if prop > 50 {
            yLabels = [0.0, 20.0, 40.0, 60.0, 80.0, 100.0]
        }
        else if prop > 20 {
            yLabels = [0.0, 10.0, 20.0, 30.0, 40.0, 50.0]
        }
        else if prop > 10 {
            yLabels = [0.0, 5.0, 10.0, 15.0, 20.0]
        }
        else if prop > 5 {
            yLabels = [0.0, 2.0, 4.0, 6.0, 8.0, 10.0]
        }
        else {
            yLabels = [0.0, 1.0, 2.0, 3.0, 4.0, 5.0]
        }
        
        return self
    }
    
    @discardableResult
    public func singleSpaceColumCount(_ prop: Int) -> Chart {
        singleSpaceColumCount = prop
        return self
    }
    
    //🔥🔥🔥🔥🔥🔥Pie 属性💧💧💧💧💧💧💧
    @discardableResult
    public func radius(_ prop: CGFloat) -> Chart {
        radius = prop
        return self
    }

    @discardableResult
    public func distance(_ prop: CGFloat) -> Chart {
        distance = prop
        return self
    }
    
    @discardableResult
    public func usePercentValuesEnabled(_ prop: Bool) -> Chart {
        usePercentValuesEnabled = prop
        return self
    }
    
    @discardableResult
    public func pieLabelTextFont(_ prop: UIFont) -> Chart {
        pieLabelTextFont = prop
        return self
    }
    
    @discardableResult
    public func drawHoleEnabled(_ prop: Bool) -> Chart {
        drawHoleEnabled = prop
        return self
    }
    
    @discardableResult
    public func holeRadiusPercent(_ prop: Double) -> Chart {
        holeRadiusPercent = prop
        return self
    }
    
    
    @discardableResult
    public func holeColor(_ prop: UIColor) -> Chart {
        holeColor = prop
        return self
    }
    
    @discardableResult
    public func drawCenterTextEnabled(_ prop: Bool) -> Chart {
        drawCenterTextEnabled = prop
        return self
    }
    
    
    @discardableResult
    public func centerText(_ prop: String, textFont: UIFont = .systemFont(ofSize: 15), textColor: UIColor = .black) -> Chart {
        centerText = prop
        centerTextFont = textFont
        centerTextColor = textColor
        return self
    }
    
    @discardableResult
    public func lineDistance(_ prop: CGFloat) -> Chart {
        lineDistance = prop
        return self
    }
    
    @discardableResult
    public func animateType(_ prop: CAMediaTimingFunctionName) -> Chart {
        animateType = prop
        return self
    }
    
    
}

extension Sequence where Element == Double {
    func minOrZero() -> Double {
        return self.min() ?? 0.0
    }
    func maxOrZero() -> Double {
        return self.max() ?? 0.0
    }
}

