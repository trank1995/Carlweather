//
//  Month.swift
//  CarlWeather
//
//  Created by spoderman on 9/4/15.
//  Copyright © 2015 spoderman. All rights reserved.
//

import Foundation
import UIKit

class Month : UIViewController {
    
    
    @IBOutlet var imageURL: UIImageView!
    @IBOutlet var timePeriod: UILabel!
    var URLPath = "http://weather.carleton.edu/"
    //let flickrURLPath = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_keys=b1217b6f18279e3d759f84a377fa07b8&text=northfield&perpage=20&format=json&nojsoncallback=1"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showTimePeriod()
        imageProcess()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showTimePeriod(){
        //to get current month
        let dayTimePeriodFormatter = NSDateFormatter()
        dayTimePeriodFormatter.dateFormat = "MM,dd,yyyy"
        let dateNum = dayTimePeriodFormatter.stringFromDate(NSDate())
        let dateNums = dateNum.componentsSeparatedByString(",")
        //to get current date
        dayTimePeriodFormatter.dateFormat = "MMM dd, yyyy"
        let dateStringNow = dayTimePeriodFormatter.stringFromDate(NSDate())
        //show on UI
        var prevMonth = Int(dateNums[0])! - 1
        var prevYear = Int(dateNums[2])!
        let day = Int(dateNums[1])!
        var prevDay = day
        timePeriod.text = "From last month " + dateNums[1] + "th to " + dateStringNow
        if (prevMonth == 0) {
            prevMonth = 12
            prevYear -= 1
        }else if (day > 28) {
            prevDay = 28
        }
        URLPath = "http://weather.carleton.edu/dplot.php?year=\(prevYear)&month=\(prevMonth)&day=\(prevDay)&year2=\(dateNums[2])&month2=\(dateNums[0])&day2=\(day)&check3=avetemp&end=end&graphtype=line"

    }
    
    func imageProcess() {
        print(URLPath)
        let url = NSURL(string: URLPath)
        let beginImage = CIImage(contentsOfURL: url!)
        let imageCG = convertCIImageToCGImage(beginImage!)
        
        imageURL.image = manipulatePixel(imageCG)
        
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
        if (a == 0x00){
            rgbArray[1] = 0x18  //background blue
            rgbArray[2] = 0x3a
            rgbArray[3] = 0x75
        }
        else{
            if (r < 0xf5){
                if (r > 0xeb)&&(g > 0xeb)&&(b > 0xeb){
                    
                    rgbArray[1] = 0x29  //another background blue
                    rgbArray[2] = 0x4b
                    rgbArray[3] = 0x86
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
                        }else{
                            rgbArray[1] = 0xff
                            rgbArray[2] = 0x00
                            rgbArray[3] = 0x00
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