//
//  GenderViewController.swift
//  Tinpons
//
//  Created by Dirk Hornung on 29/7/17.
//
//

import UIKit

class GenderViewController: UIViewController {

    @IBOutlet weak var womanButton: UIButton!
    @IBOutlet weak var manButton: UIButton!
    @IBOutlet weak var continueButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // load init values + progressBar
        if let myNavigationController = self.navigationController as? FirstSignInNavigationController {
            let gender = myNavigationController.user.gender
            if gender != "" {
                if gender == "👩‍💼" {
                    womanButton.isSelected = true
                } else if gender == "👨‍💼" {
                    manButton.isSelected = true
                }
                continueButton.isEnabled = true
            }
            myNavigationController.progressView.progress = 0.6
        }
        
        continueButton.setTitleColor(#colorLiteral(red: 0.9646058058, green: 0.9646058058, blue: 0.9646058058, alpha: 1), for: .disabled)
        continueButton.setTitleColor(#colorLiteral(red: 0.5695158243, green: 0.7503048182, blue: 0.9790232778, alpha: 1), for: .normal)
        womanButton.setTitleColor(#colorLiteral(red: 0.5695158243, green: 0.7503048182, blue: 0.9790232778, alpha: 1), for: .selected)
        womanButton.setTitleColor(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1), for: .normal)
        womanButton.adjustsImageWhenHighlighted = false
        manButton.setTitleColor(#colorLiteral(red: 0.5695158243, green: 0.7503048182, blue: 0.9790232778, alpha: 1), for: .selected)
        manButton.setTitleColor(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1), for: .normal)
        manButton.adjustsImageWhenHighlighted = false

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func womanButtonTouched(_ sender: UIButton) {
      genderTouched(isWoman: true)
    }

    @IBAction func manButtonTouched(_ sender: UIButton) {
        genderTouched(isWoman: false)
    }
    
    func genderTouched(isWoman: Bool) {
        if isWoman {
            womanButton.isSelected = true
            manButton.isSelected = false
        } else {
            womanButton.isSelected = false
            manButton.isSelected = true

        }
        guardGender()
        continueButton.isEnabled = true
    }
    
    func guardGender() {
        if let myNavigationController = self.navigationController as? FirstSignInNavigationController {
            var gender = "👨‍💼"
            if womanButton.isSelected {
                gender = "👩‍💼"
            }
            myNavigationController.user.gender = gender
        }
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guardGender()
    }

}
