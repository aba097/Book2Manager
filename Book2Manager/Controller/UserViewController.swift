//
//  UserViewController.swift
//  Book2Manager
//
//  Created by 相場智也 on 2022/04/23.
//

import UIKit

class UserViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
     
    @IBOutlet weak var TableView: UITableView!
    
    @IBOutlet weak var UpdateActivityIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet weak var SaveActivityIndicatorView: UIActivityIndicatorView!
    
    var usermodel = UserModel.shared
    let dropboxmodel = DropBoxModel.shared

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        TableView.delegate = self
        TableView.dataSource = self
        //並べ替え，削除アイコン表示
        TableView.isEditing = true
        
        dropboxmodel.userVc = self
        //exist() -> load()
        exist()
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
        upload()
    }
    
    @IBAction func UpdateAction(_ sender: Any) {
        load()
    }
    
    @IBAction func AuthenticationAction(_ sender: Any) {
        //認証する
        //セマフォはサブスレッドに適用する. Main Threadに適用すると認証が止まってしまう
        DispatchQueue.global(qos: .default).async {
            DispatchQueue.main.async {
                //認証
                // 認証をセマフォでデットロックしてしまうためMain Threadで実行する
                self.dropboxmodel.authentication("User")
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
        UpdateActivityIndicatorView.startAnimating()
        
        DispatchQueue.global(qos: .default).async {
            DispatchQueue.main.async {
                //ファイルが存在するか確認
                self.usermodel.exist()
            }
            
            self.usermodel.existSemaphore.wait()
            
            if self.usermodel.existState == "doDownload" {
                DispatchQueue.main.async {
                    //user.txt読み込み
                    self.load()
                }
            }else if self.usermodel.existState == "notExist" {
                //defaultuserを用意する
                self.usermodel.users = ["user0", "user1", "user2", "user3", "user4", "use5", "user6", "user7", "user8", "user9", "user10", "user11", "user12", "user13", "user14", "user15"]
                
                self.usermodel.useridx = [0, 1 ,2 ,3 ,4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]
                DispatchQueue.main.sync {
                    self.TableView.reloadData()
                    self.UpdateActivityIndicatorView.stopAnimating()
                }
                
            }else { //error
                DispatchQueue.main.sync {
                    self.UpdateActivityIndicatorView.stopAnimating()
                    
                    let alert = UIAlertController(title: "error", message: self.usermodel.downloadState, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    func load(){
        //グルグル表示
        UpdateActivityIndicatorView.startAnimating()

        DispatchQueue.global(qos: .default).async {
            DispatchQueue.main.async {
                //ダウンロードし，bookdataに格納
                self.usermodel.download()
            }
            //ダウンロード終了後
            self.usermodel.downloadSemaphore.wait()
            
            if self.usermodel.downloadState != "success" { //error
                DispatchQueue.main.sync {
                    self.UpdateActivityIndicatorView.stopAnimating()
        
                    let alert = UIAlertController(title: "error", message: self.usermodel.downloadState, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true, completion: nil)
                }
            }else{
                DispatchQueue.main.sync {
                    self.TableView.reloadData()
                    self.UpdateActivityIndicatorView.stopAnimating()
                }
            }
        }
    }
    
    func upload(){
        //グルグル表示
        SaveActivityIndicatorView.startAnimating()
        
        DispatchQueue.global(qos: .default).async {
            DispatchQueue.main.async {
                self.usermodel.upload()
            }
            
            self.usermodel.uploadSemaphore.wait()
            
            //アラートの表示はメインスレッドで行う
            DispatchQueue.main.sync {
                //グルグル非表示
                self.SaveActivityIndicatorView.stopAnimating()
                
                if self.usermodel.uploadState !=  "success" {
                    let alert = UIAlertController(title: "error", message: self.usermodel.uploadState, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true, completion: nil)
                }else{
                    let alert = UIAlertController(title: "success", message: "アップロード成功", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
            
    }
    
    
}
