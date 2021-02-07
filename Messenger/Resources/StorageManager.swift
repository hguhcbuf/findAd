//
//  StorageManager.swift
//  Messenger
//
//  Created by 김종현 on 2021/01/22.
//  Copyright © 2021 kjh. All rights reserved.
//

import Foundation
import FirebaseStorage

/// Allows you to get, fetch, and upload files to firebase storage
final class StorageManager {
    
    static let shared = StorageManager()
    
    private let storage = Storage.storage().reference()
    
    public typealias UploadPictureCompletion = (Result<String, Error>) -> Void
    
    ///uploads picture to firebase storage and returns completion with url string to download
    public func uploadProfilePicture(with data: Data, filename: String, completion: @escaping UploadPictureCompletion) {
        
        storage.child("images/\(filename)").putData(data, metadata: nil) { [weak self] (metadata, error) in
            
            guard let strongSelf = self else {
                return
            }
            
            guard error == nil else {
                print("failed to upload data to firebase for picture")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            strongSelf.storage.child("images/\(filename)").downloadURL { (url, error) in
                guard let url = url else {
                    print("failed to download url from firebase")
                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    return
                }
                
                let urlString = url.absoluteString
                print("download url returned: \(urlString)")
                completion(.success(urlString))
            }
        }
        
    }
    
    
    public enum StorageErrors: Error {
        case failedToUpload
        case failedToGetDownloadUrl
    }
    
    public func downloadURL(for path: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let reference = storage.child(path)
        
        reference.downloadURL { (url, error) in
            guard let url = url, error == nil else {
                completion(.failure(StorageErrors.failedToGetDownloadUrl))
                return
            }
            
            completion(.success(url))
        }
    }
    
    ///Upload image that will be sent in a conversation message
    public func uploadMesssagePhoto(with data: Data, filename: String, completion: @escaping UploadPictureCompletion) {
        
        storage.child("message_images/\(filename)").putData(data, metadata: nil) { [weak self] (metadata, error) in
            guard error == nil else {
                print("failed to upload data to firebase for picture")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            self?.storage.child("message_images/\(filename)").downloadURL { (url, error) in
                guard let url = url else {
                    print("failed to download url from firebase")
                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    return
                }
                
                let urlString = url.absoluteString
                print("download url returned: \(urlString)")
                completion(.success(urlString))
            }
        }
        
    }
    
    ///Upload video that will be sent in a conversation message
    public func uploadMesssageVideo(with fileUrl: URL, filename: String, completion: @escaping UploadPictureCompletion) {
        
        storage.child("message_videos/\(filename)").putFile(from: fileUrl, metadata: nil) { [weak self] (metadata, error) in
            guard error == nil else {
                print("failed to upload video to firebase for picture")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            self?.storage.child("message_images/\(filename)").downloadURL { (url, error) in
                guard let url = url else {
                    print("failed to download url from firebase")
                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    return
                }
                
                let urlString = url.absoluteString
                print("download url returned: \(urlString)")
                completion(.success(urlString))
            }
        }
        
    }
    
}
