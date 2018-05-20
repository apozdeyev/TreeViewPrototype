//
//  TreeViewController.swift
//  tree_view_prototype
//
//  Created by Anatoliy Pozdeyev on 16/05/2018.
//  Copyright © 2018 Hitask. All rights reserved.
//

// TODOs:
// 3. analyze performance
// 4. think how to reuse content cells of sub-items.

import Foundation
import UIKit

class TreeViewController: UIViewController, ITreeDataSource {
	@IBOutlet var treeView: TreeView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		treeView.treeDataSource = self
	}
	
	func dataSource(forItemsPath path: Array<Any>) -> ITableDataSource! {
		if path.count == 0 {
			return ArrayDataSource(for: Array(1...50))
		} else if path.count < 4 {
			return ArrayDataSource(for: Array(1...5))
//			return ArrayDataSource(for: [])
		} else {
			return ArrayDataSource(for: [])
		}
	}
	
}
