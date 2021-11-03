//
//  DatabaseManager.swift
//  MessengerFireBase
//
//  Created by apple on 01/11/2021.
//  Copyright © 2021 apple. All rights reserved.
//

import Foundation
import FirebaseDatabase
struct ChatAppUser {
    let fName: String
    let lName: String
    let emailAddress : String
    
    var safeEmail: String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    var profilePictureFileName : String{
        //AFRAZ9-gmail-com_proile_picture.png
        return ("\(safeEmail)_profile_picture.png")
    }
}

final class DatabaseManager{
    
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
    
    static func safeEmail(emailAddress: String) -> String{
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
}
//Mark:- Account Managment
extension DatabaseManager
{
    public func userExist(with email: String,completion: @escaping ((Bool)-> Void))
    {
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        database.child(safeEmail).observeSingleEvent(of: .value, with: {snapshot in
            guard snapshot.value as? String != nil else {
                completion(false)
                return
            }
            completion(true)
        })
    }
    
    /// INSERT new user to database
    public func insertUser (with user: ChatAppUser, completion: @escaping (Bool) -> Void){
        database.child(user.safeEmail).setValue([
            "first_name":user.fName,
            "last_name":user.lName
            ],withCompletionBlock: {error , _ in
                guard error == nil else {
                    print("Failed to write to database")
                    completion(false)
                    return
                }
                /*
                    users => [
                 [
                 "name":
                 "safeEmail":
                 ],[
                 "name":
                 "safeEmail":
                 ]
            ]
                */
                self.database.child("users").observeSingleEvent(of: .value, with: {snapshot in
                    if var userCollection = snapshot.value as? [[String: String]]{
                        //append user library
                        let newElement = ["name": user.fName + " " + user.lName,
                                         "email": user.safeEmail]
                        userCollection.append(newElement)
                        
                        self.database.child("users").setValue(userCollection, withCompletionBlock: { error , _ in
                            guard error == nil else{
                                completion(false)
                                return
                            }
                            completion(true)
                        })
                    }
                    else{
                        //create that array
                        let newConnection: [[String: String]] = [
                            ["name": user.fName + " " + user.lName,
                             "email": user.safeEmail]
                        ]
                        self.database.child("users").setValue(newConnection, withCompletionBlock: { error , _ in
                            guard error == nil else{
                                completion(false)
                                return
                            }
                            completion(true)
                        })
                    }
                })
                
                completion(true)
        })
    }
    
    public func getAllUsers(completion: @escaping (Result<[[String: String]], Error>)-> Void){
        database.child("users").observeSingleEvent(of: .value, with: { snapshoot in
            guard let value = snapshoot.value as? [[String: String]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            completion(.success(value))
        })
    }
    
    public enum DatabaseError: Error {
        case failedToFetch
    }
}
