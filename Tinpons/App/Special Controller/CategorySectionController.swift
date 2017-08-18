//
//  CategorySectionController.swift
//  WeGoLoco
//
//  Created by Dirk Hornung on 18/8/17.
//
//

import UIKit
import IGListKit

final class CategoryItem: NSObject {
    
    let color: UIColor
    let itemCount: Int
    
    init(color: UIColor, itemCount: Int) {
        self.color = color
        self.itemCount = itemCount
    }
    
}

extension CategoryItem: ListDiffable {
    
    func diffIdentifier() -> NSObjectProtocol {
        return self
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return self === object ? true : self.isEqual(object)
    }
    
}

final class CategorySectionController: ListSectionController {
    
    private var object: CategoryItem?
    
    override init() {
        super.init()
        self.minimumInteritemSpacing = 5
        self.minimumLineSpacing = 5
    }
    
    override func numberOfItems() -> Int {
        return object?.itemCount ?? 0
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        let width = collectionContext?.containerSize.width ?? 0
        let itemSize = floor(width / 2) - 2.5
        return CGSize(width: itemSize, height: itemSize)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(of: CategoryCell.self, for: self, at: index) as? CategoryCell else {
            fatalError()
        }
        cell.backgroundColor = object?.color
        cell.image = UIImage(named: "shirt")
        cell.text = "\(index + 1)"
        return cell
    }
    
    override func didUpdate(to object: Any) {
        self.object = object as? CategoryItem
    }
    
}
