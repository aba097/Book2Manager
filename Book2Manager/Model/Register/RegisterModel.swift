//
//  RegisterModel.swift
//  Book2Manager
//
//  Created by 相場智也 on 2022/04/25.
//

import Foundation
import UIKit
import SwiftyDropbox

class RegisterModel {
    
    let filename = "bookdata.json"
    let filepath = "/test/path/"
    
    var bookdata: [Bookdata] = []
    
    //upload
    let uploadSemaphore = DispatchSemaphore(value: 0)
    var uploadState = ""
    
    //download
    let downloadSemaphore = DispatchSemaphore(value: 0)
    var downloadState = ""
    
    //exist
    let existSemaphore = DispatchSemaphore(value: 0)
    var existState = ""
    
    //JSON struct
    struct Bookdata: Codable {
        var id: Int        //本のID
        var title: String  //本のタイトル
        var author: String //本の著者
        var publisher: String //本の出版社
        var comment: String //本のコメント
        var state : String //本の貸し借り状態
    }
    
    //bookdata.jsonが存在するか確認
    func exist(){
        if DropboxClientsManager.authorizedClient == nil {
            existState = "認証してください"
            existSemaphore.signal()
            return
        }
        
        let client = DropboxClientsManager.authorizedClient!
        //ファイル一覧を取得
        client.files.listFolder(path: filepath).response { response, error in
            if let response = response {
                var flag = false
                for entry in response.entries {
                    //print(entry.name) ファイル一覧
                    if entry.name == self.filename {
                        self.existState = "doDownload"
                        flag = true
                    }
                }
                if !flag { //bookdata.jsonが存在しない
                    self.existState = "notExist"
                }
                self.existSemaphore.signal()
            } else if let error = error {
                print(error)
                self.existState = "ファイル一覧取得失敗"
                self.existSemaphore.signal()
            }
        }
    }
    
    //dropboxからダウンロード
    func download(){
        if DropboxClientsManager.authorizedClient == nil {
            downloadState = "認証してください"
            downloadSemaphore.signal()
            return
        }
        
        let client = DropboxClientsManager.authorizedClient!
        
        // Download to Data
        client.files.download(path: filepath + filename)
            .response { response, error in
                if let response = response {
                    
                    let fileContents = response.1
                    guard let tmpbookdata = try? JSONDecoder().decode([Bookdata].self, from: fileContents) else {
                        self.downloadState = "JSONデコードエラー"
                        self.downloadSemaphore.signal()
                        return
                    }
                    //ダウンロード成功後 bookdataに追加
                    self.bookdata = tmpbookdata
    
                    self.downloadState = "success"
                    self.downloadSemaphore.signal()
                } else if let error = error {
                    print(error)
                    self.downloadState = "ダウンロード失敗"
                    self.downloadSemaphore.signal()
                }
            }
            .progress { progressData in
                print(progressData)
            }
    }
    
    //DropBoxにアップロード
    func upload(_ title: String, _ author: String, _ publisher: String, _ comment: String) {
        
        if DropboxClientsManager.authorizedClient == nil {
            uploadState = "認証してください"
            uploadSemaphore.signal()
            return
        }
        
        let client = DropboxClientsManager.authorizedClient!
    
        
        //追加本のid
        var newId = 0
        if bookdata.count != 0 {
            newId = bookdata[bookdata.count - 1].id + 1
        }
        
        //追加
        bookdata.append(Bookdata(id: newId, title: title, author: author, publisher: publisher, comment: comment, state: ""))
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        guard let data = try? encoder.encode(bookdata) else {
            uploadState = "JSONエンコードエラー"
            uploadSemaphore.signal()
            return
        }
        
      
        client.files.upload(path: filepath + filename, mode: .overwrite, input: data)
            .response { response, error in
                if let response = response {
                    //print(response)
                    self.uploadState = "success"
                    self.uploadSemaphore.signal()
                } else if let error = error {
                    print(error)
                    self.uploadState = "アップロード失敗"
                    self.uploadSemaphore.signal()
                }
            }
            .progress { progressData in
                print(progressData)
            }
            
    }
    
}
