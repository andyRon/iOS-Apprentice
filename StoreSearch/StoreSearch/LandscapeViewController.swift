//
//  LandscapeViewController.swift
//  StoreSearch
//
//  Created by Andy Ron on 2019/8/26.
//  Copyright © 2019 Andy Ron. All rights reserved.
//
/// 横屏时的控制器

import UIKit

class LandscapeViewController: UIViewController {

  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var pageControl: UIPageControl!
  
  var search: Search!
  
  /// 用来判断LandscapeViewController是否是第一次添加到屏幕中
  private var firstTime = true
  
  private var downloads = [URLSessionDownloadTask]()
  

  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Remove constraints from main view
    view.removeConstraints(view.constraints)
    view.translatesAutoresizingMaskIntoConstraints = true
    // Remove constraints for page control
    pageControl.removeConstraints(pageControl.constraints)
    pageControl.translatesAutoresizingMaskIntoConstraints = true
    // Remove constraints for scroll view
    scrollView.removeConstraints(scrollView.constraints)
    scrollView.translatesAutoresizingMaskIntoConstraints = true
    
    view.backgroundColor = UIColor(patternImage: UIImage(named: "LandscapeBackground")!)
    
    scrollView.contentSize = CGSize(width: 1000, height: 1000)
    pageControl.numberOfPages = 0
    
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    let safeFrame = view.safeAreaLayoutGuide.layoutFrame
    scrollView.frame = safeFrame
    pageControl.frame = CGRect(x: safeFrame.origin.x,
                               y: safeFrame.size.height - pageControl.frame.size.height,
                               width: safeFrame.size.width,
                               height: pageControl.frame.size.height)
    if firstTime {
      firstTime = false
      
      switch search.state {
      case .notSearchedYet:
        break
      case .loading:
        showSpinner()
      case .results(let list):
        tileButtons(list)
      case .noResults:
        showNothingFoundLabel()
      }
    }
  }

  // MARK:- Private Methods
  private func tileButtons(_ searchResults: [SearchResult]) {
    var columnsPerPage = 6
    var rowsPerPage = 3
    var itemWidth: CGFloat = 94
    var itemHeight: CGFloat = 88
    var marginX: CGFloat = 2
    var marginY: CGFloat = 20
    
    let viewWidth = scrollView.bounds.size.width
    
    switch viewWidth {
    case 568:
      // 4-inch device
      break
      
    case 667:
      // 4.7-inch device
      columnsPerPage = 7
      itemWidth = 95
      itemHeight = 98
      marginX = 1
      marginY = 29
      
    case 736:
      // 5.5-inch device
      columnsPerPage = 8
      rowsPerPage = 4
      itemWidth = 92
      marginX = 0
      
    case 724:
      // iPhone X
      columnsPerPage = 8
      rowsPerPage = 3
      itemWidth = 90
      itemHeight = 98
      marginX = 2
      marginY = 29
      
    default:
      break
    }
    // Button size
    let buttonWidth: CGFloat = 82
    let buttonHeight: CGFloat = 82
    let paddingHorz = (itemWidth - buttonWidth)/2
    let paddingVert = (itemHeight - buttonHeight)/2
    
    // Add the buttons
    var row = 0
    var column = 0
    var x = marginX
    for (index, result) in searchResults.enumerated() {
      // 1
      let button = UIButton(type: .custom)
      button.setBackgroundImage(UIImage(named: "LandscapeButton"), for: .normal)
      // 2
      button.frame = CGRect(x: x + paddingHorz,
                            y: marginY + CGFloat(row)*itemHeight + paddingVert,
                            width: buttonWidth, height: buttonHeight)
      
      button.tag = 2000 + index
      button.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
      // 3
      scrollView.addSubview(button)
      // 4
      row += 1
      if row == rowsPerPage {
        row = 0; x += itemWidth; column += 1
        
        if column == columnsPerPage {
          column = 0; x += marginX * 2
        }
      }
      downloadImage(for: result, andPlaceOn: button)
    }
    
    // Set scroll view content size
    let buttonsPerPage = columnsPerPage * rowsPerPage
    let numPages = 1 + (searchResults.count - 1) / buttonsPerPage
    scrollView.contentSize = CGSize(width: CGFloat(numPages) * viewWidth, height: scrollView.bounds.size.height)
    
    print("Number of pages: \(numPages)")
    
    pageControl.numberOfPages = numPages
    pageControl.currentPage = 0
  }
  
  private func downloadImage(for searchResult: SearchResult, andPlaceOn button: UIButton) {
    if let url = URL(string: searchResult.imageSmall) {
      let task = URLSession.shared.downloadTask(with: url) {
        [weak button] url, response, error in
        
        if error == nil, let url = url,
          let data = try? Data(contentsOf: url),
          let image = UIImage(data: data) {
          DispatchQueue.main.async {
            if let button = button {
              button.setImage(image, for: .normal)
            }
          }
        }
      }
      task.resume()
      downloads.append(task)
    }
  }
  
  private func showSpinner() {
    let spinner = UIActivityIndicatorView(style: .whiteLarge)
    spinner.center = CGPoint(x: scrollView.bounds.midX + 0.5, y: scrollView.bounds.midY + 0.5)
    spinner.tag = 1000
    view.addSubview(spinner)
    spinner.startAnimating()
  }
  
  private func showNothingFoundLabel() {
    let label = UILabel(frame: CGRect.zero)
    label.text = NSLocalizedString("Nothing Found", comment: "Label: Nothing Found")
    label.textColor = UIColor.white
    label.backgroundColor = UIColor.clear
    
    label.sizeToFit()
    
    var rect = label.frame
    rect.size.width = ceil(rect.size.width/2) * 2    // make even
    rect.size.height = ceil(rect.size.height/2) * 2  // make even
    label.frame = rect
    
    label.center = CGPoint(x: scrollView.bounds.midX, y: scrollView.bounds.midY)
    view.addSubview(label)
  }
  
  // MARK: - Actions
  @IBAction func pageChanged(_ sender: UIPageControl) {
    print("当前页:\(sender.currentPage)")
    // 点击 Page Control，更新Scroll View
    UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
      self.scrollView.contentOffset = CGPoint(x: self.scrollView.bounds.size.width * CGFloat(sender.currentPage), y: 0)
      },
      completion: nil)
  }
  
  @objc func buttonPressed(_ sender: UIButton) {
    performSegue(withIdentifier: "ShowDetail", sender: sender)
  }
  
  // MARK: - Public Methods
  func searchResultsReceived() {
    hideSpinner()
    
    switch search.state {
    case .notSearchedYet, .loading:
      break
    case .noResults:
      showNothingFoundLabel()
    case .results(let list):
      tileButtons(list)
    }
  }
  
  func hideSpinner() {
    view.viewWithTag(1000)?.removeFromSuperview()
  }
  
  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "ShowDetail" {
      if case .results(let list) = search.state {
        let detailViewController = segue.destination as! DetailViewController
        let searchResult = list[(sender as! UIButton).tag - 2000]
        detailViewController.searchResult = searchResult
      }
    }
  }
  
  deinit {
    print("deinit \(self)")
    for task in downloads {
      task.cancel()
    }
  }
  
  
}

extension LandscapeViewController: UIScrollViewDelegate {
  
  /// 滑动后操作，计算滑动后的页数
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let width = scrollView.bounds.size.width
    let page = Int((scrollView.contentOffset.x + width/2)/width)
    pageControl.currentPage = page
  }
}
