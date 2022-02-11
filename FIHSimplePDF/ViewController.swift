//
//  ViewController.swift
//  Demo
//
//  Created by Suguru Kishimoto on 2016/02/04.
//
//

import UIKit
import SimplePDF
import WebKit
class ViewController: UIViewController {
    var webView : WKWebView!
    var documentsFileName : String!
    var shareTitle: String!

    
    fileprivate func pdfHealthTableItem(_ keyArr: [String], _ healthItems: [Any], _ itemWidth: CGFloat, _ flagColor: inout [String], _ pdf: SimplePDF, _ columnCount: Int, _ tableHeader: [Any], _ tableHeaderColor: String) {
        //遍历数组 取出 对应的key值
        for i in 0..<keyArr.count {
            var itemValues:[String] = []
            
            let key = keyArr[i]
            
            for item in healthItems {
                let dict:[String:Any] = item as! [String:Any]
                let signleInfo:[Any] = dict["info"] as! [Any]
                //NSLog("%@", signleInfo)
                for signleItem in signleInfo {
                    let signleDict:[String:Any] = signleItem as! [String:Any]
                    if signleDict["key"] as! String == key {
                        if itemValues.count < 2 {
                            itemValues.append(signleDict["title"] as! String)
                            itemValues.append(signleDict["refenrence"] as! String)
                        }
                        itemValues.append(signleDict["value"] as! String)
                    }
                }
            }
            NSLog("当前\(key)查询结束:\n%@",itemValues)
            
            var alignments:[ContentAlignment] = []
            var columnWidths: [CGFloat] = []
            var fonts:[UIFont] = []
            var textColors:[UIColor] = []
            var backColors:[UIColor] = [];
            
            for i in 0..<itemValues.count {
                alignments.append(.center)
                columnWidths.append(itemWidth)
                fonts.append(.systemFont(ofSize: 16))
                textColors.append(.black)
                
                if i > 1 && flagColor[i-2] == "1" {
                    NSLog("\(backColors)")
                    backColors.append(.green)
                }
                else {
                    backColors.append(.white)
                }
            }
            
            let tableDefinition = TableDefinition(alignments: alignments, columnWidths: columnWidths, fonts: fonts, textColors: textColors, backColors)
            
            if i > 17 {
                //超过 17行需要翻页，
                if i % 18 == 0 {
                    pdf.beginNewPage()
                    let userData : [String :Any] = getData()
                    pdfPageHeader(pdf, userData)
                    pdf.addText("檢查項目&結果", font: UIFont.systemFont(ofSize: 20), textColor: .darkGray)
                    pdfPageHealthItem(pdf, healthItems, tableHeaderColor, false)
                }
                
                pdf.addTable(1, columnCount: columnCount, rowHeight: 30, tableLineWidth: 2, tableDefinition: tableDefinition, dataArray: [itemValues])
                NSLog("一组数据结束")
                
                
            }
            else {
                //表数据
                pdf.addTable(1, columnCount: columnCount, rowHeight: 30, tableLineWidth: 2, tableDefinition: tableDefinition, dataArray: [itemValues])
            }
        }
    }
    
    fileprivate func pdfPageHealthItem(_ pdf: SimplePDF, _ healthItems: [Any], _ color: String, _ tableDetail: Bool) {
        
        pdf.addVerticalSpace(5)
        //获取 columnCount + 第一列 + 参考值
        let columnCount = healthItems.count + 2
        
        var tableHeader = ["", "參考值"]
        
        var keyArr:[String] = []
        
        var flagColor:[String] = ["0", "0", "0"]
        
        for (index, item) in healthItems.enumerated() {
            let dict:[String:Any] = item as! [String:Any]
            tableHeader.append(dict["date"] as! String)
            let signleInfo:[Any] = dict["info"] as! [Any]
            let color:String = dict["color"] as! String
            
            //颜色设置
            flagColor[index] = color
            
            //取出对应的检查项
            for i in 0..<signleInfo.count {
                let signleDict:[String:Any] = signleInfo[i] as! [String : Any]
                let key:String = signleDict["key"] as! String
                
                if !keyArr.contains(key) {
                    keyArr.append(key)
                }
            }
        }
        
        let itemWidth: CGFloat = CGFloat((Float(PDFPageSize.A4.width) - 40.0) / Float(5));
        
        var alignments:[ContentAlignment] = []
        var columnWidths: [CGFloat] = []
        var fonts:[UIFont] = []
        var textColors:[UIColor] = []
        var backColors:[UIColor] = [];
        
        for i in 0..<columnCount {
            if i == 0 {
                alignments.append(.left)
            }else {
                alignments.append(.center)
            }
            columnWidths.append(itemWidth)
            fonts.append(.systemFont(ofSize: 16))
            textColors.append(.black)
            
            if i > 1 && flagColor[i-2] == "1" || color == "1" {
                backColors.append(.green)
            }
            else {
                backColors.append(.white)
            }
        }
        
        let tableDefinition = TableDefinition(alignments: alignments, columnWidths: columnWidths, fonts: fonts, textColors: textColors, backColors)
        //表头
        pdf.addTable(1, columnCount: columnCount, rowHeight: 30, tableLineWidth: 2, tableDefinition: tableDefinition, dataArray: [tableHeader])
        
        
        if tableDetail {
            //设置健康内容数据
            pdfHealthTableItem(keyArr, healthItems, itemWidth, &flagColor, pdf, columnCount, tableHeader, color)
            pdf.addVerticalSpace(5)
        }
    
    }
    
    
    //公共头部
    fileprivate func pdfPageHeader(_ pdf: SimplePDF, _ userData: [String : Any]) {
        
        let headers:[String : Any] = userData["headers"] as! [String : Any]
        let userInfo:[String : String] = userData["userInfo"] as! [String : String]
        
        // 设置标题
        pdf.beginHorizontalArrangement()
        pdf.addVerticalSpace(15)
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "test", ofType: "png")!
        let image = UIImage(contentsOfFile: path)!
        pdf.setContentAlignment(.left)
        pdf.addImage(image)
        
        pdf.addVerticalSpace(53)
        pdf.addHorizontalSpace(5)
        pdf.setContentAlignment(.left)
        pdf.addText(headers["hospital"] as! String, font: UIFont.systemFont(ofSize: 25), textColor: .darkGray)
        
        pdf.addVerticalSpace(-38)
        pdf.setContentAlignment(.right)
        pdf.addText(headers["title"] as! String, font: UIFont.systemFont(ofSize: 36, weight: .bold), textColor: .darkGray)
        
        pdf.endHorizontalArrangement()
        
        pdf.addLineSpace(30)
        pdf.addLineSeparator()
        pdf.addVerticalSpace(5)
        pdf.setContentAlignment(.left)
        pdf.addText("輸出時間：" + userInfo["date"]!, font: UIFont.systemFont(ofSize: 20), textColor: .darkGray)
        
        let sex = userInfo["sex"] == "1" ? "女" : "男"
        pdf.addText("ID " + userInfo["num"]! + " | " + sex + " | " + userInfo["age"]!, font: UIFont.systemFont(ofSize: 20), textColor: .darkGray)
        pdf.addText("紀錄區間：" + userInfo["recordTime"]!, font: UIFont.systemFont(ofSize: 20), textColor: .darkGray)
        
        pdf.addVerticalSpace(5)
        pdf.addLineSeparator()
        pdf.addVerticalSpace(5)
        
    }
    
    
    @objc func shareBtnDidClick() {
        if documentsFileName == nil {
            return
        }
    
        //只要放 文件路径名称，不要放图片，不然 Airdrop 发送失败
        let shareItems:[Any] = [URL.init(fileURLWithPath: documentsFileName) as Any]
        let activityVC: UIActivityViewController = UIActivityViewController.init(activityItems: shareItems, applicationActivities:nil)
        //排除分享途径
        activityVC.excludedActivityTypes = [.postToFacebook, .mail]
        
        self.present(activityVC, animated: true, completion: nil)
    }
    
    
    @objc func btnDidClick() {
        
        let userData : [String :Any] = getData()
        
        let pdf = SimplePDF(pageSize: PDFPageSize.A4)
        
        pdfPageHeader(pdf, userData)
        
        pdf.addText("Company Name", font: UIFont.systemFont(ofSize: 20), textColor: .darkGray)
        pdf.addText("Address Line 1", font: UIFont.systemFont(ofSize: 20), textColor: .darkGray)
        pdf.addText("City State - 123456", font: UIFont.systemFont(ofSize: 20), textColor: .darkGray)
        
        
        //第二页
//        pdf.beginNewPage()
//        pdfPageHeader(pdf, userData)
        
        let healthItems: [Any] = userData["healthItems"] as! [Any]
        let color: String = userData["color"] as! String
        
        var elementArr: [Any] = []
        
        let healthItem : [String: Any] = healthItems.first as! [String : Any]
        let info : [Any] = healthItem["info"] as! [Any]
        
        let rowCount = info.count + 1
        
        for i in 0..<healthItems.count {
            
            elementArr.append(healthItems[i])
            
            // 插入最后一个数据，进行数据重组展示
            if (elementArr.count == 3 || i == healthItems.count-1) {
                
                if healthItems.count > 0 || (rowCount > 18) {
                    pdf.beginNewPage()
                    pdfPageHeader(pdf, userData)
                }
                
                pdf.addText("檢查項目&結果", font: UIFont.systemFont(ofSize: 20), textColor: .darkGray)
                pdfPageHealthItem(pdf, elementArr, color, true)
                NSLog("一组数据结束")
                elementArr = []
            }
        }
        
        
        
        if let documentDirectories = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
            
            let headers:[String : Any] = userData["headers"] as! [String : Any]
            
            let title = headers["title"] as! String
            
            shareTitle = "\(title)"
            
            documentsFileName = documentDirectories + "/" + shareTitle + ".pdf"
            
            let pdfData = pdf.generatePDFdata()
            do{
                try pdfData.write(to: URL(fileURLWithPath: documentsFileName), options: .atomic)
                print("\nThe generated pdf can be found at:")
                print("\n\t\(String(describing: documentsFileName))\n")
                
                
                webView.load(pdfData, mimeType: "application/pdf", characterEncodingName: "GBK", baseURL:NSURL.init(fileURLWithPath: "") as URL)
            }catch{
                print(error)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("123启动了")
        
        let webConfig = WKWebViewConfiguration()
        let frame = CGRect.init(x: 0, y: 150, width: view.frame.width, height: view.frame.height - 120)
        webView = WKWebView(frame: frame, configuration: webConfig)
        view.addSubview(webView)
        
        let btn = UIButton.init(type: .custom)
        btn.frame = CGRect.init(x: 30, y: 80, width: 100, height: 44)
        btn.setTitle("獲取數據", for: .normal)
        btn.setTitleColor(.red, for: .normal)
        btn.layer.borderColor = UIColor.red.cgColor
        btn.layer.borderWidth = 1
        btn.addTarget(self, action: #selector(getBtnDidClick), for: .touchUpInside)
        view.addSubview(btn)
        
        let shareBtn = UIButton.init(type: .custom)
        shareBtn.frame = CGRect.init(x: 200, y: 80, width: 100, height: 44)
        shareBtn.setTitle("分享文件", for: .normal)
        shareBtn.setTitleColor(.black, for: .normal)
        shareBtn.layer.borderColor = UIColor.black.cgColor
        shareBtn.layer.borderWidth = 1
        shareBtn.addTarget(self, action: #selector(shareBtnDidClick), for: .touchUpInside)
        view.addSubview(shareBtn)
    }
    
    @objc func getBtnDidClick() {
        //pdfDemo()
        self.navigationController?.pushViewController(ChartsViewController(), animated: true)
        
    }
    
    fileprivate func pdfDemo() {
        let pdf = SimplePDF(pageSize: PDFPageSize.A4)
        
        pdf.addText("绘制圆角")
        pdf.addVerticalSpace(30)
        //        pdf.addFIHCircle(size: CGSize(width: 100, height: 100), backColor: .red, )
        
        //        pdf.beginHorizontalArrangement()
        pdf.setContentAlignment(.right)
        pdf.addHorizontalSpace(PDFPageSize.A4.width - 120 - 30)
        pdf.addFIHCircle(size: CGSize(width: 120, height: 120), backColor: .gray, lineWidth: 20, startAngle: 0, endAngle: .pi * 2, clockwise: false)
        pdf.addFIHSpace(-120)
        pdf.addFIHCircle(size: CGSize(width: 120, height: 120), backColor: .green, lineWidth: 20, startAngle: .pi * 3/2, endAngle: .pi, clockwise: false)
        pdf.setContentAlignment(.center)
        pdf.addHorizontalSpace(13)
        pdf.addVerticalSpace(-95)
        pdf.addText("90%", font: .systemFont(ofSize: 26, weight: .bold), textColor: .green)
        pdf.addText("達成率", font: .systemFont(ofSize: 16, weight: .regular), textColor: .gray)
        
        if let documentDirectories = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
            
            shareTitle = "绘制圆角"
            
            documentsFileName = documentDirectories + "/" + shareTitle + ".pdf"
            
            let pdfData = pdf.generatePDFdata()
            do{
                try pdfData.write(to: URL(fileURLWithPath: documentsFileName), options: .atomic)
                print("\nThe generated pdf can be found at:")
                print("\n\t\(String(describing: documentsFileName))\n")
                
                
                webView.load(pdfData, mimeType: "application/pdf", characterEncodingName: "GBK", baseURL:NSURL.init(fileURLWithPath: "") as URL)
            }catch{
                print(error)
            }
        }
    }
    
    
    func getData() -> Dictionary<String, Any> {
        
        //第一组数据
        let dict : [String :Any] = ["key":"height", "title":"身高", "value": "02","refenrence":"02"]
        let dict1 : [String :Any] = ["key":"weight", "title":"體重", "value": "12","refenrence":"12"]
        let dict2 : [String :Any] = ["key":"eye", "title":"視力", "value": "4.8","refenrence":"5.0"]
        let dict21 : [String :Any] = ["key":"boolth", "title":"牙齒", "value": "4.8","refenrence":"5.0"]
        let dict22 : [String :Any] = ["key":"righteye", "title":"右眼", "value": "4.8","refenrence":"5.0"]
        let dict23 : [String :Any] = ["key":"heart", "title":"心臟", "value": "4.8","refenrence":"5.0"]
        let dict24 : [String :Any] = ["key":"blood", "title":"血液", "value": "4.8","refenrence":"5.0"]
        let dict25 : [String :Any] = ["key":"hand", "title":"手", "value": "4.8","refenrence":"5.0"]
        let dict26 : [String :Any] = ["key":"leg", "title":"腿", "value": "4.8","refenrence":"5.0"]
        let dict27 : [String :Any] = ["key":"boolth1", "title":"牙齒1", "value": "4.8","refenrence":"5.0"]
        let dict28 : [String :Any] = ["key":"righteye1", "title":"右眼1", "value": "4.8","refenrence":"5.0"]
        let dict29 : [String :Any] = ["key":"heart1", "title":"心臟1", "value": "4.8","refenrence":"5.0"]
        let dict30 : [String :Any] = ["key":"blood1", "title":"血液1", "value": "4.8","refenrence":"5.0"]
        let dict31 : [String :Any] = ["key":"hand1", "title":"手1", "value": "4.8","refenrence":"5.0"]
        let dict32 : [String :Any] = ["key":"leg1", "title":"腿1", "value": "4.8","refenrence":"5.0"]
        let dict33 : [String :Any] = ["key":"boolth11", "title":"牙齒11", "value": "4.8","refenrence":"5.0"]
        let dict34 : [String :Any] = ["key":"righteye11", "title":"右眼11", "value": "4.8","refenrence":"5.0"]
        let dict35 : [String :Any] = ["key":"heart11", "title":"心臟11", "value": "4.8","refenrence":"5.0"]
        let dict36 : [String :Any] = ["key":"blood11", "title":"血液11", "value": "4.8","refenrence":"5.0"]
        let dict37 : [String :Any] = ["key":"hand11", "title":"手11", "value": "4.8","refenrence":"5.0"]
        let dict38 : [String :Any] = ["key":"leg11", "title":"腿11", "value": "4.8","refenrence":"5.0"]
 
        var arr = [Dictionary<String, Any>]()
        arr.append(dict)
        arr.append(dict1)
        arr.append(dict2)
        arr.append(dict21)
        arr.append(dict22)
        arr.append(dict23)
        arr.append(dict24)
        arr.append(dict25)
        arr.append(dict26)
        arr.append(dict27)
        arr.append(dict28)
        arr.append(dict29)
        arr.append(dict30)
        arr.append(dict31)
        arr.append(dict32)
        arr.append(dict33)
        arr.append(dict34)
        arr.append(dict35)
        arr.append(dict36)
        arr.append(dict37)
        arr.append(dict38)
        
        
        let healthItem1 : [String: Any] = ["date":"2021/12/12", "info": arr, "color":"1"]
        
        //第二组数据
        let dict3 : [String :Any] = ["key":"height", "title":"身高", "value": "01","refenrence":"02"]
        let dict4 : [String :Any] = ["key":"weight", "title":"體重", "value": "13","refenrence":"12"]
        let dict5 : [String :Any] = ["key":"eye", "title":"視力", "value": "4.9","refenrence":"5.0"]
 
        var arr2 = [Dictionary<String, Any>]()
        arr2.append(dict3)
        arr2.append(dict4)
        arr2.append(dict5)
        arr2.append(dict21)
        arr2.append(dict22)
        arr2.append(dict23)
        arr2.append(dict24)
        arr2.append(dict25)
        arr2.append(dict26)
        arr2.append(dict27)
        arr2.append(dict28)
        arr2.append(dict29)
        arr2.append(dict30)
        arr2.append(dict31)
        arr2.append(dict32)
        arr2.append(dict33)
        arr2.append(dict34)
        arr2.append(dict35)
        arr2.append(dict36)
        arr2.append(dict37)
        arr2.append(dict38)
        
        let healthItem2 : [String: Any] = ["date":"2021/12/13", "info": arr2, "color":"0"]
        
        //第三组数据
        let dict6 : [String :Any] = ["key":"height", "title":"身高", "value": "03","refenrence":"02"]
        let dict7 : [String :Any] = ["key":"weight", "title":"體重", "value": "11","refenrence":"12"]
        let dict8 : [String :Any] = ["key":"eye", "title":"視力", "value": "5.0","refenrence":"5.0"]
 
        var arr3 = [Dictionary<String, Any>]()
        arr3.append(dict6)
        arr3.append(dict7)
        arr3.append(dict8)
        arr3.append(dict21)
        arr3.append(dict22)
        arr3.append(dict23)
        arr3.append(dict24)
        arr3.append(dict25)
        arr3.append(dict26)
        arr3.append(dict27)
        arr3.append(dict28)
        arr3.append(dict29)
        arr3.append(dict30)
        arr3.append(dict31)
        arr3.append(dict32)
        arr3.append(dict33)
        arr3.append(dict34)
        arr3.append(dict35)
        arr3.append(dict36)
        arr3.append(dict37)
        arr3.append(dict38)
        
        let healthItem3 : [String: Any] = ["date":"2021/12/14", "info": arr3, "color":"0"]
        
        
        //第四组数据
        let dict9 : [String :Any] = ["key":"height", "title":"身高", "value": "03","refenrence":"02"]
        let dict10 : [String :Any] = ["key":"weight", "title":"體重", "value": "11","refenrence":"12"]
        let dict11 : [String :Any] = ["key":"eye", "title":"視力", "value": "5.0","refenrence":"5.0"]
 
        var arr4 = [Dictionary<String, Any>]()
        arr4.append(dict9)
        arr4.append(dict10)
        arr4.append(dict11)
        arr4.append(dict21)
        arr4.append(dict22)
        arr4.append(dict23)
        arr4.append(dict24)
        arr4.append(dict25)
        arr4.append(dict26)
        arr4.append(dict27)
        arr4.append(dict28)
        arr4.append(dict29)
        arr4.append(dict30)
        arr4.append(dict31)
        arr4.append(dict32)
        arr4.append(dict33)
        arr4.append(dict34)
        arr4.append(dict35)
        arr4.append(dict36)
        arr4.append(dict37)
        arr4.append(dict38)
        
        let healthItem4 : [String: Any] = ["date":"2021/12/15", "info": arr4, "color":"0"]
        
        let healthArr = [healthItem1, healthItem2, healthItem3, healthItem4]//, healthItem5, healthItem6, healthItem7]
        
        let headers :[String :Any] = ["icon":"", "title":"健康檢查紀錄表", "hospital": "台中館"]
        let userInfo :[String :Any] = ["date":"2021/10/20", "num":"0933-123-456", "sex": "1", "age": "50", "recordTime": "2021年11月～2021年12月17日"]
        
        let healthInfo : [String: Any] = ["headers": headers, "userInfo": userInfo, "healthItems": healthArr, "color": "0"]
        
        // 字典或者数组 转 JSON
        let jsonData = try! JSONSerialization.data(withJSONObject: healthInfo, options: .prettyPrinted)
        let str = String(data: jsonData, encoding: .utf8)
        
        //路径
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        
        let filePath = path  + "/data666.json"

        try! str!.write(toFile: filePath, atomically: true, encoding: String.Encoding.utf8)
        print(filePath) //取件地址 点击桌面->前往->输入地址跳转取件
        
        return healthInfo
    }
}


//        var arr5 = [Dictionary<String, Any>]()
//        arr5.append(dict9)
//        arr5.append(dict10)
//        arr5.append(dict11)
//        arr5.append(dict21)
//        arr5.append(dict22)
//        arr5.append(dict23)
//        arr5.append(dict24)
//        arr5.append(dict25)
//        arr5.append(dict26)
//        arr5.append(dict27)
//        arr5.append(dict28)
//        arr5.append(dict29)
//        arr5.append(dict30)
//        arr5.append(dict31)
//        arr5.append(dict32)
//        arr5.append(dict33)
//        arr5.append(dict34)
//        arr5.append(dict35)
//        arr5.append(dict36)
//        arr5.append(dict37)
//        arr5.append(dict38)
//
//        let healthItem5 : [String: Any] = ["date":"2021/12/16", "info": arr5, "color":"1"]
//
//        var arr6 = [Dictionary<String, Any>]()
//        arr6.append(dict9)
//        arr6.append(dict10)
//        arr6.append(dict11)
//        arr6.append(dict21)
//        arr6.append(dict22)
//        arr6.append(dict23)
//        arr6.append(dict24)
//        arr6.append(dict25)
//        arr6.append(dict26)
//        arr6.append(dict27)
//        arr6.append(dict28)
//        arr6.append(dict29)
//        arr6.append(dict30)
//        arr6.append(dict31)
//        arr6.append(dict32)
//        arr6.append(dict33)
//        arr6.append(dict34)
//        arr6.append(dict35)
//        arr6.append(dict36)
//        arr6.append(dict37)
//        arr6.append(dict38)
//
//        let healthItem6 : [String: Any] = ["date":"2021/12/17", "info": arr6, "color":"0"]
//
//
//        var arr7 = [Dictionary<String, Any>]()
//        arr7.append(dict9)
//        arr7.append(dict10)
//        arr7.append(dict11)
//        arr7.append(dict21)
//        arr7.append(dict22)
//        arr7.append(dict23)
//        arr7.append(dict24)
//        arr7.append(dict25)
//        arr7.append(dict26)
//        arr7.append(dict27)
//        arr7.append(dict28)
//        arr7.append(dict29)
//        arr7.append(dict30)
//        arr7.append(dict31)
//        arr7.append(dict32)
//        arr7.append(dict33)
//        arr7.append(dict34)
//        arr7.append(dict35)
//        arr7.append(dict36)
//        arr7.append(dict37)
//        arr7.append(dict38)
//
//        let healthItem7 : [String: Any] = ["date":"2021/12/18", "info": arr7, "color":"0"]
