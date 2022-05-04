//
//  UserViewController.swift
//  Book2Manager
//
//  Created by 相場智也 on 2022/04/23.
//

import UIKit

class UserViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
     
    @IBOutlet weak var TableView: UITableView!
    
    var usermodel = UserModel.shared
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        TableView.delegate = self
        TableView.dataSource = self
        //並べ替え，削除アイコン表示
        TableView.isEditing = true
        
        let result = usermodel.loadUserData()
        
        if result != "success" {
            //alert
            let alert = UIAlertController(title: "error", message: result, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //=============tableview ========================
    //cellの数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usermodel.users.count
    }
    
    //cellの内容
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TableCell", for: indexPath) as? TableViewCell else{
            fatalError("Dequeue failed: AnimalTableViewCell.")
        }
        
        cell.UserNameTextField.text = usermodel.users[indexPath.row]
        cell.UserNameTextField.tag = indexPath.row
        return cell
 
    }
    
    //セルの並び替え許可
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //セルを並び替えアクション　sourceIndexPathとdestinationIndexPathを入れ替える
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        usermodel.swap(sourceIndexPath.row, destinationIndexPath.row)
    }
    
    //削除ボタン非表示
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    //削除ボタンぶんのインデントを削除
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    @IBAction func SaveAction(_ sender: Any) {
        
        let result = usermodel.save()
                
        if result != "success" {
            //alert
            let alert = UIAlertController(title: "error", message: result, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true, completion: nil)
        }else{
            let alert = UIAlertController(title: "success", message: result, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func UpdateAction(_ sender: Any) {
        let result = usermodel.reLoad()
        
        if result != "success" {
            //alert
            let alert = UIAlertController(title: "error", message: result, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true, completion: nil)
        }else{
            TableView.reloadData()
        }
        
    }
    
    
}
