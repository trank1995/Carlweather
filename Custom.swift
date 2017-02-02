//
//  Custom.swift
//  CarlWeather
//
//  Created by spoderman on 9/25/15.
//  Copyright © 2015 spoderman. All rights reserved.
//
//  This is a rather simple class. It just pass the
//  location name to custom result scene

import Foundation
import UIKit

class Custom : UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    @IBOutlet var placeTextBox: UITextField!

    @IBOutlet weak var savedLocations: UIPickerView!
    var searched : NSMutableArray!
    
    var savedLocationList: [String]!
    var newPlace: String = "";
    var currentSelectedLoc = 0;
    var pickerDeleteOne = false;
    var ifgo = false;
    override func viewDidLoad() {
        readFile()
        if savedLocationList.count < 1{
            savedLocations.hidden = true
        }else{
            savedLocations.hidden = false
        }
        self.savedLocations.delegate = self
        self.savedLocations.dataSource = self
        super.viewDidLoad()
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //because there are two buttons/segues, u have to use an identifier.
        //change or set identifier by clicking on the segue. Select attribute (4th).
        if (segue.identifier == "toCustomResult"){
            let dest : CustomResult = segue.destinationViewController as! CustomResult
            dest.place = placeTextBox.text!
            newPlace = placeTextBox.text!
            ifgo = true;
            writeFile()
        }
    }
    
    func readFile(){
        

        let path = NSTemporaryDirectory() + "/saved.txt"

        
        do {
            let content = try String(contentsOfFile:path, encoding: NSUTF8StringEncoding)
            savedLocationList = content.componentsSeparatedByString("^_^")
            for (var i = 0; i<savedLocationList.count;i++){
                if savedLocationList[i] == ""{
                savedLocationList.removeAtIndex(i)
                }
            }
 
        } catch _ as NSError {
            savedLocationList = []
        }
    }
    func writeFile(){
        var writeString = "";
        if (ifgo) {
            ifgo = false
            if (!savedLocationList.contains(newPlace)){
                savedLocationList.append(newPlace)
            }
        }
        if savedLocationList.count>=1{
            for (var i = 0; i<savedLocationList.count-1; i++){
                if (savedLocationList[i] != ""){
                    writeString += savedLocationList[i] + "^_^"
                }
            }
            writeString += savedLocationList[savedLocationList.count-1]
        }
        let path = NSTemporaryDirectory() + "/saved.txt"
        
        do{
            try writeString.writeToFile(path, atomically: false, encoding: NSUTF8StringEncoding)
        }catch{
            print("failed to save")
        }


        
    }
    
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (pickerDeleteOne){
            pickerDeleteOne = false
            return savedLocationList.count - 1
        }
        return savedLocationList.count
    }
    
    /**
     *This func controls the titles of the picker wheels.
     */
    func pickerView(pickerView: UIPickerView, titleForRow row : Int, forComponent component: Int) -> String?{
        if pickerView == savedLocations{
            
            return savedLocationList[row]
        }else{
            return ""
        }
        
    }
    
    
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentSelectedLoc = row + 1
        
        if (savedLocationList.count > 0){
            placeTextBox.text = savedLocationList[row]
        }
    }
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        var attributedString: NSAttributedString!
        
        if pickerView == savedLocations{
            attributedString = NSAttributedString(string: String(savedLocationList[row]), attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
        }
        
        return attributedString
    }

    
    @IBAction func clearHistory(sender: AnyObject) {
        let writeString = ""
        savedLocationList = []
        let path = NSTemporaryDirectory() + "/saved.txt"
        savedLocations.hidden = true
        
        do{
            
            try writeString.writeToFile(path, atomically: false, encoding: NSUTF8StringEncoding)
        }catch{
            print("failed to clear")
        }
    }
    @IBAction func removeLocation(sender: AnyObject) {
        if (savedLocationList.count > 0){
            savedLocationList.removeAtIndex(currentSelectedLoc-1)
            writeFile()
            readFile()
            pickerDeleteOne = true
            if (savedLocationList.count > 0){
                savedLocations.reloadAllComponents()
            }else{
                savedLocations.hidden = true
            }
        }
    }
    
}