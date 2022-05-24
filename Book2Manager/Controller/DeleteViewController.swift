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
    
    @IBOutlet weak var ActivityIndicatorView: UIActivityIndicatorView!
    
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
        
        deletemodel.setup()
    }
    
    func setDelegate(){
        SearchPickerView.delegate = self
        SortCategoryPickerView.delegate = self
        SortOrderPickerView.delegate = self
        
        SearchBar.delegate = self
        
        CollectionView.delegate = self
        CollectionView.dataSource = self
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
        deletemodel.refresh()
    }
    
    /*-------------------UICollectionView-----------------------------------*/
    //表示するセルの数
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return deletemodel.bookdata.currentids.count // 表示するセルの数
    }
    
    //layout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: self.view.bounds.width, height: 308)
    }
    
    //セルの内容
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? CollectionViewCell else{
            fatalError("Dequeue failed: AnimalTableViewCell.")
        }
        
        let bookdata = deletemodel.bookdata
    
        //title
        cell.TitleTextView.text = bookdata.titles[bookdata.currentids[indexPath.row]]
       
        //writer
        cell.AuthorTextView.text = bookdata.authors[bookdata.currentids[indexPath.row]]
        
        //publisher
        cell.PublisherTextView.text = bookdata.publishers[bookdata.currentids[indexPath.row]]
    
        //comment
        cell.CommentTextView.text = bookdata.comments[bookdata.currentids[indexPath.row]]
        
        cell.vc = self
        cell.DeleteButton.tag = bookdata.currentids[indexPath.row]
        
        return cell
    }
    
    func deleteAction(_ sender: UIButton) {
        //長押し時
            //削除します---no---end!
            //       |---yes---本当に削除しますか---no---end!
            //                              |---yes---deleteAction
            print(sender.tag as Int)
        let alert: UIAlertController = UIAlertController(title: "削除します", message:  "", preferredStyle:  UIAlertController.Style.alert)
        
        let deleteaction: UIAlertAction = UIAlertAction(title: "Yes", style: .default, handler:{
            (action: UIAlertAction!) -> Void in
            
            let configalert: UIAlertController = UIAlertController(title: "本当に削除してもいいですか", message:  "", preferredStyle:  UIAlertController.Style.alert)
            
            let yesaction: UIAlertAction = UIAlertAction(title: "Yes", style: .default, handler:{
                
                (action: UIAlertAction!) -> Void in
                
                //削除
                self.delete(sender.tag as Int)
            })
            
            configalert.addAction(yesaction)
            configalert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
                
            self.present(configalert, animated: true, completion: nil)
            
        })
        
        alert.addAction(deleteaction)
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
            
        self.present(alert, animated: true, completion: nil)
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
    
    func exist(){
        //グルグル表示
        ActivityIndicatorView.startAnimating()
        
        DispatchQueue.global(qos: .default).async {
            DispatchQueue.main.async {
                //ファイルが存在するか確認
                self.deletemodel.bookdata.bookExist()
            }
            self.deletemodel.bookdata.existSemaphore.wait()
            
            if self.deletemodel.bookdata.existState == "doDownload" {
                DispatchQueue.main.async {
                    //本を読み込む
                    self.load()
                }
            }else if self.deletemodel.bookdata.existState == "notExist" {
                //空のbookjsonを用意する
                self.deletemodel.bookdata.bookjson = []
                
                DispatchQueue.main.sync {
                    self.ActivityIndicatorView.stopAnimating()
                    self.refresh()
                }
                
            }else { //error
                DispatchQueue.main.sync {
                    self.ActivityIndicatorView.stopAnimating()
                    
                    let alert = UIAlertController(title: "error", message: self.deletemodel.bookdata.downloadState, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    func load(){
        DispatchQueue.global(qos: .default).async {
            DispatchQueue.main.sync {
                //ダウンロードし，bookjsonに格納
                self.deletemodel.bookdata.bookDownload()
            }
            //ダウンロード終了後
            self.deletemodel.bookdata.downloadSemaphore.wait()
            
            if self.deletemodel.bookdata.downloadState != "success" { //error
                DispatchQueue.main.sync {
                    self.ActivityIndicatorView.stopAnimating()
        
                    let alert = UIAlertController(title: "error", message: self.deletemodel.bookdata.downloadState, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true, completion: nil)
                }
            }else{ //ダウンロード成功
                DispatchQueue.main.sync {
                    self.ActivityIndicatorView.stopAnimating()
                    self.refresh()
                }
            }
        }
    }
    
        
    func refresh(){
        deletemodel.bookdata.setDiplayData(searchtext: SearchBar.text, searchtarget: searchpicker.getTarget(), sortcategorytarget: sortcategorypicker.getCategoryTarget(), sortordertarget: sortorderpicker.getOrderTarget())
        deletemodel.CollectionView.reloadData()
    }
    
    func delete(_ idx: Int){
        //グルグル表示
        ActivityIndicatorView.startAnimating()
        
        DispatchQueue.global(qos: .default).async {
            DispatchQueue.main.async {
                //ダウンロードし，bookjsonに格納
                self.deletemodel.bookdata.bookDownload()
            }
            //ダウンロード終了後
            self.deletemodel.bookdata.downloadSemaphore.wait()
            
            if self.deletemodel.bookdata.downloadState != "success" { //error
                DispatchQueue.main.sync {
                    self.ActivityIndicatorView.stopAnimating()
        
                    let alert = UIAlertController(title: "error", message: self.deletemodel.bookdata.downloadState, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true, completion: nil)
                }
            }else{ //ダウンロード成功
                 let result = self.deletemodel.bookdata.delete(idx)
                
                if result != "success" { //error
                    DispatchQueue.main.sync {
                        self.ActivityIndicatorView.stopAnimating()
            
                        let alert = UIAlertController(title: "error", message: result, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(alert, animated: true, completion: nil)
                    }
                }else{
                    //削除成功したのでアップロード
                    DispatchQueue.main.async {
                        self.upload()
                    }
                }
            }
            
        }
    }
    
    func upload(){
        DispatchQueue.global(qos: .default).async {
            DispatchQueue.main.async {
                //book.jsonのアップロード
                self.deletemodel.bookdata.bookUpload()
            }
            self.deletemodel.bookdata.uploadSemaphore.wait()
            
            DispatchQueue.main.sync {
                self.ActivityIndicatorView.stopAnimating()
                
                if self.deletemodel.bookdata.uploadState != "success" { //error
                    let alert = UIAlertController(title: "error", message: self.deletemodel.bookdata.downloadState, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true, completion: nil)
                }else{
                    let alert = UIAlertController(title: "success", message: nil, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true, completion: nil)
                    
                    self.deletemodel.refresh()
                }
            }
        }
    }
    
    

}
