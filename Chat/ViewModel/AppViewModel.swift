//
//  AppViewModel.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 17.05.2022.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
import FirebaseFirestore
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
    @Published var alertText: String = ""
    @Published var showAlert = false
    @Published private(set) var messages:[Message] = []
    @Published private(set) var lastMessageId = ""

    // published mean broadcast

    let db = Firestore.firestore()
    
    func getMessages(){
        db.collection("messages").addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else{
                print("Error fetching documets: \(String(describing: error))")
                return
            }
            
            
            self.messages = documents.compactMap { document -> Message? in
                do{
                    return try document.data(as: Message.self)
                }catch{
                    print("error deconding documet into Message: \(error)")
                    return nil
                }
            }
            self.messages.sort{ $0.timestamp < $1.timestamp}
            
            if let id = self.messages.last?.id{
                self.lastMessageId = id
            }
        }
    }
    
    func sendMessage(text: String){
        do{
            let newMessage = Message(id: "\(UUID())", text: text, received: false, timestamp: Date())
            try db.collection("messages").document().setData(from: newMessage)
        }catch{
            print("error adding message to Firestore:: \(error)")
        }
    }
    
    func signIn(email: String, password:String){
        showLoader = true
        auth.signIn(withEmail: email, password: password) { [weak self] result, error in
            guard result != nil, error == nil else{
                self?.alertText = error?.localizedDescription ?? ""
                self?.showAlert = true
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
                self?.alertText = error?.localizedDescription ?? ""
                self?.showAlert = true
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
        getMessages()
    }
    
}
