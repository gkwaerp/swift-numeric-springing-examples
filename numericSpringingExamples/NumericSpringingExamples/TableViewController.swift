//
//  ViewController.swift
//  NumericSpringingExamples
//
//  Created by Geir-Kåre S. Wærp on 01/02/2020.
//  Copyright © 2020 GK. All rights reserved.
//

import UIKit

class TableViewController: UIViewController {
    enum ExampleViewController: Int, CaseIterable {
        case translateSquashRotate
        
        var viewController: UIViewController {
            switch self {
            case .translateSquashRotate:
                return TranslateRotateSquashViewController()
            }
        }
        
        var description: String {
            switch self {
            case .translateSquashRotate:
                return "Translate, Squash, Rotate"
            }
        }
    }
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureTableView()
    }

    private func configureTableView() {
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
}

extension TableViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ExampleViewController.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let example = ExampleViewController(rawValue: indexPath.row)!
        cell.textLabel!.text = example.description
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let exampleVC = ExampleViewController(rawValue: indexPath.row)!.viewController
        self.navigationController?.pushViewController(exampleVC, animated: true)
    }
}
