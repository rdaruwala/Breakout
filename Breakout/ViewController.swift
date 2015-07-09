//
//  ViewController.swift
//  Breakout
//
//  Created by Rohan Daruwala on 7/9/15.
//  Copyright © 2015 Rohan Daruwala. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollisionBehaviorDelegate {
    
    @IBOutlet weak var livesLabel: UILabel!
    
    var dynamicAnimator = UIDynamicAnimator()
    var collisionBehavior = UICollisionBehavior()
    var ball = UIView()
    var paddle = UIView()
    var brick = UIView()
    var lives:Int = 5
    
    var brickArray:[UIView] = []
    var allArray:[UIView] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lives = 5
        
        ball = UIView(frame: CGRectMake(view.center.x, view.center.y, 20, 20))
        ball.backgroundColor = UIColor.blackColor()
        ball.layer.cornerRadius = 10
        ball.clipsToBounds = true
        view.addSubview(ball)
        
        paddle = UIView(frame: CGRectMake(view.center.x, view.center.y*1.7, 80, 20))
        paddle.backgroundColor = UIColor.redColor()
        view.addSubview(paddle)
        
        /*brick = UIView(frame: CGRectMake(20, 20, 40, 20))
        brick.backgroundColor = UIColor.blueColor()
        view.addSubview(brick)*/
        
        
        setupBricks()
        
        dynamicAnimator = UIDynamicAnimator(referenceView: view)
        
        let ballDynamicBehavior = UIDynamicItemBehavior(items: [ball])
        ballDynamicBehavior.friction = 0
        ballDynamicBehavior.resistance = 0
        ballDynamicBehavior.elasticity = 1.0
        ballDynamicBehavior.allowsRotation = false
        dynamicAnimator.addBehavior(ballDynamicBehavior)
        
        let paddleDynamicBehavior = UIDynamicItemBehavior(items: [paddle])
        paddleDynamicBehavior.density = 1000
        paddleDynamicBehavior.resistance = 100
        paddleDynamicBehavior.allowsRotation = false
        dynamicAnimator.addBehavior(paddleDynamicBehavior)
        
        allArray.append(ball)
        allArray.append(paddle)
        
        let pushBehavior = UIPushBehavior(items: [ball], mode: UIPushBehaviorMode.Instantaneous)
        pushBehavior.pushDirection = CGVectorMake(0.2, 1.0)
        pushBehavior.magnitude = 0.25
        dynamicAnimator.addBehavior(pushBehavior)
        
        let collisionBehavior = UICollisionBehavior(items: allArray)
        collisionBehavior.translatesReferenceBoundsIntoBoundary = true
        collisionBehavior.collisionMode = .Everything
        collisionBehavior.collisionDelegate = self
        dynamicAnimator.addBehavior(collisionBehavior)
        
        let brickDynamicBehavior = UIDynamicItemBehavior(items: brickArray)
        brickDynamicBehavior.density = 10000
        brickDynamicBehavior.resistance = 100
        brickDynamicBehavior.allowsRotation = false
        dynamicAnimator.addBehavior(brickDynamicBehavior)
        
        
        livesLabel.text = "Lives: " + String(lives)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func onPanGestureAction(sender: AnyObject) {
        let panGesture = sender.locationInView(view)
        paddle.center = CGPointMake(panGesture.x, paddle.center.y)
        dynamicAnimator.updateItemUsingCurrentState(paddle)
    }
    
    
    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, atPoint p: CGPoint) {
        if(item.isEqual(ball) && p.y > paddle.center.y){
            lives--
            livesLabel.text = "Lives: " + String(lives)
            if(lives > 0){
                ball.center = view.center
                dynamicAnimator.updateItemUsingCurrentState(ball)
            }
            else{
                ball.removeFromSuperview()
                let alert = UIAlertController(title: "Game Over", message: "You ran out of lives!", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Play Again", style: UIAlertActionStyle.Default, handler: {void in
                    self.dynamicAnimator.removeAllBehaviors()
                    self.viewDidLoad()
                }))
                
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item1: UIDynamicItem, withItem item2: UIDynamicItem, atPoint p: CGPoint) {
        for brick in brickArray{
        if((item1.isEqual(ball) && item2.isEqual(brick)) || (item1.isEqual(brick) && item2.isEqual(ball))){
            if(brick.backgroundColor == UIColor.blueColor()){
                brick.backgroundColor = UIColor.orangeColor()
            }
            else if(brick.backgroundColor == UIColor.orangeColor()){
                brick.backgroundColor = UIColor.greenColor()
            }
            else if(brick.backgroundColor == UIColor.greenColor()){
                //brick.hidden = true
                collisionBehavior.removeItem(brick)
                //livesLabl.text = "win"
                //ball.removeFromSuperview()
                dynamicAnimator.updateItemUsingCurrentState(ball)
            }
        }
    }
    
    }
    
    func setupBricks(){
        var type:Int = 1
        for(var i = 4; i > 0; i--){
            for(var j = 1; j <= 9; j++){
                let xCoord:CGFloat = CGFloat(42*j)
                let yCoord:CGFloat = CGFloat(25*type)
                brick = UIView(frame: CGRectMake(xCoord, yCoord, 40, 20))
                if(type == 1){
                    brick.backgroundColor = UIColor.blueColor()
                }
                else if(type == 2){
                    brick.backgroundColor = UIColor.orangeColor()
                }
                else{
                    brick.backgroundColor = UIColor.greenColor()
                }
                brickArray.append(brick)
                allArray.append(brick)
                view.addSubview(brick)
            }
            type++
        }
    }
}

