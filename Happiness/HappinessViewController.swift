//
//  HappinessViewController.swift
//  Happiness
//
//  Created by 刘述清 on 16/2/16.
//  Copyright © 2016年 刘述清. All rights reserved.
//

import UIKit

class HappinessViewController: UIViewController,FaceViewDataSource{
    
    
    @IBOutlet weak var faceView: FaceView!{
        // the property observer didSet gets called when this outlet gets set
        // (i.e. when iOS makes the connection to the FaceView in the storyboard)
        // this is a perfect time to configure the FaceView with its delegate and recognizers
        didSet {
            faceView.dataSource = self
            // this pinch gesture can be handled by the View, so just "turn it on" here in the Controller
            faceView.addGestureRecognizer(UIPinchGestureRecognizer(target: faceView, action: "scale:"))
            // this pan gesture recognizer modifies the Model so it must be handled by the Controller
            // we could add it in code like below, but instead, we added it directly in the storyboard
            // and wired it up with ctrl-drag
            // faceView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "changeHappiness:"))
        }

    }
    
    @IBAction func changeHappiness(sender: UIPanGestureRecognizer) {
        switch sender.state{
        case .Ended:
            fallthrough
        case .Changed:
            let transaction=sender.translationInView(faceView)
            let happinessChange = -Int(transaction.y/Constants.HappinessGestureScale)
            if happinessChange != 0{
                happiness+=happinessChange
                sender.setTranslation(CGPointZero, inView: faceView)
            }
        default:break
        }
    }
    
    private struct Constants {
        static let HappinessGestureScale: CGFloat = 4
    }
    
    // a property to access our Model
    // incredibly simplistic Model
    // most MVCs would have more complicated Models (e.g. CalculatorBrain)
    var happiness: Int = 100 { // 0 = very sad, 100 = ecstatic
        didSet {
            // validate (actually, enforce validity of) modifications to the Model
            happiness = min(max(happiness, 0), 100)
            print("happiness = \(happiness)")
            // any time the Model changes, we need to update our View
            updateUI()
        }
    }
    
    func updateUI() {
        // to update our UI, we just need to ask the FaceView to redraw
        faceView.setNeedsDisplay()
    }
    
    // FaceViewDataSource
    func smilinessForDaceView(sender: FaceView) -> Double? {
        // interpret the Model for the View
        return Double(happiness-50)/50
    }
    
    
}
