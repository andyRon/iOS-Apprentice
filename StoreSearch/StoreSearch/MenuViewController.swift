//
//  MenuViewController.swift
//  StoreSearch
//
//  Created by Andy Ron on 2019/9/2.
//  Copyright © 2019 Andy Ron. All rights reserved.
//

import UIKit

class MenuViewController: UITableViewController {
  
  weak var delegate: MenuViewControllerDelegate?
  
  override func viewDidLoad() {
      super.viewDidLoad()

      // Uncomment the following line to preserve selection between presentations
      // self.clearsSelectionOnViewWillAppear = false

      // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
      // self.navigationItem.rightBarButtonItem = self.editButtonItem
  }

  // MARK: - Table View Delegates
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    if indexPath.row == 0 {
      delegate?.menuViewControllerSendEmail(self)
    }
  }


}

protocol MenuViewControllerDelegate: class {
  func menuViewControllerSendEmail(_ controller: MenuViewController)
}
