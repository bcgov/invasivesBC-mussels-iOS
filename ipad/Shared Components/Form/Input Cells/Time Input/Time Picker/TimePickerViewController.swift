//
//  TimePickerViewController.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-11-25.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import UIKit

public struct Time {
    var hour: Int
    var minute: Int
    var seconds: Int
    
    init(hour: Int, minute: Int, seconds: Int) {
        self.hour = hour
        self.minute = minute
        self.seconds = seconds
    }
    
    init(string: String) {
        let timeArray = string.components(separatedBy: ":")
        self.hour = Int(timeArray[0]) ?? 0
        self.minute = Int(timeArray[1]) ?? 0
        self.seconds = 0
    }
    
    func toString() -> String {
        var displayMinute: String = ""
        if minute < 10 {
            displayMinute = "0\(minute)"
        } else {
            displayMinute = "\(minute)"
        }
        return "\(hour):\(displayMinute)"
    }
}

public class TimePickerViewController: UIViewController {
    
    private var onChange: ((_ time: Time)-> Void)?
    private var initialTime: Time?
    
    @IBOutlet weak var pickerView: UIDatePicker!
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setInitialTime()
    }
    
    public func setup(initial: Time?, onChange: @escaping(_ time: Time?) -> Void) {
        self.initialTime = initial
        self.onChange = onChange
    }
    
    private func setInitialTime() {
        guard let picker = pickerView else {return}
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat =  "HH:mm"
        var startDateTime: Date? = nil
        if let initialTime = self.initialTime {
            startDateTime = timeFormatter.date(from: "\(initialTime.hour):\(initialTime.minute)")
        } else {
            startDateTime = picker.date
        }
        
        if let formattedDateTime = startDateTime, let onChange = self.onChange {
            picker.date = formattedDateTime
            onChange(getTime(from: formattedDateTime))
        }
    }
    
    private func getTime(from date: Date) -> Time {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        let seconds = calendar.component(.second, from: date)
        return Time(hour: hour, minute: minutes, seconds: seconds)
    }
    
    @IBAction func onTimeChange(_ sender: UIDatePicker) {
        guard let callback = onChange else {return}
        return callback(getTime(from: sender.date))
    }
    
}
