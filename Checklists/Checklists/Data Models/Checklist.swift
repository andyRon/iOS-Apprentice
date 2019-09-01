//
//  Checklist.swift
//  Checklists
//
//  Created by Andy Ron on 2019/7/25.
//  Copyright © 2019 Andy Ron. All rights reserved.
//

import Foundation

class Checklist: NSObject, Codable {
  var name = ""
  var items = [ChecklistItem]()
  var iconName = "No Icon"
  
  init(name: String, iconName: String = "No Icon") {
    self.name = name
    self.iconName = iconName
    super.init()
  }
  
  func countUncheckedItems() -> Int {
    var count = 0
    for item in items where !item.checked {
      count += 1
    }
    return count
  }
}
