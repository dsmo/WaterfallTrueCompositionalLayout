import UIKit

/// Pinterest/waterfall like layout allows to have shifted items of different heights independently
public final class WaterfallTrueCompositionalLayout {
    /// Creates `NSCollectionLayoutSection` instance  for `WaterfallTrueCompositionalLayout`
    /// - Parameters:
    ///   - config: Parameters describing your desired layout
    ///   - environment: environment which is accessible on provider closure for UICollectionView
    /// - Returns: Pinterest-like layout
    public static func makeLayoutSection(
        config: Configuration,
        environment: NSCollectionLayoutEnvironment
    ) -> NSCollectionLayoutSection {
        var items = [NSCollectionLayoutGroupCustomItem]()
        
        let contentWidth = environment.container.effectiveContentSize.width - config.contentInsets.leading - config.contentInsets.trailing
        let itemProvider = LayoutBuilder(
            configuration: config,
            collectionWidth: contentWidth
        )
        for i in 0..<config.itemCountProvider() {
            let item = itemProvider.makeLayoutItem(for: i)
            items.append(item)
        }
        
        let groupLayoutSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(itemProvider.contentHeight())
        )
        
        let group = NSCollectionLayoutGroup.custom(layoutSize: groupLayoutSize) { environment in
            return items
        }
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsetsReference = config.contentInsetsReference
        section.contentInsets = config.contentInsets
        return section
    }
}
