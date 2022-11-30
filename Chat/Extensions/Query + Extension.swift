//
//  Query + Extension.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 01.07.2022.
//

import Foundation
import Firebase
import FirebaseFirestore

enum QueryError: Error {
    case noDocuments
    case other
}

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

    func queryToChat(competition: @escaping (Chat?, Error?) -> Void ) {
            self.getDocuments { querySnapshot, error in

                if error != nil { return }

                if querySnapshot?.documents.count == 0 {
                    competition(nil, QueryError.noDocuments)
                }

                for document in querySnapshot!.documents {
                    do {
                        competition(try document.data(as: Chat.self), nil)
                    } catch let error {
                        competition(nil, error)
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
