//
//  GeneralUITabBarController.swift
//  Tinpons
//
//  Created by Dirk Hornung on 26/7/17.
//
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let titleFont : UIFont = UIFont(name: "Remachine Script Personal Use", size: 20.0)!

        UITabBarItem.appearance().setTitleTextAttributes([NSFontAttributeName: titleFont], for: .normal)

        // Do any additional setup after loading the view.
        
        self.tabBar.tintColor = #colorLiteral(red: 0.5019607843, green: 0.6901960784, blue: 0.9725490196, alpha: 1)
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
