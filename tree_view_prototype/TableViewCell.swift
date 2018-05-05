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
	
	static var instancesCount = 0
	
	public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier:reuseIdentifier)
		incrementAndShowInstancesCount()
	}
	
	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		incrementAndShowInstancesCount()
	}
	
	public func incrementAndShowInstancesCount() {
		TableViewCell.instancesCount += 1
		print("instancesCount: \(TableViewCell.instancesCount)")
	}
	
	public var parentTableView: UITableView?
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "reuseIdentifier")
		tableView.insetsLayoutMarginsFromSafeArea = false
	}
	
	func onCellHeightChanged(cell: UITableViewCell) {
		tableView.invalidateIntrinsicContentSize()
		
		tableView.beginUpdates()
		tableView.endUpdates()
		
		updateParentContainer()
	}
	
	@objc func updateParentContainer() {
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
			self.invalidateTableHeight()
		}
	}
	
	fileprivate func invalidateTableHeight() {
		tableView.invalidateIntrinsicContentSize()
		
		let tableCollapsed = (collapsed || num == 0)
		tableView.isHidden = tableCollapsed
		
		print("new tableViewHeight(\(title!.text!), \(self.tableView.tag): \(tableView.contentSize.height)");
		
		onHeightChanged()
		updateButtonTitle()
	}
	
	private func updateButtonTitle() {
		if (num == 0) {
			button.setTitle("", for: .normal)
		} else {
			button.setTitle("\(collapsed ? "+" : "-")\(num)", for: .normal)
		}
	}
	
	@IBAction func onBtn(_ sender: Any) {
		collapsed = !collapsed
	}
	
	@IBOutlet var title: UILabel!
	@IBOutlet var tableView: UITableView!
	@IBOutlet var button: UIButton!
	
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
		
		print("cellForRowAt: \(indexPath.row)");
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! TableViewCell
		
		cell.num = (num % 2 == 0 && depth < 20) ? 10 : 0
		cell.title.text = "\(title.text!)_\(indexPath.row)"
		cell.dynamicCellController = self
		cell.depth = depth + 1
		cell.parentTableView = tableView
		cell.tableView.tag = self.tag * 10 + indexPath.row
		
		return cell
	}
	
	public override func prepareForReuse() {
		super.prepareForReuse()
		
		print("prepareForReuse")
	}
}

