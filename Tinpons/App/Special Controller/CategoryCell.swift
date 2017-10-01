//
//  CenterLabelCell.swift
//  WeGoLoco
//
//  Created by Dirk Hornung on 18/8/17.
//
//

import UIKit

final class CategoryCell: UICollectionViewCell {
    
    lazy private var overlay: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black
        view.alpha = 0.4
        self.backgroundView?.addSubview(view)
        return view
    }()
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
        view.adjustsFontSizeToFitWidth = true
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
            overlay.backgroundColor = isSelected ? .blue : .black
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        overlay.frame = contentView.bounds
        imageView.frame = contentView.bounds
        label.frame = CGRect(x: 10, y: 0, width: contentView.bounds.width - 2 * 10, height: contentView.bounds.height)
    }
}
