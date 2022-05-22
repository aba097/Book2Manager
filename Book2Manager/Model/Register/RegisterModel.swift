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
    let filepath = NSHomeDirectory() + "/Documents/" + "bookdata.json"
    
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
        var image: String //画像名
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
        client.files.listFolder(path: "/test/path/").response { response, error in
            if let response = response {
                var flag = false
                for entry in response.entries {
                    //print(entry.name) ファイル一覧
                    if entry.name == "bookdata.json" {
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
        
        //bookdata.jsonの存在確認
        //ない場合はbookdata = []
        
        // Download to Data
        client.files.download(path: "/test/path/bookdata.json")
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
    func upload(_ title: String, _ author: String, _ publisher: String, _ comment: String, _ image: UIImageView) {
        
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
        
        var imageName = ""
        //画像のアップロード
        if image.image != nil {
            imageName = String(newId) + ".jpeg"
            let data = image.image?.jpegData(compressionQuality: 0.8)
            
            client.files.upload(path: "/test/path/" + imageName, mode: .overwrite, input: data!)
                .response { response, error in
                    if let response = response {
                        //print(response)
                        
                    } else if let error = error {
                       // print(error)
                    }
                }
                .progress { progressData in
                    print(progressData)
                }
        }
        
        //追加
        bookdata.append(Bookdata(id: newId, title: title, author: author, publisher: publisher, comment: comment, image: imageName, state: ""))
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        guard let data = try? encoder.encode(bookdata) else {
            uploadState = "JSONエンコードエラー"
            uploadSemaphore.signal()
            return
        }
        
      
        client.files.upload(path: "/test/path/bookdata.json", mode: .overwrite, input: data)
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
    
    
    func register(_ title: String, _ author: String, _ publisher: String, _ comment: String, _ image: UIImageView)->String{
        
        //JSONを読み込む
        var readRes = readJson()
        if readRes.msg != "success"{
            return readRes.msg
        }
        
        //IDを決定する
        var maxid = -1
        for book in readRes.bookdata{
            maxid = max(book.id, maxid)
        }
        maxid += 1

        //imageviewの画像を保存
        let imageRes = writeImage(image, String(maxid))
    
        if imageRes != "success" && imageRes != "noimage"{
            return imageRes
        }
        
        var imagename = ""
        if imageRes != "noimage" {
            imagename = String(maxid) + ".jpeg"
        }
        
        //登録するデータをJSONに追加
        readRes.bookdata.append(Bookdata(id: maxid, title: title, author: author, publisher: publisher, comment: comment, image: imagename, state: ""))
       
        //JSON書き込み
        let writeRes = writeJson(&readRes.bookdata)
        
        if writeRes != "success" {
            return writeRes
        }
        
        return "success"
    }
    
    //jsonファイル読み込み
    func readJson()->(msg: String, bookdata: [Bookdata]){

        guard let dirURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return ("フォルダURL取得エラー", [Bookdata]())
        }
        
        //ファイルが存在しない場合は1回目ということでsuccessを返す
        if !FileManager.default.fileExists(atPath: filepath){
            return ("success", [Bookdata]())
        }

        let fileURL = dirURL.appendingPathComponent(filename)

        guard let data = try? Data(contentsOf: fileURL) else {
            return ("JSON読み込みエラー", [Bookdata]())
        }
         
        let decoder = JSONDecoder()
        guard let bookdata = try? decoder.decode([Bookdata].self, from: data) else {
            return ("JSONデコードエラー", [Bookdata]())
        }
        
        return ("success", bookdata)
    }
    
    //jsonファイル書き込み
    func writeJson(_ bookdata: inout [Bookdata])->String{
        
        guard let dirURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return "フォルダURL取得エラー"
        }

        let fileURL = dirURL.appendingPathComponent(filename)
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        guard let jsonValue = try? encoder.encode(bookdata) else {
            return "JSONエンコードエラー"
        }
         
        do {
            try jsonValue.write(to: fileURL)
        } catch {
            return "JSON書き込みエラー"
        }
        
        return "success"
    }
    
    //imageviewの画像を保存
    func writeImage(_ image: UIImageView, _ id: String)->String{
        guard let dirURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return "フォルダURL取得エラー"
        }
        
        let fileURL = dirURL.appendingPathComponent(id + ".jpeg")
        if image.image != nil {
            //画像保存
            do {
                try image.image?.jpegData(compressionQuality: 0.8)?.write(to: fileURL)
            }catch{
                return "画像書き込みエラー"
            }
        }else{
          return "noimage"
        }
        
        return "success"
        
    
        
    }
    
}
