//
//  AboutViewController.swift
//  BullsEye
//
//  Created by Andy Ron on 2019/7/22.
//  Copyright © 2019 Andy Ron. All rights reserved.
//

import UIKit
import WebKit

class AboutViewController: UIViewController {
  @IBOutlet weak var webView: WKWebView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if let url = Bundle.main.url(forResource: "BullsEye", withExtension: "html") {
      let request = URLRequest(url: url)
      webView.load(request)
    }
  }
    

  @IBAction func close() {
    dismiss(animated: true, completion: nil)
  }

}
