//
//  TinponTableViewCell.swift
//  Tinpons
//
//  Created by Dirk Hornung on 14/7/17.
//
//

import UIKit

class TinponTableViewCell: UITableViewCell {

    var tinpon: Tinpon? {
        didSet {
            updateUI()
        }
    }
    
    @IBOutlet weak var tinponImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    func updateUI() {
        if let tinpon = tinpon {
            nameLabel.text = tinpon.name
            categoryLabel.text = tinpon.category
            priceLabel.text = String(tinpon.price as! Int)+"€"
            let resizedImageUrl = "http://tinpons-userfiles-mobilehub-1827971537.s3-website-eu-west-1.amazonaws.com/300x400/"+tinpon.imgUrl!
            tinponImageView.imageFromServerURL(urlString: resizedImageUrl)
            
            
        
            setNeedsDisplay()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
