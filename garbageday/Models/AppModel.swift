//
//  AppModel.swift
//  garbageday
//
//  Created by Jerry Walton on 2/1/21.
//

import Foundation
import UIKit

extension Notification.Name {
    static let GarbageDayChangedNotif = Notification.Name(rawValue: "GarbageDayChangedNotif")
    static let SettingsChangedNotif = Notification.Name(rawValue: "SettingsChangedNotif")
}

public enum UserDefaultsKeys : String {
    case dayOfTheWeekSettingKey
    case dayBeforeNotificationEnablementSettingKey
    case dayBeforeNotificationTimeHoursSettingKey
    case dayBeforeNotificationTimeMinsSettingKey
    case dayBeforeNotificationTimeAMPMSettingKey
    case dayOfNotificationEnablementSettingKey
    case dayOfNotificationTimeHoursSettingKey
    case dayOfNotificationTimeMinsSettingKey
    case dayOfNotificationTimeAMPMSettingKey
}

public enum DayOfTheWeek : Int, CaseIterable {
    case Sunday=1,Monday=2,Tuesday=3,Wednesday=4,Thursday=5,Friday=6,Saturday=7
    
    func getPrevDayOfWeek() -> Int {
        var val = self.rawValue
        if val == 1 {
            val = DayOfTheWeek.Saturday.rawValue
        } else {
            val = val - 1
        }
        return val
    }
    
    func toString() -> String {
        switch self {
        case .Sunday:
            return "Sunday"
        case .Monday:
            return "Monday"
        case .Tuesday:
            return "Tueday"
        case .Wednesday:
            return "Wednesday"
        case .Thursday:
            return "Thursday"
        case .Friday:
            return "Friday"
        case .Saturday:
            return "Saturday"
        }
    }
}

public enum NotificationType : String, CaseIterable {
    case DayBeforeNotification, DayOfNotification
    func title() -> String {
        switch self {
        case .DayBeforeNotification:
            return "Notification - Day before"
        case .DayOfNotification:
            return "Notification - Day of"
        }
    }
    func enablementSettingKey() -> String {
        switch self {
        case .DayBeforeNotification:
            return UserDefaultsKeys.dayBeforeNotificationEnablementSettingKey.rawValue
        case .DayOfNotification:
            return UserDefaultsKeys.dayOfNotificationEnablementSettingKey.rawValue
        }
    }
    func hoursSettingKey() -> String {
        switch self {
        case .DayBeforeNotification:
            return UserDefaultsKeys.dayBeforeNotificationTimeHoursSettingKey.rawValue
        case .DayOfNotification:
            return UserDefaultsKeys.dayOfNotificationTimeHoursSettingKey.rawValue
        }
    }
    func minsSettingKey() -> String {
        switch self {
        case .DayBeforeNotification:
            return UserDefaultsKeys.dayBeforeNotificationTimeMinsSettingKey.rawValue
        case .DayOfNotification:
            return UserDefaultsKeys.dayOfNotificationTimeMinsSettingKey.rawValue
        }
    }
    func ampmSettingKey() -> String {
        switch self {
        case .DayBeforeNotification:
            return UserDefaultsKeys.dayBeforeNotificationTimeAMPMSettingKey.rawValue
        case .DayOfNotification:
            return UserDefaultsKeys.dayOfNotificationTimeAMPMSettingKey.rawValue
        }
    }
    func localNotificationKey() -> String {
        switch self {
        case .DayBeforeNotification:
            return "garbageday.dayBeforeLocalNotification"
        case .DayOfNotification:
            return "garbageday.dayOfLocalNotification"
        }
    }
}

public enum AMPM: Int, CaseIterable {
    case am, pm
    
    func toString() -> String {
        switch self {
        case .am:
            return "AM"
        case .pm:
            return "PM"
        }
    }
}

class AppModel {
    public static let instance = AppModel()
    let nfmt = NumberFormatter()
    var dateComponents = DateComponents()
    let dateFormatter = DateFormatter()
    let localNotification = LocalNotification()
    public var firstDayOfTheWeek = 1
    public var selectedDayOfTheWeekSetting: DayOfTheWeek = .Monday
    public var dayBeforeNotificationEnablementSettting = false
    public var dayBeforeNotificationHoursSetting = 0
    public var dayBeforeNotificationMinsSetting = 0
    public var dayBeforeNotificationTimeAMPMSetting = AMPM.am.rawValue
    public var dayOfNotificationEnablementSettting = false
    public var dayOfNotificationHoursSetting = 0
    public var dayOfNotificationMinsSetting = 0
    public var dayOfNotificationTimeAMPMSetting = AMPM.am.rawValue
    public var window: UIWindow?

    private init() {
        nfmt.numberStyle = .decimal
        nfmt.maximumFractionDigits = 0
        nfmt.minimumIntegerDigits = 2
        
        // Configure the recurring date.
        let calendar = Calendar(identifier: .gregorian)
        firstDayOfTheWeek = calendar.firstWeekday
        dateComponents = calendar.dateComponents([.weekday, .hour, .minute], from: Date())
        
        dateFormatter.setLocalizedDateFormatFromTemplate("HH:mm a")
        dateFormatter.locale = Locale(identifier: "en_US")
        
        let dotw = UserDefaults.standard.integer(forKey:  UserDefaultsKeys.dayOfTheWeekSettingKey.rawValue)
        if dotw > 0 {
            selectedDayOfTheWeekSetting = DayOfTheWeek(rawValue: dotw) ?? .Monday
        }
        dayBeforeNotificationEnablementSettting = UserDefaults.standard.bool(forKey:  UserDefaultsKeys.dayBeforeNotificationEnablementSettingKey.rawValue)
        dayBeforeNotificationHoursSetting = UserDefaults.standard.integer(forKey: UserDefaultsKeys.dayBeforeNotificationTimeHoursSettingKey.rawValue)
        dayBeforeNotificationMinsSetting = UserDefaults.standard.integer(forKey: UserDefaultsKeys.dayBeforeNotificationTimeMinsSettingKey.rawValue)
        dayBeforeNotificationTimeAMPMSetting = UserDefaults.standard.integer(forKey: UserDefaultsKeys.dayBeforeNotificationTimeAMPMSettingKey.rawValue)

        dayOfNotificationEnablementSettting = UserDefaults.standard.bool(forKey:  UserDefaultsKeys.dayOfNotificationEnablementSettingKey.rawValue)
        dayOfNotificationHoursSetting = UserDefaults.standard.integer(forKey: UserDefaultsKeys.dayOfNotificationTimeHoursSettingKey.rawValue)
        dayOfNotificationMinsSetting = UserDefaults.standard.integer(forKey: UserDefaultsKeys.dayOfNotificationTimeMinsSettingKey.rawValue)
        dayOfNotificationTimeAMPMSetting = UserDefaults.standard.integer(forKey: UserDefaultsKeys.dayOfNotificationTimeAMPMSettingKey.rawValue)
    }

    public func saveSelectedDayOfTheWeekSetting(dotw: Int) {
        UserDefaults.standard.set(dotw, forKey: UserDefaultsKeys.dayOfTheWeekSettingKey.rawValue)
        selectedDayOfTheWeekSetting = DayOfTheWeek(rawValue: dotw)!
        dateComponents.weekday = selectedDayOfTheWeekSetting.rawValue
        notifyListeners()
    }
    
    public func saveNotificationEnablementSetting(notificationType: NotificationType, enable: Bool) {
        UserDefaults.standard.set(enable, forKey: notificationType.enablementSettingKey())
        switch notificationType {
        case .DayBeforeNotification:
            dayBeforeNotificationEnablementSettting = enable
            dayBeforeNotificationHoursSetting = 0
            dayBeforeNotificationMinsSetting = 0
        case .DayOfNotification:
            dayOfNotificationEnablementSettting = enable
            dayOfNotificationHoursSetting = 0
            dayBeforeNotificationMinsSetting = 0
        }
        UserDefaults.standard.set(0, forKey: notificationType.hoursSettingKey())
        UserDefaults.standard.set(0, forKey: notificationType.minsSettingKey())
        notifyListeners()
    }
    
    public func saveNotificationTimeHoursSetting(notificationType: NotificationType, hours: Int) {
        UserDefaults.standard.set(hours, forKey: notificationType.hoursSettingKey())
        switch notificationType {
        case .DayBeforeNotification:
            dayBeforeNotificationHoursSetting = hours
        case .DayOfNotification:
            dayOfNotificationHoursSetting = hours
        }
        dateComponents.hour = hours
        updateMilitaryTime(notificationType: notificationType)
        notifyListeners()
    }
    
    public func saveNotificationTimeMinsSetting(notificationType: NotificationType, mins: Int) {
        UserDefaults.standard.set(mins, forKey: notificationType.minsSettingKey())
        switch notificationType {
        case .DayBeforeNotification:
            dayBeforeNotificationMinsSetting = mins
        case .DayOfNotification:
            dayOfNotificationMinsSetting = mins
        }
        dateComponents.minute = mins
        notifyListeners()
    }
    
    public func saveNotificationTimeAMPMSetting(notificationType: NotificationType, ampm: AMPM) {
        UserDefaults.standard.set(ampm.rawValue, forKey: notificationType.ampmSettingKey())
        switch notificationType {
        case .DayBeforeNotification:
            dayBeforeNotificationTimeAMPMSetting = ampm.rawValue
        case .DayOfNotification:
            dayOfNotificationTimeAMPMSetting = ampm.rawValue
        }
        updateMilitaryTime(notificationType: notificationType)
        notifyListeners()
    }
    
    private func notifyListeners() {
        NotificationCenter.default.post(name: .SettingsChangedNotif, object: nil)
    }
    
    private func adjustHoursForAMPM(hour: Int, ampm: AMPM) -> Int {
        var hours = hour
        switch ampm {
        case .am:
            // is AM (12:00-11:59)
            if hours > 11 {
                hours = hours - 12
            }
        case .pm:
            // is PM (12:00-23:59)
            if hours < 12 {
                hours = hours + 12
            }
        }
        return hours
    }
    
    public func getNotificationTime(notificationType: NotificationType) -> String {
        switch notificationType {
        case .DayBeforeNotification:
            let ampm = AMPM(rawValue: dayBeforeNotificationTimeAMPMSetting)
            let hours = dayBeforeNotificationHoursSetting
            let mins = dayBeforeNotificationMinsSetting
            let ampmStr = ampm?.toString()
            let hoursText = AppModel.instance.nfmt.string(from: NSNumber(value: hours))
            let minsText = AppModel.instance.nfmt.string(from: NSNumber(value: mins))
            return "\(hoursText!):\(minsText!)  \(ampmStr!)"
        case .DayOfNotification:
            let ampm = AMPM(rawValue: dayOfNotificationTimeAMPMSetting)
            let hours = dayOfNotificationHoursSetting
            let mins = dayOfNotificationMinsSetting
            let ampmStr = ampm?.toString()
            let hoursText = AppModel.instance.nfmt.string(from: NSNumber(value: hours))
            let minsText = AppModel.instance.nfmt.string(from: NSNumber(value: mins))
            return "\(hoursText!):\(minsText!)  \(ampmStr!)"
        }
    }
    
    public func updateMilitaryTime(notificationType: NotificationType) {
        var ampm: AMPM!
        var hours: Int!
        switch notificationType {
        case .DayBeforeNotification:
            ampm = AMPM(rawValue: dayBeforeNotificationTimeAMPMSetting)
            hours = dayBeforeNotificationHoursSetting
        case .DayOfNotification:
            ampm = AMPM(rawValue: dayOfNotificationTimeAMPMSetting)
            hours = dayOfNotificationHoursSetting
        }
        if ampm == AMPM.am {
            // is AM (12:00-11:59)
            if hours > 11 {
                hours = hours - 12
            }
        } else {
            // is PM (12:00-11:59)
            if hours < 12 {
                hours = hours + 12
            }
        }
        AppModel.instance.dateComponents.hour = Int(hours)
        //print("dateComponents: \(AppModel.instance.dateComponents.description)")
    }
    
    public func getAlarmImage() -> UIImage {
        return UIImage(named: "alarm")!
    }
    
    public func getCalendarImage() -> UIImage {
        return UIImage(named: "calendar")!
    }
    
}
