//
//  SimplePDF.swift
//  BHS
//
//  Created by bo.rong on 2021/12/23.
//  Copyright © 2021 bo.rong. All rights reserved.
//

import UIKit

private enum SimplePDFCommand {
    
    case addText(text:String, font:UIFont, textColor:UIColor)
    case addAttributedText( NSAttributedString )
    case addImage(UIImage)
    case addLineSpace(CGFloat)
    case addHorizontalSpace(CGFloat)
    case addLineSeparator(height: CGFloat)
    case addFIHLineSeparator(size: CGSize, lineColor: UIColor)
    
    case addTable(rowCount: Int, columnCount: Int, rowHeight: CGFloat, columnWidth: CGFloat?, tableLineWidth: CGFloat, font: UIFont?, tableDefinition:TableDefinition?, dataArray: Array<Array<String>>)
    
    case addFIHTable(rowCount: Int, columnCount: Int, rowHeight: CGFloat, rowHeightRefer: CGFloat, columnWidth: CGFloat?, tableLineWidth: CGFloat, tableLineColor: UIColor, font: UIFont?, tableDefinition:TableDefinition?, dataArray: Array<Array<Any>>, columnLine: [Bool]?, rowLine:[Bool]?, imageSize: CGSize?, rowFirstLineShow:Bool?)
    
    case addFIHUITable(rowCount: Int, columnCount: Int, rowHeight: CGFloat, rowHeightRefer: CGFloat, columnWidth: CGFloat?, tableLineWidth: CGFloat, tableLineColor: UIColor, font: UIFont?, tableDefinition:TableDefinition?, dataArray: Array<Array<Any>>, columnLine: [Bool]?, rowLine:[Bool]?, imageSize: CGSize?, rowFirstLineShow:Bool?)
    
    case addFIHCircle(size: CGSize, backColor:UIColor, lineWidth:CGFloat, startAngle:CGFloat, endAngle:CGFloat, clockwise:Bool)
    case addFIHSpace(CGFloat)
    
    case addTableLine(lineHeight: CGFloat, lineWidth: CGFloat, lineColor: UIColor)
    
    
    case setContentAlignment(ContentAlignment)
    case beginNewPage
    
    case beginHorizontalArrangement
    case endHorizontalArrangement
    
}

public enum ContentAlignment {
    case left, center, right
}

public struct TableDefinition {
    let alignments: [ContentAlignment]
    let columnWidths: [CGFloat]
    let fonts:[UIFont]
    let textColors:[UIColor]
    let backColors:[UIColor]
    
//    public init(alignments: [ContentAlignment],
//                columnWidths: [CGFloat],
//                fonts:[UIFont],
//                textColors:[UIColor]) {
//        self.alignments = alignments
//        self.columnWidths = columnWidths
//        self.fonts = fonts
//        self.textColors = textColors
//    }
    
    public init(alignments: [ContentAlignment],
                columnWidths: [CGFloat],
                fonts:[UIFont],
                textColors:[UIColor],
                _ backColors:[UIColor]) {
        self.alignments = alignments
        self.columnWidths = columnWidths
        self.fonts = fonts
        self.textColors = textColors
        self.backColors = backColors
    }
}

/// PDF page size (pixel, 72dpi)
public struct PDFPageSize {
    fileprivate init() { }
    /// A4
    public static let A4 = CGSize(width: 595.0, height: 842.0)
    /// A5
    public static let A5 = CGSize(width: 420.0, height: 595.0)
    ///A6
    public static let A6 = CGSize(width: 298.0, height: 420.0)
    /// B5
    public static let B5 = CGSize(width: 516.0, height: 729.0)
}

open class SimplePDF {
    
    /* States */
    fileprivate var commands: [SimplePDFCommand] = []
    
    /* Initialization */
    fileprivate let pageBounds: CGRect
    fileprivate let pageMarginLeft: CGFloat
    fileprivate let pageMarginTop: CGFloat
    fileprivate let pageMarginBottom: CGFloat
    fileprivate let pageMarginRight: CGFloat
    
    public init(pageSize: CGSize, pageMargin: CGFloat = 20.0) {
        pageBounds = CGRect(origin: CGPoint.zero, size: pageSize)
        self.pageMarginLeft = pageMargin
        self.pageMarginTop = pageMargin
        self.pageMarginRight = pageMargin
        self.pageMarginBottom = pageMargin
    }
    
    public init(pageSize: CGSize, pageMarginLeft: CGFloat, pageMarginTop: CGFloat, pageMarginBottom: CGFloat, pageMarginRight: CGFloat) {
        pageBounds = CGRect(origin: CGPoint.zero, size: pageSize)
        self.pageMarginBottom = pageMarginBottom
        self.pageMarginRight = pageMarginRight
        self.pageMarginTop = pageMarginTop
        self.pageMarginLeft = pageMarginLeft
    }
    
    
    /// Text will be drawn from the current font and alignment settings.
    ///
    /// If text is too long and doesn't fit in the current page.
    /// SimplePDF will begin a new page and draw remaining text.
    ///
    /// This process will be repeated untill there's no text left to draw.
    open func addText(_ text: String, font:UIFont = UIFont.systemFont(ofSize: UIFont.systemFontSize), textColor:UIColor = UIColor.black) {
        commands += [ .addText(text: text, font: font, textColor: textColor) ]
    }
    
    
    /// - Important: Font and Content alignment settings will be ignored.
    /// You have to manually add those attributes to attributed text yourself.
    open func addAttributedText( _ attributedText: NSAttributedString) {
        commands += [ .addAttributedText(attributedText) ]
    }
    
    open func addImage(_ image: UIImage) {
        commands += [ .addImage(image) ]
    }
    
    open func addLineSpace(_ space: CGFloat) {
        commands += [ .addLineSpace(space) ]
    }
    
    open func addVerticalSpace(_ space:CGFloat) {
        commands += [ .addLineSpace(space) ]
    }
    
    open func addHorizontalSpace(_ space: CGFloat) {
        commands += [ .addHorizontalSpace(space) ]
    }
    
    open func addLineSeparator(height: CGFloat = 1.0) {
        commands += [ .addLineSeparator(height: height) ]
    }
    
    open func addFIHLineSeparator(size: CGSize = CGSize.init(width: 100, height: 1.0), lineColor: UIColor = .black) {
        commands += [ .addFIHLineSeparator(size: size, lineColor:lineColor)]
    }
    
    open func addTable(_ rowCount: Int, columnCount: Int, rowHeight: CGFloat, columnWidth: CGFloat, tableLineWidth: CGFloat, font: UIFont, dataArray: Array<Array<String>>) {
        commands += [ .addTable(rowCount: rowCount, columnCount: columnCount, rowHeight: rowHeight, columnWidth: columnWidth, tableLineWidth: tableLineWidth, font: font, tableDefinition: nil, dataArray: dataArray) ]
    }
    
    open func addTable(_ rowCount: Int, columnCount: Int, rowHeight: CGFloat, tableLineWidth: CGFloat, tableDefinition: TableDefinition, dataArray: Array<Array<String>>) {
        commands += [ .addTable(rowCount: rowCount, columnCount: columnCount, rowHeight: rowHeight, columnWidth: nil, tableLineWidth: tableLineWidth, font: nil, tableDefinition: tableDefinition, dataArray: dataArray) ]
    }
    
    
    // MARK: FIH 新增 相關方法
    // MARK: 🔥🔥🔥🔥🔥🔥FIH绘制表格2.0💧💧💧💧💧💧💧
    /// 繪製表格數據（默認 表格線條 都展示）
    /// - Parameters:
    ///   - rowCount: 行數
    ///   - columnCount: 列數
    ///   - rowHeight: 行高
    ///   - rowHeightRefer: 行高參考標準
    ///   - tableLineWidth: 邊框線寬
    ///   - tableDefinition: 表格內容 屬性
    ///   - dataArray: 數據源
    open func addFIHUITable(_ rowCount: Int,
                          columnCount: Int,
                          rowHeight: CGFloat,
                          rowHeightRefer: CGFloat = 30,
                          tableLineWidth: CGFloat,
                          tableLineColor: UIColor = .black,
                          tableDefinition: TableDefinition,
                          dataArray: Array<Array<Any>>,
                          imageSize:CGSize = CGSize(width: 65.0, height: 65.0),
                          rowFirstLineShow: Bool = true) {
        commands += [ .addFIHUITable(rowCount: rowCount, columnCount: columnCount, rowHeight: rowHeight, rowHeightRefer: rowHeightRefer, columnWidth: nil, tableLineWidth: tableLineWidth, tableLineColor: tableLineColor, font: nil, tableDefinition: tableDefinition, dataArray: dataArray, columnLine: nil, rowLine: nil, imageSize:imageSize, rowFirstLineShow: rowFirstLineShow) ]
    }
    
    
    /// 繪製表格數據
    /// - Parameters:
    ///   - rowCount: 行數
    ///   - columnCount: 列數
    ///   - rowHeight: 行高
    ///   - rowHeightRefer: 行高参考标准
    ///   - tableLineWidth: 邊框線寬
    ///   - tableDefinition: 表格內容 屬性
    ///   - dataArray: 數據源
    ///   - columnLine: 豎線展示控制，數組個數與 列數一直
    open func addFIHUITable(_ rowCount: Int,
                          columnCount: Int,
                          rowHeight: CGFloat,
                          rowHeightRefer: CGFloat = 30,
                          tableLineWidth: CGFloat,
                          tableLineColor: UIColor = .black,
                          tableDefinition: TableDefinition,
                          dataArray: Array<Array<Any>>,
                          columnLine: [Bool],
                          imageSize:CGSize = CGSize(width: 65.0, height: 65.0),
                          rowFirstLineShow: Bool = true) {
        commands += [ .addFIHUITable(rowCount: rowCount, columnCount: columnCount, rowHeight: rowHeight, rowHeightRefer: rowHeightRefer, columnWidth: nil, tableLineWidth: tableLineWidth, tableLineColor: tableLineColor, font: nil, tableDefinition: tableDefinition, dataArray: dataArray, columnLine: columnLine, rowLine: nil, imageSize: imageSize, rowFirstLineShow: rowFirstLineShow) ]
    }
    
    /// 繪製表格數據
    /// - Parameters:
    ///   - rowCount: 行數
    ///   - columnCount: 列數
    ///   - rowHeight: 行高
    ///   - rowHeightRefer: 行高參考值
    ///   - tableLineWidth: 邊框線寬
    ///   - tableDefinition: 表格內容 屬性
    ///   - dataArray: 數據源
    ///   - rowLine: 橫線展示控制，個數與 行數一直
    open func addFIHUITable(_ rowCount: Int,
                            columnCount: Int,
                            rowHeight: CGFloat,
                            rowHeightRefer: CGFloat = 30,
                            tableLineWidth: CGFloat,
                            tableLineColor: UIColor = .black,
                            tableDefinition: TableDefinition,
                            dataArray: Array<Array<Any>>,
                            rowLine: [Bool],
                            imageSize:CGSize = CGSize(width: 65.0, height: 65.0),
                            rowFirstLineShow: Bool = true) {
        commands += [ .addFIHUITable(rowCount: rowCount, columnCount: columnCount, rowHeight: rowHeight, rowHeightRefer: rowHeightRefer, columnWidth: nil, tableLineWidth: tableLineWidth, tableLineColor: tableLineColor, font: nil, tableDefinition: tableDefinition, dataArray: dataArray, columnLine: nil, rowLine: rowLine, imageSize: imageSize, rowFirstLineShow: rowFirstLineShow) ]
    }
    
    /// 繪製表格數據
    /// - Parameters:
    ///   - rowCount: 行數
    ///   - columnCount: 列數
    ///   - rowHeight: 行高
    ///   - rowHeightRefer: 行高参考高度
    ///   - tableLineWidth: 邊框線寬
    ///   - tableDefinition: 表格內容 屬性
    ///   - dataArray: 數據源
    ///   - columnLine: 豎線展示控制，數組個數與 列數一直
    ///   - rowLine: 橫線展示控制，個數與 行數一直
    open func addFIHUITable(_ rowCount: Int,
                            columnCount: Int,
                            rowHeight: CGFloat,
                            rowHeightRefer: CGFloat = 30,
                            tableLineWidth: CGFloat,
                            tableLineColor: UIColor = .black,
                            tableDefinition: TableDefinition,
                            dataArray: Array<Array<Any>>,
                            columnLine: [Bool],
                            rowLine: [Bool],
                            imageSize:CGSize = CGSize(width: 65.0, height: 65.0),
                            rowFirstLineShow: Bool = true) {
        commands += [ .addFIHUITable(rowCount: rowCount, columnCount: columnCount, rowHeight: rowHeight, rowHeightRefer: rowHeightRefer, columnWidth: nil, tableLineWidth: tableLineWidth, tableLineColor: tableLineColor, font: nil, tableDefinition: tableDefinition, dataArray: dataArray, columnLine: columnLine, rowLine: rowLine, imageSize: imageSize, rowFirstLineShow: rowFirstLineShow) ]
    }
    
    
    // MARK: 🔥🔥🔥🔥🔥🔥FIH绘制表格1.0💧💧💧💧💧💧💧
    /// 繪製表格數據（默認 表格線條 都展示）
    /// - Parameters:
    ///   - rowCount: 行數
    ///   - columnCount: 列數
    ///   - rowHeight: 行高
    ///   - rowHeightRefer: 行高參考標準
    ///   - tableLineWidth: 邊框線寬
    ///   - tableDefinition: 表格內容 屬性
    ///   - dataArray: 數據源
    @available(*, deprecated, message: "addFIHTable will deprecated. Use addFIHUITable instead.")
    open func addFIHTable(_ rowCount: Int,
                          columnCount: Int,
                          rowHeight: CGFloat,
                          rowHeightRefer: CGFloat = 30,
                          tableLineWidth: CGFloat,
                          tableLineColor: UIColor = .black,
                          tableDefinition: TableDefinition,
                          dataArray: Array<Array<Any>>,
                          imageSize:CGSize = CGSize(width: 65.0, height: 65.0),
                          rowFirstLineShow: Bool = true) {
        commands += [ .addFIHTable(rowCount: rowCount, columnCount: columnCount, rowHeight: rowHeight, rowHeightRefer: rowHeightRefer, columnWidth: nil, tableLineWidth: tableLineWidth, tableLineColor: tableLineColor, font: nil, tableDefinition: tableDefinition, dataArray: dataArray, columnLine: nil, rowLine: nil, imageSize:imageSize, rowFirstLineShow: rowFirstLineShow) ]
    }
    
    
    /// 繪製表格數據
    /// - Parameters:
    ///   - rowCount: 行數
    ///   - columnCount: 列數
    ///   - rowHeight: 行高
    ///   - rowHeightRefer: 行高参考标准
    ///   - tableLineWidth: 邊框線寬
    ///   - tableDefinition: 表格內容 屬性
    ///   - dataArray: 數據源
    ///   - columnLine: 豎線展示控制，數組個數與 列數一直
    @available(*, deprecated, message: "addFIHTable will deprecated. Use addFIHUITable instead.")
    open func addFIHTable(_ rowCount: Int,
                          columnCount: Int,
                          rowHeight: CGFloat,
                          rowHeightRefer: CGFloat = 30,
                          tableLineWidth: CGFloat,
                          tableLineColor: UIColor = .black,
                          tableDefinition: TableDefinition,
                          dataArray: Array<Array<Any>>,
                          columnLine: [Bool],
                          imageSize:CGSize = CGSize(width: 65.0, height: 65.0),
                          rowFirstLineShow: Bool = true) {
        commands += [ .addFIHTable(rowCount: rowCount, columnCount: columnCount, rowHeight: rowHeight, rowHeightRefer: rowHeightRefer, columnWidth: nil, tableLineWidth: tableLineWidth, tableLineColor: tableLineColor, font: nil, tableDefinition: tableDefinition, dataArray: dataArray, columnLine: columnLine, rowLine: nil, imageSize: imageSize, rowFirstLineShow: rowFirstLineShow) ]
    }
    
    /// 繪製表格數據
    /// - Parameters:
    ///   - rowCount: 行數
    ///   - columnCount: 列數
    ///   - rowHeight: 行高
    ///   - rowHeightRefer: 行高參考值
    ///   - tableLineWidth: 邊框線寬
    ///   - tableDefinition: 表格內容 屬性
    ///   - dataArray: 數據源
    ///   - rowLine: 橫線展示控制，個數與 行數一直
    @available(*, deprecated, message: "addFIHTable will deprecated. Use addFIHUITable instead.")
    open func addFIHTable(_ rowCount: Int,
                          columnCount: Int,
                          rowHeight: CGFloat,
                          rowHeightRefer: CGFloat = 30,
                          tableLineWidth: CGFloat,
                          tableLineColor: UIColor = .black,
                          tableDefinition: TableDefinition,
                          dataArray: Array<Array<Any>>,
                          rowLine: [Bool],
                          imageSize:CGSize = CGSize(width: 65.0, height: 65.0),
                          rowFirstLineShow: Bool = true) {
        commands += [ .addFIHTable(rowCount: rowCount, columnCount: columnCount, rowHeight: rowHeight, rowHeightRefer: rowHeightRefer, columnWidth: nil, tableLineWidth: tableLineWidth, tableLineColor: tableLineColor, font: nil, tableDefinition: tableDefinition, dataArray: dataArray, columnLine: nil, rowLine: rowLine, imageSize: imageSize, rowFirstLineShow: rowFirstLineShow) ]
    }
    
    /// 繪製表格數據
    /// - Parameters:
    ///   - rowCount: 行數
    ///   - columnCount: 列數
    ///   - rowHeight: 行高
    ///   - rowHeightRefer: 行高参考高度
    ///   - tableLineWidth: 邊框線寬
    ///   - tableDefinition: 表格內容 屬性
    ///   - dataArray: 數據源
    ///   - columnLine: 豎線展示控制，數組個數與 列數一直
    ///   - rowLine: 橫線展示控制，個數與 行數一直
    @available(*, deprecated, message: "addFIHTable will deprecated. Use addFIHUITable instead.")
    open func addFIHTable(_ rowCount: Int,
                          columnCount: Int,
                          rowHeight: CGFloat,
                          rowHeightRefer: CGFloat = 30,
                          tableLineWidth: CGFloat,
                          tableLineColor: UIColor = .black,
                          tableDefinition: TableDefinition,
                          dataArray: Array<Array<Any>>,
                          columnLine: [Bool],
                          rowLine: [Bool],
                          imageSize:CGSize = CGSize(width: 65.0, height: 65.0),
                          rowFirstLineShow: Bool = true) {
        commands += [ .addFIHTable(rowCount: rowCount, columnCount: columnCount, rowHeight: rowHeight, rowHeightRefer: rowHeightRefer, columnWidth: nil, tableLineWidth: tableLineWidth, tableLineColor: tableLineColor, font: nil, tableDefinition: tableDefinition, dataArray: dataArray, columnLine: columnLine, rowLine: rowLine, imageSize: imageSize, rowFirstLineShow: rowFirstLineShow) ]
    }
    
    
    ///  绘制圆环进度条
    /// - Parameters:
    ///   - size: 尺寸
    ///   - backColor: 背景色
    ///   - lineWidth: 线宽
    ///   - startAngle: 开始点
    ///   - endAngle: 结束点
    ///   - clockwise: 是否逆时针
    open func addFIHCircle(size: CGSize, backColor:UIColor, lineWidth:CGFloat, startAngle:CGFloat = .pi * 3/2, endAngle: CGFloat, clockwise: Bool) {
        commands += [ .addFIHCircle(size: size, backColor: backColor, lineWidth: lineWidth, startAngle: startAngle, endAngle: endAngle, clockwise: clockwise)]
    }
    
    
    /// 设置偏移量
    /// - Parameter space: 偏移量
    open func addFIHSpace(_ space: CGFloat) {
        commands += [ .addFIHSpace(space) ]
    }
    
    open func addTableLine(lineHeight: CGFloat, lineWidth: CGFloat, lineColor: UIColor) {
        commands += [ .addTableLine(lineHeight: lineHeight, lineWidth: lineWidth, lineColor: lineColor)]
    }
    
    open func setContentAlignment(_ alignment: ContentAlignment) {
        commands += [ .setContentAlignment(alignment) ]
    }
    
    open func beginNewPage() {
        commands += [ .beginNewPage ]
    }
    
    open func beginHorizontalArrangement() {
        commands += [ .beginHorizontalArrangement ]
    }
    
    open func endHorizontalArrangement() {
        commands += [ .endHorizontalArrangement ]
    }
    
    
    // MARK: 内部绘制方法
    /// - returns: drawing text rect
    fileprivate func drawText(_ text: String, font: UIFont, textColor: UIColor, alignment: ContentAlignment, currentOffset: CGPoint) -> CGRect {
        
        // Draw attributed text from font and paragraph style attribute.
        
        let paragraphStyle = NSMutableParagraphStyle()
        switch alignment {
        case .left:
            paragraphStyle.alignment = .left
        case .center:
            paragraphStyle.alignment = .center
        case .right:
            paragraphStyle.alignment = .right
        }
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: textColor,
            .paragraphStyle: paragraphStyle
        ]
        let attributedText = NSAttributedString(string: text, attributes: attributes)
        
        return drawAttributedText(attributedText, currentOffset: currentOffset)
    }
    
    fileprivate func drawAttributedText( _ attributedText: NSAttributedString, currentOffset: CGPoint) -> CGRect {
        
        var drawingYoffset = currentOffset.y
        
        let currentText = CFAttributedStringCreateCopy(nil, attributedText as CFAttributedString)
        let framesetter = CTFramesetterCreateWithAttributedString(currentText!)
        var currentRange = CFRange(location: 0, length: 0)
        var done = false
        
        var lastDrawnFrame: CGRect!
        
        repeat {
            
            // Get the graphics context.
            let currentContext = UIGraphicsGetCurrentContext()!
            
            // Push state
            currentContext.saveGState()
            
            // Put the text matrix into a known state. This ensures
            // that no old scaling factors are left in place.
            currentContext.textMatrix = CGAffineTransform.identity
            
            // print("y offset: \t\(drawingYOffset)")
            
            let textMaxWidth = pageBounds.width - pageMarginLeft - pageMarginRight - currentOffset.x
            let textMaxHeight = pageBounds.height - pageMarginBottom - drawingYoffset
            
            // print("drawing y offset: \t\(drawingYOffset)")
            // print("text max height: \t\(textMaxHeight)")
            
            // Create a path object to enclose the text.
            let frameRect = CGRect(x: currentOffset.x, y: drawingYoffset, width: textMaxWidth, height: textMaxHeight)
            let framePath = UIBezierPath(rect: frameRect).cgPath
            
            // Get the frame that will do the rendering.
            // The currentRange variable specifies only the starting point. The framesetter
            // lays out as much text as will fit into the frame.
            let frameRef = CTFramesetterCreateFrame(framesetter, currentRange, framePath, nil)
            
            // Core Text draws from the bottom-left corner up, so flip
            // the current transform prior to drawing.
            currentContext.translateBy(x: 0, y: pageBounds.height + drawingYoffset - pageMarginBottom)
            currentContext.scaleBy(x: 1.0, y: -1.0)
            
            // Draw the frame.
            CTFrameDraw(frameRef, currentContext)
            
            // Pop state
            currentContext.restoreGState()
            
            // Update the current range based on what was drawn.
            let visibleRange = CTFrameGetVisibleStringRange(frameRef)
            currentRange = CFRange(location: visibleRange.location + visibleRange.length , length: 0)
            
            // Update last drawn frame
            let constraintSize = CGSize(width: textMaxWidth, height: textMaxHeight)
            let drawnSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, visibleRange, nil, constraintSize, nil)
            lastDrawnFrame = CGRect(x: currentOffset.x, y: drawingYoffset, width: drawnSize.width, height: drawnSize.height)
            
            // print(suggestionSize)
            
            // If we're at the end of the text, exit the loop.
            // print("\(currentRange.location) \(CFAttributedStringGetLength(currentText))")
            if currentRange.location == CFAttributedStringGetLength(currentText) {
                done = true
                // print("exit")
            } else {
                // begin a new page to draw text that is remaining.
                UIGraphicsBeginPDFPageWithInfo(pageBounds, nil)
                drawingYoffset = pageMarginTop
                // print("begin a new page to draw text that is remaining")
            }
            
            
        } while(!done)
        
        return lastDrawnFrame
    }
    
    /// - returns: drawing image rect
    fileprivate func drawImage(_ image: UIImage, alignment: ContentAlignment, currentOffset: CGPoint) -> CGRect {
        
        /* calculate the aspect size of image */
        
        let maxWidth = min( image.size.width, pageBounds.width )
        let maxHeight = min( image.size.height, pageBounds.height - currentOffset.y )
        
        let wFactor = image.size.width / maxWidth
        let hFactor = image.size.height / maxHeight
        
        let factor = max(wFactor, hFactor)
        
        let aspectWidth = image.size.width / factor
        let aspectHeight = image.size.height / factor
        
        /* calculate x offset for rendering */
        let renderingXoffset: CGFloat
        switch alignment {
        case .left:
            renderingXoffset = currentOffset.x
        case .center:
            renderingXoffset = ( pageBounds.width - currentOffset.x - aspectWidth ) / 2.0
        case .right:
            let right = pageBounds.width - pageMarginRight
            renderingXoffset =  right - aspectWidth
        }
        
        let renderingRect = CGRect(x: renderingXoffset, y: currentOffset.y, width: aspectWidth, height: aspectHeight)
        
        // render image to current pdf context
        image.draw(in: renderingRect)
        
        return renderingRect
    }
    
    fileprivate func drawFIHLineSeparator(size: CGSize, currentOffset: CGPoint, lineColor: UIColor) -> CGRect {
        
        let drawRect = CGRect(x: currentOffset.x, y: currentOffset.y, width: size.width, height: size.height)
        let path = UIBezierPath(rect: drawRect).cgPath
        
        // Get the graphics context.
        let currentContext = UIGraphicsGetCurrentContext()!
        
        // Set color
        lineColor.setStroke()
        lineColor.setFill()
//        UIColor.black.setStroke()
//        UIColor.black.setFill()
        
        // Draw path
        currentContext.addPath(path)
        currentContext.drawPath(using: .fillStroke)
        
        // print(drawRect)
        
        return drawRect
    }
    
    
    fileprivate func drawLineSeparator(height: CGFloat, currentOffset: CGPoint) -> CGRect {
        
        let drawRect = CGRect(x: currentOffset.x, y: currentOffset.y, width: pageBounds.width - pageMarginLeft - pageMarginRight, height: height)
        let path = UIBezierPath(rect: drawRect).cgPath
        
        // Get the graphics context.
        let currentContext = UIGraphicsGetCurrentContext()!
        
        // Set color
        UIColor.black.setStroke()
        UIColor.black.setFill()
        
        // Draw path
        currentContext.addPath(path)
        currentContext.drawPath(using: .fillStroke)
        
        // print(drawRect)
        
        return drawRect
    }
    
    fileprivate func drawFIHTableLine(lineHeight: CGFloat, lineWidth: CGFloat, currentOffset: CGPoint, lineColor:UIColor) -> CGRect  {
        
        let drawRect = CGRect(x: currentOffset.x, y: currentOffset.y, width: lineWidth, height: lineHeight)
        
        drawBackColor(drawRect, backColor: lineColor, lineWidth: lineHeight)
        
        return drawRect
    }
    
    
    fileprivate func drawFIHTable(rowCount: Int,
                                  alignment: ContentAlignment,
                                  columnCount: Int,
                                  rowHeight: CGFloat,
                                  rowHeightRefer: CGFloat,
                                  columnWidth: CGFloat?,
                                  tableLineWidth: CGFloat,
                                  tableLineColor: UIColor,
                                  font: UIFont?,
                                  tableDefinition:TableDefinition?,
                                  dataArray: Array<Array<Any>>,
                                  currentOffset: CGPoint,
                                  columnLine: [Bool]?,
                                  rowLine:[Bool]?,
                                  imageSize: CGSize?,
                                  rowFirstLineShow:Bool) -> CGRect {
        
        let height = (CGFloat(rowCount)*rowHeight)
        
        let drawRect = CGRect(x: currentOffset.x, y: currentOffset.y, width: pageBounds.width - pageMarginLeft - pageMarginRight, height: height)
        
        UIColor.black.setStroke()
        UIColor.black.setFill()
        
        let tableWidth = { () -> CGFloat in
            if let cws = tableDefinition?.columnWidths {
                return cws.reduce(0, { (result, current) -> CGFloat in
                    return result + current
                })
            } else if let cw = columnWidth {
                return CGFloat(columnCount) * cw
            }
            
            return 0 // default which should never be use, because either columnWidth, or columnsWidths is set
        }()
        
        // 绘制表格横线 計算x偏移量
        var rowSpace = 0.0
        if rowLine != nil && rowLine!.count > 0 {
            for i in 0..<rowLine!.count {
                if rowLine![i] {
                    break
                }
                else {
                    let currOffset = { () -> CGFloat in
                        if let cws = tableDefinition?.columnWidths {
                            return cws[i]
                        }
                        
                        return 0 // default which should never be use, because either columnWidth, or columnsWidths is set
                    }()
                    
                    rowSpace += currOffset
                }
            }
        }
        
        //繪製橫線
        for i in 0...rowCount {
            // 第一條線是否繪製
            if i == 0 && !rowFirstLineShow {
                continue
            }
            
            //是否要繪製豎線
            let newOrigin = drawRect.origin.y + rowHeight*CGFloat(i)

            let from = CGPoint(x: drawRect.origin.x + rowSpace, y: newOrigin)
            let to = CGPoint(x: drawRect.origin.x + tableWidth, y: newOrigin)

            drawLineFromPoint(from, to: to, lineWidth: tableLineWidth, lineColor: tableLineColor)
        }
        
        
        //繪製表格豎線
        for i in 0...columnCount {
            //是否要繪製豎線
            var columnLineShow = true
            if columnLine != nil && columnLine!.count > 0 {
                columnLineShow = columnLine![i==0 ? i : i-1]
            }
            
            if columnLineShow {
                let currentOffset = { () -> CGFloat in
                    if let cws = tableDefinition?.columnWidths {
                        var offset:CGFloat = 0
                        for x in 0..<i {
                            offset += cws[x]
                        }
                        return offset
                    } else if let cw = columnWidth {
                        return cw * CGFloat(i)
                    }
                    
                    return 0 // default which should never be use, because either columnWidth, or columnsWidths is set
                }()
                
                let newOrigin = drawRect.origin.x + currentOffset
                
                let from = CGPoint(x: newOrigin, y: drawRect.origin.y)
                let to = CGPoint(x: newOrigin, y: drawRect.origin.y + CGFloat(rowCount)*rowHeight)
                
                drawLineFromPoint(from, to: to, lineWidth: tableLineWidth, lineColor: tableLineColor)
            }
        }
        
        for i in 0..<rowCount {
            for j in 0...columnCount-1 {
                let currOffset = { () -> CGFloat in
                    if let cws = tableDefinition?.columnWidths {
                        var offset:CGFloat = 0
                        for x in 0..<j {
                            offset += cws[x]
                        }
                        return offset
                    } else if let cw = columnWidth {
                        return cw * CGFloat(j)
                    }
                    
                    return 0 // default which should never be use, because either columnWidth, or columnsWidths is set
                }()
                
                let newOriginX = drawRect.origin.x + currOffset
                let newOriginY = drawRect.origin.y + ((CGFloat(i)*rowHeight))
                
                let currentFont = { () -> UIFont in
                    if let f = tableDefinition?.fonts {
                        if (f.count > j){
                            return f[j]
                        }
                    } else if let f = font {
                        return f
                    }
                    
                    return UIFont.systemFont(ofSize: UIFont.systemFontSize)
                }()
                
                let currentTextColor = { () -> UIColor in
                    if let t = tableDefinition?.textColors {
                        if t.count > j {
                            return t[j]
                        }
                    }
                    
                    return UIColor.black
                }()
                
                let currentColumnWidth = { () -> CGFloat in
                    if let cw = tableDefinition?.columnWidths {
                        if cw.count > j {
                            return cw[j]
                        }
                    } else if let cw = columnWidth {
                        return cw
                    }
                    
                    return 100 // default which should never be use, because either columnWidth, or columnsWidths is set
                }()
                
                let currentAlignment = { () -> ContentAlignment in
                    if let ca = tableDefinition?.alignments {
                        if ca.count > j {
                            return ca[j]
                        }
                    }
                    else {
                        return .left
                    }
                    return .left
                }()
                
                let currentBackColor = {() -> UIColor in
                    if let bc = tableDefinition?.backColors {
                        if bc.count > j {
                            return bc[j]
                        }
                    }
                    else {
                        return .white
                    }
                    return .white
                }()
                
                let currentColumnLineShow = {() -> Bool in
                    if let cl = columnLine {
                        if cl.count > j {
                            return cl[j]
                        }
                    }
                    else {
                        return true
                    }
                    return true
                }()
                
                let frame = CGRect(x: newOriginX, y: newOriginY, width: currentColumnWidth, height: rowHeight)
                
                let rectX = newOriginX + (currentColumnLineShow ? tableLineWidth : 0)
                let width = currentColumnWidth-(currentColumnLineShow ? 2*tableLineWidth : 0)
                
                
                let rect = CGRect(x: rectX, y: newOriginY+tableLineWidth, width: width, height: rowHeight-2*tableLineWidth)
                
                drawBackColor(rect, backColor: currentBackColor, lineWidth: width)
                
                if dataArray[i][j] is String  {
                    if rowHeight > rowHeightRefer {
                        drawMultilineTextInCellWithSpace(frame, leftSpace: 0, text: dataArray[i][j] as! NSString, font: currentFont, textColor: currentTextColor)
                    }
                    else {
                        drawTextInCell(frame, text: dataArray[i][j] as! NSString, alignment: currentAlignment, font: currentFont, textColor: currentTextColor)
                    }
                }
                else if dataArray[i][j] is UIImage {
                    drawImageInCell(frame, image: dataArray[i][j] as! UIImage, imageSize: imageSize!, alignment: currentAlignment)
                }
            }
        }
        return drawRect
    }
    
    
    fileprivate func drawFIHUITable(rowCount: Int,
                                  alignment: ContentAlignment,
                                  columnCount: Int,
                                  rowHeight: CGFloat,
                                  rowHeightRefer: CGFloat,
                                  columnWidth: CGFloat?,
                                  tableLineWidth: CGFloat,
                                  tableLineColor: UIColor,
                                  font: UIFont?,
                                  tableDefinition:TableDefinition?,
                                  dataArray: Array<Array<Any>>,
                                  currentOffset: CGPoint,
                                  columnLine: [Bool]?,
                                  rowLine:[Bool]?,
                                  imageSize: CGSize?,
                                  rowFirstLineShow:Bool) -> CGRect {
        
        let height = (CGFloat(rowCount)*rowHeight)
        
        let drawRect = CGRect(x: currentOffset.x, y: currentOffset.y, width: pageBounds.width - pageMarginLeft - pageMarginRight, height: height)
        
        UIColor.black.setStroke()
        UIColor.black.setFill()
        
        let tableWidth = { () -> CGFloat in
            if let cws = tableDefinition?.columnWidths {
                return cws.reduce(0, { (result, current) -> CGFloat in
                    return result + current
                })
            } else if let cw = columnWidth {
                return CGFloat(columnCount) * cw
            }
            
            return 0 // default which should never be use, because either columnWidth, or columnsWidths is set
        }()
        
        // 绘制表格横线 計算x偏移量
        var rowSpace = 0.0
        if rowLine != nil && rowLine!.count > 0 {
            for i in 0..<rowLine!.count {
                if rowLine![i] {
                    break
                }
                else {
                    let currOffset = { () -> CGFloat in
                        if let cws = tableDefinition?.columnWidths {
                            return cws[i]
                        }
                        
                        return 0 // default which should never be use, because either columnWidth, or columnsWidths is set
                    }()
                    
                    rowSpace += currOffset
                }
            }
        }
        
        //繪製橫線
        for i in 0...rowCount {
            // 第一條線是否繪製
            if i == 0 && !rowFirstLineShow {
                continue
            }
            
            //是否要繪製豎線
            let newOrigin = drawRect.origin.y + rowHeight*CGFloat(i)

            let from = CGPoint(x: drawRect.origin.x + rowSpace, y: newOrigin)
            let to = CGPoint(x: drawRect.origin.x + tableWidth, y: newOrigin)

            drawLineFromPoint(from, to: to, lineWidth: tableLineWidth, lineColor: tableLineColor)
        }
        
        
        //繪製表格豎線
        for i in 0...columnCount {
            //是否要繪製豎線
            var columnLineShow = true
            if columnLine != nil && columnLine!.count > 0 {
                columnLineShow = columnLine![i==0 ? i : i-1]
            }
            
            if columnLineShow {
                let currentOffset = { () -> CGFloat in
                    if let cws = tableDefinition?.columnWidths {
                        var offset:CGFloat = 0
                        for x in 0..<i {
                            offset += cws[x]
                        }
                        return offset
                    } else if let cw = columnWidth {
                        return cw * CGFloat(i)
                    }
                    
                    return 0 // default which should never be use, because either columnWidth, or columnsWidths is set
                }()
                
                let newOrigin = drawRect.origin.x + currentOffset
                
                let from = CGPoint(x: newOrigin, y: drawRect.origin.y)
                let to = CGPoint(x: newOrigin, y: drawRect.origin.y + CGFloat(rowCount)*rowHeight)
                
                drawLineFromPoint(from, to: to, lineWidth: tableLineWidth, lineColor: tableLineColor)
            }
        }
        
        for i in 0..<rowCount {
            for j in 0...columnCount-1 {
                let currOffset = { () -> CGFloat in
                    if let cws = tableDefinition?.columnWidths {
                        var offset:CGFloat = 0
                        for x in 0..<j {
                            offset += cws[x]
                        }
                        return offset
                    } else if let cw = columnWidth {
                        return cw * CGFloat(j)
                    }
                    
                    return 0 // default which should never be use, because either columnWidth, or columnsWidths is set
                }()
                
                let newOriginX = drawRect.origin.x + currOffset
                let newOriginY = drawRect.origin.y + ((CGFloat(i)*rowHeight))
                
                let currentFont = { () -> UIFont in
                    if let f = tableDefinition?.fonts {
                        if (f.count > j){
                            return f[j]
                        }
                    } else if let f = font {
                        return f
                    }
                    
                    return UIFont.systemFont(ofSize: UIFont.systemFontSize)
                }()
                
                let currentTextColor = { () -> UIColor in
                    if let t = tableDefinition?.textColors {
                        if t.count > j {
                            return t[j]
                        }
                    }
                    
                    return UIColor.black
                }()
                
                let currentColumnWidth = { () -> CGFloat in
                    if let cw = tableDefinition?.columnWidths {
                        if cw.count > j {
                            return cw[j]
                        }
                    } else if let cw = columnWidth {
                        return cw
                    }
                    
                    return 100 // default which should never be use, because either columnWidth, or columnsWidths is set
                }()
                
                let currentAlignment = { () -> ContentAlignment in
                    if let ca = tableDefinition?.alignments {
                        if ca.count > j {
                            return ca[j]
                        }
                    }
                    else {
                        return .left
                    }
                    return .left
                }()
                
                let currentBackColor = {() -> UIColor in
                    if let bc = tableDefinition?.backColors {
                        if bc.count > j {
                            return bc[j]
                        }
                    }
                    else {
                        return .white
                    }
                    return .white
                }()
                
                let currentColumnLineShow = {() -> Bool in
                    if let cl = columnLine {
                        if cl.count > j {
                            return cl[j]
                        }
                    }
                    else {
                        return true
                    }
                    return true
                }()
                
                let frame = CGRect(x: newOriginX, y: newOriginY, width: currentColumnWidth, height: rowHeight)
                
                let rectX = newOriginX + (currentColumnLineShow ? tableLineWidth : 0)
                let width = currentColumnWidth-(currentColumnLineShow ? 2*tableLineWidth : 0)
                
                
                let rect = CGRect(x: rectX, y: newOriginY+tableLineWidth, width: width, height: rowHeight-2*tableLineWidth)
                
                drawBackColor(rect, backColor: currentBackColor, lineWidth: width)
                
                if dataArray[i][j] is String  {
                    drawLabelInCell(frame, text: dataArray[i][j] as! String, alignment: currentAlignment, font: currentFont, textColor: currentTextColor)
                }
                else if dataArray[i][j] is NSMutableAttributedString {
                    //NSLog("來了老弟")
                    drawLabelMutableAttrStringInCell(frame, text: dataArray[i][j] as! NSMutableAttributedString, alignment: currentAlignment)
                }
                else if dataArray[i][j] is UIImage {
                    drawImageInCell(frame, image: dataArray[i][j] as! UIImage, imageSize: imageSize!, alignment: currentAlignment)
                }
            }
        }
        return drawRect
    }
    
    
    fileprivate func drawTable(rowCount: Int, alignment: ContentAlignment, columnCount: Int, rowHeight: CGFloat, columnWidth: CGFloat?, tableLineWidth: CGFloat, font: UIFont?, tableDefinition:TableDefinition?, dataArray: Array<Array<String>>, currentOffset: CGPoint) -> CGRect {
        
        let height = (CGFloat(rowCount)*rowHeight)
        
        let drawRect = CGRect(x: currentOffset.x, y: currentOffset.y, width: pageBounds.width - pageMarginLeft - pageMarginRight, height: height)
        
        UIColor.black.setStroke()
        UIColor.black.setFill()
        
        let tableWidth = { () -> CGFloat in
            if let cws = tableDefinition?.columnWidths {
                return cws.reduce(0, { (result, current) -> CGFloat in
                    return result + current
                })
            } else if let cw = columnWidth {
                return CGFloat(columnCount) * cw
            }
            
            return 0 // default which should never be use, because either columnWidth, or columnsWidths is set
        }()
        // 绘制表格横线
        for i in 0...rowCount {
            let newOrigin = drawRect.origin.y + rowHeight*CGFloat(i)

            let from = CGPoint(x: drawRect.origin.x, y: newOrigin)
            let to = CGPoint(x: drawRect.origin.x + tableWidth, y: newOrigin)

            drawLineFromPoint(from, to: to, lineWidth: tableLineWidth, lineColor: .black)
        }
        
        for i in 0...columnCount {
            let currentOffset = { () -> CGFloat in
                if let cws = tableDefinition?.columnWidths {
                    var offset:CGFloat = 0
                    for x in 0..<i {
                        offset += cws[x]
                    }
                    return offset
                } else if let cw = columnWidth {
                    return cw * CGFloat(i)
                }
                
                return 0 // default which should never be use, because either columnWidth, or columnsWidths is set
            }()
            
            let newOrigin = drawRect.origin.x + currentOffset
            
            let from = CGPoint(x: newOrigin, y: drawRect.origin.y)
            let to = CGPoint(x: newOrigin, y: drawRect.origin.y + CGFloat(rowCount)*rowHeight)
            
            drawLineFromPoint(from, to: to, lineWidth: tableLineWidth, lineColor: .black)
        }
        
        for i in 0..<rowCount {
            for j in 0...columnCount-1 {
                let currentOffset = { () -> CGFloat in
                    if let cws = tableDefinition?.columnWidths {
                        var offset:CGFloat = 0
                        for x in 0..<j {
                            offset += cws[x]
                        }
                        return offset
                    } else if let cw = columnWidth {
                        return cw * CGFloat(j)
                    }
                    
                    return 0 // default which should never be use, because either columnWidth, or columnsWidths is set
                }()
                
                let newOriginX = drawRect.origin.x + currentOffset
                let newOriginY = drawRect.origin.y + ((CGFloat(i)*rowHeight))
                
                let currentFont = { () -> UIFont in
                    if let f = tableDefinition?.fonts {
                        if (f.count > j){
                            return f[j]
                        }
                    } else if let f = font {
                        return f
                    }
                    
                    return UIFont.systemFont(ofSize: UIFont.systemFontSize)
                }()
                
                let currentTextColor = { () -> UIColor in
                    if let t = tableDefinition?.textColors {
                        if t.count > j {
                            return t[j]
                        }
                    }
                    
                    return UIColor.black
                }()
                
                let currentColumnWidth = { () -> CGFloat in
                    if let cw = tableDefinition?.columnWidths {
                        if cw.count > j {
                            return cw[j]
                        }
                    } else if let cw = columnWidth {
                        return cw
                    }
                    
                    return 100 // default which should never be use, because either columnWidth, or columnsWidths is set
                }()
                
                let currentAlignment = { () -> ContentAlignment in
                    if let ca = tableDefinition?.alignments {
                        if ca.count > j {
                            return ca[j]
                        }
                    }
                    else {
                        return .left
                    }
                    return .left
                }()
                
                let currentBackColor = {() -> UIColor in
                    if let bc = tableDefinition?.backColors {
                        if bc.count > j {
                            return bc[j]
                        }
                    }
                    else {
                        return .white
                    }
                    return .white
                }()
                
                let frame = CGRect(x: newOriginX, y: newOriginY, width: currentColumnWidth, height: rowHeight)
                let rect = CGRect(x: newOriginX+tableLineWidth, y: newOriginY+tableLineWidth, width: currentColumnWidth-2*tableLineWidth, height: rowHeight-2*tableLineWidth)
                
                drawBackColor(rect, backColor: currentBackColor, lineWidth: currentColumnWidth-2*tableLineWidth)
                
                if j == 1 && rowHeight > 30 {
                    drawMultilineTextInCell(frame, text: dataArray[i][j] as NSString, font: currentFont, textColor: currentTextColor, offSetX: 1, offSetY: 1)
                }
                //只有一列，如 綜合建議
                else if (j == 0 && j == columnCount - 1){
                    let rect = CGRect(x: newOriginX + 2, y: newOriginY + 2, width: currentColumnWidth - 4, height: rowHeight)
                    drawMultilineTextInCell(rect, text: dataArray[i][j] as NSString, font: currentFont, textColor: currentTextColor)
                }
                else {
                    drawTextInCell(frame, text: dataArray[i][j] as NSString, alignment: currentAlignment, font: currentFont, textColor: currentTextColor)
                }
            }
        }
        
        return drawRect
    }
    
    //画线
    fileprivate func drawLineFromPoint(_ from: CGPoint, to: CGPoint, lineWidth: CGFloat, lineColor: UIColor) {
        let context = UIGraphicsGetCurrentContext()!
        context.setLineWidth(lineWidth)
        
        let colorspace = CGColorSpaceCreateDeviceRGB()
        var color = CGColor(colorSpace: colorspace, components: [0.2, 0.2, 0.2, 1.0])
        
        if lineColor != .black {
            color = lineColor.cgColor
        }
        
        context.setStrokeColor(color!)
        context.move(to: CGPoint(x: from.x, y: from.y))
        context.addLine(to: CGPoint(x: to.x, y: to.y))
        
        context.strokePath()
    }
    
    /// 画圆环
    /// - Parameters:
    ///   - rect: 位置信息
    ///   - backColor: 背景色
    ///   - lineWidth: 线宽
    ///   - startAngle: 开始点  默认是  pi * 3/2   (12点方向)
    ///   - endAngle: 结束点
    ///   - clockwise: 是否是逆时针  默认 顺时针
    fileprivate func drawCircle(_ rect: CGRect, backColor:UIColor, lineWidth:CGFloat, startAngle:CGFloat, endAngle:CGFloat, clockwise:Bool) {
        // 获取当前context
        let ctx = UIGraphicsGetCurrentContext()!
        // 设置线的宽度
        ctx.setLineWidth(lineWidth)
        
//        ctx.setLineCap(.butt)
        // 设置画笔颜色
        let color = backColor.cgColor
        ctx.setStrokeColor(color)
        
        let originX = rect.size.width / 2
        let originY = rect.size.height / 2
        
        // 计算半径
        let radius = (originX > originY ? originY : originX) - 10.0
            
        // 逆时针画一个圆弧
        // 画一个圆弧作为context的路径，(x, y)是圆弧的圆心；radius是圆弧的半径；`startAngle' 是开始点的弧度;`endAngle' 是结束位置的弧度;（此处开始位置为屏幕坐标轴x轴正轴方向）; clockwise 为1是，圆弧是逆时针，0的时候就是顺时针。startAngle跟endAngle都是弧度制
        ctx.addArc(center: CGPoint(x: rect.origin.x + radius, y: rect.origin.y + radius), radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: clockwise)
        
        ctx.strokePath()
    }
    
    // 绘制背景色
    fileprivate func drawBackColor(_ rect: CGRect, backColor:UIColor, lineWidth: CGFloat) {
        //获取绘图上下文
        guard let context = UIGraphicsGetCurrentContext () else {
            return
        }
        context.setLineWidth(lineWidth)
        let color = backColor.cgColor
        
        context.setFillColor(color)
        context.fill(rect)
        
        context.strokePath()
    }
    
    
    //绘制文案
    fileprivate func drawMultilineTextInCellWithSpace(_ rect: CGRect, leftSpace: CGFloat, text: NSString, font: UIFont, textColor:UIColor) {
        
        let paraStyle = NSMutableParagraphStyle()
        
        let skew = 0.0
        
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: textColor,
            .paragraphStyle: paraStyle,
            .obliqueness: skew,
            .font: font
        ]
        
        let _ = text.size(withAttributes: attributes)
        let point = CGPoint(x: rect.origin.x + leftSpace, y: rect.origin.y + 2)
        let size = CGSize(width: rect.size.width - 2 - leftSpace, height: rect.size.height - 4)
        
        text.draw(in: CGRect(origin: point, size: size), withAttributes: attributes)
    }
    
    //绘制文案
    fileprivate func drawMultilineTextInCell(_ rect: CGRect, text: NSString, font: UIFont, textColor:UIColor, offSetX: CGFloat = 2, offSetY: CGFloat = 2) {
        
        let paraStyle = NSMutableParagraphStyle()
        
        let skew = 0.0
        
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: textColor,
            .paragraphStyle: paraStyle,
            .obliqueness: skew,
            .font: font
        ]
        
        let _ = text.size(withAttributes: attributes)
        
        text.draw(in: CGRect(origin: CGPoint(x: rect.origin.x + offSetX, y: rect.origin.y + offSetY), size: rect.size), withAttributes: attributes)
    }
    
    
    fileprivate func drawImageInCell(_ rect: CGRect, image: UIImage, imageSize: CGSize, alignment: ContentAlignment) {
        
        let x:CGFloat = { () -> CGFloat in
            switch alignment {
            case .left:
                return (rect.size.width - imageSize.width)/2
            case .center:
                return (rect.size.width - imageSize.width)/2
            case .right:
                return rect.size.width - imageSize.width
            }
        }()
        let y = (rect.size.height - imageSize.height)/2
        
        image.draw(in: CGRect(x: rect.origin.x + x, y: rect.origin.y + y, width: imageSize.width, height: imageSize.height))
    }
    
    //绘制文案
    fileprivate func drawTextInCell(_ rect: CGRect, text: NSString, alignment: ContentAlignment, font: UIFont, textColor:UIColor) {
        let paraStyle = NSMutableParagraphStyle()
        
        let skew = 0.0
        
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: textColor,
            .paragraphStyle: paraStyle,
            .obliqueness: skew,
            .font: font
        ]
        
        let size = text.size(withAttributes: attributes)
        
        let x:CGFloat = { () -> CGFloat in
            switch alignment {
            case .left:
                return 0
            case .center:
                return (rect.size.width - size.width)/2
            case .right:
                return rect.size.width - size.width
            }
        }()
        let y = (rect.size.height - size.height)/2
        
        text.draw(at: CGPoint(x: rect.origin.x + x, y: rect.origin.y + y), withAttributes: attributes)
    }
    
    
    //绘制文案
    fileprivate func drawLabelInCell(_ rect: CGRect, text: String, alignment: ContentAlignment, font: UIFont, textColor:UIColor) {
        
        let label = UILabel(frame: rect)
        label.numberOfLines = 0
        label.text = text
        
        if alignment == .center {
            label.textAlignment = .center
        }
        else if alignment == .right {
            label.textAlignment = .right
        }
        else {
            label.textAlignment = .left
        }
        
        label.font = font
        label.textColor = textColor
        
        label.drawText(in: rect)
    }
    
    //绘制文案
    fileprivate func drawLabelMutableAttrStringInCell(_ rect: CGRect, text: NSMutableAttributedString, alignment: ContentAlignment) {
        
        let label = UILabel(frame: rect)
        label.attributedText = text
        label.numberOfLines = 0
        if alignment == .center {
            label.textAlignment = .center
        }
        else if alignment == .right {
            label.textAlignment = .right
        }
        else {
            label.textAlignment = .left
        }
        label.drawText(in: rect)
    }
    
    
    enum ArrangementDirection {
        case horizontal
        case vertical
    }
    
    open func generatePDFdata() -> Data {
        
        let pdfData = NSMutableData()
        
        UIGraphicsBeginPDFContextToData(pdfData, pageBounds, nil)
        UIGraphicsBeginPDFPageWithInfo(pageBounds, nil)
        
        var currentOffset = CGPoint(x: pageMarginLeft, y: pageMarginTop)
        var alignment = ContentAlignment.left
        var arrangementDirection = ArrangementDirection.vertical
        var lastYOffset = currentOffset.y
        
        for command in commands {
            
            switch command{
            case let .addText(text, font, textColor):
                let textFrame = drawText(text, font: font, textColor: textColor, alignment: alignment, currentOffset: currentOffset)
                lastYOffset = textFrame.origin.y + textFrame.height
                switch arrangementDirection {
                case .horizontal:
                    currentOffset = CGPoint(x: textFrame.origin.x + textFrame.width, y: currentOffset.y)
                case .vertical:
                    currentOffset = CGPoint(x: currentOffset.x, y: lastYOffset)
                }
                
            case let .addAttributedText(attributedText):
                let textFrame = drawAttributedText(attributedText, currentOffset: currentOffset)
                lastYOffset = textFrame.origin.y + textFrame.height
                switch arrangementDirection {
                case .horizontal:
                    currentOffset = CGPoint(x: textFrame.origin.x + textFrame.width, y: currentOffset.y)
                case .vertical:
                    currentOffset = CGPoint(x: currentOffset.x, y: lastYOffset)
                }
                
            case let .addImage(image):
                let imageFrame = drawImage(image, alignment: alignment, currentOffset: currentOffset)
                lastYOffset = imageFrame.origin.y + imageFrame.height
                switch arrangementDirection {
                case .horizontal:
                    currentOffset = CGPoint(x: imageFrame.origin.x + imageFrame.width, y: currentOffset.y)
                case .vertical:
                    currentOffset = CGPoint(x: currentOffset.x, y: lastYOffset)
                }
                
            case let .addLineSeparator(height: height):
                let drawRect = drawLineSeparator(height: height, currentOffset: currentOffset)
                lastYOffset = drawRect.origin.y + drawRect.height
                switch arrangementDirection {
                case .horizontal:
                    currentOffset = CGPoint(x: drawRect.origin.x + drawRect.width, y: currentOffset.y)
                case .vertical:
                    currentOffset = CGPoint(x: currentOffset.x, y: lastYOffset)
                }
            case let .addFIHLineSeparator(size: size, lineColor: lineColor):
                
                let drawRect = drawFIHLineSeparator(size: size, currentOffset: currentOffset, lineColor: lineColor)
                lastYOffset = drawRect.origin.y + drawRect.height
                switch arrangementDirection {
                case .horizontal:
                    currentOffset = CGPoint(x: drawRect.origin.x + drawRect.width, y: currentOffset.y)
                case .vertical:
                    currentOffset = CGPoint(x: currentOffset.x, y: lastYOffset)
                }
            case let .addLineSpace(space):
                lastYOffset = currentOffset.y + space
                currentOffset = CGPoint(x: currentOffset.x, y: lastYOffset)
                
            case let .addHorizontalSpace(space):
                lastYOffset = currentOffset.y
                currentOffset = CGPoint(x: currentOffset.x + space, y: currentOffset.y)
                
            case let .addTable(rowCount, columnCount, rowHeight, columnWidth, tableLineWidth, font, tableDefinition, dataArray):
                let tableFrame = drawTable(rowCount: rowCount, alignment: alignment, columnCount: columnCount, rowHeight: rowHeight, columnWidth: columnWidth, tableLineWidth: tableLineWidth, font: font, tableDefinition: tableDefinition, dataArray: dataArray, currentOffset: currentOffset)
                lastYOffset = tableFrame.origin.y + tableFrame.height
                switch arrangementDirection {
                case .horizontal:
                    currentOffset = CGPoint(x: tableFrame.origin.x + tableFrame.width, y: currentOffset.y)
                case .vertical:
                    currentOffset = CGPoint(x: currentOffset.x, y: lastYOffset)
                }
                
            case let .addFIHTable(rowCount, columnCount, rowHeight, rowHeightRefer, columnWidth, tableLineWidth, tableLineColor, font, tableDefinition, dataArray, columnLine, rowLine, imageSize, rowFirstLineShow) :
                let tableFrame = drawFIHTable(rowCount: rowCount, alignment: alignment, columnCount: columnCount, rowHeight: rowHeight, rowHeightRefer: rowHeightRefer, columnWidth: columnWidth, tableLineWidth: tableLineWidth, tableLineColor: tableLineColor, font: font, tableDefinition: tableDefinition, dataArray: dataArray, currentOffset: currentOffset, columnLine: columnLine, rowLine: rowLine, imageSize: imageSize, rowFirstLineShow: rowFirstLineShow!)
                lastYOffset = tableFrame.origin.y + tableFrame.height
                switch arrangementDirection {
                case .horizontal:
                    currentOffset = CGPoint(x: tableFrame.origin.x + tableFrame.width, y: currentOffset.y)
                case .vertical:
                    currentOffset = CGPoint(x: currentOffset.x, y: lastYOffset)
                }
            case let .addFIHUITable(rowCount, columnCount, rowHeight, rowHeightRefer, columnWidth, tableLineWidth, tableLineColor, font, tableDefinition, dataArray, columnLine, rowLine, imageSize, rowFirstLineShow) :
                let tableFrame = drawFIHUITable(rowCount: rowCount, alignment: alignment, columnCount: columnCount, rowHeight: rowHeight, rowHeightRefer: rowHeightRefer, columnWidth: columnWidth, tableLineWidth: tableLineWidth, tableLineColor: tableLineColor, font: font, tableDefinition: tableDefinition, dataArray: dataArray, currentOffset: currentOffset, columnLine: columnLine, rowLine: rowLine, imageSize: imageSize, rowFirstLineShow: rowFirstLineShow!)
                lastYOffset = tableFrame.origin.y + tableFrame.height
                switch arrangementDirection {
                case .horizontal:
                    currentOffset = CGPoint(x: tableFrame.origin.x + tableFrame.width, y: currentOffset.y)
                case .vertical:
                    currentOffset = CGPoint(x: currentOffset.x, y: lastYOffset)
                }
            case let .addFIHCircle(size, backColor, lineWidth, startAngle, endAngle, clockwise) :
                drawCircle(CGRect(origin: currentOffset, size: size), backColor: backColor, lineWidth: lineWidth, startAngle: startAngle, endAngle: endAngle, clockwise: clockwise)
                switch arrangementDirection {
                case .horizontal:
                    currentOffset = CGPoint(x: currentOffset.x + size.width, y: currentOffset.y)
                case .vertical:
                    lastYOffset = currentOffset.y + size.height
                    currentOffset = CGPoint(x: currentOffset.x, y: lastYOffset)
                }
            case let .addFIHSpace(space) :
                switch arrangementDirection {
                case .horizontal:
                    lastYOffset = currentOffset.y
                    currentOffset = CGPoint(x: currentOffset.x + space, y: currentOffset.y)
                case .vertical:
                    lastYOffset = currentOffset.y + space
                    currentOffset = CGPoint(x: currentOffset.x, y: lastYOffset)
                }
            case let .addTableLine(lineHeight, lineWidth, lineColor):
                let tableFrame = drawFIHTableLine(lineHeight: lineHeight, lineWidth: lineWidth, currentOffset: currentOffset, lineColor: lineColor)
                lastYOffset = tableFrame.origin.y + tableFrame.height
                switch arrangementDirection {
                case .horizontal:
                    currentOffset = CGPoint(x: tableFrame.origin.x + tableFrame.width, y: currentOffset.y)
                case .vertical:
                    currentOffset = CGPoint(x: currentOffset.x, y: lastYOffset)
                }
            case let .setContentAlignment(newAlignment):
                alignment = newAlignment
                
            case .beginNewPage:
                UIGraphicsBeginPDFPageWithInfo(pageBounds, nil)
                currentOffset = CGPoint(x: pageMarginLeft, y: pageMarginTop)
                lastYOffset = currentOffset.y
                
            case .beginHorizontalArrangement:
                arrangementDirection = .horizontal
                
            case .endHorizontalArrangement:
                arrangementDirection = .vertical
                currentOffset = CGPoint(x: pageMarginLeft, y: lastYOffset)
            }
        }
        
        UIGraphicsEndPDFContext()
        
        return pdfData as Data
    }
    
}


