//
//  Day.swift
//  CarlWeather
//
//  Created by spoderman on 9/2/15.
//  Copyright © 2015 spoderman. All rights reserved.
//
//  This page shows a bunch of weather info. It uses
//  the api from openweather.

import Foundation
import UIKit

class Day : UIViewController {
    
    //bunch of labels
    @IBOutlet var todayWeatherLabelTempF: UILabel!
    @IBOutlet var currentTime: UILabel!
    @IBOutlet var todayWeatherLabelTempC: UILabel!
    @IBOutlet var todayWeatherLabelMain: UILabel!
    @IBOutlet var todayWeatherLabelDescription: UILabel!
    @IBOutlet var todayPressure: UILabel!
    @IBOutlet var todayHumidity: UILabel!
    @IBOutlet var deTempLabel: UILabel!
    @IBOutlet var windSpeedLabel: UILabel!
    @IBOutlet var windGust: UILabel!
    @IBOutlet var degLabel: UILabel!
    var tempC = 0
    
    @IBOutlet weak var loadingImage: UIImageView!

    var allSet = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingScreen()
        //get current time and show on label
        let time = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .MediumStyle, timeStyle: .ShortStyle)
        currentTime.text = "current time: " + time
        getWeatherData("http://api.openweathermap.org/data/2.5/weather?q=Northfield,us&APPID=e0ba03ca11e3913303d2fc5d50e1a1ba")


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
    func loadingScreen(){
        var imageList = [UIImage]()
        for i in 1...73{
            let imagePath = "images/loading/"+String(i)+".png"
            imageList.append(UIImage(named: imagePath)!)
        }
        //let imagePath = "images/testLoading/"+String(13)+".jpg"
        //imageList.append(UIImage(named: imagePath)!)
        if ((!allSet)){
            loadingImage.animationImages = imageList
            loadingImage.startAnimating()
        }else{
            loadingImage.stopAnimating()
            loadingImage.hidden = true
        }
        
    }
    
    func setLabels(weatherData: NSData) {
        do{
            let json = try NSJSONSerialization.JSONObjectWithData(weatherData, options: [])as! NSDictionary
            if let main = json["main"] as? NSDictionary{
                if let temp = main["temp"] as? Double {
                    todayWeatherLabelTempF.text = String(format: "%.1f", (temp*9/5)-459.67) + " ºF"
                    todayWeatherLabelTempC.text = String(format: "%.1f", temp-273.15) + " ºC"
                    tempC = Int(temp-273.15)
                    setBackground()
                }
                if let pressure = main["pressure"] as? Double {
                    todayPressure.text = "Pressure: " + String(format: "%.1f", pressure)
                }
                if let humidity = main["humidity"] as? Double {
                    todayHumidity.text = "Humidity: " + String(format: "%.1f", humidity)
                }
                if let deTemp = main["temp_min"] as? Double {
                    let deTemp2 = main["temp_max"] as? Double
                    let min = String(Int((deTemp*9/5)-460.67))
                    let max = String(Int((deTemp2!*9/5)-458.67))
                    deTempLabel.text = "Min to Max Temp: " + min + " ~ " + max + " ºF"
                }
            }
            if let wind = json["wind"] as? NSDictionary{
                if let speed = wind["speed"] as? Double {
                    windSpeedLabel.text = "Wind Speed: " + String(speed)
                }
                if let deg = wind["deg"] as? Double {
                    degLabel.text = "Degree: " + String(deg)
                }
                if let gust = wind["gust"] as? Int {
                    windGust.text = "Wind gust: " + String(gust)
                }
            }
            if let weather = json["weather"] as? NSArray{
                if let mainWeather = weather[0]["main"] as? String {
                    todayWeatherLabelMain.text = mainWeather
                }
                if let description = weather[0]["description"] as? String {
                    todayWeatherLabelDescription.text = description
                }
            }
        
        }catch {
            todayWeatherLabelTempF.text = "no connection"
        }
        loadingImage.stopAnimating()
        loadingImage.hidden = true
        todayWeatherLabelTempF.hidden = false
        currentTime.hidden = false
        todayWeatherLabelTempC.hidden = false
        todayWeatherLabelMain.hidden = false
        todayWeatherLabelDescription.hidden = false
        todayPressure.hidden = false
        todayHumidity.hidden = false
        deTempLabel.hidden = false
        windSpeedLabel.hidden = false
        windGust.hidden = false
        degLabel.hidden = false
        
        
    }
    
    func setBackground() {
        

        let ran = Int(arc4random_uniform(2))
        var filePath = "images/1.jpg"
        var background  = UIImage(named: filePath)!
        if (tempC < 0 ) {
            filePath = "images/snow/" + String(1) + ".jpg"
            background = UIImage(named: filePath)!
        }else{
            filePath = "images/sunny/" + String(1+ran) + ".jpg"
            background = UIImage(named: filePath)!
        }
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        background = manipulatePixel(background.CGImage!)!
        background = cropToBounds(background, width: screenSize.width, height: screenSize.height)

        self.view.backgroundColor = UIColor(patternImage: background)
        
        
    }
    func manipulatePixel(imageRef : CGImageRef) -> UIImage? {
        //in case someone wants to fit the image to a vertical ipad
        //let screenSize: CGRect = UIScreen.mainScreen().bounds
        
        
        let context = self.createARGBBitmapContext(imageRef)
        
        let width:Int  = Int(CGImageGetWidth(imageRef))
        let height:Int = Int(CGImageGetHeight(imageRef))
        
        let rect = CGRectMake(0, 0, CGFloat(width), CGFloat(height))
        
        CGContextDrawImage(context, rect, imageRef)
        
        let data: UnsafeMutablePointer<Void> = CGBitmapContextGetData(context)
        let dataType = UnsafeMutablePointer<UInt8>(data)
        
        var base, offset:Int
        
        for y in 0...(height - 1) {
            
            base = y * width * 4
            for x in 0...(width - 1) {
                
                offset = base + 4*x
                
                let a = dataType[offset] //alpha
                let r = dataType[offset + 1] //red
                let g = dataType[offset + 2] //green
                let b = dataType[offset + 3] //blue
                let newRGB = self.decideColor(a, r: r, g: g, b: b)
                dataType[offset] = newRGB[0]
                dataType[offset + 1] = newRGB[1]
                dataType[offset + 2] = newRGB[2]
                dataType[offset + 3] = newRGB[3]
            }
        }
        let imageRef = CGBitmapContextCreateImage(context);
        let newImage = UIImage(CGImage: imageRef!)
        
        free(data)
        return newImage
    }
    func cropToBounds(image: UIImage, width: CGFloat, height: CGFloat) -> UIImage {
        
        let contextImage: UIImage = UIImage(CGImage: image.CGImage!)
        
        
        let posX: CGFloat = (contextImage.size.width-width)/2
        let posY: CGFloat = 0
        
        
        let rect: CGRect = CGRectMake(posX, posY, contextImage.size.width-posX, contextImage.size.height)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImageRef = CGImageCreateWithImageInRect(contextImage.CGImage, rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let image: UIImage = UIImage(CGImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
        
        return image
    }
    func createARGBBitmapContext(imageRef : CGImageRef) -> CGContextRef! {
        let pixelWidth: Int = CGImageGetWidth(imageRef);
        let pixelHeight: Int = CGImageGetHeight(imageRef);
        let bitmapBytesPerRow: Int = (pixelWidth * 4)
        let bitmapByteCount: Int = (bitmapBytesPerRow * pixelHeight)
        
        let colorSpace:CGColorSpace = CGColorSpaceCreateDeviceRGB()!
        
        let bitmapData:UnsafeMutablePointer<Void> = malloc(bitmapByteCount)
        if bitmapData == nil {
            return nil
        }
        
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedFirst.rawValue)
        let context:CGContextRef = CGBitmapContextCreate(bitmapData, pixelWidth, pixelHeight, 8,bitmapBytesPerRow, colorSpace, bitmapInfo.rawValue)!
        return context
    }
    func decideColor(a: UInt8, r: UInt8, g: UInt8, b: UInt8) -> Array<UInt8>{
        var rgbArray: Array<UInt8> = [0xff,0x18,0x3a,0x75]
        //margin
        rgbArray[1] = r>>1
        rgbArray[2] = g>>1
        rgbArray[3] = b>>1

        return rgbArray
    }

}