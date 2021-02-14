//
//  NotificationVC.swift
//  garbageday
//
//  Created by Jerry Walton on 2/2/21.
//

import UIKit

class NotificationVC : UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    public var notificationType: NotificationType!
    public var isEnabled = false
    public var hoursSetting: Int = 0
    public var minsSetting: Int = 0
    public var ampm: AMPM = .am

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationBar.topItem!.title = notificationType.title()
        loadSettings()
    }
    
    private func loadSettings() {
        switch notificationType {
        case .DayBeforeNotification:
            isEnabled = AppModel.instance.dayBeforeNotificationEnablementSettting
            ampm = AMPM(rawValue: AppModel.instance.dayBeforeNotificationTimeAMPMSetting)!
            hoursSetting = AppModel.instance.dayBeforeNotificationHoursSetting
            minsSetting = AppModel.instance.dayBeforeNotificationMinsSetting
        case .DayOfNotification:
            isEnabled = AppModel.instance.dayOfNotificationEnablementSettting
            ampm = AMPM(rawValue: AppModel.instance.dayOfNotificationTimeAMPMSetting)!
            hoursSetting = AppModel.instance.dayOfNotificationHoursSetting
            minsSetting = AppModel.instance.dayOfNotificationMinsSetting
        case .none:
            break
        }
    }
    
    private func saveSettings() {
        AppModel.instance.saveNotificationEnablementSetting(notificationType: notificationType, enable: isEnabled)
        AppModel.instance.saveNotificationTimeAMPMSetting(notificationType: notificationType, ampm: ampm)
        AppModel.instance.saveNotificationTimeHoursSetting(notificationType: notificationType, hours: hoursSetting)
        AppModel.instance.saveNotificationTimeMinsSetting(notificationType: notificationType, mins: minsSetting)
    }
    
    @IBAction func handleDoneBtn() {
        dismiss(animated: true, completion: nil)
        saveSettings()
        if notificationType == .DayBeforeNotification {
            AppModel.instance.dateComponents.weekday = AppModel.instance.selectedDayOfTheWeekSetting.getPrevDayOfWeek()
        }
        AppModel.instance.localNotification.createLocalNotification(notificationType: notificationType, dateComponents: AppModel.instance.dateComponents)
    }
    
    @objc func handleEnableSwitch(_ sender: UISwitch!) {
        isEnabled = sender.isOn
        AppModel.instance.saveNotificationEnablementSetting(notificationType: self.notificationType, enable: self.isEnabled)
        // need to let the switch update first
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.tableView.reloadData()
        }
    }
    
}

extension NotificationVC : TimePickerCellDelegate {
    func timeUpdated(hours: Double, mins: Double, ampm: AMPM) {
        hoursSetting = Int(hours)
        minsSetting = Int(mins)
        self.ampm = ampm
        saveSettings()
        tableView.reloadData()
    }
}

extension NotificationVC : UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return isEnabled ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var nRows: Int
        switch section {
        case 0:
            nRows = 1
        default:
            nRows = 1
        }
        return nRows
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title: String!
        switch section {
        case 0:
            title = "Notification"
        case 1:
            title = "Time of Notification"
        default:
            break
        }
        return title
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell!
        switch indexPath.section {
        case 0:
            let ncell = tableView.dequeueReusableCell(withIdentifier: EnableNotificationCell.identifier) as! EnableNotificationCell
            ncell.title.text = isEnabled ? "Enabled" : "Disabled"
            ncell.enableSwitch.isOn = isEnabled
            ncell.enableSwitch.addTarget(self, action: #selector(NotificationVC.handleEnableSwitch(_:)), for: .valueChanged)
            cell = ncell
        case 1:
            let tcell = tableView.dequeueReusableCell(withIdentifier: TimePickerCell.identifier) as! TimePickerCell
            tcell.ampmSeg.selectedSegmentIndex = ampm.rawValue
            tcell.hoursStepper.value = Double(hoursSetting)
            tcell.minsStepper.value = Double(minsSetting)
            tcell.updateTimeValues()
            tcell.cellDelegate = self
            cell = tcell
        default:
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var h = CGFloat(44.0)
        switch indexPath.section {
        case 1:
            h = CGFloat(154)
        default:
            break
        }
        return h
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
}
