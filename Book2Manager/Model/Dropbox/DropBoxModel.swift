//
//  DropBoxModel.swift
//  Book2Manager
//
//  Created by 相場智也 on 2022/05/22.
//

import Foundation
import SwiftyDropbox

class  DropBoxModel {
    
    //シングルトン
    static let shared = DropBoxModel()
    
    weak var registerVc: RegisterViewController!
    weak var deleteVc: DeleteViewController!
    weak var userVc: UserViewController!
    
    let bookfilename = "bookdata.json"
    let bookfilepath = NSHomeDirectory() + "/Documents/" + "bookdata.json"
   
    //セマフォ　認証結果を待つ
    let authSemaphore = DispatchSemaphore(value: 0)
    //認証結果
    var authState = false
    
    //認証表示
    func authentication(_ vcName: String){
        //認証を行う
        //認証結果はSceneDelegate.swiftに返され，stateに格納
        // OAuth 2 code flow with PKCE that grants a short-lived token with scopes, and performs refreshes of the token automatically.
        let scopeRequest = ScopeRequest(scopeType: .user, scopes: ["account_info.read", "files.metadata.write", "files.metadata.read", "files.content.write", "files.content.read"], includeGrantedScopes: false)
        
        if vcName == "Register" {
            DropboxClientsManager.authorizeFromControllerV2(
                UIApplication.shared,
                controller: registerVc,
                loadingStatusDelegate: nil,
                openURL: { (url: URL) -> Void in UIApplication.shared.open(url, options: [:], completionHandler: nil) },
                scopeRequest: scopeRequest
            )
        }else if vcName == "Delete" {
            DropboxClientsManager.authorizeFromControllerV2(
                UIApplication.shared,
                controller: deleteVc,
                loadingStatusDelegate: nil,
                openURL: { (url: URL) -> Void in UIApplication.shared.open(url, options: [:], completionHandler: nil) },
                scopeRequest: scopeRequest
            )
        }else if vcName == "User" {
            DropboxClientsManager.authorizeFromControllerV2(
                UIApplication.shared,
                controller: userVc,
                loadingStatusDelegate: nil,
                openURL: { (url: URL) -> Void in UIApplication.shared.open(url, options: [:], completionHandler: nil) },
                scopeRequest: scopeRequest
            )
        }
    }
    
}
