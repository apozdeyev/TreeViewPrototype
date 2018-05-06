//
//  TableViewCell.swift
//  tree_view_prototype
//
//  Created by Anatoliy Pozdeyev on 24/04/2018.
//  Copyright © 2018 Hitask. All rights reserved.
//

import UIKit

// TODO: fix broken  layout at orientation changing
protocol DynamicCellController {
	func onCellHeightChanged(cell: UITableViewCell)
}


class TableViewCell: UITableViewCell, UITableViewDataSource, DynamicCellController,  UIScrollViewDelegate {
	
	public var scrollingEventsNotifier: ScrollingEventsNotifier?  =  nil
	public var parentTableView: UITableView?
	public var dynamicCellController: DynamicCellController?
	public var indexPath: IndexPath?
	
	static var instancesCount = 0
	
	@IBOutlet var tableViewContainerHeight: NSLayoutConstraint!
	@IBOutlet var tableViewHeight: NSLayoutConstraint!
	@IBOutlet var tableViewTop: NSLayoutConstraint!
	@IBOutlet var tableViewContainer: UIView!
	@IBOutlet var title: UILabel!
	@IBOutlet var tableView: UITableView!
	@IBOutlet var button: UIButton!
	
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
		
		// TODO:? with a lot items cells are reused incorrectly at top level.
		
		//		print("prepareForReuse")
	}
	
	fileprivate func incrementAndShowInstancesCount() {
		TableViewCell.instancesCount += 1
		print("instancesCount: \(TableViewCell.instancesCount)")
	}

	fileprivate func invalidateTableViewHeight() {
		tableViewContainerHeight.constant = tableView.contentSize.height
		tableViewHeight.constant = min(tableView.contentSize.height, UIScreen.main.bounds.height)
		
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
	}

	// MARK: DynamicCellController

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
		scrollingEventsNotifier!.addListener(listener: cell)
		
		return cell
	}

	// MARK: UIScrollViewDelegate
	public func scrollViewDidScroll(_ scrollView: UIScrollView) {
		
		// set table position and offset
		
		let cellPositionRelativeToRoot = scrollingEventsNotifier!.getRootScrollView().convert(CGPoint(x: 0, y: 0), from: self)
		
		let bottonPosition = (tableViewContainerHeight.constant - tableViewHeight.constant)
		let relativePosition = scrollView.contentOffset.y - cellPositionRelativeToRoot.y - tableViewContainer.frame.origin.y
		let newTableViewTop = max(0, min(bottonPosition, relativePosition))
		
//		if  (depth == 0 && indexPath?.row == 1) {
//			print("BEGIN")
//
//			print("root height: \(scrollingEventsNotifier!.getRootScrollView().bounds.height)")
//			print("tableViewContainerHeight: \(tableViewContainerHeight.constant)")
//			print("tableViewHeight: \(tableViewHeight.constant)")
//			print("tablewViewContainer.y: \(tablewViewContainer.frame.origin.y)")
//			print("scrollView.contentOffset: \(scrollView.contentOffset.y)")
//			print("cellPositionRelativeToRoot.y: \(cellPositionRelativeToRoot.y)")
//			print("bottonPosition: \(bottonPosition)")
//			print("relativePosition: \(relativePosition)")
//
//			print("END")
//		}
		
		tableViewTop.constant = newTableViewTop
		tableView.contentOffset = CGPoint(x: 0, y: newTableViewTop)
	}
}

