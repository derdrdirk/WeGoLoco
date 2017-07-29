//
//  PasswordViewController.swift
//  Tinpons
//
//  Created by Dirk Hornung on 28/7/17.
//
//

import UIKit

class PasswordViewController: FirstSignInViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("password did load")
        if let myNavigationController = self.navigationController as? FirstSignInNavigationController {
           print(myNavigationController.userData.email)
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
