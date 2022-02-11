//
//  ChartsViewController.swift
//  FIHSimplePDF
//
//  Created by FIH on 2022/2/9.
//

import UIKit

class ChartsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.view.addSubview(self.tableView)
        
    }
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: self.view.frame, style: .plain)
        tableView.rowHeight = 65
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
}

extension ChartsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.selectionStyle = .none
        if indexPath.row == 0 {
            cell.textLabel?.text = "Line Chart"
        }
        else {
            cell.textLabel?.text = "Pie Chart"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            self.navigationController?.pushViewController(LineChartsViewController(), animated: true)
        }
        else if indexPath.row == 1 {
            self.navigationController?.pushViewController(PieChartsViewController(), animated: true)
        }
        
        
    }
    
}


