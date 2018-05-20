//
//  TableViewCell.swift
//  tree_view_prototype
//
//  Created by Anatoliy Pozdeyev on 24/04/2018.
//  Copyright © 2018 Hitask. All rights reserved.
//

import UIKit

extension Array {
	public func concatString() -> String {
		var str = ""
		for a in self {
			str += ":"
			str += (a as AnyObject).description
		}
		
		return str
	}
}

struct RowPointer: Hashable {
	let depth: Int
	let index: Int
}

protocol DynamicCellController {
	func onCellHeightChanged(cell: UITableViewCell)
}

extension UIScreen {
	public func longestDimension() -> CGFloat {
		return max(self.bounds.width, self.bounds.height)
	}
}

// Limitations:
// 1. only autoresized estimated height of content cell is supported.
class TreeViewCell: UITableViewCell, UITableViewDataSource, DynamicCellController,  UIScrollViewDelegate, ContentCellDelegate, IntrinsicSizeObserver {
	
	public var scrollingEventsNotifier: ScrollingEventsNotifier?  =  nil
	public var parentTableView: UITableView?
	public var dynamicCellController: DynamicCellController?
	
	static var instancesCount = 0
	static var collapsedRows: [String : Bool] = [:]
	
	@IBOutlet var tableViewForSubItemsContainerHeight: NSLayoutConstraint!
	@IBOutlet var tableViewForSubItemsHeight: NSLayoutConstraint!
	@IBOutlet var tableViewForSubItemsTop: NSLayoutConstraint!
	@IBOutlet var tableViewForSubItemsContainer: UIView!
	@IBOutlet var tableViewForSubItems: UITableView!
	@IBOutlet var tableViewForContentCell: TableViewWithIntrinsicSize!
	
	public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier:reuseIdentifier)
		incrementAndShowInstancesCount()
	}
	
	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		incrementAndShowInstancesCount()
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		tableViewForSubItems.register(UINib(nibName: "TreeViewCell", bundle: nil), forCellReuseIdentifier: "TreeViewCell")
		tableViewForSubItems.insetsLayoutMarginsFromSafeArea = false
		
		tableViewForContentCell.register(UINib(nibName: "ContentCell", bundle: nil), forCellReuseIdentifier: "ContentCell")
		tableViewForContentCell.intrinsicSizeObserver =  self
	}
	
	public override func prepareForReuse() {
		super.prepareForReuse()
		
		// print("prepareForReuse")
	}
	
//	fileprivate var itemsDataSource: ITableDataSource? {
//		didSet {
//			do {
//				try itemsDataSource?.performFetch()
//			} catch {
//				print("performFetch failed")
//			}
//
//			tableViewForSubItems.reloadData()
//		}
//	}
	
	fileprivate var itemsDataSource: ITableDataSource?
	
	public var treeDataSource: ITreeDataSource? {
		didSet {
			itemsDataSource = treeDataSource?.dataSource(forItemsPath: itemsPath)
			tableViewForContentCell.reloadData()
		}
	}
	
	public var itemsPath: Array<Any>? {
		didSet {
			updateCellPadding()
		}
	}
	
	func subItemsCount() -> Int {
		return Int(itemsDataSource?.numberOfObjects ?? 0)
	}
	
	fileprivate func updateCellPadding() {
		self.contentView.layoutMargins = UIEdgeInsetsMake(0, CGFloat(10 + 10 * depth()), 0, 0);
	}
	
	fileprivate func depth() -> Int {
		return itemsPath?.count ?? 0
	}
	
	fileprivate func item() -> Any {
		guard let item = itemsPath?.last else {
			print("itemsPath is unexpectedly not set.")
			return 0
		}
		
		return item
	}
	
	fileprivate var collapsed: Bool = true {
		didSet {
			invalidateSubItems()
			invalidateTableForSubItemsHeightAndLayout()
			updateButtonTitle()
			updateParentContainer()
		}
	}
	
	fileprivate func invalidateSubItems() {
		let tableCollapsed = (collapsed || subItemsCount() == 0)
		if tableCollapsed {
			tableViewForSubItems.dataSource = nil
		} else {
			tableViewForSubItems.dataSource = self
			// TODO: refactor
			do {
				try itemsDataSource?.performFetch()
			} catch {
				print("performFetch failed")
			}		}
		
		tableViewForSubItems.reloadData()
	}
	
	fileprivate func incrementAndShowInstancesCount() {
		TreeViewCell.instancesCount += 1
		print("instancesCount: \(TreeViewCell.instancesCount)")
	}

	fileprivate func invalidateTableViewHeight() {
		tableViewForSubItemsContainerHeight.constant = tableViewForSubItems.contentSize.height
		tableViewForSubItemsHeight.constant = min(tableViewForSubItems.contentSize.height, UIScreen.main.longestDimension())
	}
	
	fileprivate func invalidateTableForSubItemsHeightAndLayout() {
		invalidateTableViewHeight()
		// TODO: cell height is not updated.
//		layoutIfNeeded()
		setNeedsLayout()
//		layoutIfNeeded()
	}
	
	fileprivate func updateParentContainer() {
		if (dynamicCellController != nil) {
			dynamicCellController?.onCellHeightChanged(cell: self)
		}
	}

	fileprivate func updateButtonTitle() {
		tableViewForContentCell.reloadData()
	}

	// MARK: DynamicCellController

	fileprivate func updateRowCollapsedState() {
		TreeViewCell.collapsedRows[itemsPath!.concatString()] = collapsed
//		print("save state: \(itemsPath!) - \(collapsed)")
	}

	public func restoreRowCollapsedState() {
		let newCollapsedValue = TreeViewCell.collapsedRows[itemsPath!.concatString()] ?? true
		if newCollapsedValue != collapsed {
			collapsed = newCollapsedValue
			
			invalidateTableViewHeight()
			
//			print("restore state\(itemsPath!): \(newCollapsedValue), height: \(frame.height), table content height: \(tableView.contentSize.height)")
		}
	}

	func onCellHeightChanged(cell: UITableViewCell) {
		let tableCollapsed = (collapsed || subItemsCount() == 0)
		
		if !tableCollapsed {
			tableViewForSubItems.beginUpdates()
			tableViewForSubItems.endUpdates()
			
			invalidateTableForSubItemsHeightAndLayout()
		}
		
		updateParentContainer()
	}

	// MARK: UITableViewDataSource

	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if (tableView == tableViewForSubItems) {
			return subItemsCount()
		} else {
			return 1
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if (tableView == tableViewForSubItems) {
			return cellForSubItem(indexPath)
		} else {
			return cellForContent()
		}
	}
	
	func cellForSubItem(_ indexPath: IndexPath) -> UITableViewCell {
		
//		print("cellForSubItem \(itemsPath!.concatString()) - \(indexPath.row)")
		
		let cell = tableViewForSubItems.dequeueReusableCell(withIdentifier: "TreeViewCell", for: indexPath) as! TreeViewCell
		
		let cellItem = itemsDataSource!.object(at: UInt(indexPath.row))!
		cell.itemsPath = itemsPath! + [ cellItem ]
		cell.dynamicCellController = self
		cell.parentTableView = tableViewForSubItems
		cell.scrollingEventsNotifier = scrollingEventsNotifier
		cell.restoreRowCollapsedState()
		cell.treeDataSource = treeDataSource
		scrollingEventsNotifier!.addListener(listener: cell)
		
		return cell
	}
	
	func cellForContent() -> UITableViewCell {
//		print("cellForContent \(itemsPath!.concatString())")
		
		let cell = tableViewForContentCell.dequeueReusableCell(withIdentifier: "ContentCell", for: IndexPath(row: 0, section: 0)) as! ContentCell
		
		cell.title.text = itemsPath?.concatString()
		cell.btn.titleLabel?.text = subItemsCount().description
		cell.btn.setTitle("\(collapsed ? "+" : "-")\(subItemsCount().description)", for: .normal)
		cell.contentCellDelegate = self
		
		return cell
	}
	
	// MARK: UIScrollViewDelegate
	public func scrollViewDidScroll(_ scrollView: UIScrollView) {
		
		// set table position and offset
		
		let cellPositionRelativeToRoot = scrollingEventsNotifier!.getRootScrollView().convert(CGPoint(x: 0, y: 0), from: self)
		
		let bottomPosition = (tableViewForSubItemsContainerHeight.constant - tableViewForSubItemsHeight.constant)
		let relativePosition = scrollView.contentOffset.y - cellPositionRelativeToRoot.y - tableViewForSubItemsContainer.frame.origin.y
		let newTableOffset = max(0, min(bottomPosition, relativePosition))
		let newTableViewTop = newTableOffset + tableViewForContentCell.contentSize.height
		
		tableViewForSubItemsTop.constant = newTableViewTop
		tableViewForSubItems.contentOffset = CGPoint(x: 0, y: newTableOffset)
	}
	
	func updateTableViewForSubItemsPosition() {
		scrollViewDidScroll(scrollingEventsNotifier!.getRootScrollView())
	}

	
	func onButtonTapped(cell: ContentCell) {
		collapsed = !collapsed
		updateRowCollapsedState()
	}
	
	func onIntrinsicSizeChanged(view: UIView) {
//		print("onIntrinsicSizeChanged: \(itemsPath!.concatString())")
		
		updateTableViewForSubItemsPosition()
		onCellHeightChanged(cell: self)
	}
}

