//
//  CarListFlowLayout.swift
//  CarLens
//


import UIKit

final class CarListFlowLayout: UICollectionViewFlowLayout {

    private var firstSetupDone = false

    private let spacingBetweenElements = 20

    override func prepare() {
        super.prepare()
        guard !firstSetupDone else { return }
        setup()
        firstSetupDone = true
    }

    private func setup() {
        guard let collectionView = collectionView else { return }
        scrollDirection = .horizontal
        minimumLineSpacing = 20
        itemSize = CGSize(width: collectionView.bounds.width - 80, height: collectionView.bounds.height)
        let inset = (collectionView.bounds.width - itemSize.width) / 2
        collectionView.contentInset = .init(top: 0, left: inset, bottom: 0, right: inset)
        collectionView.decelerationRate = UIScrollView.DecelerationRate.fast
    }

    /// SeeAlso: UICollectionViewFlowLayout
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }

    /// SeeAlso: UICollectionViewFlowLayout
    override class var layoutAttributesClass: AnyClass {
        return CarListLayoutAttributes.self
    }

    /// SeeAlso: UICollectionViewFlowLayout
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView = collectionView,
            let allAttributes = super.layoutAttributesForElements(in: rect) else { return nil }

        for attributes in allAttributes {
            let collectionCenter = collectionView.bounds.size.width / 2
            let offset = collectionView.contentOffset.x
            let normalizedCenter = attributes.center.x - offset

            let maxDistance = itemSize.width + minimumLineSpacing
            let distanceFromCenter = min(collectionCenter - normalizedCenter, maxDistance)
            let ratio = (maxDistance - abs(distanceFromCenter)) / maxDistance
            let normalizedRatio = min(1, max(0, ratio))

            guard let attributes = attributes as? CarListLayoutAttributes else { continue }
            attributes.progress = Double(normalizedRatio)
        }
        return allAttributes
    }

    /// SeeAlso: UICollectionViewFlowLayout
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint,
                                      withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView,
            let layoutAttributes = layoutAttributesForElements(in: collectionView.bounds) else {
            return .init(x: 0, y: 0)
        }
        // Snapping closest cell to the center
        let centerOffset = collectionView.bounds.size.width / 2
        let offsetWithCenter = proposedContentOffset.x + (proposedContentOffset.x * velocity.x) + centerOffset
        let closestAttribute = layoutAttributes
            .sorted { abs($0.center.x - offsetWithCenter) < abs($1.center.x - offsetWithCenter) }
            .first ?? UICollectionViewLayoutAttributes()
        return CGPoint(x: closestAttribute.center.x - centerOffset, y: 0)
    }
}
