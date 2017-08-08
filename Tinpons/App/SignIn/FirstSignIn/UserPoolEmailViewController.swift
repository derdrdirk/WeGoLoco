//
//  UserPoolEmailViewController.swift
//  WeGoLoco
//
//  Created by Dirk Hornung on 8/8/17.
//
//

import UIKit

class UserPoolEmailViewController: EmailViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func onValidEmailEntered() {
        self.performSegue(withIdentifier: "segueToUserPoolPasswordViewController", sender: self)
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
