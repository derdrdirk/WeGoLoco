//
//  FirstSignInNavigationController.swift
//  Tinpons
//
//  Created by Dirk Hornung on 28/7/17.
//
//

import UIKit

class FirstSignInNavigationController: UINavigationController {

    var progressView = UIProgressView()
    var userData = UserData()
    
    struct UserData {
        var email: String?
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // position progressBar
        progressView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 2)
        progressView.progress = 0.2
        progressView.trackTintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        progressView.progressTintColor = #colorLiteral(red: 0.5019607843, green: 0.6901960784, blue: 0.9725490196, alpha: 1)
        progressView.transform = progressView.transform.scaledBy(x: 1, y: 8)
        self.view.addSubview(progressView)
        
        // hide navigation Bar
        self.navigationController?.isNavigationBarHidden = true
        UINavigationBar.appearance().setBackgroundImage(
            UIImage(),
            for: .any,
            barMetrics: .default)
        
        UINavigationBar.appearance().shadowImage = UIImage()

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


