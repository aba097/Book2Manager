//
//  UserModel.swift
//  Book2Manager
//
//  Created by 相場智也 on 2022/04/28.
//

import Foundation

class UserModel{
    
    //シングルトンs
    static let shared = UserModel()
    
    let filename = "user.txt"
    let filepath = NSHomeDirectory() + "/Documents/" + "user.txt"
    
    var users = ["user0", "user1", "user2", "user3", "user4", "use5", "user6", "user7", "user8", "user9", "user10", "user11", "user12", "user13", "user14", "user15"]
    
    //並べ替え状態を保持する
    var useridx = [0, 1 ,2 ,3 ,4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]
    
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