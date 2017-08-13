//
//  FavouriteCollectionViewController.swift
//  Tinpons
//
//  Created by Dirk Hornung on 17/7/17.
//
//

import UIKit

private let reuseIdentifier = "favouriteCollectionViewCell"


class FavouriteCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, ResetUIProtocol {
    
    // MARK: ResetUIProtocol
    var didAppear: Bool = false
    func resetUI() {
        if didAppear {
            updateDataSource()
        }
    }
    
    var tinpons: [Tinpon] = []
    var refresher:UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ResetUIProtocol
        didAppear = true
        
        let collectionViewFlowLayout = UICollectionViewFlowLayout()
        let myCollectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: collectionViewFlowLayout)
        // A flow layout works with the collection view’s delegate object to determine the size of items, headers, and footers in each section and grid.
        // That delegate object must conform to the UICollectionViewDelegateFlowLayout protocol.
        myCollectionView.delegate = self
        myCollectionView.dataSource = self
        
        // init refresher
        self.refresher = UIRefreshControl()
        self.collectionView!.alwaysBounceVertical = true
        self.refresher.addTarget(self, action: #selector(updateDataSource), for: .valueChanged)
        self.collectionView!.refreshControl = refresher
        
        // load data
        updateDataSource()
    }
    
    
    func updateDataSource() {
        tinpons = []
        self.collectionView!.refreshControl?.beginRefreshing()
        TinponsAPI.getFavouriteTinpons{ [weak self] tinpons in
            guard let strongSelf = self else { return }
            if let tinpons = tinpons {
                strongSelf.tinpons.append(contentsOf: tinpons)
            }
            
            DispatchQueue.main.async {
                strongSelf.collectionView?.reloadData()
                strongSelf.collectionView!.refreshControl?.endRefreshing()
            }
        }

//        SwipedTinpon.loadAllFavouriteTinpons{ [weak self] tinpons in
//            guard let strongSelf = self else { return }
//            strongSelf.tinpons.append(contentsOf: tinpons)
//            
//            DispatchQueue.main.async {
//                strongSelf.collectionView?.reloadData()
//                strongSelf.collectionView!.refreshControl?.endRefreshing()
//            }
//        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return self.tinpons.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! FavouriteCollectionViewCell
        
        
        // cell size
        let width = self.view.bounds.size.width
        let height = width*4/3
//        
        cell.bounds.size.width = width
        cell.bounds.size.height = height
        cell.clipsToBounds = true
        cell.tinpon = tinpons[indexPath.row]
        
        return cell
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = self.view.bounds.size.width
        let height = width*4/3
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10;
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10;
    }
    

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
