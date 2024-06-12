//
//  IntrinsicTableView.swift
//  Gorod
//
//  Created by Ruslan Aiginin on 27/06/2019.
//  Copyright © 2019 RTG Soft. All rights reserved.
//

import UIKit

final class IntrinsicTableView: UITableView {
    
    override var contentSize: CGSize {
        didSet {
            self.invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        self.layoutIfNeeded()
        return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height + contentInset.top + contentInset.bottom)
    }
    
}
