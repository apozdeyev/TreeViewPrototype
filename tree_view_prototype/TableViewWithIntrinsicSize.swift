import UIKit

protocol IntrinsicSizeObserver : NSObjectProtocol {
	func onIntrinsicSizeChanged(view: UIView)
}

class TableViewWithIntrinsicSize: UITableView {
	weak open var intrinsicSizeObserver: IntrinsicSizeObserver?
	
	fileprivate var previousContentSize: CGSize = CGSize(width: 0, height: 0)
	
	public override var intrinsicContentSize: CGSize {
		get {
//			print("intrinsicContentSize (\(self.tag)): \(contentSize.height)")
			return contentSize
		}
	}
	
	public override func layoutSubviews() {
		var isContentSizeUpdated = false
		if previousContentSize != contentSize {
			invalidateIntrinsicContentSize()
			previousContentSize = contentSize
//			print("invalidateIntrinsicContentSize")
			isContentSizeUpdated = true
		}
		
//		print("layoutSubviews0 \(contentSize)")
		
		super.layoutSubviews()
		
//		print("layoutSubviews1 \(contentSize)")
		
		if isContentSizeUpdated {
			DispatchQueue.main.async() {
				self.intrinsicSizeObserver?.onIntrinsicSizeChanged(view: self)
			}
		}
	}
}
