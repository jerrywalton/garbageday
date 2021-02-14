//
//  SettingsVC.swift
//  garbageday
//
//  Created by Jerry Walton on 2/1/21.
//

import UIKit

class SettingsVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(handleGarbageDayChangedNotif), name: .GarbageDayChangedNotif, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleSettingsChangedNotif), name: .SettingsChangedNotif, object: nil)
    }

    @IBAction func handleDoneBtn() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc
    func handleGarbageDayChangedNotif() {
        tableView.reloadData()
    }
    
    @objc
    func handleSettingsChangedNotif() {
        tableView.reloadData()
    }
    
}

extension SettingsVC : UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title: String!
        switch section {
        case 0:
            title = "Garbage Pickup Day"
        case 1:
            title = NotificationType.DayBeforeNotification.title()
        case 2:
            title = NotificationType.DayOfNotification.title()
        default:
            break
        }
        return title
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingCell.identifier) as! SettingCell
        switch indexPath.section {
        case 0:
            cell.icon.image = AppModel.instance.getCalendarImage()
            cell.title.text = "\(AppModel.instance.selectedDayOfTheWeekSetting)"
        case 1:
            cell.icon.image = nil
            var text = "Disabled"
            if AppModel.instance.dayBeforeNotificationEnablementSettting == true {
                cell.icon.image = AppModel.instance.getAlarmImage()
                text = AppModel.instance.getNotificationTime(notificationType: NotificationType.DayBeforeNotification)
            }
            cell.title.text = text
        case 2:
            cell.icon.image = nil
            var text = "Disabled"
            if AppModel.instance.dayOfNotificationEnablementSettting == true {
                cell.icon.image = AppModel.instance.getAlarmImage()
                text = AppModel.instance.getNotificationTime(notificationType: NotificationType.DayOfNotification)
            }
            cell.title.text = text
        default:
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        switch indexPath.section {
        case 0:
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "GarbageDayVC") as! GarbageDayVC
            present(vc, animated: true, completion: nil)
        case 1, 2:
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "NotificationVC") as! NotificationVC
            vc.notificationType = indexPath.section == 1 ? .DayBeforeNotification : .DayOfNotification
            present(vc, animated: true, completion: nil)
        default:
            break
        }
    }
    
}
