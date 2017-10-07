//
//  selectProductCategoryViewController.swift
//  WeGoLoco
//
//  Created by Dirk Hornung on 8/9/17.
//
//

class SelectProductCategoryViewController: SelectCategoryViewController, AddProductProtocol {
    // MARK: - AddProductProtocol
    var tinpon: Tinpon!
    func guardTinpon() {
        tinpon.category = self.category
    }
    
    // MARK: - Model
    var category: String {
        get {
            return Categories.getCategoryfrom(name: singleSelection!).rawValue
        }
    }
    
    override func onContinue() {
        super.onContinue()
        performSegue(withIdentifier: "segueToColorsAndSizes", sender: nil)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guardTinpon()
        
        let sizesVC = segue.destination as! SizesViewController
        sizesVC.tinpon = tinpon
        sizesVC.gender = gender
        sizesVC.category = Categories.getCategoryfrom(name: singleSelection!)
    }
}
