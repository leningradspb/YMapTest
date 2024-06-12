//
//  StartModalOnMapVC.swift
//  YMapTest
//
//  Created by Eduard Kanevskii on 12.06.2024.
//

import UIKit

final class StartModalOnMapVC: UIViewController {
    private let collectionView = IntrinsicLastAddressesOnMapCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    // локализаций еще не было, поэтому хардкод
    private let whereToGoButton = PrimaryButton(text: "Куда едем?", isNavigateIcon: true)
    
    private var lastAddresses = StartModalOnMapModel.mocks
    /// 8
    private let lastAddressCellPadding: CGFloat = 8
    /// 16
    private let minimumLineSpacingForSection : CGFloat = 16
    /// 98
    private let lastAddressCellHeight: CGFloat = 98
    /// 2
    private let cellsPerWidthCount: CGFloat = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        setupWhereToGoButton()
        setupCollection()
    }
    
    private func setupWhereToGoButton() {
        view.addSubview(whereToGoButton)
        
        whereToGoButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Constants.Layout.commonVertical)
            $0.leading.equalToSuperview().offset(Constants.Layout.commonHorizontal)
            $0.trailing.equalToSuperview().offset(-Constants.Layout.commonHorizontal)
        }
    }
    
    private func setupCollection() {
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints {
//            $0.top.equalToSuperview().offset(100)
            $0.top.equalTo(whereToGoButton.snp.bottom)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
//            $0.height.equalTo(110)
            $0.bottom.equalToSuperview()
        }
        
        collectionView.register(LastAddressGridCell.self, forCellWithReuseIdentifier: LastAddressGridCell.identifier)
        collectionView.contentInset = UIEdgeInsets(top: Constants.Layout.mediumVertical, left: Constants.Layout.commonHorizontal, bottom: Constants.Layout.bottomPadding, right: Constants.Layout.commonHorizontal)
        collectionView.delegate = self
        collectionView.dataSource = self
//        collectionView.collectionViewLayout = makeCollectionViewLayout()
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .vertical
//            flowLayout.estimatedItemSize = CGSize(width: 375, height: 200)
        }
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isScrollEnabled = false
//        collectionView.contentInset.bottom =
//        collectionView.invalidateIntrinsicContentSize()
//        collectionView.reloadData()
    }
}

extension StartModalOnMapVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        lastAddresses.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LastAddressGridCell.identifier, for: indexPath) as? LastAddressGridCell, let model = lastAddresses[safe: indexPath.row] else { return UICollectionViewCell() }
        
        cell.update(with: model)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        collectionView.deselectItem(at: indexPath, animated: true)
        print("didSelectItemAt \(indexPath.row)")
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        /// отступ в констрейнтах
        let collectionViewPadding = Constants.Layout.commonHorizontal
        let width = (view.bounds.width / cellsPerWidthCount) - collectionViewPadding - lastAddressCellPadding
        let size = CGSize(width: width, height: lastAddressCellHeight)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return minimumLineSpacingForSection
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return lastAddressCellPadding
    }
}

private extension StartModalOnMapVC {
    enum Section {
        case main
    }
}

extension StartModalOnMapVC {
    struct StartModalOnMapModel: Hashable {
        let id: String
        let address: String?
        let time: String?
        
        static let mocks = [
                            StartModalOnMapModel(id: "1", address: "Восточная 7Г", time: "13 минут"),
                            StartModalOnMapModel(id: "2", address: "Проспект Космонавтов 128", time: "20 минут"),
                            StartModalOnMapModel(id: "3", address: "Восточная 7Г", time: "13 минут"),
                            StartModalOnMapModel(id: "4", address: "Проспект Космонавтов 128", time: "20 минут")
                            ]
    }
}
