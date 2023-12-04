//
//  WaterfallTrueCompositionalLayout+LayoutBuilder.swift
//  
//
//  Created by Evgeny Shishko on 12.09.2022.
//

import UIKit

extension WaterfallTrueCompositionalLayout {
    final class LayoutBuilder {
        private var columnHeights: [CGFloat]
        private let columnCount: CGFloat
        private let itemHeightProvider: ItemHeightProvider
        private let interItemSpacing: CGFloat
        private let collectionWidth: CGFloat
        private let contentInsets: UIEdgeInsets
        
        init(
            configuration: Configuration,
            collectionWidth: CGFloat
        ) {
            let contentInsets = edgeInsets(for: configuration.contentInsets)
            self.columnHeights = [CGFloat](repeating: contentInsets.top, count: configuration.columnCount)
            self.columnCount = CGFloat(configuration.columnCount)
            self.itemHeightProvider = configuration.itemHeightProvider
            self.interItemSpacing = configuration.interItemSpacing
            self.collectionWidth = collectionWidth
            self.contentInsets = contentInsets
        }
        
        func makeLayoutItem(for row: Int) -> NSCollectionLayoutGroupCustomItem {
            let frame = frame(for: row)
            columnHeights[columnIndex()] = frame.maxY + interItemSpacing
            return NSCollectionLayoutGroupCustomItem(frame: frame)
        }
        
        func maxColumnHeight() -> CGFloat {
            return columnHeights.max() ?? 0
        }
        
        func contentHeight() -> CGFloat {
            return maxColumnHeight() + contentInsets.bottom
        }
    }
}

private extension WaterfallTrueCompositionalLayout.LayoutBuilder {
    private var columnWidth: CGFloat {
        let spacing = (columnCount - 1) * interItemSpacing
        return (collectionWidth - contentInsets.left - contentInsets.right - spacing) / columnCount
    }
    
    func frame(for row: Int) -> CGRect {
        let width = columnWidth
        let height = itemHeightProvider(row, width)
        let size = CGSize(width: width, height: height)
        let origin = itemOrigin(width: size.width)
        return CGRect(origin: origin, size: size)
    }
    
    private func itemOrigin(width: CGFloat) -> CGPoint {
        let y = columnHeights[columnIndex()].rounded()
        let x = contentInsets.left + (width + interItemSpacing) * CGFloat(columnIndex())
        return CGPoint(x: x, y: y)
    }
    
    private func columnIndex() -> Int {
        columnHeights
            .enumerated()
            .min(by: { $0.element < $1.element })?
            .offset ?? 0
    }
}

fileprivate func edgeInsets(for directionalEdgeInsets: NSDirectionalEdgeInsets) -> UIEdgeInsets {
    let direction = UIView.userInterfaceLayoutDirection(for: .unspecified)
    let left, right: CGFloat
    switch direction {
    case .rightToLeft:
        left = directionalEdgeInsets.trailing
        right = directionalEdgeInsets.leading
    default:
        left = directionalEdgeInsets.leading
        right = directionalEdgeInsets.trailing
    }
    return UIEdgeInsets(
        top: directionalEdgeInsets.top,
        left: left,
        bottom: directionalEdgeInsets.bottom,
        right: right
    )
}
