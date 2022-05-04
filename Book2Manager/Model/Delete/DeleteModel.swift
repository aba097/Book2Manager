//
//  File.swift
//  Book2Manager
//
//  Created by 相場智也 on 2022/05/04.
//

import Foundation
import UIKit

class DeleteModel{
    
    weak var CollectionView: UICollectionView!
    weak var vc: DeleteViewController!
    
    var bookdata = BookDataModel()
    
    let refreshcontrol = UIRefreshControl()

    func setup() -> String{
        
        //refresh　下に引っ張ったときの動作を設定
        CollectionView.refreshControl = refreshcontrol
        refreshcontrol.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        let result = refresh()
        if result != "success" {
            return result
        }
        return "success"
    }
    
    func load() -> String {
        //データ読み込み
        var result = bookdata.bookLoad()
        if result != "success" {
            return result
        }
    
        result = bookdata.jsonParse()
        if result != "success" {
            return result
        }
        
        result = bookdata.userLoad()
        if result != "success" {
            return result
        }

        return "success"
    }
    
    func delete(_ idx: Int) -> String {
        
        //json読み込み
        var result = bookdata.bookLoad()
        if result != "success" {
            return result
        }
        
        //json削除
        result = bookdata.delete(idx)
        if result != "success" {
            return result
        }
        
        //ファイル読み込み
        result = refresh()
        if result != "success" {
            return result
        }
        
        return "success"
        
    }
    //ここにfileloadしてもいいかも
    @objc func refresh() -> String{
        
        //ファイル読み込み
        let result = load()
        if result != "success" {
            return result
        }
        
        bookdata.setDiplayData(searchtext: vc.SearchBar.text, searchtarget: vc.searchpicker.getTarget(), sortcategorytarget: vc.sortcategorypicker.getCategoryTarget(), sortordertarget: vc.sortorderpicker.getOrderTarget())
    
        CollectionView.reloadData()
        CollectionView.refreshControl?.endRefreshing()
        
        return "success"
    }
 
}
