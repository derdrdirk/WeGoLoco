//
//  Profile.swift
//  Tinpons
//
//  Created by Dirk Hornung on 5/7/17.
//
//

import UIKit
import Eureka

class ProfileViewController: FormViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up Eureka form
        form +++ Section("Profil")
            <<< DateRow() { $0.value = Date(); $0.title = "Birthday" }
            <<< SegmentedRow<String>() {
                $0.title = "Gender"
                $0.options = ["👨‍💼", "👩‍💼"]
                $0.value = "👨‍💼"
            }
            <<< SliderRow() {
                $0.title = "Height"
                $0.value = 1.70
                $0.minimumValue = 1.00
                $0.maximumValue = 2.00
                 $0.steps = 100
            }
        form +++ Section("Tinpons")
            <<< MultipleSelectorRow<String>() {
                $0.title = "Categories"
                $0.options = ["👕", "👖", "👟", "👜", "🕶"]
                $0.value = ["👕", "👖", "👟"]
                }
                .onPresent { from, to in
                    to.sectionKeyForValue = { option in
                        switch option {
                        case "👕", "👖", "👟": return "Clothing"
                        case "👜", "🕶": return "Accessoires"
                        default: return ""
                        }
                    }
                }
        
    }

    @IBAction func cancel(_ sender: UIBarButtonItem) {
        presentingViewController?.dismiss(animated: true)
    }
    
    
   }
