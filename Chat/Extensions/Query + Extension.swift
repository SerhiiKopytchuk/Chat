//
//  Query + Extension.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 01.07.2022.
//

import Foundation
import Firebase

extension Query {

    func queryToChat(competition: @escaping (Chat) -> Void) {
        self.getDocuments { querySnapshot, error in

            if error != nil { return }

            for document in querySnapshot!.documents {
                do {
                    competition(try document.data(as: Chat.self))
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }

    func queryToChat(competition: @escaping (Chat) -> Void, failure: @escaping (String) -> Void) {
        self.getDocuments { querySnapshot, error in

            if error != nil { return }

            if querySnapshot?.documents.count == 0 {
                failure("No chats")
                return
            }

            for document in querySnapshot!.documents {
                do {
                    competition(try document.data(as: Chat.self))
                } catch {
                    failure("error to get Chat data")
                    print(error.localizedDescription)
                }
            }
        }
    }

    func queryToChannel(competition: @escaping (Channel) -> Void, failure: @escaping (String) -> Void) {
        self.getDocuments { querySnapshot, error in

            if error != nil {
                failure(error?.localizedDescription ?? "error")
                return
            }

            if querySnapshot?.documents.count == 0 {
                failure("No channels")
                return
            }

            for document in querySnapshot!.documents {
                do {
                    competition(try document.data(as: Channel.self))
                    return
                } catch {
                    print(error.localizedDescription)
                }
            }

        }
    }

}
