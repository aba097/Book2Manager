//
//  RegisterViewController.swift
//  Book2Manager
//
//  Created by 相場智也 on 2022/04/23.
//

import UIKit
import AVFoundation
import Foundation


extension UIScrollView {
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            self.superview?.touchesBegan(touches, with: event)
            print("touches began")
    }
}

class RegisterViewController: UIViewController, UIScrollViewDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var TitleTextField: UITextField!
    
    @IBOutlet weak var AuthorTextField: UITextField!
    
    @IBOutlet weak var PublisherTextField: UITextField!
    
    @IBOutlet weak var CommentTextView: UITextView!
    
    @IBOutlet weak var IsbnTextField: UITextField!
    
    @IBOutlet weak var ImageView: UIImageView!
    
    
    @IBOutlet weak var RegisterButton: UIButton!
    
    @IBOutlet weak var CaptureView: UIView!
    
    @IBOutlet weak var ScrollView: UIScrollView!
    
    //model
    var barcodemodel = BarcodeModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ScrollView.delegate = self
        TitleTextField.delegate = self
        AuthorTextField.delegate = self
        PublisherTextField.delegate = self
        CommentTextView.layer.cornerRadius = 5
        
        textViewSetup()
        barcodemodel.setup(CaptureView, TitleTextField, AuthorTextField, PublisherTextField, CommentTextView, ImageView, RegisterButton)
       
    }
    
    // textViewを閉じるためのボタンを生成
    func textViewSetup(){
        //ツールバー生成
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 40))
        // スタイルを設定
        toolBar.barStyle = UIBarStyle.default
        // 画面幅に合わせてサイズを変更
        toolBar.sizeToFit()
        // 閉じるボタンを右に配置するためのスペース?
        let spacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
        // 閉じるボタン
        let commitButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(commitButtonTapped))
        // スペース、閉じるボタンを右側に配置
        toolBar.items = [spacer, commitButton]
        // textViewのキーボードにツールバーを設定
        CommentTextView.inputAccessoryView = toolBar
    }
    
    @objc func commitButtonTapped() {
        self.view.endEditing(true)
    }
        
    //=======textfield===============
    //TextFieldリターンキーが押されたとき
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        //今フォーカスが当たっているテキストボックスからフォーカスを外す
        textField.resignFirstResponder()
        
        //tileが入力されていたらボタンを有効にする
        if let textname = TitleTextField.text{
            if textname.count != 0{
                RegisterButton.isEnabled = true
            }else{
                RegisterButton.isEnabled = false
            }
        }
        
        return true
    }
    
    //TextField入力中
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        //tileが入力されていたらボタンを有効にする
        if let textname = TitleTextField.text{
            if textname.count != 0{
                RegisterButton.isEnabled = true
            }else{
                RegisterButton.isEnabled = false
            }
        }
        return true
    }

    @IBAction func ImageUploadAction(_ sender: Any) {
    }
    
    
    @IBAction func BarcodeReadAction(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            CaptureView.isHidden = false
            if !barcodemodel.captureSession.isRunning {
                barcodemodel.captureSession.startRunning()
            }
        }else{
            CaptureView.isHidden = true
            if barcodemodel.captureSession.isRunning {
                barcodemodel.captureSession.stopRunning()
            }
        }
        
    }
    
    @IBAction func ISBNcodeAction(_ sender: Any) {
        barcodemodel.bookSearch(isbncode: IsbnTextField.text!)
    }
    
    @IBAction func RegisterAction(_ sender: Any) {
    }
    
}
