//
//  StartModalOnMapVC.swift
//  YMapTest
//
//  Created by Eduard Kanevskii on 12.06.2024.
//

import UIKit

final class StartModalOnMapVC: UIViewController {
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    fileprivate typealias DataSource = UICollectionViewDiffableDataSource<Section, String>
    fileprivate typealias Snapshot = NSDiffableDataSourceSnapshot<Section, String>
    private lazy var dataSource = makeDataSource()
    // локализаций еще не было, поэтому хардкод
    private let whereToGoButton = PrimaryButton(text: "Куда едем?", isNavigateIcon: true)
    
    private var lastAddresses = StartModalOnMapModel.mocks
    
    init() {
        super.init(nibName: nil, bundle: nil)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
            $0.top.equalTo(whereToGoButton.snp.bottom).offset(Constants.Layout.mediumVertical)
            $0.leading.equalToSuperview().offset(Constants.Layout.commonHorizontal)
            $0.trailing.equalToSuperview().offset(-Constants.Layout.commonHorizontal)
            $0.bottom.equalToSuperview()
        }
        
        collectionView.register(LastAddressGridCell.self, forCellWithReuseIdentifier: LastAddressGridCell.identifier)
        collectionView.collectionViewLayout = makeCollectionViewLayout()
        collectionView.delegate = self
        collectionView.dataSource = self.dataSource
        applySnapshot()
        collectionView.reloadData()
    }
    
    private func makeCollectionViewLayout() -> UICollectionViewLayout {
        let layoutSize: NSCollectionLayoutSize = .init(widthDimension: .fractionalWidth(1),
                                                       heightDimension: .absolute(152))
        let item = NSCollectionLayoutItem(layoutSize: layoutSize)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: layoutSize,
                                                       subitem: item,
                                                       count: 1)
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 16
        section.contentInsets = .init(top: 24, leading: 16, bottom: 16, trailing: 16)

        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    private func makeDataSource() -> DataSource {
        DataSource(collectionView: collectionView) { [weak self] collectionView, indexPath, id in
            guard let self = self,
                  let model = self.lastAddresses[safe: indexPath.row] else { return UICollectionViewCell() }
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LastAddressGridCell.identifier, for: indexPath) as! LastAddressGridCell
            cell.update(with: model)
            
            return cell
        }
    }
    
    private func applySnapshot() {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        let safe = lastAddresses.compactMap { $0.id }.uniqueElements
        snapshot.appendItems(safe, toSection: .main)
        DispatchQueue.main.async {
            self.dataSource.apply(snapshot)
        }
    }
}

extension StartModalOnMapVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        collectionView.deselectItem(at: indexPath, animated: true)
        print("didSelectItemAt \(indexPath.row)")
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
