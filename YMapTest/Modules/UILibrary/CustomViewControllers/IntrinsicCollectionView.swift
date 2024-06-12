

import UIKit

final class IntrinsicCollectionView: UICollectionView
{
    override var contentSize: CGSize
    {
        didSet {
            self.invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize
    {
        self.layoutIfNeeded()
        return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height)
    }
}

// Нужно для того, чтобы корректно отрабатывали тени у ячеек (иначе обрезаются) E.K
final class IntrinsicLastAddressesOnMapCollectionView: UICollectionView
{
    override var contentSize: CGSize
    {
        didSet {
            self.invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize
    {
        self.layoutIfNeeded()
        return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height + Constants.Layout.mediumVertical + Constants.Layout.bottomPadding)
    }
}
