//
//  SubtitleLabel.swift
//  YMapTest
//
//  Created by Eduard Kanevskii on 11.06.2024.
//

import UIKit

public class SubtitleLabel: UILabel {
    public init(text: String = "", numberOfLines: Int = 0, textAlignment: NSTextAlignment = .left, fontSize: CGFloat = 14) {
        super.init(frame: .zero)
        self.text = text
        self.numberOfLines = numberOfLines
        self.textColor = .textColor
        self.font = .appFont(weight: .regular, size: fontSize)
        self.textAlignment = textAlignment
        self.lineBreakMode = .byWordWrapping
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
