//
//  TreeView.swift
//  tree_view_prototype
//
//  Created by Anatoliy Pozdeyev on 15/05/2018.
//  Copyright © 2018 Hitask. All rights reserved.
//

import Foundation
import UIKit

protocol ScrollingEventsNotifier {
	func addListener(listener: UIScrollViewDelegate)
	
	func  getRootScrollView() -> UIScrollView
}

class TreeView: UITableView, UITableViewDataSource, DynamicCellController, ScrollingEventsNotifier {
	
	fileprivate var itemsDataSource: ITableDataSource? {
		didSet {
			do {
				try itemsDataSource?.performFetch()
			} catch {
				print("performFetch failed")
			}
			
			reloadData()
		}
	}
	
	public var treeDataSource: ITreeDataSource? {
		didSet {
			itemsDataSource = treeDataSource?.dataSource(forItemsPath: [])
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		self.register(UINib(nibName: "TreeViewCell", bundle: nil), forCellReuseIdentifier: "TreeViewCell")
		
		self.dataSource = self
	}
	
	
	var scrollingEventsListeners = [UIScrollViewDelegate]()
	
	func addListener(listener: UIScrollViewDelegate) {
		if !scrollingEventsListeners.contains(where: { (iter) -> Bool in
			listener.isEqual(iter)
		}) {
			scrollingEventsListeners.append(listener)
		}
	}
	
	func  getRootScrollView() -> UIScrollView {
		return self
	}
	
	func onCellHeightChanged(cell: UITableViewCell) {
		self.beginUpdates()
		self.endUpdates()
	}
	
	// MARK: - Table view data source
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		// #warning Incomplete implementation, return the number of rows
		return Int(itemsDataSource?.numberOfObjects ?? 0)
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		//		print("cellForRowAt [\(indexPath.row)]")
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "TreeViewCell", for: indexPath) as! TreeViewCell
		
		cell.itemsPath = [itemsDataSource!.object(at: UInt(indexPath.row))]
		cell.dynamicCellController = self
		cell.parentTableView = tableView
		cell.scrollingEventsNotifier = self
		cell.restoreRowCollapsedState()
		cell.treeDataSource = treeDataSource
		addListener(listener: cell)
		
		return cell
	}
	
	public func scrollViewDidScroll(_ scrollView: UIScrollView) {
		scrollingEventsListeners.forEach {
			$0.scrollViewDidScroll!(scrollView)
		}
	}
}
