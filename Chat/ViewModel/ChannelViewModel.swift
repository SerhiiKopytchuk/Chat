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

    @Published var createdChannelImage: UIImage?
    @Published var lastCreatedChannelId: String?
    @Published private(set) var isSavedImage = false

    let firestoreManager = FirestorePathManager.shared

    // MARK: - computedProperties

    var doesUsesSubscribed: Bool {
        for id in currentChannel.subscribersId ?? [] where id == currentUser.id {
            return true
        }
        if currentChannel.ownerId == currentUser.id {
            return true
        }
        return false
    }

    // MARK: - functions

    func saveImageLocally(image: UIImage, imageName: String) {
        DispatchQueue.main.async {
            self.createdChannelImage = image
            self.lastCreatedChannelId = imageName
            self.isSavedImage = true
        }
    }

    func subscribeToChannel() {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in

            self?.firestoreManager.getUserDocumentReference(for: self?.currentUser.id)
                .updateData(["channels": FieldValue.arrayUnion([self?.currentChannel.id ?? "someChannelId"])])

            self?.firestoreManager.getChannelDocumentReference(for: self?.currentChannel.id)
                .updateData(["subscribersId": FieldValue.arrayUnion([self?.currentUser.id ?? "someUserId"])])

        }
    }

    func getSearchChannels() {
        DispatchQueue.global(qos: .utility).async { [weak self] in
            self?.firestoreManager.channelsCollection.whereField("isPrivate", isEqualTo: false)
                .getDocuments(completion: { querySnapshot, error in

                    guard let documents = querySnapshot?.documents else {
                        print("Error fetching documents: \(String(describing: error))")
                        return
                    }

                    DispatchQueue.main.async {
                        self?.searchChannels = documents.compactMap {document -> Channel? in
                            do {
                                let channel = self?.filterChannel(channel: try document.data(as: Channel.self))
                                return channel
                            } catch {
                                print("error decoding document into Channel: \(error)")
                                return nil
                            }
                        }
                    }
                })
        }
    }

    private func filterChannel(channel: Channel) -> Channel? {
        if channel.name.lowercased()
            .contains(self.searchText.lowercased()) {
            return channel
        }
        return nil
    }

    func getCurrentChannel( channelId: String, competition: @escaping (Channel) -> Void) {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            self?.firestoreManager.getChannelDocumentReference(for: channelId)
                .getDocument { document, error in

                    if error.review(message: "failed to getCurrentChannel") { return }

                    if let channel = try? document?.data(as: Channel.self) {
                        DispatchQueue.main.async {
                            competition(channel)
                        }
                    }
                }
        }
    }

    func getChannel( name: String, ownerId: String, competition: @escaping (Channel?, String?) -> Void) {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            self?.firestoreManager.channelsCollection
                .whereField("ownerId", isEqualTo: ownerId)
                .whereField("name", isEqualTo: name)
                .queryToChannel(competition: { channel, error in

                    guard let channel, error == nil else {
                        competition(nil, error?.localizedDescription)
                        return
                    }

                    DispatchQueue.main.async {
                        self?.currentChannel = channel
                        competition(channel, nil)
                    }
                })
        }
    }

    func createChannel(name: String,
                       description: String,
                       competition: @escaping (Channel) -> Void) {

        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            let newChannel = Channel(name: name,
                                     description: description,
                                     ownerId: self?.currentUser.id ?? "some id",
                                     ownerName: self?.currentUser.name ?? "some id",
                                     isPrivate: self?.channelType == ChannelType.privateType)

            try? self?.firestoreManager.channelsCollection.document().setData(from: newChannel)

            self?.getChannel(name: name, ownerId: self?.currentUser.id ?? "some id") { channel, errorDescription in

                guard let channel, errorDescription == nil else {
                    print(errorDescription ?? "")
                    return
                }

                DispatchQueue.main.async {
                    self?.currentChannel = channel
                    self?.addChannelIdToOwner()
                    competition(channel)
                }
            }
        }
    }

    fileprivate func addChannelIdToOwner() {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            self?.firestoreManager.getUserDocumentReference(for: self?.owner.id)
                .updateData(["channels": FieldValue.arrayUnion([self?.currentChannel.id ?? "someChannelId"])])
        }
    }

    func changeLastActivityAndSortChannels() {
        DispatchQueue.main.async {
            for index in self.channels.indices {
                if self.channels[index].id == self.currentChannel.id {
                    self.channels[index].lastActivityTimestamp = Date()
                    break
                }
            }
            self.sortChannels()
        }
    }

    func getChannels(fromUpdate: Bool = false, channelsId: [String] = []) {
        DispatchQueue.global(qos: .utility).async { [weak self] in

            if channelsId.isEmpty {

                DispatchQueue.main.async {
                    withAnimation(.easeInOut.delay(0.5)) {
                        self?.channels = []
                    }
                }

                self?.getCurrentUserChannels()

            } else {
                self?.addOrRemoveChannels(channelsId: channelsId)
            }

        }

        if !fromUpdate {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.updateChannels()
            }
        }
    }

    private func getCurrentUserChannels() {
        DispatchQueue.global(qos: .utility).async { [weak self] in
            var channelsLocal: [Channel] = []
            let group = DispatchGroup()

            for channelId in self?.currentUser.channels ?? [] {
                group.enter()
                self?.firestoreManager.getChannelDocumentReference(for: channelId)
                    .toChannel { channel in
                        channelsLocal.append(channel)
                        group.leave()
                    }
            }

            group.notify(queue: .main) {
                channelsLocal.sort { $0.lastActivityTimestamp > $1.lastActivityTimestamp }
                self?.channels = channelsLocal
            }
        }
    }

    private func addOrRemoveChannels(channelsId: [String]) {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            if channelsId.count > self?.channels.count ?? 0 {
                self?.addChannels(channelsId: channelsId)
            } else {
                self?.removeChannels(channelsId: channelsId)
            }
        }
    }

    private func addChannels(channelsId: [String]) {
        for channelId in channelsId {
            if !self.currentUser.channels.contains(channelId) {
                self.firestoreManager.getChannelDocumentReference(for: channelId)
                    .toChannel { [weak self] channel in
                        DispatchQueue.main.async {
                            withAnimation(.easeInOut.delay(0.5)) {
                                self?.channels.append(channel)
                                self?.currentUser.channels.append(channel.id ?? "some channel id")
                                self?.sortChannels()
                            }
                        }

                    }
            }
        }
    }

    private func removeChannels(channelsId: [String]) {
        for channel in channels {
            if !channelsId.contains(channel.id ?? "some id") {
                DispatchQueue.main.async {
                    withAnimation(.easeInOut.delay(0.5)) {
                        self.channels = self.channels.filter({ $0.id != channel.id})
                        self.currentUser.channels = self.currentUser.channels.filter({ $0 != channel.id})
                    }
                }
            }
        }
    }

    func sortChannels() {
        DispatchQueue.main.async {
            withAnimation(.easeInOut) {
                self.channels.sort { $0.lastActivityTimestamp > $1.lastActivityTimestamp }
            }
        }
    }

    private func updateChannels() {
        DispatchQueue.global(qos: .utility).async { [weak self] in
            self?.firestoreManager.getUserDocumentReference(for: self?.currentUser.id)
                .addSnapshotListener { document, error in

                    if error.review(message: "failed to updateChannels") { return }

                    guard let userLocal = try? document?.data(as: User.self) else {
                        return
                    }

                    if userLocal.channels.count != self?.channels.count {
                        self?.getChannels(fromUpdate: true,
                                          channelsId: userLocal.channels)
                    }

                }
        }
    }

    func delete(channel: Channel?) {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            self?.deleteFiles(channel: channel) {
                self?.removeFromSubscribersAndOwner(channel: channel)
                self?.firestoreManager.getChannelDocumentReference(for: channel?.id)
                    .delete { err in
                        if err.review(message: "failed to delete channel") { return }
                    }
            }
        }
    }

    func deleteFiles(channel: Channel?, competition: @escaping () -> Void) {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            self?.deleteImageFile(for: channel)
            self?.deleteMessagesFiles(for: channel, competition: {
                competition()

            })
        }
    }

    fileprivate func deleteImageFile(for channel: Channel?) {
        let ref = StorageReferencesManager.shared.getChannelImageReference(channelId: channel?.id ?? "someId")
        ref.delete { error in
            if error.review(message: "failed to deleteChannelImageFile") { return }
        }
    }

    fileprivate func deleteMessagesFiles(for channel: Channel?, competition: @escaping () -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            for element in channel?.storageFilesId ?? [] {
                let ref = StorageReferencesManager.shared
                    .getChannelMessageImageReference(channelId: channel?.id ?? "someId",
                                                     imageId: element)
                ref.delete { error in
                    if error.review(message: "failed to deleteChannelMessagesFiles") { return }
                }
            }
            competition()
        }
    }

    fileprivate func removeFromSubscribersAndOwner(channel: Channel?) {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            if let subscribersId  = channel?.subscribersId {
                if !subscribersId.isEmpty {
                    for id in subscribersId {
                        self?.removeChannelFromUserSubscriptions(id: id)
                    }
                }
            }
            self?.removeChannelFromUserSubscriptions(id: self?.currentChannel.ownerId ?? "some id")
        }
    }

    func removeChannelFromUserSubscriptions(id: String = "someId") {
        removeCurrentUserFromChannelSubscribers()
        self.firestoreManager.getUserDocumentReference(for: id)
            .updateData([
                "channels": FieldValue.arrayRemove(["\(currentChannel.id ?? "someId")"])
            ])
    }

    fileprivate func removeCurrentUserFromChannelSubscribers() {
        self.firestoreManager.getChannelDocumentReference(for: currentChannel.id)
            .updateData([
                "subscribersId": FieldValue.arrayRemove(["\(currentUser.id )"])
            ])
    }

    func clearPreviousDataBeforeSignIn() {
        DispatchQueue.main.async {
            self.currentUser = User()
            self.searchText = ""
            self.channels = []
            self.searchChannels = []
        }
    }

    func deleteEveryChannel() {
        for channel in channels {
            if channel.ownerId == currentUser.id {
                delete(channel: channel)
            } else {
                removeChannelFromUserSubscriptions(id: channel.id ?? "")
            }
        }
    }

}
