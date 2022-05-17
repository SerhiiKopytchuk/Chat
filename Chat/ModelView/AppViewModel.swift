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
    var isSignedIn:Bool{
        return auth.currentUser != nil
    }
    
    func signIn(email: String, password:String){
        auth.signIn(withEmail: email, password: password) { [weak self] result, error in
            guard result != nil, error == nil else{
                return
            }
            DispatchQueue.main.async {
                self?.signedIn = true
            }
        }
    }
    
    func signUp(email:String, password:String){
        auth.createUser(withEmail: email, password: password) { [weak self] result, error in
            guard result != nil, error == nil else{
                return
            }
            DispatchQueue.main.async {
                self?.signedIn = true
            }
        }
    }
    
}
