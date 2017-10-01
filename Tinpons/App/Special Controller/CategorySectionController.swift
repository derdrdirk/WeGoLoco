//
//  CategorySectionController.swift
//  WeGoLoco
//
//  Created by Dirk Hornung on 18/8/17.
//
//

import UIKit
import IGListKit

final class CategoryItems: NSObject {
    
    let categories: [String]
    let gender: String!
    init(gender: String) {
        self.gender = gender
        if gender == "male" {
            self.categories = Categories.male
        } else {
            self.categories = Categories.female
        }
    }
    
}

extension CategoryItems: ListDiffable {
    
    func diffIdentifier() -> NSObjectProtocol {
        return self
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return self === object ? true : self.isEqual(object)
    }
    
}

final class CategorySectionController: ListSectionController {
    
    private var object: CategoryItems?
    
    override init() {
        super.init()
        self.minimumInteritemSpacing = 5
        self.minimumLineSpacing = 5
    }
    
    override func numberOfItems() -> Int {
        return object!.categories.count
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
        let category = object!.categories[index]
        // imageName = "male/Shoes"
        let gender = object!.gender!
        let imageName = "\(gender)/\(category)"
        cell.image = UIImage(named: imageName)
        cell.text = category
        return cell
    }
    
    override func didUpdate(to object: Any) {
        self.object = object as? CategoryItems
    }
    
    override func didSelectItem(at index: Int) {
        let cell = self.cellForItem(at: index) as! CategoryCell
    }
    
}
