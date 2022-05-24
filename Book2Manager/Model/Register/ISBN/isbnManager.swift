//
//  isbnManager.swift
//  Book2Manager
//
//  Created by 相場智也 on 2022/04/25.
//

import Foundation

class IsbnManager {
    
    //OpenDBAPIを使用して図書データ取得
    func getBookData(isbn: String) -> (title: String, author: String, publisher: String, comment: String, isEnable: Bool) {
        var title = ""
        var author = ""
        var publisher = ""
        var comment = ""
        var isEnable = false
        
        let baseUrlString = "https://api.openbd.jp/v1/"
        let searchUrlString = "\(baseUrlString)get"
        let searchUrl = URL(string: searchUrlString)!
        guard var components = URLComponents(url: searchUrl, resolvingAgainstBaseURL: searchUrl.baseURL != nil) else {
            return(title, author, publisher, comment, isEnable)
            
        }
        
        //セマフォ
        let semaphore = DispatchSemaphore(value: 0)
        
        components.queryItems = [URLQueryItem(name: "isbn", value: isbn)]
        
        var request = URLRequest(url: components.url!)
    
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        URLSession.shared.dataTask(with: request) { data, response, error in
 
            if let error = error {
                print("Error: \(error)")
                semaphore.signal()
                return
            }
            
            guard let data = data else {
                semaphore.signal()
                return
            }
    
            do {
                let bookdata:[Isbn] = try JSONDecoder().decode([Isbn].self, from: data)
                title = bookdata[0].summary.title
                author = bookdata[0].summary.author
                publisher = bookdata[0].summary.publisher
                comment = bookdata[0].onix.CollateralDetail.TextContent[0].Text
                isEnable = true
                
            } catch let error {
                print("Error: \(error)")
            }
            
            semaphore.signal()
        }.resume()
        
        semaphore.wait()
        return(title, author, publisher, comment, isEnable)
        
    }
    
}
