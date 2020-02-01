//
//  ViewController.swift
//  NumericSpringingExamples
//
//  Created by Geir-Kåre S. Wærp on 01/02/2020.
//  Copyright © 2020 GK. All rights reserved.
//

import UIKit

class TableViewController: UIViewController {
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
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    
}
