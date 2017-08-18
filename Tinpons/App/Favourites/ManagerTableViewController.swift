//
//  TinponTableViewController.swift
//  Tinpons
//
//  Created by Dirk Hornung on 14/7/17.
//
//

import UIKit
import Whisper

class ManagerTableViewController: UITableViewController, LoadingAnimationProtocol, ResetUIProtocol {
    
    // MARK: LoadingAnimationProtocol
    var loadingAnimationIndicator: UIActivityIndicatorView!
    var loadingAnimationOverlay: UIView!
    var loadingAnimationView: UIView!
    
    // MARK: ResetUIProtocol
    var didAppear: Bool = false
    func resetUI() {
        if(didAppear) {
            updateDataSource()
        }
    }
    
    
    var tinpons: [DynamoDBTinpon] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ResetUIProtocol
        didAppear = true
        
        // AnimationLoaderProtocol
        loadingAnimationView = self.tableView
        
        updateDataSource()
        
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "Tirar para actualizar")
        refreshControl?.addTarget(self, action: #selector(updateDataSource), for: UIControlEvents.valueChanged)
    }
    
    func updateDataSource() {
//        startLoadingAnimation()
//        
//        TinponWrapper.loadAllTinponsForSignedInUser{ [weak self] tinpons in
//            guard let strongSelf = self else { return }
//            strongSelf.tinpons = tinpons
//            
//            DispatchQueue.main.async {
//                print("manger loaded")
//                strongSelf.stopLoadingAnimation()
//                
//                strongSelf.tableView.reloadData()
//                strongSelf.refreshControl?.endRefreshing()
//            }
//        }
    }
    
    @IBAction func whisperThatTinponIsSaved(_ segue: UIStoryboardSegue) {
        let message = Message(title: "Tinpon saved.", backgroundColor: .green)
        // Show and hide a message after delay
        Whisper.show(whisper: message, to: navigationController!, action: .show)
    }
    
    // MARK: Table Data Source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tinpons.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "managerCell", for: indexPath) as! ManagerTableViewCell
        cell.tinpon = tinpons[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tinpons[indexPath.row].deactivateTinpon()
            
            let cell = self.tableView(self.tableView, cellForRowAt: indexPath) as! ManagerTableViewCell
            cell.tinpon?.active = NSNumber(value: true)
            tableView.setEditing(false, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Deactivate"
    }
}
