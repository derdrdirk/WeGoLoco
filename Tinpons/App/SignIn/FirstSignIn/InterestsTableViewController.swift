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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let myNavigationController = self.navigationController as? SignInNavigationController {
            myNavigationController.progressView.progress = 0.84
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // loadingAnimationProtocol
        loadingAnimationView = self.view
        
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        
        
        // load init values + progressView
        if let myNavigationController = self.navigationController as? SignInNavigationController {
            if myNavigationController.user.categories.isEmpty {
                myNavigationController.user.categories.forEach{
                    switch($0) {
                    case "👞":
                        👞Switch.isOn = true
                        print("touch shoe")
                    case "👖": 👖Switch.isOn = true
                    case "👕": 👕Switch.isOn = true
                    default: ()
                    }
                }
                categories = myNavigationController.user.categories
                validate()
            }
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
        if let myNavigationController = self.navigationController as? SignInNavigationController {
            myNavigationController.user.categories = categories
        }
    }
    
    @IBAction func continueButtonTouched(_ sender: UIButton) {
        if let myNavigationController = self.navigationController as? SignInNavigationController {
            startLoadingAnimation()
            UserAPI.update(preparedObject: myNavigationController.user, onCompletionClosure:  { [weak self] in
                guard let strongSelf = self else { return }
                DispatchQueue.main.async {
                    strongSelf.stopLoadingAnimation()
                    
                    
                    // clean registration
                    if let myNavigationController = strongSelf.navigationController as? SignInNavigationController {
                        myNavigationController.user = User()
                    }
                    strongSelf.navigationController?.popToRootViewController(animated: true)
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
