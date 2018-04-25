//
//  TableViewController.swift
//  tree_view_prototype
//
//  Created by Anatoliy Pozdeyev on 24/04/2018.
//  Copyright © 2018 Hitask. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController, DynamicCellController {
	func onCellHeightChanged(cell: UITableViewCell) {
		tableView.beginUpdates()
		tableView.endUpdates()
	}
	

    override func viewDidLoad() {
        super.viewDidLoad()
		
		tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "reuseIdentifier")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! TableViewCell

		cell.num = indexPath.row
		cell.title.text = "\(indexPath.row)"
		cell.dynamicCellController = self
		cell.parentTableView = tableView
		
        // Configure the cell...

        return cell
    }

}
