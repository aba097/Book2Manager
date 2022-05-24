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
    
    //ここにfileloadしてもいいかも
    @objc func refresh(){
        
        //ファイル読み込み
        vc.load()
        
        CollectionView.refreshControl?.endRefreshing()
    }
 
}
