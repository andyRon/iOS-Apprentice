//
//  AllListsViewController.swift
//  Checklists
//
//  Created by Andy Ron on 2019/7/25.
//  Copyright © 2019 Andy Ron. All rights reserved.
//

import UIKit

class AllListsViewController: UITableViewController, ListDetailViewControllerDelegate, UINavigationControllerDelegate {
  
  let cellIdentifier = "ChecklistCell"

  
  var dataModel: DataModel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationController?.navigationBar.prefersLargeTitles = true
    
//    tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
    
  
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    navigationController?.delegate = self
    let index = dataModel.indexOfSelectedChecklist
    if index > 0 && index < dataModel.lists.count {
      let checklist = dataModel.lists[index]
      performSegue(withIdentifier: "ShowChecklist", sender: checklist)
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    tableView.reloadData()
  }

  // MARK: - Table view data source
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dataModel.lists.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell: UITableViewCell!
    if let c = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) {
      cell = c
    } else {
      cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
    }
    
    let checklist = dataModel.lists[indexPath.row]
    cell.textLabel!.text = checklist.name
    cell.accessoryType = .detailDisclosureButton

    let count = checklist.countUncheckedItems()
    if checklist.items.count == 0 {
      cell.detailTextLabel!.text = "(No Items)"
    } else {
      cell.detailTextLabel!.text =  count == 0 ? "All Done" : "\(count) Remaining"
    }
    
    cell.imageView!.image = UIImage(named: checklist.iconName)
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    dataModel.indexOfSelectedChecklist = indexPath.row
    
    let checklist = dataModel.lists[indexPath.row]
    performSegue(withIdentifier: "ShowChecklist", sender: checklist)
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    dataModel.lists.remove(at: indexPath.row)
    tableView.deleteRows(at: [indexPath], with: .automatic)
  }
  
  override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
    let controller = storyboard?.instantiateViewController(withIdentifier: "ListDetailViewController") as! ListDetailViewController
    controller.delegate = self
    
    let checklist = dataModel.lists[indexPath.row]
    controller.checklistToEdit = checklist
    
    navigationController?.pushViewController(controller, animated: true)
  }
  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "ShowChecklist" {
      let controller = segue.destination as! ChecklistViewController
      controller.checklist = sender as? Checklist
    } else if segue.identifier == "AddChecklist" {
      let controller = segue.destination as! ListDetailViewController
      controller.delegate = self
    }
  }
  
  // MARK: - List Detail View Controller Delegate
  func listDetailViewControllerDidCancel(_ contoller: ListDetailViewController) {
    navigationController?.popViewController(animated: true)
  }
  
  func listDetailViewController(_ controller: ListDetailViewController, didFinishAdding checklist: Checklist) {
    dataModel.lists.append(checklist)
    dataModel.sortChecklists()
    
    tableView.reloadData()
    navigationController?.popViewController(animated: true)
  }
  
  func listDetailViewController(_ controller: ListDetailViewController, didFinishEditing checklist: Checklist) {
    dataModel.sortChecklists()
    
    tableView.reloadData()
    navigationController?.popViewController(animated: true)
  }
  
  // MARK: - Navigation Controller Delegates
  func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
    if viewController === self {
      dataModel.indexOfSelectedChecklist = -1
    }
  }
  
}
