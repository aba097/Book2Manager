//
//  RegisterModel.swift
//  Book2Manager
//
//  Created by 相場智也 on 2022/04/25.
//

import Foundation
import UIKit

class RegisterModel {
    
    let filename = "text.json"
    
    //JSON struct
    struct Bookdata: Codable {
        var id: Int        //本のID
        var title: String  //本のタイトル
        var author: String //本の著者
        var publisher: String //本の出版社
        var comment: String //本のコメント
        var image: String //本のURL
        var state : Int //本の貸し借り状態
    }
    
    func register(_ title: String, _ author: String, _ publisher: String, _ comment: String, _ image: UIImageView)->String{
        
        //JSONを読み込む
        var readRes = readJson()
        
        //IDを決定する
        var maxid = 0
        for book in readRes.bookdata{
            maxid = max(book.id, maxid)
        }
        maxid += 1
        
        //imageviewの画像を保存
        let imageRes = writeImage(image, String(maxid))
    
        //登録するデータをJSONに追加
        //JSONファイルが存在しない場合
        if readRes.bookdata.count == 1{
            readRes.bookdata[0] = Bookdata(id: maxid, title: title, author: author, publisher: publisher, comment: comment, image: String(maxid) + ".jpeg", state: -1)
        }else{
            readRes.bookdata.append(Bookdata(id: maxid, title: title, author: author, publisher: publisher, comment: comment, image: String(maxid) + ".jpeg", state: -1))
        }
        //JSON書き込み
        let writeRes = writeJson(&readRes.bookdata)
        
        return "success"
    }
    
    //jsonファイル読み込み
    func readJson()->(msg: String, bookdata: [Bookdata]){
        guard let dirURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            fatalError("フォルダURL取得エラー")
        }

        let fileURL = dirURL.appendingPathComponent("bookdata.json")
 
        guard let data = try? Data(contentsOf: fileURL) else {
            return ("ファイル読み込みエラー",[Bookdata(id: 0,title: "",author: "",publisher: "",comment: "",image: "",state: 0)])
        }
         
        let decoder = JSONDecoder()
        guard let bookdata = try? decoder.decode([Bookdata].self, from: data) else {
            return ("JSON読み込みエラー",[Bookdata(id: 0,title: "",author: "",publisher: "",comment: "",image: "",state: 0)])
        }
        
        return ("success", bookdata)
    }
    
    //jsonファイル書き込み
    func writeJson(_ bookdata: inout [Bookdata])->String{
        
        guard let dirURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return "フォルダURL取得エラー"
        }

        let fileURL = dirURL.appendingPathComponent("bookdata.json")
        
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
        }
        
        return "success"
        
    
        
    }
    
}
