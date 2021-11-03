//
//  StorageManager.swift
//  MessengerFireBase
//
//  Created by apple on 03/11/2021.
//  Copyright © 2021 apple. All rights reserved.
//

import Foundation
import FirebaseStorage
final class StorageManager {
    
    static let shared = StorageManager()
    
    private let storage = Storage.storage().reference()

    public typealias UploadPictureComplition = (Result<String, Error>) -> Void
    
    public func UploadProfilePicture(with data: Data,fileName: String,completion:@escaping UploadPictureComplition){
        storage.child("image/\(fileName)").putData(data, metadata: nil,completion: {metadata , error in
            guard error == nil else{
                //failed
                print("failedToUploaad")
                completion(.failure(StorageErrors.failedToUploaad))
                return
            }
            self.storage.child("image/\(fileName)").downloadURL(completion: {url, error in
                guard let url = url else {
                    print("failedToGetDownloadUrl")
                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    return
                }
                let urlString = url.absoluteString
                print("Download urL Sucess \(urlString)")
                completion(.success(urlString))
            })
        })
    }
 
    public enum StorageErrors: Error {
        case failedToUploaad
        case failedToGetDownloadUrl
    }
    public func downloadURL(path: String,completion: @escaping (Result<URL, Error>)-> Void){
        let referencr = storage.child(path)
        referencr.downloadURL(completion: {url, error in
            guard let url = url, error == nil else{
                completion(.failure(StorageErrors.failedToGetDownloadUrl))
                return
            }
            completion(.success(url))
        })
    }
}
