//
//  PlotScene.swift
//  CarlWeather
//
//  Created by spoderman on 9/9/15.
//  Copyright © 2015 spoderman. All rights reserved.
//

import Foundation
import UIKit

class PlotScene : UIViewController, UIPickerViewDelegate {
    //variables that users can change
    var currentDateType = "from"
    var currentScale = "min"
    var requestedData = "Temperature"
    var currentDateString = "00, Jan, 01, 1999"
    var hourSelected = "00"
    var daySelected = "01"
    var monthSelected = "Jan"
    var yearSelected = "1999"
    var year = [1999]
    var month = ["Jan", "Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov", "Dec"]
    var day = [01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31]
    var hour = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]
    //lists of options
    let minutelist = ["Temperature", "Heat Index", "Wind Chill", "Barometric Pressure", "Solar Radiation", "Daily Rainfall", "Monthly Rainfall", "Wind Speed", "Relative Humidity", "Dewpoint"]
    let monthList = ["High Temperature", "Low Temperature", "Average Temperature", "High Barometric Pressure", "Low Barometric Pressure", "Rainfall", "Peak WindGust", "High Relative Humidity", "Low Relative Humidity"]

    @IBOutlet var yearPicker: UIPickerView!
    @IBOutlet var monthPicker: UIPickerView!
    @IBOutlet var dayPicker: UIPickerView!
    @IBOutlet var hourPicker: UIPickerView!
    @IBOutlet var requestedPicker: UIPickerView!
    @IBOutlet var requestedPicker2: UIPickerView!
        

    @IBOutlet var fromDate: UIButton!
    @IBOutlet var toDate: UIButton!
    @IBOutlet var controller: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateYear()
        requestedPicker2.hidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toResult"{
            let dest : Result = segue.destinationViewController as! Result
            dest.startDate = (fromDate.titleLabel?.text)!
            dest.endDate = (toDate.titleLabel?.text)!
            dest.requestedData = (requestedData)
            dest.scale = currentScale
            dest.type = requestedData
        }
    }

    
    
    
    @IBAction func changeScale(sender: AnyObject) {
        if controller.selectedSegmentIndex == 0 {
            currentScale = "min"
            requestedPicker.hidden = false
            requestedPicker2.hidden = true
            hourPicker.hidden = false
            dayPicker.hidden = false
            requestedData = "Temperature"
            
        }
        if controller.selectedSegmentIndex == 1 {
            currentScale = "day"
            requestedPicker.hidden = true
            requestedPicker2.hidden = false
            hourPicker.hidden = true
            dayPicker.hidden = false
            requestedData = "High Temperature"
        }
        if controller.selectedSegmentIndex == 2 {
            currentScale = "day"
            daySelected = "01"
            requestedPicker.hidden = true
            requestedPicker2.hidden = false
            hourPicker.hidden = true
            dayPicker.hidden = true
            requestedData = "High Temperature"
            
        }
        refreshLabels(currentScale,dataType: "from")
        refreshLabels(currentScale,dataType: "to")
    }
    func refreshLabels(scaleOfDate:String, dataType:String){
        
        if scaleOfDate == "min"{
        currentDateString = hourSelected + ", " + monthSelected + ", " + daySelected + ", " + yearSelected
        
        }else if scaleOfDate == "day"{
            currentDateString = monthSelected + ", " + daySelected + ", " + yearSelected
        }else{
            currentDateString = monthSelected + ", " + yearSelected
        }
        if dataType == "from"{
            fromDate.setTitle(currentDateString, forState: .Normal)
        }else if dataType == "to"{
            toDate.setTitle(currentDateString, forState: .Normal)
        }
    }
    
    /**
    * this void func updates the year wheel to current year
    */
    func updateYear() {
        let timePeriodFormatter = NSDateFormatter()
        timePeriodFormatter.dateFormat = "yyyy"
        let currentYear = Int(timePeriodFormatter.stringFromDate(NSDate()))
        for var yearI = 2000; yearI < currentYear!+1; ++yearI {
            year.append(yearI)
        }
    }
    
    /**
    * These are some funcs I copied from youtube. Some controls the row,
    * some controls the columns and some
    */
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView!) -> Int{
        return 1
    }
    func pickerView(pickerView: UIPickerView!, numberOfRowsInComponent component: Int) -> Int {

        if pickerView == yearPicker{
            return year.count
        }else if pickerView == monthPicker{
            return month.count
        }else if pickerView == dayPicker{
            return day.count
        }else if pickerView == hourPicker{
            return hour.count
        }else if pickerView == requestedPicker{
            return minutelist.count
        }else if pickerView == requestedPicker2{
            return monthList.count
        }else{
            return 0
        }
    }
    
    /**
    *This func controls the titles of the picker wheels.
    */
    func pickerView(pickerView: UIPickerView, titleForRow row : Int, forComponent component: Int) -> String?{
        if pickerView == yearPicker{
            return String(year[row])
        }else if pickerView == monthPicker{
            return String(month[row])
        }else if pickerView == dayPicker{
            return String(day[row])
        }else if pickerView == hourPicker{
            return String(hour[row])
        }else if pickerView == requestedPicker{
            return String(minutelist[row])
        }else if pickerView == requestedPicker2{
            return String(monthList[row])
        }else{
            return ""
        }
    }
    
    
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == hourPicker{
            if controller.selectedSegmentIndex != 0{
                hourSelected = "00"
            }else{
                hourSelected = String(hour[row])
            }
        }else if pickerView == dayPicker{
            daySelected = String(day[row])
        }else if pickerView == monthPicker{
            monthSelected = String(month[row])
        }else if pickerView == yearPicker{
            yearSelected = String(year[row])
        }else if pickerView == requestedPicker{
            requestedData = String(minutelist[row])
        }else if pickerView == requestedPicker2{
            requestedData = String(monthList[row])
        }
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH, MM, dd, yyyy"
        if currentDateType == "from" {
            refreshLabels(currentScale, dataType: "from")
        }else if currentDateType == "to" {
            refreshLabels(currentScale, dataType: "to")
        }
        
    }
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        var attributedString: NSAttributedString!
        
        if pickerView == hourPicker{
            attributedString = NSAttributedString(string: String(hour[row]), attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
        }else if pickerView == dayPicker{
            attributedString = NSAttributedString(string: String(day[row]), attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
        }else if pickerView == monthPicker{
            attributedString = NSAttributedString(string: String(month[row]), attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
        }else if pickerView == yearPicker{
            attributedString = NSAttributedString(string: String(year[row]), attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
        }else if pickerView == requestedPicker{
            attributedString = NSAttributedString(string: String(minutelist[row]), attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
        }else if pickerView == requestedPicker2{
            attributedString = NSAttributedString(string: String(monthList[row]), attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
        }
        
        return attributedString
    }
    
    
    /**
    * Controls the input type. When the label/button is clicked,
    * change current input type.
    */
    @IBAction func clickFrom(sender: AnyObject) {
        currentDateType = "from"
    }
    /**
    * Controls the input type. When the label/button is clicked,
    * change current input type.
    */
    @IBAction func clickTo(sender: AnyObject) {
        currentDateType = "to"
    }
}