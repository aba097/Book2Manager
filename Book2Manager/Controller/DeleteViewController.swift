//
//  DeleteViewController.swift
//  Book2Manager
//
//  Created by 相場智也 on 2022/04/23.
//

import UIKit

class DeleteViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UISearchBarDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate {

    @IBOutlet weak var SearchBar: UISearchBar!
    
    @IBOutlet weak var SearchPickerView: UIPickerView!
    
    @IBOutlet weak var SortCategoryPickerView: UIPickerView!
    
    @IBOutlet weak var SortOrderPickerView: UIPickerView!
    
    @IBOutlet weak var CollectionView: UICollectionView!
    
    //インスタンス化
    let searchpicker = SearchPickerModel()
    let sortcategorypicker = SortCategoryPickerModel()
    let sortorderpicker = SortOrderPickerModel()
    let dropboxmodel = DropBoxModel.shared
    
    private let deletemodel = DeleteModel()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        setDelegate()
    
        deletemodel.vc = self
        deletemodel.CollectionView = self.CollectionView
        
        dropboxmodel.deleteVc = self
        
        fileLoadAlert(deletemodel.setup())
    }
    
    func setDelegate(){
        SearchPickerView.delegate = self
        SortCategoryPickerView.delegate = self
        SortOrderPickerView.delegate = self
        
        SearchBar.delegate = self
        
        CollectionView.delegate = self
        CollectionView.dataSource = self
    }
    
    //ファイル関連のエラーをAlertする
    func fileLoadAlert(_ msg: String){
        
        if msg != "success" {
            //alert
            let alert = UIAlertController(title: "error", message: msg, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true, completion: nil)
        }
    }
  
    /*-------------------UIPicker-----------------------------------*/
    // UIPickerViewの列の数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //UIPickerViewの項目数
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case 0:
            return searchpicker.getSize()
        case 1:
            return sortcategorypicker.getSize()
        case 2:
            return sortorderpicker.getSize()
        default:
            return 1
        }
    }
    
    //UIPickerViewの内容
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?{
        
        switch pickerView.tag {
        case 0:
            return searchpicker.getElement(row)
        case 1:
            return sortcategorypicker.getElement(row)
        case 2:
            return sortorderpicker.getElement(row)
        default:
            return "error"
        }
    }
    
    //UIPickerViewで現在選択しているもの
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    
        switch pickerView.tag {
        case 0:
            searchpicker.setTarget(searchpicker.getElement(row))
        case 1:
            sortcategorypicker.setCategoryTarget(sortcategorypicker.getElement(row))
        case 2:
            sortorderpicker.setOrderTarget(sortorderpicker.getElement(row))
        default: break
            
        }
        
        
    }
    
    /*-------------------UISearchBar-----------------------------------*/
    //uisearchbar
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // キーボードを閉じる
        view.endEditing(true)
        fileLoadAlert(deletemodel.refresh())
    }
    
    /*-------------------UICollectionView-----------------------------------*/
    //表示するセルの数
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return deletemodel.bookdata.currentids.count // 表示するセルの数
    }
    
    //layout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: self.view.bounds.width, height: 263)
    }
    
    //セルの内容
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? CollectionViewCell else{
            fatalError("Dequeue failed: AnimalTableViewCell.")
        }
        
        let bookdata = deletemodel.bookdata
        
        
        //image
        if bookdata.images[bookdata.currentids[indexPath.row]] != "" {
            cell.ImageView.image = UIImage(contentsOfFile: bookdata.images[bookdata.currentids[indexPath.row]])
        }
        else{
            cell.ImageView.image = nil
        }
    
        //title
        cell.TitleTextView.text = bookdata.titles[bookdata.currentids[indexPath.row]]
       
        //writer
        cell.AuthorTextView.text = bookdata.authors[bookdata.currentids[indexPath.row]]
        
        //publisher
        cell.PublisherTextView.text = bookdata.publishers[bookdata.currentids[indexPath.row]]
    
        //comment
        cell.CommentTextView.text = bookdata.comments[bookdata.currentids[indexPath.row]]
        
        cell.tag = indexPath.row
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))
        longPressGesture.delegate = self
        cell.addGestureRecognizer(longPressGesture)
        
        return cell
    }
    
    //cell Long Press イベント 本の削除
    @objc func longPress(_ sender: UILongPressGestureRecognizer){
      
        //長押し時
        if sender.state == .began {
            //削除します---no---end!
            //       |---yes---本当に削除しますか---no---end!
            //                              |---yes---deleteAction
            
            let alert: UIAlertController = UIAlertController(title: "削除します", message:  "", preferredStyle:  UIAlertController.Style.alert)
            
            let deleteaction: UIAlertAction = UIAlertAction(title: "Yes", style: .default, handler:{
                (action: UIAlertAction!) -> Void in
                
                let configalert: UIAlertController = UIAlertController(title: "本当に削除してもいいですか", message:  "", preferredStyle:  UIAlertController.Style.alert)
                
                let yesaction: UIAlertAction = UIAlertAction(title: "Yes", style: .default, handler:{
                    
                    (action: UIAlertAction!) -> Void in
                    
                    //削除
                    self.deleteAction(sender.view!.tag as Int)
                })
                
                configalert.addAction(yesaction)
                configalert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
                    
                self.present(configalert, animated: true, completion: nil)
                
            })
            
            alert.addAction(deleteaction)
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
                
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func deleteAction(_ idx: Int){
        //idxはcurrentidのid
        let result = deletemodel.delete(idx)
        
        if result != "success" {
            //alert
            let alert = UIAlertController(title: "error", message: result, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true, completion: nil)
        }else{
            let alert = UIAlertController(title: "success", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func AuthenticationAction(_ sender: Any) {
        //認証する
        //セマフォはサブスレッドに適用する. Main Threadに適用すると認証が止まってしまう
        DispatchQueue.global(qos: .default).async {
            DispatchQueue.main.async {
                //認証
                // 認証をセマフォでデットロックしてしまうためMain Threadで実行する
                self.dropboxmodel.authentication("Delete")
            }
            //sginalは認証が終了後SceneDelegate.swiftで行われる
            self.dropboxmodel.authSemaphore.wait()
            //アラートの表示はメインスレッドで行う
            DispatchQueue.main.sync {
                if self.dropboxmodel.authState {
                    let alert = UIAlertController(title: "success", message: "認証成功", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true, completion: nil)
                }else{
                    let alert = UIAlertController(title: "error", message: "認証失敗", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }

    }
    
    

}
