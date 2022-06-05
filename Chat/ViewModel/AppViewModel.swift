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
    @Published var user:User = User(chats: [], gmail: "", id: "", name: "")
    @Published var users:[User] = []
    @Published var searchText = ""
    @Published var chats:[Conversation] = []

    var isSignedIn:Bool{
        return auth.currentUser != nil
    }
    
    

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
    
    func sendMessage(text: String, UID:String){
        do{
            let newMessage = Message(id: "\(UUID())", text: text, senderId: UID, timestamp: Date())
            try db.collection("messages").document().setData(from: newMessage)
        }catch{
            print("error adding message to Firestore:: \(error)")
        }
    }
    
    func createFbUser(name:String, gmail:String){
        do{
            let newUser = User(chats: [], gmail: gmail, id: Auth.auth().currentUser?.uid ?? "\(UUID())", name: name)
            try db.collection("users").document("\(newUser.id)").setData(from: newUser)
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
                self?.showLoader = false
                self?.getCurrentUesr()
            }
            
        }
    }
    
    func getCurrentUesr(){
        let docRef = self.db.collection("users").document(Auth.auth().currentUser?.uid ?? "")
        
        docRef.getDocument(as: User.self) { result in
          switch result {
          case .success(let user):
            // A Book value was successfully initialized from the DocumentSnapshot.
            self.user = user
              self.getChats()
          case .failure(let error):
            print(error)
          }
        }
      
        
    }
    
    func getChats(){
        for chatId in user.chats{
            let docRef = db.collection("Chats").document(chatId)

            docRef.getDocument(as: Conversation.self) { result in
                
                switch result {
                case .success(let chat):
                    self.chats.append(chat)
                case .failure(let error):
                    print("Error decoding city: \(error)")
                }
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
                self?.getCurrentUesr()
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
                self?.showLoader = false
                self?.createFbUser(name: Auth.auth().currentUser?.displayName ?? "", gmail: Auth.auth().currentUser?.email ?? "")
            }
        }
    }
    
    func getAllUsers(){
        db.collection("users").addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else{
                print("Error fetching documets: \(String(describing: error))")
                return
            }
            
            
            self.users = documents.compactMap { document -> User? in
                do{
                 
                    let user = try document.data(as: User.self)
                    if user.name.contains(self.searchText){
                        return user
                    }
                    return nil
                }catch{
                    print("error deconding documet into Message: \(error)")
                    return nil
                }
            }
        }
    }
    

    
    func signOut(){
        try! auth.signOut()
        self.signedIn = false
    }
    
    func getUserUID()->String{
        return self.auth.currentUser?.uid ?? "no UID"
    }
    
    init(){
        getAllUsers()
        
        getMessages()
        getCurrentUesr()
    }
    
}
