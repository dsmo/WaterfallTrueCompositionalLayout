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
        private let contentInsets: NSDirectionalEdgeInsets
        private lazy var resolvedContentInsets: UIEdgeInsets = {
            let direction = UIView.userInterfaceLayoutDirection(for: .unspecified)
            let left, right: CGFloat
            if direction == .leftToRight {
                left = contentInsets.leading
                right = contentInsets.trailing
            } else {
                left = contentInsets.trailing
                right = contentInsets.trailing
            }
            return UIEdgeInsets(top: contentInsets.top, left: left, bottom: contentInsets.bottom, right: right)
        }()
        
        init(
            configuration: Configuration,
            collectionWidth: CGFloat
        ) {
            self.columnHeights = [CGFloat](repeating: 0, count: configuration.columnCount)
            self.columnCount = CGFloat(configuration.columnCount)
            self.itemHeightProvider = configuration.itemHeightProvider
            self.interItemSpacing = configuration.interItemSpacing
            self.collectionWidth = collectionWidth
            self.contentInsets = configuration.contentInsets
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
            return maxColumnHeight() + contentInsets.top + contentInsets.bottom
        }
    }
}

private extension WaterfallTrueCompositionalLayout.LayoutBuilder {
    private var columnWidth: CGFloat {
        let spacing = (columnCount - 1) * interItemSpacing
        return (collectionWidth - resolvedContentInsets.left - resolvedContentInsets.right - spacing) / columnCount
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
        let x = resolvedContentInsets.left + (width + interItemSpacing) * CGFloat(columnIndex())
        return CGPoint(x: x, y: y)
    }
    
    private func columnIndex() -> Int {
        columnHeights
            .enumerated()
            .min(by: { $0.element < $1.element })?
            .offset ?? 0
    }
}
