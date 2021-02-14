//
//  TimePickerCell.swift
//  garbageday
//
//  Created by Jerry Walton on 2/5/21.
//

import UIKit

protocol TimePickerCellDelegate : NSObject {
    func timeUpdated(hours: Double, mins: Double, ampm: AMPM)
}

class TimePickerCell : UITableViewCell {
    static let identifier = "TimePickerCell"
    public weak var cellDelegate: TimePickerCellDelegate!
    @IBOutlet public weak var hoursLbl: UILabel!
    @IBOutlet public weak var minsLbl: UILabel!
    @IBOutlet weak var ampmSeg: UISegmentedControl!
    @IBOutlet weak var hoursStepper: UIStepper!
    @IBOutlet weak var minsStepper: UIStepper!
    var hoursPrevVal: Double = 12.0
    var minsPrevVal : Double = 0.0

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    public func updateTimeValues(callDelegate: Bool = false) {
        if minsPrevVal == 59.0 && minsStepper.value == 0.0 {
            hoursStepper.value = hoursPrevVal == 12 ? 0 : hoursPrevVal + 1.0
        } else if minsPrevVal == 0.0 && minsStepper.value == 59.0 {
            hoursStepper.value = hoursPrevVal == 1 ? 12 : hoursPrevVal - 1.0
        }
        hoursPrevVal = hoursStepper.value
        minsPrevVal = minsStepper.value
        hoursLbl.text = AppModel.instance.nfmt.string(from: NSNumber(value: hoursPrevVal))
        minsLbl.text = AppModel.instance.nfmt.string(from: NSNumber(value: minsPrevVal))
        if cellDelegate != nil && callDelegate {
                cellDelegate.timeUpdated(hours: hoursPrevVal, mins: minsPrevVal, ampm: ampmSeg.selectedSegmentIndex == 0 ? .am : .pm)
        }
    }
    
    @IBAction func handleAMPMSegChange() {
        updateTimeValues(callDelegate: true)
    }
    
    @IBAction func handleHoursStepperChange() {
        updateTimeValues(callDelegate: true)
    }
    
    @IBAction func handleMinsStepperChange() {
        updateTimeValues(callDelegate: true)
    }
    
}
