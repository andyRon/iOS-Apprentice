//
//  ChecklistItem.swift
//  Checklists
//
//  Created by Andy Ron on 2019/7/23.
//  Copyright © 2019 Andy Ron. All rights reserved.
//

import Foundation
import UserNotifications

class ChecklistItem: NSObject, Codable {
  var text = ""
  var checked = false
  
  var dueDate = Date()
  var shouldRemind = false
  var itemID = -1
  
  override init() {
    super.init()
    itemID = DataModel.nextChecklistItemID()
  }
  
  deinit {
    removeNotification()
  }
  
  func toggleChecked() {
    checked = !checked
  }
  
  func scheduleNotification() {
    removeNotification()
    if shouldRemind && dueDate > Date() {
//      print("We should schedule a nofitication")
      
      let content = UNMutableNotificationContent()
      content.title = "Reminder:"
      content.body = text
      content.sound = UNNotificationSound.default
      
      let calendar = Calendar(identifier: .gregorian)
      let components =  calendar.dateComponents([.year, .month, .day, .hour, .minute], from: dueDate)
      
      let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
      
      let request = UNNotificationRequest(identifier: "\(itemID)", content: content, trigger: trigger)
      
      let center = UNUserNotificationCenter.current()
      center.add(request)
      
      print("Scheduled: \(request) for itemD: \(itemID)")
      
    }
  }
  
  func removeNotification() {
    let center = UNUserNotificationCenter.current()
    center.removePendingNotificationRequests(withIdentifiers: ["\(itemID)"])
  }
}
