//
//  Search.swift
//  StoreSearch
//
//  Created by Andy Ron on 2019/8/31.
//  Copyright © 2019 Andy Ron. All rights reserved.
//

import Foundation
import UIKit

typealias SearchComplete = (Bool) -> Void
/*
 not only describes the state and results of the search, it will also encapsulate all the logic for talking to the iTunes web service
 */
class Search {

  enum State {
    /// 还没有发生搜索，当然也没有载入，也没有结果
    case notSearchedYet
    /// 搜索，正在载入
    case loading
    /// 搜索后，没有结果
    case noResults
    /// 搜索成功，有结果
    case results([SearchResult])
  }
  
  private(set) var state: State = .notSearchedYet
  
  private var dataTask: URLSessionTask? = nil
  
  enum Category: Int {
    case all = 0
    case music = 1
    case software = 2
    case ebooks = 3
    
    var type: String {
      switch self {
      case .all: return ""
      case .music: return "musicTrack"
      case .software: return "software"
      case .ebooks: return "ebook"
      }
    }
  }
  
  enum AnimationStyle {
    case slide
    case fade
  }
  
  func performSearch(for text: String, category: Category, completion: @escaping SearchComplete) {
    if !text.isEmpty {
      dataTask?.cancel()
      UIApplication.shared.isNetworkActivityIndicatorVisible = true
      
      state = .loading
      
      let url = iTunesURL(searchText: text, category: category)
      let session = URLSession.shared
      dataTask = session.dataTask(with: url, completionHandler: { (data, response, error) in
        var newState = State.notSearchedYet
        var success = false
        if let error = error as NSError?, error.code == -999 {
          return
        }
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let data = data {
          var searchResults = self.parse(data: data)
          if searchResults.isEmpty {
            newState = .noResults
          } else {
            searchResults.sort(by: <)
            newState = .results(searchResults)
          }
          success = true
        }
        
        DispatchQueue.main.async {
          self.state = newState
          completion(success)
          UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
        
      })
      dataTask?.resume()
    }
  }
  
  private func iTunesURL(searchText: String, category: Category) -> URL {
    let locale = Locale.autoupdatingCurrent
    let language = locale.identifier
    let coutryCode = locale.regionCode ?? "en_US"
    
    
    let kind = category.type
    
    let encodedText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
    let urlString = "https://itunes.apple.com/search?term=\(encodedText)&limit=200&entity=\(kind)" + "&lang=\(language)&country=\(coutryCode)"
    let url = URL(string: urlString)
    print("URL: \(url!)")
    return url!
  }
  
  private func parse(data: Data) -> [SearchResult] {
    do {
      let decoder = JSONDecoder()
      let result = try decoder.decode(ResultArray.self, from: data)
      return result.results
    } catch {
      print("JSON Error: \(error)")
      return []
    }
  }
}
