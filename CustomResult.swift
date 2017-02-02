//
//  CustomResult.swift
//  CarlWeather
//
//  Created by spoderman on 9/29/15.
//  Copyright © 2015 spoderman. All rights reserved.
//

import Foundation
import UIKit
class CustomResult : UIViewController {
    
    @IBOutlet var placeLabel: UILabel!
    @IBOutlet var stationName: UILabel!
    
    @IBOutlet var tempLabel: UILabel!
    @IBOutlet var tempLabel2: UILabel!
    @IBOutlet var descrpt: UILabel!
    @IBOutlet var descrpt2: UILabel!
    
    var place = String()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        placeLabel.text = place
        place = place.stringByReplacingOccurrencesOfString(" ", withString: "")
        getWeatherData("http://api.openweathermap.org/data/2.5/weather?q=\(place),us&APPID=e0ba03ca11e3913303d2fc5d50e1a1ba")
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func getWeatherData(urlString : String) {
        let url = NSURL(string: urlString)
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) { (data, response, error) in dispatch_async(dispatch_get_main_queue(), { self.setLabels(data!)})
        }
        task.resume()
        
    }
    func setLabels(weatherData: NSData) {
        do{
            let json = try NSJSONSerialization.JSONObjectWithData(weatherData, options: [])as! NSDictionary
            if let main = json["main"] as? NSDictionary{
                if let temp = main["temp"] as? Double {
                    tempLabel.text = String(format: "%.1f", (temp*9/5)-459.67) + " ºF"
                    tempLabel2.text = String(format: "%.1f", temp-273.15) + " ºC"
                }
            }
            if let placeName = json["name"] as? String{
                if let sys = json["sys"] as? NSDictionary{
                    if let country = sys["country"] as? String{
                        stationName.text = placeName + ", " + country
                    }
                }
            }
            if let weather = json["weather"] as? NSArray{
                if let mainWeather = weather[0]["main"] as? String {
                    descrpt.text = mainWeather
                }
                if let description = weather[0]["description"] as? String {
                    descrpt2.text = description
                }
            }
            placeLabel.hidden = false
            stationName.hidden = false
            tempLabel.hidden = false
            tempLabel2.hidden = false
            descrpt.hidden = false
            descrpt2.hidden = false
            
            
        }catch {
            tempLabel.text = "no connection"
        }
    }
}