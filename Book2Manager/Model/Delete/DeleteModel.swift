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
       // CollectionView.refreshControl = refreshcontrol
        //refreshcontrol.addTarget(self, action: #selector(refresh), for: .valueChanged)
      
        //データ読み込み
        var result = bookdata.bookLoad()
        
        if result != "success" {
            return result
        }
        
        result = bookdata.jsonParse()
        
        if result != "sucess" {
            return result
        }
        
        result = bookdata.userLoad()
        
        if result != "sucess" {
            return result
        }
        
        //refresh()
        
        return "success"
    }
    /*
    //ここにfileloadしてもいいかも
    @objc func refresh(){
        
        bookdata.setDiplayData(searchtext: vc.SearchBar.text, searchtarget: vc.searchpicker.getTarget(), sortcategorytarget: vc.sortcategorypicker.getCategoryTarget(), sortordertarget: vc.sortorderpicker.getOrderTarget())
                
        cells = []
        CollectionView.reloadData()
        
        CollectionView.refreshControl?.endRefreshing()
    }
 */
}
