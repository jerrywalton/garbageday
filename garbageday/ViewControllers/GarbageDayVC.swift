//
//  GarbageDayVC.swift
//  garbageday
//
//  Created by Jerry Walton on 2/2/21.
//

import UIKit

class GarbageDayVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func handleDoneBtn() {
        dismiss(animated: true, completion: nil)
    }
}

extension GarbageDayVC : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DayOfTheWeek.allCases.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Garbage Pickup Day"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {        
        let cell = tableView.dequeueReusableCell(withIdentifier: DayOfTheWeekCell.identifier) as! DayOfTheWeekCell
        let dotw = DayOfTheWeek.allCases[indexPath.row] as DayOfTheWeek
        cell.accessoryType = (indexPath.row + 1 == AppModel.instance.selectedDayOfTheWeekSetting.rawValue) ? UITableViewCell.AccessoryType.checkmark : UITableViewCell.AccessoryType.none
        cell.title.text = "\(dotw)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        AppModel.instance.saveSelectedDayOfTheWeekSetting(dotw: indexPath.row + 1)
        tableView.reloadData()
        NotificationCenter.default.post(Notification.init(name: .GarbageDayChangedNotif))
    }
    
}
