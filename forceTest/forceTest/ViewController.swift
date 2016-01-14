//
//  ViewController.swift
//  forceTest
//
//  Created by 修敏傑 on 1/8/16.
//  Copyright © 2016 NTU. All rights reserved.
//

import UIKit
import Charts

class ViewController: UIViewController {

    var dataToWrite = [[Float]]()
    var count : Int = 0
    
    var currentTouchInDetectView = false
    
    var userName : String?
    
    var showData = [Float]()
    @IBOutlet var lineChart: LineChartView!
    
    @IBOutlet var detectView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let alertController = UIAlertController(title: "Name of User", message: "Please Input User Name", preferredStyle: UIAlertControllerStyle.Alert)
        
        
        alertController.addTextFieldWithConfigurationHandler {
            textField in
            textField.placeholder = "Name"
        }
        
        let okAction = UIAlertAction(title: "ok", style: UIAlertActionStyle.Default) { (action) -> Void in
            self.userName = alertController.textFields?.first?.text
        }
        alertController.addAction(okAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {

        for touch in touches{
            
            if detectView.pointInside(touch.locationInView(detectView), withEvent: event)
            {
                detectView.backgroundColor = UIColor.redColor()
                print("start")
        
                currentTouchInDetectView = true
            }
        }
        
        dataToWrite.append([Float]())
        
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if currentTouchInDetectView
        {
            dataToWrite[count].append(Float(touches.first!.force) / Float(touches.first!.maximumPossibleForce))
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if currentTouchInDetectView
        {
            detectView.backgroundColor = UIColor.blueColor()
            let stringArray = dataToWrite[count].map{String($0)}
            
            if stringArray.count != 0
            {
                print(stringArray.joinWithSeparator(","))
            }
            count++
        }
        
        currentTouchInDetectView = false
    }
    
    @IBAction func writeFile(sender: AnyObject) {
        let dir = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first!
        let responseDataLocation = dir.stringByAppendingString("/" + self.userName! + ".txt")
        
        
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
        count = 0
    }


}

