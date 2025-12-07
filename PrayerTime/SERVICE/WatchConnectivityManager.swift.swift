//
//  WatchConnectivityManager.swift.swift
//  PrayerTime
//
//  Created by Linda on 06/12/2025.
//


import Foundation

struct AnimalModel: Codable, Hashable {
    var name: String
  
} //for test

import WatchConnectivity
import SwiftUI
import Combine

class WatchConnectivityManager :  NSObject, ObservableObject, WCSessionDelegate{
    
    
    
    let animals = ["🐱Cat", "🐶Puppy", "🦄Unicorn"] //hardcoded Array for example purposes


   
    
    static let shared = WatchConnectivityManager() //a singleton instance of the class

    @Published var messages: [String] = [] //to store messages
    @Published var messagesData: [AnimalModel] = [] //to decode these messages
    

    
    //Create a session
        var session: WCSession
    //Initialize the session
        init(session: WCSession = .default) {
            self.session = session
            super.init()
    //Assign its delegate to the class
            self.session.delegate = self
    //Activate the session
            session.activate()
        }



    // ✅ iOS Requires These Functions, but watchOS 9+ Doesn't Support Them
           #if os(iOS)
           func sessionDidBecomeInactive(_ session: WCSession) {
               print("WCSession became inactive")
           }

           func sessionDidDeactivate(_ session: WCSession) {
               print("WCSession deactivated")
               WCSession.default.activate() // Reactivate session after deactivation
           }
           #endif

    //Activation check func
        func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("The session has completed activation.")
            }
        }

    
    
    //Watch Side
    
    //Send message func to send the message from Watch the iOS
    
     func sendMessage(index: Int) {
        let messages: [String: Any] =
            ["animal": animals[index]]
        self.session.sendMessage(messages, replyHandler: nil) { (error) in
            print(error.localizedDescription)
        }
    }
    
    
    //Send message data func send message data and decode it from Watch to the iOS
    
     func sendMessageData(index: Int) {
        let animal = AnimalModel(name: animals[index])
        guard let data = try? JSONEncoder().encode(animal) else {
            return
        }
        self.session.sendMessageData(data, replyHandler: nil) { (error) in
            print(error.localizedDescription)
        }
    }
    
    
    
    
    //iOS Side
    
    //this func recieves message from the Watch
     func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
         DispatchQueue.main.async {
             let receivedAnimal = message["animal"] as? String ?? "UMA"
             print(receivedAnimal)
           
             self.messages.append( receivedAnimal)
         }
     }
   
    
    //after recieving the message, this func will decode the message data
      func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
          DispatchQueue.main.async {
              guard let message = try? JSONDecoder().decode(AnimalModel.self, from: messageData) else {
                  return
              }
              self.messagesData.append(message)
          }
      }

}
