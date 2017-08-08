//
//  UserPoolEmailConfirmationViewController.swift
//  WeGoLoco
//
//  Created by Dirk Hornung on 8/8/17.
//
//

import UIKit

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
        print("onUserConfirmed")
        
        signInViewController.tableDelegate?.getCell(signInViewController.tableView, for: signInViewController.userNameRow!)?.inputBox.text = signInNavigationController.user.email
        signInViewController.tableDelegate?.getCell(signInViewController.tableView, for: signInViewController.passwordRow!)?.inputBox.text = signInNavigationController.user.password

        signInViewController.handleUserPoolSignIn()
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
