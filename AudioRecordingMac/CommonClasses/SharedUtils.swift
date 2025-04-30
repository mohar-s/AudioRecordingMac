//
//  SharedUtils.swift
//  AudioRecordingMac
//
//  Created by Mohar on 29/04/25.
//

import GoogleSignIn

class SharedUtils {
    static var shared: SharedUtils = .init()
    
    var selectedRecoding : Recording?
    var user : GIDGoogleUser?
    private init() {}
    
    func isAllowedRecodingPermission() -> Bool {
        return true
    }
    
    func setAllowedRecodingPermission(isAllow: Bool)  {
        // save the permission in local
    }
    
    func getAllObjects() -> [Recording] {
        
          if let objects = UserDefaults.standard.value(forKey: "user_objects") as? Data {
              print("user_objects found")
             let decoder = JSONDecoder()
             if let objectsDecoded = try? decoder.decode([Recording].self, from: objects) as [Recording] {
                 print("user_objects \(objectsDecoded)")
                return objectsDecoded
             } else {
                 print("user_objects parsing issue")
                return []
             }
          } else {
              print("user_objects not found")
             return []
          }
       }

     func saveAllObjects(allObjects: [Recording]) {
          let encoder = JSONEncoder()
          if let encoded = try? encoder.encode(allObjects){
             UserDefaults.standard.set(encoded, forKey: "user_objects")
              print("user_objects saved")
          }
     }
    
    func clearAllData()  {
        UserDefaults.standard.set(nil, forKey: "user_objects")
        UserDefaults.standard.synchronize()
    }
    
    func getLatestRecoding() -> Recording? {
        var sortList = getAllObjects()
       sortList.sort { r1, r2 in
            r1.date > r2.date
        }
        
       return sortList.first
    }
    
    func createNewRecoding(name : String)  {
        let trimName = name.trim()
        var allRecodings = getAllObjects()
        let recording = Recording(name: trimName, filePath: trimName, date: Date())
        allRecodings.append(recording)
        saveAllObjects(allObjects: allRecodings)
    }
    
    
}

struct Recording: Codable {
    var uuid: UUID? = UUID()
    var name: String
    var filePath: String
    var date: Date
}


extension String {
    func trim() -> String {
        return self.replacingOccurrences(of: " ", with: "")
   }
}
