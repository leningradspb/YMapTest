//
//  TitleLabel.swift
//  YMapTest
//
//  Created by Eduard Kanevskii on 11.06.2024.
//

import UIKit

public class TitleLabel: UILabel {
    public init(text: String = "", numberOfLines: Int = 0, textAlignment: NSTextAlignment = .left) {
        super.init(frame: .zero)
        self.text = text
        self.numberOfLines = numberOfLines
        self.textColor = .textColor
        self.font = .appFont(weight: .medium, size: 18)
        self.textAlignment = textAlignment
        self.setContentHuggingPriority(.required, for: .vertical)
        self.setContentHuggingPriority(.required, for: .horizontal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

