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

class EditChannelViewModel: ObservableObject {

    @Published var currentUser: User = User(chats: [], channels: [], gmail: "", id: "", name: "")
    @Published var currentChannel: Channel = Channel(id: "",
                                                     name: "",
                                                     description: "",
                                                     ownerId: "",
                                                     ownerName: "",
                                                     subscribersId: [],
                                                     messages: [],
                                                     lastActivityTimestamp: Date(),
                                                     isPrivate: true)
    @Published var channelSubscribers: [User] = []
    @Published var usersToAddToChannel: [User] = []

    @Published var searchText = ""

    let dataBase = Firestore.firestore()

    func removeUserFromSubscribersList(id: String) {

        for index in currentChannel.subscribersId?.indices.reversed() ?? [] {
            if id == currentChannel.subscribersId?[index] {
                currentChannel.subscribersId?.remove(at: index)
            }
        }

        for index in channelSubscribers.indices.reversed() {
            if id == channelSubscribers[index].id {
                channelSubscribers.remove(at: index)
                return
            }
        }
    }

    func getChannelSubscribers() {
        dataBase.collection("users").getDocuments { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documets: \(String(describing: error))")
                return
            }

            self.channelSubscribers = documents.compactMap { document -> User? in
                do {

                    let user = try document.data(as: User.self)

                    return self.filterRemoveUsers(user: user)
                } catch {
                    print("error deconding documet into User: \(error)")
                    return nil
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
        removeCertainFromChannelSubscribers(id: id)
        dataBase.collection("users").document(id).updateData([
            "channels": FieldValue.arrayRemove(["\(currentChannel.id ?? "someId")"])
        ])
    }

    fileprivate func removeCertainFromChannelSubscribers(id: String) {
        dataBase.collection("channels").document(currentChannel.id ?? "some ID").updateData([
            "subscribersId": FieldValue.arrayRemove(["\(id)"])
        ])
    }
}
