//
//  TinponManagerTableViewCell.swift
//  Tinpons
//
//  Created by Dirk Hornung on 14/7/17.
//
//

import UIKit

class ManagerTableViewCell: UITableViewCell {

    var tinpon: DynamoDBTinpon? {
        didSet {
            updateUI()
        }
    }
    
    @IBOutlet weak var tinponImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var createdAtLabel: UILabel!
    @IBOutlet weak var activationSwitch: UISwitch!
    
    func updateUI() {
        if let tinpon = tinpon {
            nameLabel.text = tinpon.name
            let resizedImageUrl = "http://tinpons-userfiles-mobilehub-1827971537.s3-website-eu-west-1.amazonaws.com/300x400/"+tinpon.imgUrl!
            //tinponImage.imageFromServerURL(urlString: resizedImageUrl)
            activationSwitch.isOn = tinpon.active == true
            createdAtLabel.text = tinpon.createdAt?.dateFromISO8601?.DDMMyyyy
            descriptionLabel.text = tinpon.category!+" | "+(tinpon.price?.stringValue)!+" €"
        }
        
        setNeedsDisplay()
    }
    
    @IBAction func tabActivationSwitch(_ sender: UISwitch) {
        if sender.isOn {
            tinpon?.activateTinpon()
        } else {
            tinpon?.deactivateTinpon()
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
