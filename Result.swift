//
//  Result.swift
//  CarlWeather
//
//  Created by spoderman on 9/4/15.
//  Copyright © 2015 spoderman. All rights reserved.
//

import Foundation
import UIKit

class Result : UIViewController {
    
    
    @IBOutlet var startLabel: UILabel!
    @IBOutlet var endLabel: UILabel!
    @IBOutlet var result: UILabel!
    @IBOutlet var imageURL: UIImageView!
    
    var URLPath = "http://weather.carleton.edu/"
    var scale = String()
    var startDate = String()
    var endDate = String()
    var requestedData = String()
    var startArray:[String] = ["1","1","1","1991"]
    var endArray:[String] = ["1","1","1","1991"]
    var type = "temperature"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //avoid outOfIndex error
        if (startDate == "From"){
            startDate = "1, 1, 1, 1991"
        }
        if (endDate == "To"){
            endDate = "1, 1, 1, 1991"
        }
        //set label using the data from plotscene
        startLabel.text = "From: " + startDate
        endLabel.text = "To: " + endDate
        result.text = requestedData
        
        //seperate strings, to get date
        startArray =  startDate.componentsSeparatedByString(", ")
        endArray =  endDate.componentsSeparatedByString(", ")
        //change the url according to the input
        loadAdressURL()
        //load image
        imageProcess()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    /**
    * Change global variable URLPath
    * accordng to the input
    **/
    func loadAdressURL(){
        var month = startArray[0]
        var month2 = endArray[0]
        var rdnValue = "rplot"
        if scale != "year"{
            month = startArray[startArray.count-3]
            month2 = endArray[endArray.count-3]
            
        }
        var startURLString = "year="+startArray[startArray.count-1]+"&month=" + translateMonth(month)
        var endURLString = "year2="+endArray[endArray.count-1]+"&month2="+translateMonth(month2)
        if scale == "min"{
            startURLString = startURLString + "&day="+startArray[2]+"&hour="+startArray[0]
            endURLString = endURLString + "&day2="+endArray[2]+"&hour2="+endArray[0]
            rdnValue = "rplot"
        }
        if scale == "day"{
            startURLString = startURLString + "&day="+startArray[1]
            endURLString = endURLString + "&day2="+endArray[1]
            rdnValue = "dplot"
        }
        if scale == "year"{
            startURLString = startURLString + "&day="+"1"
            endURLString = endURLString + "&day2="+"1"
            rdnValue = "nplot"
        }
        //the init of the url can be rplot, dplot or nplot depending on the scale
        // of minute, day or year.
        type = translate(type)
        URLPath = "http://weather.carleton.edu/\(rdnValue).php?\(startURLString)&\(endURLString)&check1=\(type)&end=end&graphtype=line"
        
    }
    /***
    * This function takes the variable name in
    * the form of the URL request, and translate
    * to more human readable form
    */
    func translate (inputType: String) -> String {
        var dictionary = [String:String]()
        let tagLs = ["Temperature", "Heat Index", "Wind Chill", "Barometric Pressure", "Solar Radiation", "Daily Rainfall", "Monthly Rainfall", "Wind Speed", "Relative Humidity", "Dewpoint","High Temperature", "Low Temperature", "Average Temperature", "High Barometric Pressure", "Low Barometric Pressure", "Rainfall", "Peak WindGust", "High Relative Humidity", "Low Relative Humidity"]
        let codeLs = ["temp", "heat_index", "windchill", "barometer", "solarrad", "dailyrain", "monthlyrain", "ws1", "humidity", "dewpoint","hightemp", "lowtemp", "avetemp", "highbar", "lowbar", "rain", "gust", "highhumid", "lowhumid"]
        for index in 0 ... 18{
            dictionary[tagLs[index]] = codeLs[index]
        }
        return dictionary[inputType]!
    }
    
    func translateMonth (inputType: String) -> String {
        var dictionary = [String:String]()
        let tagLs = ["01","02","03","04","05","06","07","08","09","10","11","12",]
        let codeLs = ["Jan", "Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]
        for index in 0 ... 11{
            dictionary[codeLs[index]] = tagLs[index]
        }
        return dictionary[inputType]!
    }
    /**
    * create CIImage with URLPath, and then convert
    * it to CGImage for pixel manipulation. Put on 
    * screen afterwards.
    **/
    func imageProcess() {
        let url = NSURL(string: URLPath)
        let beginImage = CIImage(contentsOfURL: url!)
        let imageCG = convertCIImageToCGImage(beginImage!)
        //manipulate and paste
        imageURL.image = manipulatePixel(imageCG)
    }
    /***
    * Change the background to dark blue. Blacklines,
    * including words, to yellow. Coordinates to white.
    */
    func manipulatePixel(imageRef : CGImageRef) -> UIImage? {
        let context = self.createARGBBitmapContext(imageRef)
        let width:Int  = Int(CGImageGetWidth(imageRef))
        let height:Int = Int(CGImageGetHeight(imageRef))
        let rect = CGRectMake(0, 0, CGFloat(width), CGFloat(height))
        
        CGContextDrawImage(context, rect, imageRef)
        
        let data: UnsafeMutablePointer<Void> = CGBitmapContextGetData(context)
        let dataType = UnsafeMutablePointer<UInt8>(data)
        
        var base, offset:Int
        
        //pixel manipulation
        for y in 0...(height - 1) {
            
            base = y * width * 4
            for x in 0...(width - 1) {
                
                offset = base + 4*x
                //too lazy to understand how they store argb
                //but it's y*width*4+4*x + 1,2,3
                let a = dataType[offset] //alpha
                let r = dataType[offset + 1] //red
                let g = dataType[offset + 2] //green
                let b = dataType[offset + 3] //blue
                //get new color according to the old color
                let newRGB = self.decideColor(a, r: r, g: g, b: b)
                //change to new color
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
        if (a<=0x42) {
            rgbArray[1] = 0x18  //background blue
            rgbArray[2] = 0x3a
            rgbArray[3] = 0x75
        }else{
            if (r < 0xf5){
                if (r > 0xeb)&&(g > 0xeb)&&(b > 0xeb){
                    rgbArray[1] = 0x29  //another background blue
                    rgbArray[2] = 0x4b
                    rgbArray[3] = 0x86
                    
                }else{
                    if (r > 0xeb)&&(g > 0xeb)&&(b > 0xeb){
                        rgbArray[1] = 0xff
                        rgbArray[2] = 0x00
                        rgbArray[3] = 0x00
                    }else{
                        if (r < 0x32)&&(g < 0x32)&&(b < 0x32){
                            rgbArray[1] = 0xff  //yellow
                            rgbArray[2] = 0xe6
                            rgbArray[3] = 0x54
                        }else{
                            if (r > 0xbe)&&(g > 0xbe)&&(b > 0xbe){
                                rgbArray[1] = 0xff
                                rgbArray[2] = 0xff
                                rgbArray[3] = 0xff
                            }
                        }
                    }
                }
            }else{
                rgbArray[1] = 0x18  //background blue
                rgbArray[2] = 0x3a
                rgbArray[3] = 0x75
            }
        }
        return rgbArray
    }
    
    
    func convertCIImageToCGImage(inputImage: CIImage) -> CGImage! {
        let context = CIContext(options: nil)
        return context.createCGImage(inputImage, fromRect: inputImage.extent)
    }

}