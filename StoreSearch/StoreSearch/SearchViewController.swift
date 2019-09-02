//
//  SearchViewController.swift
//  StoreSearch
//
//  Created by Andy Ron on 2019/8/22.
//  Copyright © 2019 Andy Ron. All rights reserved.
//

import UIKit



class SearchViewController: UIViewController {
  
  @IBOutlet weak var searchBar: UISearchBar!
  @IBOutlet weak var tableView: UITableView!
  
  private let search = Search()
  
  struct TableView {
    struct CellIdentifiers {
      static let searchResultCell = "SearchResultCell"
      static let nothingFoundCell = "NothingFoundCell"
      static let loadingCell = "LoadingCell"
    }
  }
  
  weak var splitViewDetail: DetailViewController?
  
  @IBOutlet weak var segmentedControl: UISegmentedControl!
  
  var landscapeVC: LandscapeViewController?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    tableView.contentInset = UIEdgeInsets(top: 108, left: 0, bottom: 0, right: 0)
    
    var cellNib = UINib(nibName: TableView.CellIdentifiers.searchResultCell, bundle: nil)
    tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.searchResultCell)
    
    cellNib = UINib(nibName: TableView.CellIdentifiers.nothingFoundCell, bundle: nil)
    tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.nothingFoundCell)
    
    cellNib = UINib(nibName: TableView.CellIdentifiers.loadingCell, bundle: nil)
    tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.loadingCell)
    
    if UIDevice.current.userInterfaceIdiom != .pad {
      searchBar.becomeFirstResponder()  // 获得焦点
    }
    
    title = NSLocalizedString("Search", comment: "split view master button")
    
  }
  
  override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
    super.willTransition(to: newCollection, with: coordinator)
    
    let rect = UIScreen.main.bounds
    if (rect.width == 736 && rect.height == 414) || (rect.width == 414 && rect.height == 736) {
      if presentedViewController != nil {
        dismiss(animated: true, completion: nil)
      }
    } else if UIDevice.current.userInterfaceIdiom != .pad {
      switch newCollection.verticalSizeClass {
      case .compact:
        showLandscape(with: coordinator)
      case .regular, .unspecified:
        hideLandscape(with: coordinator)
      }
    }
    
    
    
  }
  
  // MARK: - Actions
  
  @IBAction func segmentChanged(_ sender: UISegmentedControl) {
    performSearch()
  }
  
  // MARK: - Helper Methods
  func showNetworkError() {
    let alert = UIAlertController(title: NSLocalizedString("Whoops...", comment: "Error alert: title"),  message: NSLocalizedString("There was an error accessing the iTunes Store. Please try again.", comment: "Error alert: message"), preferredStyle: .alert)
    
    let action = UIAlertAction(title: "OK", style: .default, handler: nil)
    alert.addAction(action)
    present(alert, animated: true, completion: nil)
  }
  /// Show the landscape view on device rotation
  func showLandscape(with coordinator: UIViewControllerTransitionCoordinator) {
    // 1
    guard landscapeVC == nil else { return }
    // 2
    landscapeVC = storyboard!.instantiateViewController(withIdentifier: "LandscapeViewController") as? LandscapeViewController
    if let controller = landscapeVC {
      controller.search = search
      // 3
      controller.view.frame = view.bounds
      controller.view.alpha = 0
      // 4
      view.addSubview(controller.view)
      addChild(controller)
      // 转到横屏时的动画
      coordinator.animate(alongsideTransition: { _ in
        controller.view.alpha = 1
        self.searchBar.resignFirstResponder()  // 隐藏键盘
        if self.presentedViewController != nil {  // 隐藏Detail pop-up
          self.dismiss(animated: true, completion: nil)
        }
      }) { _ in
        controller.didMove(toParent: self)
      }
    }
  }
  /// Switch back to the portrait view
  func hideLandscape(with coordinator: UIViewControllerTransitionCoordinator) {
    if let controller = landscapeVC {
      controller.willMove(toParent: nil)
      // 转回竖屏时的动画
      coordinator.animate(alongsideTransition: { (_) in
        controller.view.alpha = 0
        if self.presentedViewController != nil {
          self.dismiss(animated: true, completion: nil)
        }
      }) { (_) in
        controller.view.removeFromSuperview()
        controller.removeFromParent()
        self.landscapeVC = nil
      }
    }
  }
  
  // MARK:- Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "ShowDetail" {
      if case .results(let list) = search.state {
        let detailViewController = segue.destination as! DetailViewController
        let indexPath = sender as! IndexPath
        let searchResult = list[indexPath.row]
        detailViewController.searchResult = searchResult
        detailViewController.isPopup = true
      }
    }

  }
  
  // MARK: - Private
  private func hideMastePane() {
    UIView.animate(withDuration: 0.25, animations: {
      self.splitViewController!.preferredDisplayMode = .primaryHidden
    }) { (_) in
      self.splitViewController!.preferredDisplayMode = .automatic
    }
  }
  
}

extension SearchViewController: UISearchBarDelegate {
  
  func position(for bar: UIBarPositioning) -> UIBarPosition {
    return .topAttached
  }
  
  /// 搜索内容输入完后的代理方法
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    performSearch()
  }
  
  func performSearch() {
    
    if let category = Search.Category(rawValue: segmentedControl.selectedSegmentIndex) {
      search.performSearch(for: searchBar.text!, category: category, completion: { success in
        if !success {
          self.showNetworkError()
        }
        self.tableView.reloadData()
        self.landscapeVC?.searchResultsReceived()
      })
      
      tableView.reloadData()
      searchBar.resignFirstResponder()
    }
    
    
  }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch search.state {
    case .notSearchedYet: return 0
    case .loading: return 1
    case .noResults: return 1
    case .results(let list): return list.count
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    switch search.state {
    case .notSearchedYet:
      fatalError("Should never get here")
    case .loading:
      let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.loadingCell, for: indexPath)
      let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
      spinner.startAnimating()
      return cell
    case .noResults:
      return tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.nothingFoundCell, for: indexPath)
    case .results(let list):
      let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.searchResultCell, for: indexPath) as! SearchResultCell
      
      let searchResult = list[indexPath.row]
      cell.configure(for: searchResult)
      return cell
    }

  }
  
  // 选中后
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    searchBar.resignFirstResponder()
    
    if view.window!.rootViewController!.traitCollection.horizontalSizeClass == .compact {
      tableView.deselectRow(at: indexPath, animated: true)   // 选中后，去除选中并有动画
      performSegue(withIdentifier: "ShowDetail", sender: indexPath)
      
    } else {
      if case .results(let list) = search.state {
        splitViewDetail?.searchResult = list[indexPath.row]
        if splitViewController!.displayMode != .allVisible {
          hideMastePane()
        }
      }
    }
  }
  
  func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    switch search.state {
    case .notSearchedYet, .loading, .noResults:
      return nil  // 不能被选中
    case .results:
      return indexPath
    }
  }
}

