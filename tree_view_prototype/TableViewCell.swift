//
//  TableViewCell.swift
//  tree_view_prototype
//
//  Created by Anatoliy Pozdeyev on 24/04/2018.
//  Copyright © 2018 Hitask. All rights reserved.
//

import UIKit

// TODO: analyze performance at scrolling with huge amount and  near expanded rows at second and third level.

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


class TableViewCell: UITableViewCell, UITableViewDataSource, DynamicCellController,  UIScrollViewDelegate {

	public var scrollingEventsNotifier: ScrollingEventsNotifier?  =  nil
	public var parentTableView: UITableView?
	public var dynamicCellController: DynamicCellController?
	public var indexPath: IndexPath?
	
	static var instancesCount = 0
	static var collapsedRows: [RowPointer: Bool] = [:]
	
	@IBOutlet var tableViewContainerHeight: NSLayoutConstraint!
	@IBOutlet var tableViewHeight: NSLayoutConstraint!
	@IBOutlet var tableViewTop: NSLayoutConstraint!
	@IBOutlet var tableViewContainer: UIView!
	@IBOutlet var title: UILabel!
	@IBOutlet var tableView: UITableView!
	@IBOutlet var button: UIButton!
	@IBOutlet var contentStackView: UIStackView!
	
	public var depth: Int = 0 {
		didSet {
			self.contentView.layoutMargins = UIEdgeInsetsMake(0, CGFloat(10 + 10 * depth), 0, 0);
		}
	}
	public var num: Int = 0 {
		didSet {
			updateButtonTitle()
			tableView.reloadData()
		}
	}

	fileprivate var collapsed: Bool = true {
		didSet {
			invalidateTableViewContainerVisibility()
			invalidateTableViewHeight()
			updateButtonTitle()
			updateParentContainer()
		}
	}
	
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
		
		tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "reuseIdentifier")
		tableView.insetsLayoutMarginsFromSafeArea = false
	}
	
	public override func prepareForReuse() {
		super.prepareForReuse()
		
		// print("prepareForReuse")
	}
	
	fileprivate func incrementAndShowInstancesCount() {
		TableViewCell.instancesCount += 1
		print("instancesCount: \(TableViewCell.instancesCount)")
	}

	fileprivate func invalidateTableViewHeight() {
		tableViewContainerHeight.constant = tableView.contentSize.height
		tableViewHeight.constant = min(tableView.contentSize.height, UIScreen.main.longestDimension())
		
		layoutIfNeeded()
	}
	
	fileprivate func updateParentContainer() {
		if (dynamicCellController != nil) {
			dynamicCellController?.onCellHeightChanged(cell: self)
		}
	}
	
	fileprivate func invalidateTableViewContainerVisibility() {
		let tableCollapsed = (collapsed || num == 0)
		tableViewContainer.isHidden = tableCollapsed
	}

	fileprivate func updateButtonTitle() {
		if (num == 0) {
			button.setTitle("", for: .normal)
		} else {
			button.setTitle("\(collapsed ? "+" : "-")\(num)", for: .normal)
		}
	}
	
	@IBAction func onBtn(_ sender: Any) {
		collapsed = !collapsed
		updateRowCollapsedState()
	}

	// MARK: DynamicCellController

	fileprivate func updateRowCollapsedState() {
		let rowPointer = RowPointer(depth: depth, index: indexPath!.row)
		TableViewCell.collapsedRows[rowPointer] = collapsed
	}

	public func restoreRowCollapsedState() {
		let rowPointer = RowPointer(depth: depth, index: indexPath!.row)
		let newCollapsedValue = TableViewCell.collapsedRows[rowPointer] ?? true
		if newCollapsedValue != collapsed {
			collapsed = newCollapsedValue
			print("restored state(\(rowPointer): \(newCollapsedValue)")
		}
	}

	func onCellHeightChanged(cell: UITableViewCell) {
		tableView.beginUpdates()
		tableView.endUpdates()

		invalidateTableViewHeight()
		updateParentContainer()
	}

	// MARK: UITableViewDataSource

	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return num
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
//		print("cellForRowAt: \(indexPath.row)");
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! TableViewCell
		
		cell.num = (num % 2 == 0 && depth < 20) ? 10 : 0
		cell.title.text = "\(title.text!)_\(indexPath.row)"
		cell.dynamicCellController = self
		cell.depth = depth + 1
		cell.parentTableView = tableView
		cell.tableView.tag = self.tag * 10 + indexPath.row
		cell.scrollingEventsNotifier = scrollingEventsNotifier
		cell.indexPath = indexPath
		cell.restoreRowCollapsedState()
		scrollingEventsNotifier!.addListener(listener: cell)
		
		return cell
	}

	// MARK: UIScrollViewDelegate
	public func scrollViewDidScroll(_ scrollView: UIScrollView) {
		
		// set table position and offset
		
		let cellPositionRelativeToRoot = scrollingEventsNotifier!.getRootScrollView().convert(CGPoint(x: 0, y: 0), from: self)
		
		let bottomPosition = (tableViewContainerHeight.constant - tableViewHeight.constant)
		let relativePosition = scrollView.contentOffset.y - cellPositionRelativeToRoot.y - tableViewContainer.frame.origin.y
		let newTableOffset = max(0, min(bottomPosition, relativePosition))
		let newTableViewTop = newTableOffset + contentStackView.bounds.height
		
		if  (depth == 0 && indexPath?.row == 14) {
			print("BEGIN")

			print("root height: \(scrollingEventsNotifier!.getRootScrollView().bounds.height)")
			print("tableViewContainerHeight: \(tableViewContainerHeight.constant)")
			print("tableViewHeight: \(tableViewHeight.constant)")
			print("tablewViewContainer.y: \(tableViewContainer.frame.origin.y)")
			print("scrollView.contentOffset: \(scrollView.contentOffset.y)")
			print("cellPositionRelativeToRoot.y: \(cellPositionRelativeToRoot.y)")
			print("bottomPosition: \(bottomPosition)")
			print("relativePosition: \(relativePosition)")
			print("newTableViewTop: \(newTableViewTop)")

			print("END")
		}
		
		tableViewTop.constant = newTableViewTop
		tableView.contentOffset = CGPoint(x: 0, y: newTableOffset)
	}
}

