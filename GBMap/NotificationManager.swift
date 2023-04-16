//
//  NotificationManager.swift
//  GBMap
//
//  Created by Алексей on 16.04.2023.
//

import UIKit
import UserNotifications

class NotificationManager {
    
    static let instance = NotificationManager()
    
    func notificationCenter() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            guard granted else {
                print("Запросить доступ")
                return
            }
            
        }
                
    }
    
    func scheduleNotification() {
        
        DispatchQueue.main.async {
            let badge = UIApplication.shared.applicationIconBadgeNumber + 1
        
            let content = self.makeNotificationContent(badge: badge , identifier: "timeAlarm")
            let trigger = self.makeIntervalNotificatioTrigger(setTime: 1800)
            
            self.sendNotificatioRequest(identifier: "timeAlarm", content: content, trigger: trigger)
        }
        
    }
      
    func makeNotificationContent(badge: Int, identifier: String) -> UNNotificationContent {
        let content = UNMutableNotificationContent()
        
        content.title = "GPMap"
        content.subtitle = "Давно не заходили =("
        content.body = "Поехали на юга =)"
        content.badge = NSNumber(value: badge)
        content.categoryIdentifier = identifier
        content.sound = UNNotificationSound.default
        
        return content
    }
    
    func makeIntervalNotificatioTrigger(setTime: Int) -> UNNotificationTrigger {
        UNTimeIntervalNotificationTrigger( timeInterval: TimeInterval(setTime), repeats: false )
    }
    
    func sendNotificatioRequest(identifier: String, content: UNNotificationContent, trigger: UNNotificationTrigger) {
        // Создаём запрос на показ уведомления
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        let center = UNUserNotificationCenter.current()
        // Добавляем запрос в центр уведомлений
        center.add(request) { error in
            // Если не получилось добавить запрос, показываем ошибку, которая при этом возникла
            if let error = error { print("sendNotificatioRequest = ",error.localizedDescription)
            }
        }
    }
    
    func refreshBadgeNumber(badge: Int) {
            UIApplication.shared.applicationIconBadgeNumber = badge
    }
    
}

