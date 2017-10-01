//
//  selectProductCategoryViewController.swift
//  WeGoLoco
//
//  Created by Dirk Hornung on 8/9/17.
//
//

class SelectProductCategoryViewController: SelectCategoryViewController {
    override func touchContinue(_ sender: UIBarButtonItem) {
        super.touchContinue(sender)
        performSegue(withIdentifier: "segueToColorsAndSizes", sender: nil)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let colorsAndSizesVC = segue.destination as! ColorsAndSizesViewController
        colorsAndSizesVC.category = singleSelection
    }
}
