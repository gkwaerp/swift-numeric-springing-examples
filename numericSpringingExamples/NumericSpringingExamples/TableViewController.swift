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
        case translateRotateSquash
        
        var viewController: UIViewController {
            switch self {
            case .translateRotateSquash:
                return TranslateRotateSquashViewController()
            }
        }
        
        var description: String {
            switch self {
            case .translateRotateSquash:
                return "Translate, Rotate, Squash"
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let selectedIndexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: selectedIndexPath, animated: true)
        }
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
        let example = ExampleViewController(rawValue: indexPath.row)!
        let exampleVC = example.viewController
        self.navigationController?.pushViewController(exampleVC, animated: true)
        exampleVC.title = example.description
    }
}
