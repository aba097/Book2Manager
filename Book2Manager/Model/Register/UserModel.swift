//
//  UserModel.swift
//  Book2Manager
//
//  Created by 相場智也 on 2022/04/28.
//

import Foundation

class UserModel{
    let filename = "user.txt"
    let filepath = NSHomeDirectory() + "/Documents/" + "user.txt"
    
    var users = ["user0", "user1", "user2", "user3", "user4", "use5", "user6", "user7", "user8", "user9", "user10", "user11", "user12", "user13", "user14", "user15"]
    
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
            
            
        }
        return "success"
    }
}
