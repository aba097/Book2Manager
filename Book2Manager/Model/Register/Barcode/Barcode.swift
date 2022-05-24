//
//  Barcode.swift
//  Book2Manager
//
//  Created by 相場智也 on 2022/04/25.
//

import UIKit
import Foundation
import AVFoundation

class BarcodeModel: NSObject, AVCaptureMetadataOutputObjectsDelegate{
    
    weak var CaptureView: UIView!
    weak var TitleTextField: UITextField!
    weak var AuthorTextField: UITextField!
    weak var PublisherTextField: UITextField!
    weak var CommentTextView: UITextView!
    weak var RegisterButton: UIButton!
    
    var isbnmanager = IsbnManager()
    
    lazy var captureSession:AVCaptureSession = AVCaptureSession()
    lazy var captureDevice: AVCaptureDevice = AVCaptureDevice.default(for: AVMediaType.video)!
    lazy var capturePreviewLayer: AVCaptureVideoPreviewLayer = {
        let layer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        return layer
    }()
        
    var captureInput: AVCaptureInput? = nil
    lazy var Output: AVCaptureMetadataOutput = {
        let output = AVCaptureMetadataOutput()
        output.setMetadataObjectsDelegate(self, queue: .main)
        return output
    }()
    
    func setup(_ captureview :UIView, _ title: UITextField, _ author: UITextField, _ publisher: UITextField, _ comment: UITextView, _ button: UIButton){
        
        CaptureView = captureview
        TitleTextField = title
        AuthorTextField = author
        PublisherTextField = publisher
        CommentTextView = comment
        RegisterButton = button
        
        
        do {
            captureInput = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(captureInput!)
            captureSession.addOutput(Output)
            Output.metadataObjectTypes = Output.availableMetadataObjectTypes
            capturePreviewLayer.frame = self.CaptureView?.bounds ?? CGRect.zero
            capturePreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            CaptureView?.layer.addSublayer(capturePreviewLayer)
            //captureSession.startRunning()
        
        } catch let error as NSError {
            print(error)
        }
    }
    
    //バーコード読み取り
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        self.captureSession.stopRunning()
        
        let objects = metadataObjects
        var detectionString: String? = nil
        let barcodeTypes = [AVMetadataObject.ObjectType.ean8, AVMetadataObject.ObjectType.ean13]
        for metadataObject in objects {
            loop: for type in barcodeTypes {
                guard metadataObject.type == type else { continue }
                guard self.capturePreviewLayer.transformedMetadataObject(for: metadataObject) is AVMetadataMachineReadableCodeObject else { continue }
                if let object = metadataObject as? AVMetadataMachineReadableCodeObject {
                    detectionString = object.stringValue
                    break loop
                }
            }
    
            guard let value = detectionString else { continue }
            
            bookSearch(isbncode: value)
            
            
        }
        self.captureSession.startRunning()
    }
    
    func bookSearch(isbncode: String){
        
        let result = isbnmanager.getBookData(isbn: isbncode)
        
        self.TitleTextField.text = result.title
        self.AuthorTextField.text = result.author
        self.PublisherTextField.text = result.publisher
        self.CommentTextView.text = result.comment
      
        //登録ボタンを押せるように
        self.RegisterButton.isEnabled = result.isEnable
        
    }
    
    
    
}
