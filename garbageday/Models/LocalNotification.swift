//
//  LocalNotification.swift
//  garbageday
//
//  Created by Jerry Walton on 2/13/21.
//

import Foundation
import NotificationCenter
import UIKit

class LocalNotification {
 
    var authGiven = false
    let localNotificationKey = "garbageday.reminder"
    
    public func requestAuthorization() {
        let center =  UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { [unowned self] (result, error) in
            //handle result of request failure
            self.authGiven = result
            //print("local notifications auth given: \(self.authGiven)")
            if !self.authGiven {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Authorization Required", message: "Please use Settings -> Notifications -> GarbageDay - to allow this app to create local notifications for garbage day reminders.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    AppModel.instance.window?.rootViewController?.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    public func createLocalNotification(notificationType: NotificationType, dateComponents: DateComponents) {
        //get the notification center
        let center =  UNUserNotificationCenter.current()

        //create the content for the notification
        let content = UNMutableNotificationContent()
        content.title = "Garbage Day"
        content.subtitle = "Reminder"
        content.body = "Don't forget to take the garbage down."
        content.sound = UNNotificationSound.default

        //print("creating local notification: \(dateComponents)")
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        //create request to display
        let request = UNNotificationRequest(identifier: notificationType.localNotificationKey(), content: content, trigger: trigger)

        //add request to notification center
        center.add(request) { (error) in
            if error != nil {
                print("error \(String(describing: error))")
            }
        }
        
        //print("Local Notification request: \(request)")
    }
    
    public func removeLocalNotifications(notificationType: NotificationType) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationType.localNotificationKey()])
    }
}
