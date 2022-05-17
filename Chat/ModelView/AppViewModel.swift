//
//  AppViewModel.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 17.05.2022.
//

import Foundation
import Firebase
import SwiftUI

class AppViewModel: ObservableObject{
    let auth = Auth.auth()
    
    @Published var signedIn = false
    @Published var username: String = ""

    // published mean broadcast
    
    func signIn(email: String, password:String){
        auth.signIn(withEmail: email, password: password) { [weak self] result, error in
            guard result != nil, error == nil else{
                return
            }
            DispatchQueue.main.async {
                self?.username = Auth.auth().currentUser?.displayName ?? ""
            }
            self?.signedIn = true
        }
    }
    
    func signUp(username: String, email:String, password:String){
        auth.createUser(withEmail: email, password: password) { [weak self] result, error in
            guard result != nil, error == nil else{
                return
            }
            DispatchQueue.main.async {
            self?.setUserName(username: username)
            }
            
                self?.signedIn = true
            
            
        }
    }
    
    func setUserName(username: String) {
        let changeProfileRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeProfileRequest?.displayName = username
        changeProfileRequest?.commitChanges(completion: { [weak self] error in
            guard let self = self else { return }
            if error != nil{
                print(error ?? "error")
            }else{
                self.username = username
            }
        })
    }
    
    init(){
        self.signedIn = auth.currentUser != nil
        self.username = auth.currentUser?.displayName ?? ""
    }
    
}
