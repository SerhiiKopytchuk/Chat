//
//  EditChannelViewModel.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 21.07.2022.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
import FirebaseFirestore
import SwiftUI
import FirebaseStorage

class EditChannelViewModel: ObservableObject {

    @Published var currentUser: User = User()
    @Published var currentChannel: Channel = Channel()
    @Published var channelSubscribers: [User] = []
    @Published var usersToAddToChannel: [User] = []

    @Published var searchText = ""

    let dataBase = Firestore.firestore()
    private let firebaseManager = FirestorePathManager.shared

    func updateChannelInfo(name: String, description: String) {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            self?.firebaseManager.getChannelDocumentReference(for: self?.currentChannel.id)
                .updateData(["name": name,
                             "description": description])

            DispatchQueue.main.async {
                self?.currentChannel.name = name
                self?.currentChannel.description = description
            }
        }
    }

    func removeUserFromSubscribersList(id: String) {
        withAnimation {
            for index in self.currentChannel.subscribersId?.indices.reversed() ?? [] {
                if id == self.currentChannel.subscribersId?[index] {
                    self.currentChannel.subscribersId?.remove(at: index)
                }
            }

            for index in self.channelSubscribers.indices.reversed() {
                if id == self.channelSubscribers[index].id {
                    self.channelSubscribers.remove(at: index)
                    return
                }
            }
        }
    }

    func getChannelSubscribers() {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            self?.firebaseManager.usersCollection
                .getDocuments { querySnapshot, error in

                    guard let documents = querySnapshot?.documents else {
                        print("Error fetching documets: \(String(describing: error))")
                        return
                    }

                    DispatchQueue.main.async {
                        self?.channelSubscribers = documents.compactMap { document -> User? in
                            do {

                                let user = try document.data(as: User.self)

                                return self?.filterRemoveUsers(user: user)
                            } catch {
                                print("error deconding documet into User: \(error)")
                                return nil
                            }
                        }
                    }
                }
        }
    }

    private func filterRemoveUsers(user: User) -> User? {
        if self.currentChannel.subscribersId?.contains(user.id) ?? false {
            return user
        }
        return nil
    }

    func subscribeUsersToChannel(usersId: [String]) {
        for userId in usersId {

            self.currentChannel.subscribersId?.append(userId)

            self.dataBase.collection("channels").document(currentChannel.id ?? "some ChannelId")
                .updateData(["subscribersId": FieldValue.arrayUnion([userId])])

            self.dataBase.collection("users").document(userId)
                .updateData(["channels": FieldValue.arrayUnion([self.currentChannel.id ?? "someChatId"])])

        }
    }

    func getUsersToAddToChannel() {
        dataBase.collection("users").addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documets: \(String(describing: error))")
                return
            }

            self.usersToAddToChannel = documents.compactMap { document -> User? in
                do {

                    let user = try document.data(as: User.self)

                    return self.addUserToChannelFilter(user: user)
                } catch {
                    print("error deconding documet into User: \(error)")
                    return nil
                }
            }
        }
    }

    private func addUserToChannelFilter(user: User) -> User? {
        if doesUserNameContains(user: user) != nil {
            if self.currentChannel.subscribersId?.contains(user.id) ?? false {
                return nil
            }
            return user
        }
        return nil
    }

    private func doesUserNameContains(user: User) -> User? {
        if user.name.contains(self.searchText) && user.name != currentUser.name {
            return user
        }
        return nil
    }

    func removeChannelFromSubscriptionsWithCertainUser(id: String) {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            self?.removeCertainFromChannelSubscribers(id: id)
            self?.firebaseManager.getUserDocumentReference(for: id).updateData([
                "channels": FieldValue.arrayRemove(["\(self?.currentChannel.id ?? "someId")"])
            ])
        }

    }

    fileprivate func removeCertainFromChannelSubscribers(id: String) {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            self?.firebaseManager.getChannelDocumentReference(for: self?.currentChannel.id).updateData([
                "subscribersId": FieldValue.arrayRemove(["\(id)"])
            ])
        }
    }
}
