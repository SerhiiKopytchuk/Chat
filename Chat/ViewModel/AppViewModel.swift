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
    @Published var showLoader = false
    
    var isSignedIn:Bool{
         return auth.currentUser != nil
    }
    
    
    @Published var username: String = ""
    @Published var gmail: String = ""
    

    // published mean broadcast
    
    
    func signIn(email: String, password:String){
        showLoader = true
        auth.signIn(withEmail: email, password: password) { [weak self] result, error in
            guard result != nil, error == nil else{
                self?.showLoader = false
                return
            }
            DispatchQueue.main.async {
                self?.signedIn = true
                self?.username = Auth.auth().currentUser?.displayName ?? ""
                self?.gmail = email
                self?.showLoader = false
            }
           
        }
    }
    
    func signIn(credential: AuthCredential){
        Auth.auth().signIn(with: credential){ [weak self] result, error in
            guard result != nil, error == nil else{
                
                return
            }
            DispatchQueue.main.async {
                self?.signedIn = true
                self?.username = Auth.auth().currentUser?.displayName ?? ""
                self?.gmail = Auth.auth().currentUser?.email ?? ""
               
            }
        }
    }
    
    func signUp(username: String,  email:String, password:String){
        showLoader = true
        auth.createUser(withEmail: email, password: password) { [weak self] result, error in
            guard result != nil, error == nil else{
                self?.showLoader = false
                return
            }
            DispatchQueue.main.async {
                self?.signedIn = true
                self?.setUserName(username: username)
                self?.gmail = email
                self?.showLoader = false
            }
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
    
    func signOut(){
        try! auth.signOut()
        self.signedIn = false
    }
    
    init(){
        self.username = auth.currentUser?.displayName ?? ""
        self.gmail = auth.currentUser?.email ?? ""
    }
    
}
