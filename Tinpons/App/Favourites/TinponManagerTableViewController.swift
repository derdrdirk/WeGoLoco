//
//  TinponTableViewController.swift
//  Tinpons
//
//  Created by Dirk Hornung on 14/7/17.
//
//

import UIKit

class TinponManagerTableViewController: UITableViewController, ResetUIProtocol {
    var tinpons: [Tinpon] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateDataSource()
        
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl?.addTarget(self, action: #selector(updateDataSource), for: UIControlEvents.valueChanged)
    }
    
    func resetUI() {
        print("reset tinpons manager")
        updateDataSource()
    }
    
    func updateDataSource() {
        Tinpon.loadAllTinponsForUser{ [weak self] tinpons in
            guard let strongSelf = self else { return }
            strongSelf.tinpons = tinpons
            
            DispatchQueue.main.async {
                strongSelf.tableView.reloadData()
                strongSelf.refreshControl?.endRefreshing()
            }
        }
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "tinponManagerCell", for: indexPath) as! TinponManagerTableViewCell
        cell.tinpon = tinpons[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tinpons[indexPath.row].deactivateTinpon()
            
            let cell = self.tableView(self.tableView, cellForRowAt: indexPath) as! TinponManagerTableViewCell
            cell.tinpon?.active = NSNumber(value: true)
            tableView.setEditing(false, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Deactivate"
    }
}
