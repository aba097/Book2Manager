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
        print(result)
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
