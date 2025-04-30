//
//  FilePath.swift
//  AudioRecordingMac
//
//  Created by Mohar on 24/04/25.
//

import Foundation



class FilePath {
    static var shared = FilePath()
    private init() {}
    
    var fileExtention = "m4a"
    
    func getBasePath() -> URL {
//        let filename = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask)[0]
            
        let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        return documentURL
    }
    
    func getUniqeFilePath() -> URL {
        return getBasePath().appendingPathComponent("Recording_\(Date().timeIntervalSince1970).\(fileExtention)")
    }
    
    func getFileName(fullUrl : URL) -> String {
        return fullUrl.lastPathComponent
    }
    
    func getFullFilePath(fileName : String) -> URL {
        if fileName.contains(fileExtention) {
            return getBasePath().appendingPathComponent(fileName)
        } else {
            return getBasePath().appendingPathComponent("\(fileName).\(fileExtention)")
        }
    }
}
