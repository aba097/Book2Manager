//
//  UserViewController.swift
//  Book2Manager
//
//  Created by 相場智也 on 2022/04/23.
//

import UIKit

class UserViewController: UIViewController {

    @IBOutlet weak var TableView: UITableView!
    
    var usermodel = UserModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let result = usermodel.loadUserData()
        
        if result != "success" {
            //alert
            let alert = UIAlertController(title: "error", message: result, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}
