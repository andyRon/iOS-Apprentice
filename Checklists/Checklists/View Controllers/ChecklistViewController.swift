//
//  ViewController.swift
//  Checklists
//
//  Created by Andy Ron on 2019/7/23.
//  Copyright © 2019 Andy Ron. All rights reserved.
//

import UIKit

class ChecklistViewController: UITableViewController, ItemDetailViewControllerDelegate {
  
//  var items = [ChecklistItem]()
  
  var checklist: Checklist!

  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.largeTitleDisplayMode = .never
    
//    loadChecklistItems()
    
    title = checklist.name
  }

  // MARK: - Table View Data Source
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return checklist.items.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ChecklistItem", for: indexPath)
    let item = checklist.items[indexPath.row]
    
    configureText(for: cell, with: item)
    configureCheckmark(for: cell, with: item)
    return cell
  }
  
  // MARK: - Table View Delegate
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    if let cell = tableView.cellForRow(at: indexPath) {
      let item = checklist.items[indexPath.row]
      item.toggleChecked()
      configureCheckmark(for: cell, with: item)
    }
    // 点击选中某一row后，背景颜色有一个动画，来表示被选中过
    tableView.deselectRow(at: indexPath, animated: true)
    
//    saveChecklistItems()
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    checklist.items.remove(at: indexPath.row)
    
    tableView.deleteRows(at: [indexPath], with: .automatic)
  }
  
  func configureCheckmark(for cell: UITableViewCell, with item: ChecklistItem) {
    let label = cell.viewWithTag(1001) as! UILabel
    
    if item.checked {
      label.text = "✔️"
    } else {
      label.text = ""
    }
  }
  
  func configureText(for cell: UITableViewCell, with item: ChecklistItem) {
    let label = cell.viewWithTag(1000) as! UILabel
//    label.text = item.text
    label.text = "\(item.itemID): \(item.text)"
  }
  
  // MARK: - Actions
  
  // MARK: - Add Item ViewController Delegate
  func itemDetailViewControllerDidCancel(_ contoller: ItemDetailViewController) {
    navigationController?.popViewController(animated: true)
    
//    saveChecklistItems()
  }
  
  func itemDetailViewController(_ controller: ItemDetailViewController, didFinishAdding item: ChecklistItem) {
    let newRowIndex = checklist.items.count
    checklist.items.append(item)
    
    let indexPath = IndexPath(row: newRowIndex, section: 0)
    tableView.insertRows(at: [indexPath], with: .automatic)
    
    navigationController?.popViewController(animated: true)
    
//    saveChecklistItems()
  }
  
  func itemDetailViewController(_ controller: ItemDetailViewController, didFinishEditing item: ChecklistItem) {
    if let index = checklist.items.firstIndex(of: item) {
      let indexPath = IndexPath(row: index, section: 0)
      if let cell = tableView.cellForRow(at: indexPath) {
        configureText(for: cell, with: item)
      }
    }
    navigationController?.popViewController(animated: true)
    
//    saveChecklistItems()
  }
  
  // MARK: - Navigation
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "AddItem" {
      let controller = segue.destination as! ItemDetailViewController
      controller.delegate = self
    } else if segue.identifier == "EditItem" {
      let controller = segue.destination as! ItemDetailViewController
      controller.delegate = self
      
      if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
        controller.itemToEdit = checklist.items[indexPath.row]
      }
    }
  }
  
//  func documentsDirectory() -> URL {
//    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//    return paths[0]
//  }
//
//  func dataFilePath() -> URL {
//    return documentsDirectory().appendingPathComponent("Checklists.plist")
//  }
//
//  func saveChecklistItems() {
//    let encoder = PropertyListEncoder()
//
//    do {
//      let data = try encoder.encode(items)
//
//      try data.write(to: dataFilePath(), options: Data.WritingOptions.atomic)
//    } catch {
//      print("Error encoding item array: \(error.localizedDescription)")
//    }
//  }
//
//  func loadChecklistItems() {
//    let path = dataFilePath()
//    // try? 表示如果失败就返回nil
//    if let data = try? Data(contentsOf: path) {
//      let decoder = PropertyListDecoder()
//      do {
//        // .self 表示数据的类型
//        items = try decoder.decode([ChecklistItem].self, from: data)
//      } catch {
//        print("Error decoding item array: \(error.localizedDescription)")
//      }
//    }
//  }
}

