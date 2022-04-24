//
//  RegisterViewController.swift
//  Book2Manager
//
//  Created by 相場智也 on 2022/04/23.
//

import UIKit
import AVFoundation
import Foundation

class RegisterViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVCaptureMetadataOutputObjectsDelegate {

    @IBOutlet weak var TitleTextField: UITextField!
    
    @IBOutlet weak var AuthorTextField: UITextField!
    
    @IBOutlet weak var PublisherTextField: UITextField!
    
    @IBOutlet weak var CommentTextView: UITextView!
    
    @IBOutlet weak var IsbnTextField: UITextField!
    
    @IBOutlet weak var ImageView: UIImageView!
    
    
    @IBOutlet weak var RegisterButton: UIButton!
    
    @IBOutlet weak var CaptureView: UIView!
    private lazy var captureSession: AVCaptureSession = AVCaptureSession()
    private lazy var captureDevice: AVCaptureDevice = AVCaptureDevice.default(for: AVMediaType.video)!
    private lazy var capturePreviewLayer: AVCaptureVideoPreviewLayer = {
        let layer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        return layer
    }()
        
    private var captureInput: AVCaptureInput? = nil
    private lazy var Output: AVCaptureMetadataOutput = {
        let output = AVCaptureMetadataOutput()
        output.setMetadataObjectsDelegate(self, queue: .main)
        return output
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        TitleTextField.delegate = self
        AuthorTextField.delegate = self
        PublisherTextField.delegate = self
        CommentTextView.layer.cornerRadius = 5
        
    }
    
    
    
    @IBAction func ImageUploadAction(_ sender: Any) {
    }
    
    
    @IBAction func BarcodeReadAction(_ sender: Any) {
    }
    
    @IBAction func RegisterAction(_ sender: Any) {
    }
    
}
