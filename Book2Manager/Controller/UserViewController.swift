//
//  UserViewController.swift
//  Book2Manager
//
//  Created by 相場智也 on 2022/04/23.
//

import UIKit

class UserViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
     
    @IBOutlet weak var TableView: UITableView!
    
    var usermodel = UserModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        TableView.delegate = self
        TableView.dataSource = self
        
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
        
        return cell
 
    }
    
    @IBAction func SaveAction(_ sender: Any) {
    
    }
    
}
