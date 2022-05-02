//
//  TableViewCell.swift
//  Book2Manager
//
//  Created by 相場智也 on 2022/04/28.
//

import UIKit

class TableViewCell: UITableViewCell{
    
    @IBOutlet weak var UserNameTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        UserNameTextField.delegate = self
    }
}

//TextFieldのリターンキーが押された時，キーボード閉じる
extension TableViewCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        UserNameTextField.resignFirstResponder()
        return true
    }
}
