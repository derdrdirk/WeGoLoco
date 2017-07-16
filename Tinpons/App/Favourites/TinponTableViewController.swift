//
//  TinponTableViewController.swift
//  Tinpons
//
//  Created by Dirk Hornung on 14/7/17.
//
//

import UIKit

class TinponTableViewController: FavouritesTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        print("database")
    }
    
    override func updateDataSource() {
        tinpons = []
        Tinpon.loadAllTinponsForUser{ [weak self] tinpons in
            guard let strongSelf = self else { return }
            strongSelf.tinpons.append(contentsOf: tinpons)
            
            DispatchQueue.main.async {
                strongSelf.tableView.reloadData()
                strongSelf.refreshControl?.endRefreshing()
            }
        }
    }
    
    // MARK: Table Data Source
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tinponManagerCell", for: indexPath) as! TinponManagerTableViewCell
        cell.tinpon = tinpons[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tinpons[indexPath.row].deactivateTinpon()
            
            let cell = self.tableView(self.tableView, cellForRowAt: indexPath) as! TinponTableViewCell
            cell.tinpon?.active = NSNumber(value: true)
            tableView.setEditing(false, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Deactivate"
    }
}
