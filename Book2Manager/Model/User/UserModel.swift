//
//  UserModel.swift
//  Book2Manager
//
//  Created by 相場智也 on 2022/04/28.
//

import Foundation
import SwiftyDropbox

class UserModel{
    
    //シングルトン
    static let shared = UserModel()
    
    let filename = "user.txt"
    let filepath = "/test/path/"
    
    var users = ["user0", "user1", "user2", "user3", "user4", "use5", "user6", "user7", "user8", "user9", "user10", "user11", "user12", "user13", "user14", "user15"]
    
    //並べ替え状態を保持する
    var useridx = [0, 1 ,2 ,3 ,4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]
    
    //upload
    let uploadSemaphore = DispatchSemaphore(value: 0)
    var uploadState = ""
    
    //download
    let downloadSemaphore = DispatchSemaphore(value: 0)
    var downloadState = ""
    
    //exist
    let existSemaphore = DispatchSemaphore(value: 0)
    var existState = ""
    
    //更新ボタンを押した
    func reLoad() -> String {
        
        let result = loadUserData()
        
        if result != "success" {
            return result
        }
        useridx = [0, 1 ,2 ,3 ,4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]
        
        return "success"
    }
    
    //user.txtが存在するか確認
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
                    let text = String(data: fileContents, encoding: .utf8)
                    
                    //usersに追加
                    self.users = text!.components(separatedBy: "\n").filter{!$0.isEmpty}
                    
                    self.useridx = [0, 1 ,2 ,3 ,4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]
                    
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
    func upload() {
        
        if DropboxClientsManager.authorizedClient == nil {
            uploadState = "認証してください"
            uploadSemaphore.signal()
            return
        }
        
        let client = DropboxClientsManager.authorizedClient!
    
        var writetxt = users[useridx[0]]
        for i in 1 ..< useridx.count {
            writetxt += "\n" + users[useridx[i]]
        }
        
        let data = writetxt.data(using: .utf8)
            
        client.files.upload(path: filepath + filename, mode: .overwrite, input: data!)
            .response { response, error in
                if let response = response {
                    //print(response)
                    self.uploadState = "success"
                    self.uploadSemaphore.signal()
                } else if let error = error {
                   // print(error)
                    self.uploadState = "アップロード失敗"
                    self.uploadSemaphore.signal()
                }
            }
            .progress { progressData in
                print(progressData)
            }
        
    }
    
    
    
    
    func loadUserData()->String{
        
        guard let dirURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return "フォルダURL取得エラー"
        }
        
        //user.txtファイルがない場合は，usersを書き込み作成
        if !FileManager.default.fileExists(atPath: filepath){
            let fileURL = dirURL.appendingPathComponent(filename)
            
            FileManager.default.createFile(atPath: filepath, contents: nil, attributes: nil)
    
            var writetxt = users[0]
            for i in 1 ..< users.count {
                writetxt += "\n" + users[i]
            }
            do {
                try writetxt.write(to: fileURL, atomically: false, encoding: .utf8)
            } catch {
                return "ファイル書き込みエラー"
            }
            
        }else{
        //user.txtが存在する場合はusersに読み込み
            let fileURL = dirURL.appendingPathComponent(filename)

            do {
                let text = try String(contentsOf: fileURL)
                users = text.components(separatedBy: "\n").filter{!$0.isEmpty}
                
            }catch {
                return "ファイル読み込みエラー"
            }
        }
        
        return "success"
    }
    
    func swap(_ start : Int, _ end: Int){
        
        //一個ずつ左にする
        if(start < end){
            let tmp = useridx[start]
            for i in start ..< end {
                useridx[i] = useridx[i + 1]
            }
            useridx[end] = tmp
        }
        else if (start > end){
            let tmp = useridx[start]
            for i in (end + 1 ... start).reversed() {
                useridx[i] = useridx[i - 1]
            }
            useridx[end] = tmp
        }
    }
    
    func save()->String{
        
        guard let dirURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return "フォルダURL取得エラー"
        }
        
        let fileURL = dirURL.appendingPathComponent(filename)
        
        var writetxt = users[useridx[0]]
        for i in 1 ..< useridx.count {
            writetxt += "\n" + users[useridx[i]]
        }
      
        do {
            try writetxt.write(to: fileURL, atomically: false, encoding: .utf8)
        } catch {
            return "ファイル書き込みエラー"
        }

        return "success"
    }
}
