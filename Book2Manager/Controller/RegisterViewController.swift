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
    
    @IBOutlet weak var ImageView: UIImageView!
    
    
    @IBOutlet weak var RegisterButton: UIButton!
    
    @IBOutlet weak var CaptureView: UIView!
    
    //model
    var barcodemodel = BarcodeModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        TitleTextField.delegate = self
        AuthorTextField.delegate = self
        PublisherTextField.delegate = self
        CommentTextView.layer.cornerRadius = 5
        
        barcodemodel.setup(CaptureView, TitleTextField, AuthorTextField, PublisherTextField, CommentTextView, ImageView, RegisterButton)
       
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
