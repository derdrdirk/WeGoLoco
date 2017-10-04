//
//  selectProductCategoryViewController.swift
//  WeGoLoco
//
//  Created by Dirk Hornung on 8/9/17.
//
//

class SelectProductCategoryViewController: SelectCategoryViewController {
    override func onContinue() {
        super.onContinue()
        performSegue(withIdentifier: "segueToColorsAndSizes", sender: nil)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let sizesVC = segue.destination as! SizesViewController
        sizesVC.gender = gender
        sizesVC.category = Categories.getCategoryfrom(name: singleSelection!)
    }
}
