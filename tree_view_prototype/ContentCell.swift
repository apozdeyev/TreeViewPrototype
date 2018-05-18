//
//  ContentCell.swift
//  tree_view_prototype
//
//  Created by Anatoliy Pozdeyev on 24/04/2018.
//  Copyright © 2018 Hitask. All rights reserved.
//

import UIKit

protocol ContentCellDelegate : NSObjectProtocol {
	func onButtonTapped(cell: ContentCell)
}

class ContentCell: UITableViewCell {
	weak open var contentCellDelegate: ContentCellDelegate?
	
	@IBOutlet var title: UILabel!
	@IBOutlet var btn: UIButton!
	@IBAction func onBtn(_ sender: Any) {
		contentCellDelegate?.onButtonTapped(cell: self)
	}
	
	
}

