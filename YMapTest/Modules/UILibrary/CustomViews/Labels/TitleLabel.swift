//
//  TitleLabel.swift
//  YMapTest
//
//  Created by Eduard Kanevskii on 11.06.2024.
//

import UIKit

public class TitleLabel: UILabel {
    public init(text: String = "", numberOfLines: Int = 0, textAlignment: NSTextAlignment = .left, fontSize: CGFloat = 18) {
        super.init(frame: .zero)
        self.numberOfLines = numberOfLines
        self.textColor = .textColor
        self.font = .appFont(weight: .medium, size: fontSize)
        self.textAlignment = textAlignment
        self.setContentHuggingPriority(.required, for: .vertical)
        self.setContentHuggingPriority(.required, for: .horizontal)
        self.lineBreakMode = .byWordWrapping
        self.text = text
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

