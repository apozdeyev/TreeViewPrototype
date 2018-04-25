//
//  TableViewCell.swift
//  tree_view_prototype
//
//  Created by Anatoliy Pozdeyev on 24/04/2018.
//  Copyright © 2018 Hitask. All rights reserved.
//

import UIKit

protocol DynamicCellController {
	func onCellHeightChanged(cell: UITableViewCell)
}


class TableViewCell: UITableViewCell, UITableViewDataSource, DynamicCellController {
	
	public var parentTableView: UITableView?
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "reuseIdentifier")
		tableView.insetsLayoutMarginsFromSafeArea = false
	}
	
	override func layoutSubviews() {
//		let oldHeight = frame.size.height
//		let oldTableContentHeight = tableView.contentSize.height
		
		let oldTableHeight = tableView.frame.size.height
		
		super.layoutSubviews()
		
//		let newHeight = frame.size.height
//		let newTableContentHeight = tableView.contentSize.height
		
//		if (oldHeight != newHeight) {
//			updateParentContainer()
//		}
		
		let tableContentHeight = tableView.contentSize.height
		let tableHeight = tableView.frame.size.height
		var newTableHeight:CGFloat = 0
		if (tableContentHeight != tableHeight) {
			if (collapsed || num == 0) {
				newTableHeight = 0
			} else {
				newTableHeight = tableView.contentSize.height
			}
		}

		if (abs(newTableHeight - tableViewHeight.constant) > 1) {
			tableViewHeight.constant = newTableHeight
//			setNeedsUpdateConstraints()
//			setNeedsLayout()
//			updateParentContainer()
		}
		
		updateParentContainer()
	}
	
	func onCellHeightChanged(cell: UITableViewCell) {
		tableView.beginUpdates()
		tableView.endUpdates()
		
		updateParentContainer()
	}
	
	@objc func updateParentContainer() {
		// TODO:???
//		tableViewHeight.constant = tableView.contentSize.height
		if (collapsed || num == 0) {
			tableViewHeight.constant = 0
		} else {
			tableViewHeight.constant = tableView.contentSize.height
		}
		
		if (dynamicCellController != nil) {
			dynamicCellController?.onCellHeightChanged(cell: self)
		}
	}
	
	public var dynamicCellController: DynamicCellController?

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
	public var collapsed: Bool = true {
		didSet {
			UIView.animate(withDuration: 0.3) {
				self.invalidateTableHeight()
			}
		}
	}
	
	fileprivate func invalidateTableHeight() {
		if (collapsed || num == 0) {
			tableViewHeight.constant = 0
		} else {
			tableViewHeight.constant = tableView.contentSize.height
		}
		
		print("new tableViewHeight(\(title!.text!)): \(tableView.contentSize.height)");
		
		layoutIfNeeded()
		onHeightChanged()
		updateButtonTitle()
		
//		parentTableView?.beginUpdates()
//		parentTableView?.endUpdates()
	}
	
	private func updateButtonTitle() {
		if (num == 0) {
			button.setTitle("", for: .normal)
		} else {
			button.setTitle("\(collapsed ? "+" : "-")\(num)", for: .normal)
		}
	}
	
	@IBAction func onBtn(_ sender: Any) {
//		tableView.invalidateHeight()
		collapsed = !collapsed
	}
	
	@IBOutlet var title: UILabel!
	@IBOutlet var tableView: UITableView!
	@IBOutlet var button: UIButton!
	
	@IBOutlet var tableViewHeight: NSLayoutConstraint!
	
	public func collapse() {
		collapsed = true
	}
	
	public func expand() {
		collapsed = false
	}
	
	private func onHeightChanged() {
		if (dynamicCellController != nil) {
			dynamicCellController?.onCellHeightChanged(cell: self)
		}
	}
	
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
	
	func numberOfSections(in tableView: UITableView) -> Int {
		// #warning Incomplete implementation, return the number of sections
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		// #warning Incomplete implementation, return the number of rows
		return num
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! TableViewCell
		
		cell.num = (num % 2 == 0 && depth < 2) ? 2 : 0
		cell.title.text = "\(title.text!)_\(indexPath.row)"
		cell.dynamicCellController = self
		cell.depth = depth + 1
		cell.parentTableView = tableView
		
		return cell
	}
}


//extension UITableView {
//	// TODO: fix, not work - it needs to know table height when it's height is zero, may be use not table view, but we need reused cells.
//	public func invalidateHeight() {
//		self.beginUpdates()
//		self.endUpdates()
//
//		let rowsCount = numberOfRows(inSection: 0)
//		for i in 0...rowsCount {
//			let cell = cellForRow(at: IndexPath.init(row: i, section: 0))
//			let t = cell?.frame
//		}
//
//		layoutIfNeeded()
//		let rowsCount2 = numberOfRows(inSection: 0)
//		layoutSubviews()
//		let rowsCount3 = numberOfRows(inSection: 0)
//	}
//}
