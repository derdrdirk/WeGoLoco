//
//  CenterLabelCell.swift
//  WeGoLoco
//
//  Created by Dirk Hornung on 18/8/17.
//
//

import UIKit

final class CategoryCell: UICollectionViewCell {
    lazy private var imageView: UIImageView = {
        let imageView = UIImageView()
        self.backgroundView = imageView
        return imageView
    }()
    
    var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = newValue
        }
    }
    
    lazy private var label: UILabel = {
        let view = UILabel()
        view.backgroundColor = .clear
        view.textAlignment = .center
        view.textColor = .white
        view.font = Font.body()
        self.contentView.addSubview(view)
        return view
    }()
    
    var text: String? {
        get {
            return label.text
        }
        set {
            label.text = newValue
        }
    }
    
    override var isSelected: Bool {
        didSet {
            image = isSelected ? #imageLiteral(resourceName: "shirtNotSelected") : #imageLiteral(resourceName: "Shirt")
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // add overlay
       // self.contentView.insertSubview(overlay, aboveSubview: imageView)
        
        imageView.frame = contentView.bounds
        label.frame = contentView.bounds
    }
}
