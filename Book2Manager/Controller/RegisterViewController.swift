//
//  RegisterViewController.swift
//  Book2Manager
//
//  Created by 相場智也 on 2022/04/23.
//

import UIKit
import AVFoundation
import Foundation

class RegisterViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var TitleTextField: UITextField!
    
    @IBOutlet weak var AuthorTextField: UITextField!
    
    @IBOutlet weak var PublisherTextField: UITextField!
    
    @IBOutlet weak var CommentTextView: UITextView!
    
    @IBOutlet weak var IsbnTextField: UITextField!
    
    @IBOutlet weak var RegisterButton: UIButton!
    
    @IBOutlet weak var CaptureView: UIView!

    //グルグル
    @IBOutlet weak var ActivityIndicatorView: UIActivityIndicatorView!
    
    //model
    var barcodemodel = BarcodeModel()
    var registermodel = RegisterModel()
    let dropboxmodel = DropBoxModel.shared
    
    //くるくる
    var activityIndicatorView = UIActivityIndicatorView()
    
    //フォトライブラリ操作
    var imagepicker: UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        TitleTextField.delegate = self
        AuthorTextField.delegate = self
        PublisherTextField.delegate = self
        IsbnTextField.delegate = self
        CommentTextView.layer.cornerRadius = 5
        
        dropboxmodel.registerVc = self

        textViewSetup()
        barcodemodel.setup(CaptureView, TitleTextField, AuthorTextField, PublisherTextField, CommentTextView, RegisterButton)

    }
    
    //=======textview===============
    // textViewを閉じるためのキーボード上のボタンを生成
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
        //登録
        //ファイルの存在確認→ダウンロード→アップロードを行っている
        exist()
    }
    
    
    @IBAction func AuthenticationAction(_ sender: Any) {
        //認証する
        //セマフォはサブスレッドに適用する. Main Threadに適用すると認証が止まってしまう
        DispatchQueue.global(qos: .default).async {
            DispatchQueue.main.async {
                //認証
                // 認証をセマフォでデットロックしてしまうためMain Threadで実行する
                self.dropboxmodel.authentication("Register")
            }
            //sginalは認証が終了後SceneDelegate.swiftで行われる
            self.dropboxmodel.authSemaphore.wait()
            //アラートの表示はメインスレッドで行う
            DispatchQueue.main.async {
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
                self.registermodel.exist()
            }
            
            self.registermodel.existSemaphore.wait()
            
            if self.registermodel.existState == "doDownload" {
                DispatchQueue.main.async {
                    self.download()
                }
            }else if self.registermodel.existState == "notExist" {
                //空のbookdataを用意する
                self.registermodel.bookdata = []
                DispatchQueue.main.async {
                    self.upload()
                }
            }else { //error
                DispatchQueue.main.async {
                    self.ActivityIndicatorView.stopAnimating()
                    
                    let alert = UIAlertController(title: "error", message: self.registermodel.downloadState, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true, completion: nil)
                }
                return
            }
        }
    }
    
    func download(){
        DispatchQueue.global(qos: .default).async {
            DispatchQueue.main.async {
                //ダウンロードし，bookdataに格納
                self.registermodel.download()
            }
            //ダウンロード終了後
            self.registermodel.downloadSemaphore.wait()
            
            if self.registermodel.downloadState != "success" { //error
                DispatchQueue.main.async {
                    self.ActivityIndicatorView.stopAnimating()
        
                    let alert = UIAlertController(title: "error", message: self.registermodel.downloadState, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true, completion: nil)
                }
            }else{
                DispatchQueue.main.async {
                    self.upload()
                }
            }
        }
    }
    func upload(){
        
        var title = ""
        var author = ""
        var publisher = ""
        var comment = ""
        
        if TitleTextField.text != nil && TitleTextField.text?.count != 0 {
            title = TitleTextField.text!
        }
        
        if AuthorTextField.text != nil && AuthorTextField.text?.count != 0{
            author = AuthorTextField.text!
        }
        
        if PublisherTextField.text != nil && PublisherTextField.text?.count != 0{
            publisher = PublisherTextField.text!
        }
        
        if CommentTextView.text != nil && CommentTextView?.text?.count != 0 {
            comment = CommentTextView.text!
        }
        
        
        DispatchQueue.global(qos: .default).async {
            //アップロードする
            DispatchQueue.main.async {
                //セマフォでデットロックしてしまうためMain Threadで実行する
                self.registermodel.upload(title, author, publisher, comment)
            }
            //アップロード終了後
            self.registermodel.uploadSemaphore.wait()
            
            //アラートの表示はメインスレッドで行う
            DispatchQueue.main.async {
                //グルグル非表示
                self.ActivityIndicatorView.stopAnimating()
                
                if self.registermodel.uploadState !=  "success" {
                    let alert = UIAlertController(title: "error", message: self.registermodel.uploadState, preferredStyle: .alert)
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
