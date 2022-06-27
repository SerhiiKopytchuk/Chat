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

class ChannelViewModel: ObservableObject {

    // MARK: - vars

    @Published var currentUser: User = User(chats: [], channels: [], gmail: "", id: "", name: "")
    @Published var owner: User = User(chats: [], channels: [], gmail: "", id: "", name: "")
    @Published var subscribers: [String] = []

    @Published var channels: [Channel] = []
    @Published var currentChannel: Channel = Channel(id: "",
                                                     name: "",
                                                     description: "",
                                                     ownerId: "",
                                                     subscribersId: [],
                                                     messages: [])

    let dataBase = Firestore.firestore()

    // MARK: - functions

    func getCurrentChannel( channelId: String, competition: @escaping (Channel) -> Void) {

        dataBase.collection("channels").document(channelId).getDocument { document, error in
            if error != nil {
                print("error to get current channel: " + (error?.localizedDescription ?? ""))
                return
            }
            if let channel = try? document?.data(as: Channel.self) {
                competition(channel)
            }
        }
    }

    func createChannel(subscribersId: [String],
                       name: String,
                       description: String,
                       competition: @escaping (Channel) -> Void) {
        do {

            let newChannel = Channel(id: "\(UUID())",
                                     name: name,
                                     description: description,
                                     ownerId: currentUser.id,
                                     subscribersId: subscribersId,
                                     messages: [])

            try dataBase.collection("channels").document().setData(from: newChannel)

            getCurrentChannel(channelId: newChannel.id ?? "SomeId") { channel in
                self.currentChannel = channel
                self.addChannelsIdToUsers()
                competition(channel)
            }
        } catch {
            print("error creating chat to Firestore:: \(error)")
        }
    }

    fileprivate func addChannelsIdToUsers() {
        DispatchQueue.main.async {
            for userId in self.currentChannel.subscribersId {
                self.dataBase.collection("users").document(userId)
                    .updateData(["channels": FieldValue.arrayUnion([self.currentChannel.id ?? "someChatId"])])
            }
        }
    }

    private func updateChannels() {
        DispatchQueue.main.async {
            self.dataBase.collection("users").document(self.currentUser.id)
                .addSnapshotListener { document, error in
                    if error != nil {
                        return
                    } else {
                        guard let userLocal = try? document?.data(as: User.self) else {
                            return
                        }
                        if userLocal.channels.count != self.currentUser.channels.count {
                            self.getChannels(fromUpdate: true, channelPart: userLocal.channels)
                        }
                    }
                }
        }
    }

    func getChannels(fromUpdate: Bool = false, channelPart: [String] = []) {
        self.channels = []
        if channelPart.isEmpty {
            for channelId in currentUser.channels {
                let docRef = dataBase.collection("channels").document(channelId)
                docRef.getDocument(as: Channel.self) { result in
                    switch result {
                    case .success(let channel):
                        self.channels.append(channel)
                    case .failure(let error):
                        print("Error decoding channel: \(error)")
                    }
                }
            }
        } else {
            for channelId in channelPart {
                let docRef = dataBase.collection("channels").document(channelId)
                docRef.getDocument(as: Channel.self) { result in
                    switch result {
                    case .success(let channel):
                        self.channels.append(channel)
                    case .failure(let error):
                        print("Error decoding channel: \(error)")
                    }
                }
            }
        }

        if !fromUpdate {
            self.updateChannels()
        }
    }

}
