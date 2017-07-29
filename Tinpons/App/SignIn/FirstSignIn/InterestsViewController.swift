//
//  InterestsViewController.swift
//  Tinpons
//
//  Created by Dirk Hornung on 29/7/17.
//
//

import UIKit

class InterestsViewController: UIViewController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let myNavigationController = self.navigationController as? FirstSignInNavigationController {
            myNavigationController.progressView.progress = 0.8
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let myNavigationController = self.navigationController as? FirstSignInNavigationController {
            print(myNavigationController.userData.gender)
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        if let myNavigationController = self.navigationController as? FirstSignInNavigationController {
            myNavigationController.progressView.progress = 0.6
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
