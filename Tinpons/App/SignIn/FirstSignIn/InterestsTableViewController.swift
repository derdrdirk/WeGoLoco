//
//  InterestsTableViewController.swift
//  Tinpons
//
//  Created by Dirk Hornung on 29/7/17.
//
//

import UIKit

class InterestsTableViewController: UITableViewController, LoadingAnimationProtocol {
    
    // MARK: LoadingAnimationProtocol
    var loadingAnimationView: UIView!
    var loadingAnimationOverlay: UIView!
    var loadingAnimationIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var 👞Switch: UISwitch!
    @IBOutlet weak var 👖Switch: UISwitch!
    @IBOutlet weak var 👕Switch: UISwitch!
    
    @IBOutlet weak var continueButton: UIButton!
    var categories = Set<String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // loadingAnimationProtocol
        loadingAnimationView = self.view
        
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        
        
        // load init values + progressView
        if let myNavigationController = self.navigationController as? FirstSignInNavigationController {
            if !myNavigationController.user.tinponCategories.isEmpty {
                myNavigationController.user.tinponCategories.forEach{
                    switch($0) {
                    case "👞":
                        👞Switch.isOn = true
                        print("touch shoe")
                    case "👖": 👖Switch.isOn = true
                    case "👕": 👕Switch.isOn = true
                    default: ()
                    }
                }
                categories = myNavigationController.user.tinponCategories
                validate()
            }
            myNavigationController.progressView.progress = 0.8
        }


        continueButton.setTitleColor(#colorLiteral(red: 0.9646058058, green: 0.9646058058, blue: 0.9646058058, alpha: 1), for: .disabled)
        continueButton.setTitleColor(#colorLiteral(red: 0.5695158243, green: 0.7503048182, blue: 0.9790232778, alpha: 1), for: .normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func 👞SwitchTouched(_ sender: UISwitch) {
        handleSwitch(sender: sender, switchValue: "👞")
    }
    
    @IBAction func 👖SwitchTouched(_ sender: UISwitch) {
        handleSwitch(sender: sender, switchValue: "👖")
    }
    
    @IBAction func 👕SwitchTocuhed(_ sender: UISwitch) {
        handleSwitch(sender: sender, switchValue: "👕")
    }
    
    
    func handleSwitch(sender: UISwitch, switchValue: String) {
        if sender.isOn {
            categories.insert(switchValue)
        } else {
            categories.remove(switchValue)
        }
        guardInterests()
        validate()
    }
    
    func validate() {
        if categories.isEmpty {
            continueButton.isEnabled = false
        } else {
            continueButton.isEnabled = true
        }
    }
    
    func guardInterests() {
        if let myNavigationController = self.navigationController as? FirstSignInNavigationController {
            myNavigationController.user.tinponCategories = categories
        }
    }
    
    @IBAction func continueButtonTouched(_ sender: UIButton) {
        print("dismiss")
        if let myNavigationController = self.navigationController as? FirstSignInNavigationController {
            startLoadingAnimation()
            UserAPI.save(preparedObject: myNavigationController.user, onCompletionClosure:  { [weak self] in
                guard let strongSelf = self else { return }
                DispatchQueue.main.async {
                    strongSelf.stopLoadingAnimation()
                    strongSelf.presentingViewController?.dismiss(animated: true, completion: nil)
                }
            })
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guardInterests()
    }
}
