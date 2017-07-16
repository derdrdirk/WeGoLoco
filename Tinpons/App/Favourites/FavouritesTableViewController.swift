//
//  FavouritesTableViewController.swift
//  Tinpons
//
//  Created by Dirk Hornung on 14/7/17.
//
//

import UIKit

class FavouritesTableViewController: UITableViewController {

    var tinpons: [Tinpon] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        updateDataSource()
        
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl?.addTarget(self, action: #selector(updateDataSource), for: UIControlEvents.valueChanged)
    }

    func updateDataSource() {
        tinpons = []
        SwipedTinpon.loadAllFavouriteTinpons{ [weak self] tinpons in
            guard let strongSelf = self else { return }
            strongSelf.tinpons.append(contentsOf: tinpons)
            
            DispatchQueue.main.async {
                strongSelf.tableView.reloadData()
                strongSelf.refreshControl?.endRefreshing()
            }
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tinpons.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tinponCell", for: indexPath) as! TinponTableViewCell
        cell.tinpon = tinpons[indexPath.row]
        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tinpons[indexPath.row].removeFromFavourites()
            tinpons.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } 
//            else if editingStyle == .insert {
//            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//        }    
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
