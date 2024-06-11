//
//  CustomLabel.swift
//  YMapTest
//
//  Created by Eduard Kanevskii on 11.06.2024.
//

import UIKit

public class CustomLabel: UILabel {
    public init(font: UIFont, text: String = "", numberOfLines: Int = 0, textColor: UIColor = .textColor, textAlignment: NSTextAlignment = .left) {
        super.init(frame: .zero)
        self.text = text
        self.numberOfLines = numberOfLines
        self.textColor = textColor
        self.font = font
        self.textAlignment = textAlignment
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
