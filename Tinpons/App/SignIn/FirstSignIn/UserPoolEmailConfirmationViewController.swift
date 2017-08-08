//
//  UserPoolEmailConfirmationViewController.swift
//  WeGoLoco
//
//  Created by Dirk Hornung on 8/8/17.
//
//

import UIKit
import PromiseKit

class UserPoolEmailConfirmationViewController: EmailConfirmationViewController {

    var signInViewController: SignInViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        signInViewController = navigationController?.viewControllers[0] as! SignInViewController
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func onUserConfirmed() {
        firstly {
            UserAPI.save(user: signInNavigationController.user)
        }.then { Void -> Void in
            // Login new User
            self.signInViewController.tableDelegate?.getCell(self.signInViewController.tableView, for: self.signInViewController.userNameRow!)?.inputBox.text = self.signInNavigationController.user.email
            self.signInViewController.tableDelegate?.getCell(self.signInViewController.tableView, for: self.signInViewController.passwordRow!)?.inputBox.text = self.signInNavigationController.user.password
            
            self.signInViewController.handleUserPoolSignIn()
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
