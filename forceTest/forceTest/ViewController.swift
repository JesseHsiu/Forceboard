//
//  ViewController.swift
//  forceTest
//
//  Created by 修敏傑 on 1/8/16.
//  Copyright © 2016 NTU. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var dataToWrite = [[Float]]()
    var count : Int = 0
    
    var currentTouchInDetectView = false
    
    @IBOutlet var detectView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {

        for touch in touches{
            
            if detectView.pointInside(touch.locationInView(detectView), withEvent: event)
            {
//                print("start")
                currentTouchInDetectView = true
            }
        }
        
        dataToWrite.append([Float]())
        
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if currentTouchInDetectView
        {
//            dataToWrite[count].append(1.234)
            let stringArray = dataToWrite[count].map{String($0)}
            
            if stringArray.count != 0
            {
                print(stringArray.joinWithSeparator(","))
            }
            
//            print("end")
            count++
        }
        
        currentTouchInDetectView = false
    }
    
    override func touchesEstimatedPropertiesUpdated(touches: Set<NSObject>) {
        
        if currentTouchInDetectView
        {
            let touches = touches as! Set<UITouch>
            
            for touch in touches
            {
                dataToWrite[count].append(Float(touch.force))
            }
        }
    }
    
    @IBAction func writeFile(sender: AnyObject) {
        let dir = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first!
        let responseDataLocation = dir.stringByAppendingString("/output.txt")
        
        
        var tmpString = ""
        
        for data in dataToWrite{
            for raw in data{
                tmpString = tmpString + String(raw) + ","
            }
            tmpString = tmpString + "\n"
        }
        
        do{
            try tmpString.writeToFile(responseDataLocation, atomically: true, encoding: NSUTF8StringEncoding)
        }
        catch
        {
            print("error happended")
        }
        dataToWrite.removeAll()
    }


}

