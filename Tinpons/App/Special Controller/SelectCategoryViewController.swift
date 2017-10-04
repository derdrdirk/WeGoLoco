//
//  CategorySelectorViewController.swift
//  WeGoLoco
//
//  Created by Dirk Hornung on 18/8/17.
//
//

import UIKit
import IGListKit

class SelectCategoryViewController: UIViewController, ListAdapterDataSource {

    public var gender: Gender!
    public var isMultipleSelection: Bool!
    public var segueWithIdentifier: String!
    
    public var singleSelection: String?
    public var multipleSelection = [String]()

    private var data = [Any]()
    lazy private var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    }()
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(collectionView)
        
        collectionView.backgroundColor = UIColor.white
        collectionView.allowsMultipleSelection = isMultipleSelection
        
        adapter.collectionView = collectionView
        adapter.dataSource = self
    
        // data
        data.append(CategoryItems(gender: gender))
        adapter.performUpdates(animated: true, completion: nil)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    
    // MARK: ListAdapterDataSource
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return data as! [CategoryItems]
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        let categorySectionController = CategorySectionController()
        categorySectionController.isMultipleSelection = isMultipleSelection
        categorySectionController.onContinue = onContinue
        return categorySectionController
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? { return nil }
    
    
    // MARK: - Action
    
    func onContinue() {
        if isMultipleSelection {
            multipleSelection = selectedCategories()!
        } else {
            singleSelection = selectedCategories()![0]
        }
    }
    
    @IBAction func touchContinue(_ sender: UIBarButtonItem) {
       onContinue()
    }

    // MARK: - Helper
    
    private func selectedCategories() -> [String]? {
        if let selectedIndexPaths = collectionView.indexPathsForSelectedItems {
            var categories = [String]()
            for indexPath in selectedIndexPaths {
                let cell = collectionView.cellForItem(at: indexPath) as! CategoryCell
                categories.append(cell.text!)
            }
            return categories
        } else {
            return nil
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
