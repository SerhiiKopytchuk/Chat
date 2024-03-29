//
//  PresenceViewModel.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 20.10.2022.
//

import SwiftUI
import FirebaseDatabase

class PresenceViewModel: ObservableObject {

    let usersRef = Database.database().reference(withPath: "online")
    var currentUser = User(gmail: UUID().uuidString, id: UUID().uuidString, name: UUID().uuidString)

    @Published var onlineUsers: [String] = []

    func startSetup(user: User) {
        self.currentUser = user
        let currentUserRef = self.usersRef.child(user.id)
        currentUserRef.setValue(user.gmail)
        currentUserRef.onDisconnectRemoveValue()
        self.addObservers()
    }

    func addObservers() {
        self.observeAddOnline()
        self.observeRemoveOnline()
    }

    func observeAddOnline() {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            self?.usersRef.observe(.childAdded) { snap, _  in
                guard let email = snap.value as? String else { return }
                DispatchQueue.main.async {
                    self?.onlineUsers.append(email)
                }
            }
        }
    }

    func observeRemoveOnline() {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            self?.usersRef.observe(.childRemoved) { snap  in
                guard let emailToFind = snap.value as? String else { return }
                if let index = self?.onlineUsers.firstIndex(of: emailToFind) {
                    DispatchQueue.main.async {
                        self?.onlineUsers.remove(at: index)
                    }
                }
            }
        }
    }

    func setOffline() {
        let currentUserRef = self.usersRef.child(currentUser.id)
        currentUserRef.removeValue()
    }
}
