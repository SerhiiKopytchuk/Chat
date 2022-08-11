//
//  ChannelViewModel.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 26.06.2022.
//
import Foundation
import Firebase
import FirebaseFirestoreSwift
import FirebaseFirestore
import SwiftUI

class ChannelViewModel: ObservableObject {

    // MARK: - vars

    @Published var currentUser: User = User()
    @Published var owner: User = User()
    @Published var searchText = ""

    @Published var channels: [Channel] = []
    @Published var searchChannels: [Channel] = []
    @Published var currentChannel: Channel = Channel()
    @Published var channelType: ChannelType = .publicType

    @Published var channelSubscribers: [User] = []

    @Published var createdChannelImage: UIImage?
    @Published var lastCreatedChannelId: String?
    @Published private(set) var isSavedImage = false

    let dataBase = Firestore.firestore()

    // MARK: - functions

    func saveImageLocally(image: UIImage, imageName: String) {
        createdChannelImage = image
        lastCreatedChannelId = imageName
        isSavedImage = true
    }

    func getChannelOwner() {
        dataBase.collection("users").document("\(currentChannel.ownerId)").getDocument { document, error in
            if self.isError(error: error) { return }

            if let channelOwner = try? document?.data(as: User.self) {
                self.owner = channelOwner
            }
        }
    }

    func subscribeToChannel() {
        DispatchQueue.main.async {

            self.dataBase.collection("users").document(self.currentUser.id)
                .updateData(["channels": FieldValue.arrayUnion([self.currentChannel.id ?? "someChatId"])])

            self.dataBase.collection("channels").document(self.currentChannel.id ?? "SomeChannelId")
                .updateData(["subscribersId": FieldValue.arrayUnion([self.currentUser.id ])])

        }
    }

    func doesUsesSubscribed () -> Bool {
        for id in currentChannel.subscribersId ?? [] where id == currentUser.id {
            return true
        }
        if currentChannel.ownerId == currentUser.id {
            return true
        }
        return false
    }

    func getSearchChannels() {

        dataBase.collection("channels").whereField("isPrivate", isEqualTo: false)
            .addSnapshotListener { querySnapshot, error in

                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(String(describing: error))")
                    return
                }

                self.searchChannels = documents.compactMap {document -> Channel? in
                    do {
                        let channel = self.filterChannel(channel: try document.data(as: Channel.self))
                        return channel
                    } catch {
                        print("error decoding document into Channel: \(error)")
                        return nil
                    }
                }
            }
    }

    private func filterChannel(channel: Channel) -> Channel? {
        if channel.name.contains(self.searchText) {
            return channel
        }
        return nil
    }

    func getCurrentChannel( channelId: String, competition: @escaping (Channel) -> Void) {

        dataBase.collection("channels").document(channelId).getDocument { document, error in

            if self.isError(error: error) { return }

            if let channel = try? document?.data(as: Channel.self) {
                competition(channel)
            }

        }
    }

    func getCurrentChannel( name: String, ownerId: String,
                            competition: @escaping (Channel) -> Void,
                            failure: @escaping (String) -> Void) {

        dataBase.collection("channels")
            .whereField("ownerId", isEqualTo: ownerId)
            .whereField("name", isEqualTo: name)
            .queryToChannel { channel in
                self.currentChannel = channel
                competition(channel)
                return

            } failure: { text in
                failure(text)
                return
            }

    }

    func createChannel(name: String,
                       description: String,
                       competition: @escaping (Channel) -> Void) {
        do {

            try creatingChannel(name: name,
                                description: description,
                                competition: { channel in
                competition(channel)
            })

        } catch {
            print("error creating chat to Firestore:: \(error)")
        }
    }

    fileprivate func creatingChannel(name: String,
                                     description: String,
                                     competition: @escaping (Channel) -> Void) throws {

        let newChannel = Channel(name: name,
                                 description: description,
                                 ownerId: currentUser.id,
                                 ownerName: currentUser.name,
                                 isPrivate: channelType == ChannelType.privateType)

        try dataBase.collection("channels").document().setData(from: newChannel)

        getCurrentChannel(name: name, ownerId: currentUser.id) { channel in
            self.currentChannel = channel
            self.addChannelIdToOwner()
            competition(channel)
        } failure: { _ in
            print("failure")
        }

    }

    fileprivate func addChannelIdToOwner() {
        DispatchQueue.main.async {

            self.dataBase.collection("users").document(self.owner.id)
                .updateData(["channels": FieldValue.arrayUnion([self.currentChannel.id ?? "someChatId"])])

        }
    }

    func changeLastActivityAndSortChannels() {
        for index in self.channels.indices {
            if channels[index].id == self.currentChannel.id {
                channels[index].lastActivityTimestamp = Date()
                break
            }
        }
        sortChannels()
    }

    func getChannels(fromUpdate: Bool = false, channelsId: [String] = []) {

        withAnimation(.easeInOut.delay(0.5)) {

            if channelsId.isEmpty {

                self.channels = []

                for channelId in currentUser.channels {
                    dataBase.collection("channels").document(channelId)
                        .toChannel { channel in
                            self.channels.append(channel)
                            self.sortChannels()

                        }
                }

            } else {
                if channelsId.count > channels.count {
                    addChannels(channelsId: channelsId)
                } else {
                    removeChannels(channelsId: channelsId)
                }
            }

        }

        if !fromUpdate {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.updateChannels()
            }
        }
    }

    private func addChannels(channelsId: [String]) {
        for channelId in channelsId {
            if !currentUser.channels.contains(channelId) {
                dataBase.collection("channels").document(channelId)
                    .toChannel { channel in
                        self.channels.append(channel)
                        self.currentUser.chats.append(channel.id ?? "some channel id")
                        self.sortChannels()
                    }
            }
        }
    }

    private func removeChannels(channelsId: [String]) {
        for channel in channels {
            if !channelsId.contains(channel.id ?? "some id") {
                self.channels = channels.filter({ $0.id != channel.id})
                self.currentUser.channels = currentUser.channels.filter({ $0 != channel.id})
            }
        }
    }

    func sortChannels() {
        self.channels.sort { $0.lastActivityTimestamp > $1.lastActivityTimestamp }
    }

    private func updateChannels() {
        DispatchQueue.main.async {
            self.dataBase.collection("users").document(self.currentUser.id)
                .addSnapshotListener { document, error in

                    if self.isError(error: error) { return }

                    guard let userLocal = try? document?.data(as: User.self) else {
                        return
                    }

                    if userLocal.channels.count != self.channels.count {
                        self.getChannels(fromUpdate: true,
                                         channelsId: userLocal.channels)
                    }
                }
        }
    }

    func deleteChannel() {
        removeChannelFromSubscribersAndOwner()
        dataBase.collection("channels").document("\(currentChannel.id ?? "someId")").delete { err in
            if self.isError(error: err) { return }
        }
    }

    fileprivate func removeChannelFromSubscribersAndOwner() {
        if let subscribersId  = currentChannel.subscribersId {
            if !subscribersId.isEmpty {
                for id in subscribersId {
                    removeChannelFromUserSubscriptions(id: id)
                }
            }
        }

        removeChannelFromUserSubscriptions(id: currentChannel.ownerId)
    }

    func removeChannelFromUserSubscriptions(id: String = "someId") {
        removeCurrentUserFromChannelSubscribers()
        dataBase.collection("users").document(id).updateData([
            "channels": FieldValue.arrayRemove(["\(currentChannel.id ?? "someId")"])
        ])
    }

    fileprivate func removeCurrentUserFromChannelSubscribers() {
        dataBase.collection("channels").document(currentChannel.id ?? "some ID").updateData([
            "subscribersId": FieldValue.arrayRemove(["\(currentUser.id )"])
        ])
    }

    fileprivate func isError(error: Error?) -> Bool {
        if error != nil {
            print(error?.localizedDescription ?? "error")
            return true
        } else {
            return false
        }
    }

    func clearPreviousDataBeforeSignIn() {
        currentUser = User()
        searchText = ""
        channels = []
        searchChannels = []
    }

}
