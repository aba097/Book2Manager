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

    func setup(){
        
        //refresh　下に引っ張ったときの動作を設定
        CollectionView.refreshControl = refreshcontrol
        refreshcontrol.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        refresh()
    
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
        /*
        //ファイル読み込み
        result = refresh()
        if result != "success" {
            return result
        }
        */
        return "success"
        
    }
    //ここにfileloadしてもいいかも
    @objc func refresh(){
        
        //ファイル読み込み
        vc.load()
        
        CollectionView.refreshControl?.endRefreshing()
    }
 
}
