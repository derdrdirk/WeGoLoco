//
//  InterestsTableViewController.swift
//  Tinpons
//
//  Created by Dirk Hornung on 29/7/17.
//
//

import UIKit

class InterestsTableViewController: UITableViewController {
    
    @IBOutlet weak var continueButton: UIButton!
    var categories = Array<String>()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let myNavigationController = self.navigationController as? FirstSignInNavigationController {
            myNavigationController.progressView.progress = 0.8
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none


        continueButton.setTitleColor(#colorLiteral(red: 0.9646058058, green: 0.9646058058, blue: 0.9646058058, alpha: 1), for: .disabled)
        continueButton.setTitleColor(#colorLiteral(red: 0.5695158243, green: 0.7503048182, blue: 0.9790232778, alpha: 1), for: .normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func 👞Switch(_ sender: UISwitch) {
        handleSwitch(sender: sender, switchValue: "👞")
    }
    
    @IBAction func 👖Switch(_ sender: UISwitch) {
        handleSwitch(sender: sender, switchValue: "👖")
    }
    
    @IBAction func 👕Switch(_ sender: UISwitch) {
        handleSwitch(sender: sender, switchValue: "👕")
    }
    
    
    func handleSwitch(sender: UISwitch, switchValue: String) {
        if sender.isOn {
            categories.append(switchValue)
        } else {
            categories.remove(at: categories.index(of: switchValue)!)
        }
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
            myNavigationController.userData.interests = categories
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guardInterests()
    }
}
