//
//  EnterAddressModalVC.swift
//  YMapTest
//
//  Created by Eduard Kanevskii on 12.06.2024.
//

import UIKit

final class EnterAddressModalVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .primaryColor
        
    }

}
    
private extension EnterAddressModalVC {
    enum Section {
        case main
    }
}
