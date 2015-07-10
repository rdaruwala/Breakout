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
    var firstTime = true
    
    var brickArray:[UIView] = []
    var allArray:[UIView] = []
    
    var ballDynamicBehavior:UIDynamicItemBehavior!
    var paddleDynamicBehavior:UIDynamicItemBehavior!
    var pushBehavior:UIPushBehavior!
    var brickDynamicBehavior:UIDynamicItemBehavior!
    
    
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
        
        ballDynamicBehavior = UIDynamicItemBehavior(items: [ball])
        ballDynamicBehavior.friction = 0
        ballDynamicBehavior.resistance = 0
        ballDynamicBehavior.elasticity = 1.0
        ballDynamicBehavior.allowsRotation = false
        dynamicAnimator.addBehavior(ballDynamicBehavior)
        
        paddleDynamicBehavior = UIDynamicItemBehavior(items: [paddle])
        paddleDynamicBehavior.density = 1000
        paddleDynamicBehavior.resistance = 100
        paddleDynamicBehavior.allowsRotation = false
        dynamicAnimator.addBehavior(paddleDynamicBehavior)
        
        allArray.append(ball)
        allArray.append(paddle)
        
        pushBehavior = UIPushBehavior(items: [ball], mode: UIPushBehaviorMode.Instantaneous)
        pushBehavior.pushDirection = CGVectorMake(0.2, 1.0)
        pushBehavior.magnitude = 0.25
        dynamicAnimator.addBehavior(pushBehavior)
        
        collisionBehavior = UICollisionBehavior(items: allArray)
        collisionBehavior.translatesReferenceBoundsIntoBoundary = true
        collisionBehavior.collisionMode = .Everything
        collisionBehavior.collisionDelegate = self
        dynamicAnimator.addBehavior(collisionBehavior)
        
        brickDynamicBehavior = UIDynamicItemBehavior(items: brickArray)
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
                ball.center = CGPointMake(100000, -10000)
                paddle.center = CGPointMake(-10000, -100000)
                ball.removeFromSuperview()
                dynamicAnimator.removeBehavior(ballDynamicBehavior)
                let alert = UIAlertController(title: "Game Over", message: "You ran out of lives!", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Play Again", style: UIAlertActionStyle.Default, handler: {void in
                    self.dynamicAnimator.removeAllBehaviors()
                    self.resetBoard()
                }))
                
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item1: UIDynamicItem, withItem item2: UIDynamicItem, atPoint p: CGPoint) {
        for(var i = 0; i < brickArray.count; i++){
            if((item1.isEqual(ball) && item2.isEqual(brickArray[i])) || (item1.isEqual(brickArray[i]) && item2.isEqual(ball))){
                if(brickArray[i].backgroundColor == UIColor.blueColor()){
                    brickArray[i].backgroundColor = UIColor.orangeColor()
                }
                else if(brickArray[i].backgroundColor == UIColor.orangeColor()){
                    brickArray[i].backgroundColor = UIColor.greenColor()
                }
                else if(brickArray[i].backgroundColor == UIColor.greenColor()){
                    brickArray[i].center = CGPointMake(-100000, -100000)
                    brickArray[i].hidden = true
                    collisionBehavior.removeItem(brickArray[i])
                    dynamicAnimator.updateItemUsingCurrentState(brickArray[i])
                    brickArray[i].removeFromSuperview()
                    //livesLabl.text = "win"
                    //ball.removeFromSuperview()
                    dynamicAnimator.updateItemUsingCurrentState(ball)
                    brickArray.removeAtIndex(i)
                    if(brickArray.count == 0){
                        ball.center = CGPointMake(100000, -10000)
                        paddle.center = CGPointMake(-10000, -100000)
                        dynamicAnimator.removeBehavior(ballDynamicBehavior)
                        ball.removeFromSuperview()
                        let alert = UIAlertController(title: "You win!", message: "You won the game!", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "Play Again", style: UIAlertActionStyle.Default, handler: {void in
                            self.dynamicAnimator.removeAllBehaviors()
                            self.resetBoard()
                        }))
                        
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                }
            }
        }
        
    }
    
    func setupBricks(){
        var type:Int = 1
        for(var i = 4; i > 0; i--){
            for(var j = 1; j <= 9; j++){
                let xCoord:CGFloat = CGFloat(42*(j-1))
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
                if(firstTime){
                    allArray.append(brick)
                }
                view.addSubview(brick)
            }
            type++
        }
    }
    
    /*func resetBoard(){
        dynamicAnimator.removeBehavior(ballDynamicBehavior)
        
        lives = 5
        livesLabel.text = "Lives: " + String(lives)
        setupBricks()
        
        ball = UIView(frame: CGRectMake(view.center.x, view.center.y, 20, 20))
        ball.backgroundColor = UIColor.blackColor()
        ball.layer.cornerRadius = 10
        ball.clipsToBounds = true
        view.addSubview(ball)
        
        paddle.center = CGPointMake(view.center.x, view.center.y*1.7)
        
        ballDynamicBehavior = UIDynamicItemBehavior(items: [ball])
        ballDynamicBehavior.friction = 0
        ballDynamicBehavior.resistance = 0
        ballDynamicBehavior.elasticity = 1.0
        ballDynamicBehavior.allowsRotation = false
        dynamicAnimator.addBehavior(ballDynamicBehavior)
        
        let pushBehavior = UIPushBehavior(items: [ball], mode: UIPushBehaviorMode.Instantaneous)
        pushBehavior.pushDirection = CGVectorMake(0.2, 1.0)
        pushBehavior.magnitude = 0.25
        dynamicAnimator.addBehavior(pushBehavior)
        
    }*/
    
    func resetBoard(){
        lives = 5
        
        for box in brickArray{
            box.center = CGPointMake(-100101, 42342)
            box.removeFromSuperview()
        }
        
        for box in allArray{
            box.center = CGPointMake(-100101, 42342)
            box.removeFromSuperview()
        }
        
        brickArray.removeAll()
        
        allArray.removeAll()
        
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
        
        ballDynamicBehavior = UIDynamicItemBehavior(items: [ball])
        ballDynamicBehavior.friction = 0
        ballDynamicBehavior.resistance = 0
        ballDynamicBehavior.elasticity = 1.0
        ballDynamicBehavior.allowsRotation = false
        dynamicAnimator.addBehavior(ballDynamicBehavior)
        
        paddleDynamicBehavior = UIDynamicItemBehavior(items: [paddle])
        paddleDynamicBehavior.density = 1000
        paddleDynamicBehavior.resistance = 100
        paddleDynamicBehavior.allowsRotation = false
        dynamicAnimator.addBehavior(paddleDynamicBehavior)
        
        allArray.append(ball)
        allArray.append(paddle)
        
        pushBehavior = UIPushBehavior(items: [ball], mode: UIPushBehaviorMode.Instantaneous)
        pushBehavior.pushDirection = CGVectorMake(0.2, 1.0)
        pushBehavior.magnitude = 0.25
        dynamicAnimator.addBehavior(pushBehavior)
        
        collisionBehavior = UICollisionBehavior(items: allArray)
        collisionBehavior.translatesReferenceBoundsIntoBoundary = true
        collisionBehavior.collisionMode = .Everything
        collisionBehavior.collisionDelegate = self
        dynamicAnimator.addBehavior(collisionBehavior)
        
        brickDynamicBehavior = UIDynamicItemBehavior(items: brickArray)
        brickDynamicBehavior.density = 10000
        brickDynamicBehavior.resistance = 100
        brickDynamicBehavior.allowsRotation = false
        dynamicAnimator.addBehavior(brickDynamicBehavior)
        
        
        livesLabel.text = "Lives: " + String(lives)
    }
    
    
}