//
//  CalendarVC.swift
//  BBNDaily
//
//  Created by Mike Veson on 9/12/21.
//

import UIKit
import GoogleSignIn
import Firebase
import ProgressHUD
import InitialsImageView
import SafariServices
import FSCalendar
import WebKit

class CalendarVC: UIViewController, FSCalendarDelegate, FSCalendarDataSource, UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentDay.count
    }
    func setTimes() {
        var i = 0
        for x in currentWeekday {
            i+=1
            let time = x.reminderTime.prefix(5)
            let time1 = x.startTime.prefix(5)
            let time2 = x.endTime.prefix(5)
            let m = time.replacingOccurrences(of: time.prefix(3), with: "")
            let m1 = time1.replacingOccurrences(of:  time1.prefix(3), with: "")
            let m2 = time2.replacingOccurrences(of: time2.prefix(3), with: "")
            var amOrPm = 0
            var amOrPm1 = 0
            var amOrPm2 = 0
            if x.reminderTime.contains("pm") && !time.prefix(2).contains("12"){
                amOrPm = 12
            }
            if x.startTime.contains("pm") && !time1.prefix(2).contains("12"){
                amOrPm1 = 12
            }
            if x.endTime.contains("pm") && !time2.prefix(2).contains("12") {
                amOrPm2 = 12
            }
            let calendar = Calendar.current
            let now = Date()
            let t = calendar.date(
                bySettingHour: (Int(time.prefix(2))!+amOrPm),
                minute: Int(m)!,
                second: 0,
                of: now)!
            let t1 = calendar.date(
                bySettingHour: (Int(time1.prefix(2))!+amOrPm1),
                minute: Int(m1)!,
                second: 0,
                of: now)!
            let t2 = calendar.date(
                bySettingHour: (Int(time2.prefix(2))!+amOrPm2),
                minute: Int(m2)!,
                second: 0,
                of: now)!
            if now.isBetweenTimeFrame(date1: t, date2: t2) {
                currentBlock = x
                //                    cell.backgroundColor = UIColor(named: "inverse")?.withAlphaComponent(0.1)
                //                    cell.contentView.backgroundColor = UIColor(named: "inverse")?.withAlphaComponent(0.1)
                var name = ""
                if currentBlock.block != "N/A" {
                    var className = LoginVC.blocks[currentBlock.block] as? String
                    if className == "" {
                        className = "[\(currentBlock.block) Class]"
                    }
                    name = className ?? ""
                }
                else {
                    name = "\(currentBlock.name)"
                }
                let formatter = DateComponentsFormatter()
                
                formatter.maximumUnitCount = 1
                formatter.unitsStyle = .abbreviated
                formatter.zeroFormattingBehavior = .dropAll
                formatter.allowedUnits = [.day, .hour, .minute, .second]
                if now.isBetweenTimeFrame(date1: t, date2: t1) {
                    let interval = Date().getTimeBetween(to: t1)
                    self.navigationItem.title = "\(formatter.string(from: interval)!) Until \(name)"
                    Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [self] timer in
                        print("interval")
                        if interval <= 0 {
                            timer.invalidate()
                        }
                        setTimes()
                        ScheduleCalendar.reloadData()
                    }
                }
                else {
                    let interval = Date().getTimeBetween(to: t2)
                    //                    interval.
                    self.navigationItem.title = "\(formatter.string(from: interval)!) left in \(name)"
                    Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [self] timer in
                        print("interval")
                        if interval <= 0 {
                            timer.invalidate()
                        }
                        setTimes()
                        ScheduleCalendar.reloadData()
                    }
                }
            }
            else {
                if currentBlock.reminderTime == x.reminderTime && i == currentWeekday.count {
                    currentBlock = block(name: "b4r0n", startTime: "b4r0n", endTime: "b4r0n", block: "b4r0n", reminderTime: "3", length: 0)
                    self.navigationItem.title = "My Schedule"
                }
            }
        }
    }
    var currentWeekday = [block]()
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: blockTableViewCell.identifier, for: indexPath) as? blockTableViewCell else {
            fatalError()
        }
        let thisBlock = currentDay[indexPath.row]
        var isLunch = true
        if !thisBlock.name.lowercased().contains("lunch") {
            isLunch = false
        }
        cell.configure(with: currentDay[indexPath.row], isLunch: isLunch)
        
        cell.selectionStyle = .none
        let formatter1 = DateFormatter()
        formatter1.dateFormat = "yyyy-MM-dd"
        formatter1.dateStyle = .short
        let stringDate = formatter1.string(from: Date())
        if currentDate == stringDate {
            let time = currentDay[indexPath.row].reminderTime.prefix(5)
            let time1 = currentDay[indexPath.row].startTime.prefix(5)
            let time2 = currentDay[indexPath.row].endTime.prefix(5)
            let m = time.replacingOccurrences(of: time.prefix(3), with: "")
            let m1 = time1.replacingOccurrences(of:  time1.prefix(3), with: "")
            let m2 = time2.replacingOccurrences(of: time2.prefix(3), with: "")
            var amOrPm = 0
            var amOrPm1 = 0
            var amOrPm2 = 0
            if currentDay[indexPath.row].reminderTime.contains("pm") && !time.prefix(2).contains("12"){
                amOrPm = 12
            }
            if currentDay[indexPath.row].startTime.contains("pm") && !time1.prefix(2).contains("12"){
                amOrPm1 = 12
            }
            if currentDay[indexPath.row].endTime.contains("pm") && !time2.prefix(2).contains("12") {
                amOrPm2 = 12
            }
            let calendar = Calendar.current
            let now = Date()
            let t = calendar.date(
                bySettingHour: (Int(time.prefix(2))!+amOrPm),
                minute: Int(m)!,
                second: 0,
                of: now)!
            let t1 = calendar.date(
                bySettingHour: (Int(time1.prefix(2))!+amOrPm1),
                minute: Int(m1)!,
                second: 0,
                of: now)!
            let t2 = calendar.date(
                bySettingHour: (Int(time2.prefix(2))!+amOrPm2),
                minute: Int(m2)!,
                second: 0,
                of: now)!
            if now.isBetweenTimeFrame(date1: t, date2: t2) {
                currentBlock = currentDay[indexPath.row]
                cell.backgroundColor = UIColor(named: "inverse")?.withAlphaComponent(0.1)
                cell.contentView.backgroundColor = UIColor(named: "inverse")?.withAlphaComponent(0.1)
            }
            else {
                cell.backgroundColor = UIColor(named: "background")
                cell.contentView.backgroundColor = UIColor(named: "background")
            }
        }
        else {
            cell.backgroundColor = UIColor(named: "background")
            cell.contentView.backgroundColor = UIColor(named: "background")
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let block = currentDay[indexPath.row]
        if block.name.lowercased().contains("lunch") {
            (tableView.cellForRow(at: indexPath) as! blockTableViewCell).animateView()
            self.performSegue(withIdentifier: "Lunch", sender: nil)
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setCurrentday(date: realCurrentDate)
        ScheduleCalendar.reloadData()
        setTimes()
    }
    var currentBlock = block(name: "b4r0n", startTime: "b4r0n", endTime: "b4r0n", block: "b4r0n", reminderTime: "3", length: 0)
    static var isLunch1 = false
    var calendarIsExpanded = true
    @IBAction func switchCalendar(_ sender: UIBarButtonItem) {
        if calendarIsExpanded {
            CalendarHeightConstraint.constant = 90
            UIView.animate(withDuration: 0.5) {
                self.CalendarArrow.image = UIImage(systemName: "chevron.down")
                self.view.layoutIfNeeded()
                
            }
            self.calendar.scope = .week
            calendarIsExpanded = false
        }
        else {
            self.calendar.scope = .month
            CalendarHeightConstraint.constant = height
            UIView.animate(withDuration: 0.5) {
                self.CalendarArrow.image = UIImage(systemName: "chevron.up")
                self.view.layoutIfNeeded()
            }
            calendarIsExpanded = true
        }
    }
    @IBOutlet weak var CalendarArrow: UIBarButtonItem!
    var currentDate = ""
    @IBOutlet weak var ScheduleCalendar: UITableView!
    @IBOutlet weak var calendar: FSCalendar!
    static let monday =  [
        block(name: "B", startTime: "08:15am", endTime: "09:00am", block: "B", reminderTime: "08:10am", length: 45),
        block(name: "D", startTime: "09:05am", endTime: "09:50am", block: "D", reminderTime: "09:00am", length: 45),
        block(name: "Assembly", startTime: "09:55am", endTime: "10:35am", block: "N/A", reminderTime: "09:50am", length: 40),
        block(name: "C", startTime: "10:40am", endTime: "11:25am", block: "C", reminderTime: "10:35am", length: 45),
        block(name: "F1", startTime: "11:30am", endTime: "12:15pm", block: "F", reminderTime: "11:25am", length: 45),
        block(name: "Lunch", startTime: "12:20pm", endTime: "12:45pm", block: "N/A", reminderTime: "12:15pm", length: 25),
        block(name: "Extended A", startTime: "12:50pm", endTime: "01:55pm", block: "A", reminderTime: "12:45pm", length: 65),
        block(name: "Community Activity", startTime: "02:00pm", endTime: "02:35pm", block: "N/A", reminderTime: "01:55pm", length: 35),
        block(name: "E", startTime: "02:40pm", endTime: "03:25pm", block: "E", reminderTime: "02:35pm", length: 45)
    ]
    static let mondayL1 =  [
        block(name: "B", startTime: "08:15am", endTime: "09:00am", block: "B", reminderTime: "08:10am", length: 45),
        block(name: "D", startTime: "09:05am", endTime: "09:50am", block: "D", reminderTime: "09:00am", length: 45),
        block(name: "Assembly", startTime: "09:55am", endTime: "10:35am", block: "N/A", reminderTime: "09:50am", length: 40),
        block(name: "C", startTime: "10:40am", endTime: "11:25am", block: "C", reminderTime: "10:35am", length: 45),
        block(name: "Lunch", startTime: "11:30am", endTime: "11:55am", block: "N/A", reminderTime: "11:25am", length: 25),
        block(name: "F2", startTime: "12:00pm", endTime: "12:45pm", block: "F", reminderTime: "11:55am", length: 45),
        block(name: "Extended A", startTime: "12:50pm", endTime: "01:55pm", block: "A", reminderTime: "12:45pm", length: 65),
        block(name: "Community Activity", startTime: "02:00pm", endTime: "02:35pm", block: "N/A", reminderTime: "01:55pm", length: 35),
        block(name: "E", startTime: "02:40pm", endTime: "03:25pm", block: "E", reminderTime: "02:35pm", length: 45)
    ]
    static let tuesday =  [
        block(name: "A", startTime: "08:15am", endTime: "09:00am", block: "A", reminderTime: "08:10am", length: 45),
        block(name: "F", startTime: "09:05am", endTime: "09:50am", block: "F", reminderTime: "09:00am", length: 45),
        block(name: "Wellness Break", startTime: "09:55am", endTime: "10:15am", block: "N/A", reminderTime: "09:50am", length: 40),
        block(name: "Extended G", startTime: "10:20am", endTime: "11:25am", block: "G", reminderTime: "10:15am", length: 65),
        block(name: "E1", startTime: "11:30am", endTime: "12:15pm", block: "E", reminderTime: "11:25am", length: 45),
        block(name: "Lunch", startTime: "12:20pm", endTime: "12:45pm", block: "N/A", reminderTime: "12:15pm", length: 25),
        block(name: "Extended B", startTime: "12:50pm", endTime: "1:55pm", block: "B", reminderTime: "12:45pm", length: 65),
        block(name: "Advisory", startTime: "02:00pm", endTime: "02:35pm", block: "N/A", reminderTime: "01:55pm", length: 35),
        block(name: "D", startTime: "02:40pm", endTime: "03:25pm", block: "D", reminderTime: "02:35pm", length: 45)
    ]
    static let tuesdayL1 =  [
        block(name: "A", startTime: "08:15am", endTime: "09:00am", block: "A", reminderTime: "08:10am", length: 45),
        block(name: "F", startTime: "09:05am", endTime: "09:50am", block: "F", reminderTime: "09:00am", length: 45),
        block(name: "Wellness Break", startTime: "09:55am", endTime: "10:15am", block: "N/A", reminderTime: "09:50am", length: 40),
        block(name: "Extended G", startTime: "10:20am", endTime: "11:25am", block: "G", reminderTime: "10:15am", length: 65),
        block(name: "Lunch", startTime: "11:30am", endTime: "11:55am", block: "N/A", reminderTime: "11:25am", length: 25),
        block(name: "E2", startTime: "12:00pm", endTime: "12:45pm", block: "E", reminderTime: "11:55am", length: 45),
        block(name: "Extended B", startTime: "12:50pm", endTime: "1:55pm", block: "B", reminderTime: "12:45pm", length: 65),
        block(name: "Advisory", startTime: "02:00pm", endTime: "02:35pm", block: "N/A", reminderTime: "01:55pm", length: 35),
        block(name: "D", startTime: "02:40pm", endTime: "03:25pm", block: "D", reminderTime: "02:35pm", length: 45)
    ]
    static let wednesday =  [
        block(name: "G", startTime: "08:15am", endTime: "09:00am", block: "G", reminderTime: "08:10am", length: 45),
        block(name: "C", startTime: "09:05am", endTime: "09:50am", block: "C", reminderTime: "09:00am", length: 45),
        block(name: "Class Meeting", startTime: "09:55am", endTime: "10:15am", block: "N/A", reminderTime: "09:50am", length: 20),
        block(name: "Extended F", startTime: "10:20am", endTime: "11:25am", block: "F", reminderTime: "10:15am", length: 65),
        block(name: "A1", startTime: "11:30am", endTime: "12:15pm", block: "A", reminderTime: "11:25am", length: 45),
        block(name: "Lunch", startTime: "12:20pm", endTime: "12:45pm", block: "N/A", reminderTime: "12:15pm", length: 25),
        block(name: "Community Activity", startTime: "12:45pm", endTime: "1:25pm", block: "N/A", reminderTime: "12:40pm", length: 40)
    ]
    static let wednesdayL1 =  [
        block(name: "G", startTime: "08:15am", endTime: "09:00am", block: "G", reminderTime: "08:10am", length: 45),
        block(name: "C", startTime: "09:05am", endTime: "09:50am", block: "C", reminderTime: "09:00am", length: 45),
        block(name: "Class Meeting", startTime: "09:55am", endTime: "10:15am", block: "N/A", reminderTime: "09:50am", length: 20),
        block(name: "Extended F", startTime: "10:20am", endTime: "11:25am", block: "F", reminderTime: "10:15am", length: 65),
        block(name: "Lunch", startTime: "11:30am", endTime: "11:55am", block: "N/A", reminderTime: "11:25am", length: 45),
        block(name: "A2", startTime: "12:00pm", endTime: "12:45pm", block: "A", reminderTime: "11:55am", length: 25),
        block(name: "Community Activity", startTime: "12:45pm", endTime: "1:25pm", block: "N/A", reminderTime: "12:40pm", length: 40)
    ]
    static let thursday =  [
        block(name: "C", startTime: "08:15am", endTime: "09:00am", block: "C", reminderTime: "08:10am", length: 45),
        block(name: "B", startTime: "09:05am", endTime: "09:50am", block: "B", reminderTime: "09:00am", length: 45),
        block(name: "Advisory", startTime: "09:55am", endTime: "10:15am", block: "N/A", reminderTime: "09:50am", length: 20),
        block(name: "Extended D", startTime: "10:20am", endTime: "11:25am", block: "D", reminderTime: "10:15am", length: 45),
        block(name: "G1", startTime: "11:30am", endTime: "12:15pm", block: "G", reminderTime: "11:25am", length: 45),
        block(name: "Lunch", startTime: "12:20pm", endTime: "12:45pm", block: "N/A", reminderTime: "12:15pm", length: 25),
        block(name: "Extended E", startTime: "12:50pm", endTime: "1:55pm", block: "E", reminderTime: "12:45pm", length: 65),
        block(name: "Office Hours", startTime: "02:00pm", endTime: "02:35pm", block: "N/A", reminderTime: "01:55pm", length: 35),
        block(name: "F", startTime: "02:40pm", endTime: "03:25pm", block: "F", reminderTime: "02:35pm", length: 45)
    ]
    static let thursdayL1 =  [
        block(name: "C", startTime: "08:15am", endTime: "09:00am", block: "C", reminderTime: "08:10am", length: 45),
        block(name: "B", startTime: "09:05am", endTime: "09:50am", block: "B", reminderTime: "09:00am", length: 45),
        block(name: "Advisory", startTime: "09:55am", endTime: "10:15am", block: "N/A", reminderTime: "09:50am", length: 20),
        block(name: "Extended D", startTime: "10:20am", endTime: "11:25am", block: "D", reminderTime: "10:15am", length: 45),
        block(name: "Lunch", startTime: "11:30am", endTime: "11:55am", block: "N/A", reminderTime: "11:25am", length: 25),
        block(name: "G2", startTime: "12:00pm", endTime: "12:45pm", block: "G", reminderTime: "11:55am", length: 45),
        block(name: "Extended E", startTime: "12:50pm", endTime: "1:55pm", block: "E", reminderTime: "12:45pm", length: 65),
        block(name: "Office Hours", startTime: "02:00pm", endTime: "02:35pm", block: "N/A", reminderTime: "01:55pm", length: 35),
        block(name: "F", startTime: "02:40pm", endTime: "03:25pm", block: "F", reminderTime: "02:35pm", length: 45)
    ]
    static let friday = [
        block(name: "E", startTime: "08:15am", endTime: "09:00am", block: "E", reminderTime: "08:10am", length: 45),
        block(name: "G", startTime: "09:05am", endTime: "09:50am", block: "G", reminderTime: "09:00am", length: 45),
        block(name: "Assembly", startTime: "09:55am", endTime: "10:35am", block: "N/A", reminderTime: "09:50am", length: 40),
        block(name: "B", startTime: "10:40am", endTime: "11:25am", block: "B", reminderTime: "10:15am", length: 45),
        block(name: "D1", startTime: "11:30am", endTime: "12:15pm", block: "D", reminderTime: "11:25am", length: 45),
        block(name: "Lunch", startTime: "12:20pm", endTime: "12:45pm", block: "N/A", reminderTime: "12:15pm", length: 25),
        block(name: "Extended C", startTime: "12:50pm", endTime: "1:55pm", block: "C", reminderTime: "12:45pm", length: 65),
        block(name: "A", startTime: "02:00pm", endTime: "02:45pm", block: "A", reminderTime: "01:55pm", length: 45),
        block(name: "Community Activity", startTime: "02:50pm", endTime: "03:25pm", block: "N/A", reminderTime: "02:35pm", length: 35)
    ]
    static let fridayL1 = [
        block(name: "E", startTime: "08:15am", endTime: "09:00am", block: "E", reminderTime: "08:10am", length: 45),
        block(name: "G", startTime: "09:05am", endTime: "09:50am", block: "G", reminderTime: "09:00am", length: 45),
        block(name: "Assembly", startTime: "09:55am", endTime: "10:35am", block: "N/A", reminderTime: "09:50am", length: 40),
        block(name: "B", startTime: "10:40am", endTime: "11:25am", block: "B", reminderTime: "10:15am", length: 45),
        block(name: "Lunch", startTime: "11:30am", endTime: "11:55am", block: "N/A", reminderTime: "11:25am", length: 25),
        block(name: "D2", startTime: "12:00pm", endTime: "12:45pm", block: "D", reminderTime: "11:55am", length: 45),
        block(name: "Extended C", startTime: "12:50pm", endTime: "1:55pm", block: "C", reminderTime: "12:45pm", length: 65),
        block(name: "A", startTime: "02:00pm", endTime: "02:45pm", block: "A", reminderTime: "01:55pm", length: 45),
        block(name: "Community Activity", startTime: "02:50pm", endTime: "03:25pm", block: "N/A", reminderTime: "02:35pm", length: 35)
    ]
    @IBOutlet weak var CalendarHeightConstraint: NSLayoutConstraint!
    var currentDay = [block]()
    var height = CGFloat(0)
    override func viewDidLoad() {
        super.viewDidLoad()
        ScheduleCalendar.register(blockTableViewCell.self, forCellReuseIdentifier: blockTableViewCell.identifier)
        ScheduleCalendar.backgroundColor = UIColor(named: "background")
        height = view.frame.height/4
        CalendarHeightConstraint.constant = height
        view.layoutIfNeeded()
        ScheduleCalendar.showsVerticalScrollIndicator = false
        ScheduleCalendar.tableFooterView = UIView(frame: .zero)
        currentWeekday = setCurrentday(date: Date())
        calendar.delegate = self
        calendar.dataSource = self
        ScheduleCalendar.delegate = self
        ScheduleCalendar.dataSource = self
        //        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: { results in
            for x in results {
                print("title: \(x.content.title) ")
            }
        })
        setTimes()
        //        setNotif()
    }
    func setNotif() {
        let hours = 13
        var dateComponents = DateComponents()
        dateComponents.hour = hours
        dateComponents.minute = 13
        dateComponents.second = 35
        dateComponents.timeZone = .current
        dateComponents.weekday = 6
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        // 2
        let content = UNMutableNotificationContent()
        content.title = "5 Minutes Until B Block"
        content.sound = UNNotificationSound.default
        
        let randomIdentifier = UUID().uuidString
        let request = UNNotificationRequest(identifier: randomIdentifier, content: content, trigger: trigger)
        
        // 3
        UNUserNotificationCenter.current().add(request) { error in
            if error != nil {
                print("something went wrong")
            }
        }
    }
    let vacationDates = [
        NoSchoolDay(date: "Monday, September 6, 2021", reason: "Labor Day"),
        NoSchoolDay(date: "Tuesday, September 7, 2021", reason: "Rosh Hashanah"),
        NoSchoolDay(date: "Thursday, September 16, 2021", reason: "Yom Kippur"),
        NoSchoolDay(date: "Monday, October 11, 2021", reason: "Indigenous Peoples Day"),
        NoSchoolDay(date: "Tuesday, October 12, 2021", reason: "Professional Day"),
        NoSchoolDay(date: "Thursday, November 11, 2021", reason: "Veterans Day"),
        NoSchoolDay(date: "Thursday, November 25, 2021", reason: "Thankgiving Break"),
        NoSchoolDay(date: "Friday, November 26, 2021", reason: "Thankgiving Break"),
        NoSchoolDay(date: "Tuesday, January 4, 2022", reason: "Thankgiving Break"),
        NoSchoolDay(date: "Monday, January 17, 2022", reason: "MLK Jr. Day"),
        NoSchoolDay(date: "Monday, February 21, 2022", reason: "Presidents Day"),
        NoSchoolDay(date: "Tuesday, February 22, 2022", reason: "Professional Day"),
        NoSchoolDay(date: "Monday, April 18, 2022", reason: "Patriots Day"),
        NoSchoolDay(date: "Monday, May 30, 2022", reason: "Memorial Day")
    ]
    var realCurrentDate = Date()
    let halfDays = [NoSchoolDay(date: "Wednesday, November 24, 2021", reason: "Thanksgiving Break Start")]
    func setCurrentday(date: Date) -> [block] {
        realCurrentDate = date
        let formatter2 = DateFormatter()
        formatter2.dateFormat = "yyyy-MM-dd"
        formatter2.dateStyle = .short
        let stringDate1 = formatter2.string(from: date)
        currentDate = stringDate1
        let formatter1 = DateFormatter()
        formatter1.dateFormat = "yyyy-MM-dd"
        formatter1.dateStyle = .full
        let stringDate = formatter1.string(from: date)
        let weekDay = stringDate.prefix(upTo: formatter1.string(from: date).firstIndex(of: ",")!)
        let bigArray = LoginVC.getLunchDays()
        let monday = bigArray[0]
        let tuesday = bigArray[1]
        let wednesday = bigArray[2]
        let thursday = bigArray[3]
        let friday = bigArray[4]
        switch weekDay {
        case "Monday":
            currentDay = monday
        case "Tuesday":
            currentDay = tuesday
        case "Wednesday":
            currentDay = wednesday
        case "Thursday":
            currentDay = thursday
        case "Friday":
            currentDay = friday
        default:
            currentDay = [block]()
        }
        if currentDay.isEmpty {
            ScheduleCalendar.setEmptyMessage("No Class - Enjoy your Weekend")
        }
        else {
            ScheduleCalendar.restore()
        }
        
        for x in vacationDates {
            if stringDate.lowercased() == x.date.lowercased() {
                currentDay = [block]()
                ScheduleCalendar.restore()
                ScheduleCalendar.setEmptyMessage("No Class - \(x.reason)")
                return currentDay
            }
        }
        if date.isBetweenTimeFrame(date1: "18 Dec 2021 04:00".dateFromMultipleFormats() ?? Date(), date2: "02 Jan 2022 04:00".dateFromMultipleFormats() ?? Date()) || date.isBetweenTimeFrame(date1: "12 Mar 2022 04:00".dateFromMultipleFormats() ?? Date(), date2: "27 Mar 2022 04:00".dateFromMultipleFormats() ?? Date()) {
            currentDay = [block]()
            ScheduleCalendar.restore()
            ScheduleCalendar.setEmptyMessage("No Class - Enjoy Break!")
            return currentDay
        }
        
        if stringDate == "Wednesday, September 8, 2021" {
            ScheduleCalendar.restore()
            currentDay = customWednesday
            return currentDay
        }
        if stringDate == "Thursday, September 9, 2021" {
            ScheduleCalendar.restore()
            currentDay = customThursday
            return currentDay
        }
        if stringDate == "Friday, September 10, 2021" {
            ScheduleCalendar.restore()
            currentDay = customFriday
            return currentDay
        }
        return currentDay
    }
    private var customWednesday = [
        block(name: "9's go to Biv", startTime: "07:30am", endTime: "08:15am", block: "N/A", reminderTime: "07:25am", length: 45),
        block(name: "New 10's and 11's community", startTime: "08:15am", endTime: "09:00am", block: "N/A", reminderTime: "07:25am", length: 45),
        block(name: "Advisory", startTime: "09:00am", endTime: "09:35am", block: "N/A", reminderTime: "07:25am", length: 45),
        block(name: "Orientation Block 1", startTime: "09:40am", endTime: "10:30am", block: "N/A", reminderTime: "07:25am", length: 45),
        block(name: "Orientation Block 2", startTime: "10:35am", endTime: "11:25am", block: "N/A", reminderTime: "07:25am", length: 45),
        block(name: "Cookout Lunch", startTime: "11:30am", endTime: "12:15pm", block: "N/A", reminderTime: "07:25am", length: 45),
        block(name: "Orientation Block 3", startTime: "12:20pm", endTime: "01:10pm", block: "N/A", reminderTime: "07:25am", length: 45),
        block(name: "Orientation Block 4", startTime: "01:15pm", endTime: "02:05pm", block: "N/A", reminderTime: "07:25am", length: 45),
        block(name: "Advisory", startTime: "02:10pm", endTime: "02:30pm", block: "N/A", reminderTime: "07:25am", length: 45),
        block(name: "Athletics", startTime: "03:00pm", endTime: "04:30pm", block: "N/A", reminderTime: "07:25am", length: 45)
    ]
    private var customThursday = [
        block(name: "Advisory", startTime: "09:00am", endTime: "09:45am", block: "N/A", reminderTime: "08:55am", length: 45),
        block(name: "Escape Room Orientation", startTime: "09:50am", endTime: "10:40am", block: "N/A", reminderTime: "09:50am", length: 45),
        block(name: "Class Meetings", startTime: "10:45am", endTime: "11:30am", block: "N/A", reminderTime: "10:40am", length: 45),
        block(name: "Cookout Lunch", startTime: "11:30am", endTime: "12:30pm", block: "N/A", reminderTime: "11:30am", length: 45),
        block(name: "Senior Meeting, 10 and 11 on turf", startTime: "12:35pm", endTime: "01:20pm", block: "N/A", reminderTime: "12:30pm", length: 45),
        block(name: "Advisory", startTime: "01:25pm", endTime: "02:10pm", block: "N/A", reminderTime: "01:20pm", length: 45),
        block(name: "Ice Cream Truck", startTime: "02:15pm", endTime: "03:15pm", block: "N/A", reminderTime: "02:10pm", length: 45),
        block(name: "Athletics", startTime: "03:30pm", endTime: "04:30pm", block: "N/A", reminderTime: "03:15pm", length: 45),
        block(name: "Seniors Dinner", startTime: "05:30pm", endTime: "07:30pm", block: "N/A", reminderTime: "04:30pm", length: 45)
    ]
    private var customFriday = [
        block(name: "Assembly", startTime: "08:15am", endTime: "08:40am", block: "N/A", reminderTime: "08:10am", length: 45),
        block(name: "A", startTime: "08:50am", endTime: "09:20am", block: "A", reminderTime: "08:40am", length: 45),
        block(name: "B", startTime: "09:25am", endTime: "09:55am", block: "B", reminderTime: "09:20am", length: 45),
        block(name: "Break", startTime: "10:00am", endTime: "10:20am", block: "N/A", reminderTime: "09:55am", length: 45),
        block(name: "C", startTime: "10:25am", endTime: "10:55am", block: "C", reminderTime: "10:20am", length: 45),
        block(name: "D", startTime: "11:00am", endTime: "11:30am", block: "D", reminderTime: "10:55am", length: 45),
        block(name: "Lunch", startTime: "11:35am", endTime: "12:05pm", block: "N/A", reminderTime: "11:30am", length: 45),
        block(name: "E", startTime: "12:10pm", endTime: "12:40pm", block: "E", reminderTime: "12:05pm", length: 45),
        block(name: "Break", startTime: "12:45pm", endTime: "12:55pm", block: "N/A", reminderTime: "12:40pm", length: 45),
        block(name: "F", startTime: "01:00pm", endTime: "01:30pm", block: "F", reminderTime: "12:55pm", length: 45),
        block(name: "G", startTime: "01:35pm", endTime: "02:05pm", block: "G", reminderTime: "01:30pm", length: 45),
        block(name: "Advisory", startTime: "02:10pm", endTime: "02:30pm", block: "N/A", reminderTime: "02:05pm", length: 45)
    ]
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        setCurrentday(date: date)
        ScheduleCalendar.reloadData()
        setTimes()
    }
}

struct block {
    let name: String
    let startTime: String
    let endTime: String
    let block: String
    let reminderTime: String
    let length: Int
}

struct NoSchoolDay {
    let date: String
    let reason: String
}

class blockTableViewCell: UITableViewCell {
    static let identifier = "blockTableViewCell"
    
    private let TitleLabel: UILabel = {
        let label = UILabel ()
        label.numberOfLines = 0
        label.textColor = UIColor(named: "inverse")
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.minimumScaleFactor = 0.8
        label.adjustsFontSizeToFitWidth = true
        return label
    } ()
    private let BlockLabel: UILabel = {
        let label = UILabel ()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = UIColor(named: "lightGray")
        return label
    } ()
    private let RightLabel: UILabel = {
        let label = UILabel ()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor(named: "gold")
        label.minimumScaleFactor = 0.8
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .right
        return label
    } ()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(TitleLabel)
        contentView.addSubview(BlockLabel)
        contentView.addSubview(RightLabel)
        contentView.backgroundColor = UIColor(named: "background")
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
    var constraint = NSLayoutConstraint()
    override func layoutSubviews() {
        super.layoutSubviews()
        constraint = TitleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -10)
        constraint.isActive = true
        TitleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10).isActive = true
        TitleLabel.rightAnchor.constraint(equalTo: RightLabel.leftAnchor, constant: -2).isActive = true
        BlockLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 10).isActive = true
        BlockLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10).isActive = true
        RightLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 100).isActive = true
        RightLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -10).isActive = true
        RightLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10).isActive = true
        
    }
    override func prepareForReuse(){
        super.prepareForReuse()
    }
    func configure (with viewModel: block, isLunch: Bool){
        if viewModel.block != "N/A" {
            BlockLabel.isHidden = false
            var className = LoginVC.blocks[viewModel.block] as? String
            if className == "" {
                className = "[\(viewModel.block) Class]"
            }
            TitleLabel.text = className
            BlockLabel.text = "\(viewModel.name)"
        }
        else {
            TitleLabel.text = "\(viewModel.name)"
            if isLunch {
                BlockLabel.isHidden = false
                BlockLabel.text = "Menu Available"
            }
            else {
                if viewModel.name.lowercased().contains("advisory") {
                    TitleLabel.text = "\(viewModel.name) \(LoginVC.blocks["room-advisory"] ?? "")"
                }
                BlockLabel.isHidden = true
            }
        }
        RightLabel.text = "\(viewModel.startTime) \u{2192} \(viewModel.endTime)"
    }
}

class LunchMenuVC: CustomLoader, WKNavigationDelegate {
    private let webView: WKWebView = {
        let webview = WKWebView(frame: .zero)
        return webview
    }()
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        hideLoaderView()
    }
    //    let urlString = "https://firebasestorage.googleapis.com/v0/b/bbn-daily.appspot.com/o/lunchmenus%2Flunchmenu-allergy.docx?alt=media&token=3830574a-a486-419f-8eb1-2dc0bc00620c"
    override func viewDidLoad() {
        super.viewDidLoad()
        let storage = FirebaseStorage.Storage.storage()
        let reference = storage.reference(withPath: "lunchmenus/lunchmenu-allergy.docx")
        reference.downloadURL(completion: { [self] (url, error) in
            if let error = error {
                print(error)
            }
            else {
                print("the url is: \(url!.absoluteString)")
                let urlstring = url!.absoluteString
                webView.backgroundColor = UIColor.white
                view.addSubview(webView)
                webView.frame = view.bounds
                webView.navigationDelegate = self
                guard let url = URL(string: urlstring) else {
                    return
                }
                webView.load(URLRequest(url: url))
                showLoaderView()
            }
        })
        view.backgroundColor = UIColor.white
        
    }
}