//
//  DrawView.swift
//  assignment4
//
//  Created by Farhoud Talebi on 2019-03-30.
//  Copyright © 2019 COMP1601-Farhoud. All rights reserved.
//

//**All coordinates and numbers are in real world numbers (velocity, position, etc.) and only translated to pixels/onscreen coordinates (using "pxlRatio" variable) when printing**//

let gravity = -9.81 as CGFloat;

import UIKit

class DrawView: UIView {
    var timer: Timer?;
    var timerIsRunning = false;
    var currentLine: Line?;
    var currentCircle: Circle?;
    var pathPoints = [CGPoint]();
    var theoreticalPoints = [CGPoint]();
    var pathPoint: CGPoint?;
    var pxlRatio: CGFloat?;
    
    var initialized = false;
    var launched = false;
    
    
    @IBInspectable var gGridLineColor: UIColor = UIColor.gray {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable var bGridLineColor: UIColor = UIColor.blue {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable var gGridlineThickness: CGFloat = 1 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var bGridlineThickness: CGFloat = 2 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var currentLineColor: UIColor = UIColor.red {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable var lineThickness: CGFloat = 6 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var currentCircleColor: UIColor = UIColor.red {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var pathPointColor: UIColor = UIColor.black {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var apexPointColor: UIColor = UIColor.blue {
        didSet {
            setNeedsDisplay()
        }
    }
    
    
    func runTimer() {
        if timer != nil {return}
        timer = Timer.scheduledTimer(timeInterval: 0.01, //means 0.01 sec interval
            target: self,
            selector: (#selector(DrawView.updateTimer)),
            userInfo: nil,
            repeats: true)
        timerIsRunning = true
    }
    

    @objc func updateTimer(){
        if(launched) {
            if (currentCircle!.centre.y < 0) { return } //Stops simulation of ball once it lands
            currentCircle?.advanceInArea(area: self.frame) //Eulers simulation
        }
        setNeedsDisplay();
    }
    

    
    //Velocity line
    func strokeLine(line: Line){
        //Use BezierPath to draw lines
        let path = UIBezierPath();
        path.lineWidth = CGFloat(lineThickness);
        path.lineCapStyle = CGLineCap.round;
        
        path.move(to: line.begin);
        path.addLine(to: line.end);
        path.stroke(); //actually draw the path
    }
    
    //Grey grid line (20 meter interval)
    func strokeGLine(line: Line){
        //Use BezierPath to draw lines
        let path = UIBezierPath();
        path.lineWidth = CGFloat(gGridlineThickness);
        path.lineCapStyle = CGLineCap.round;
        
        path.move(to: line.begin);
        path.addLine(to: line.end);
        path.stroke(); //actually draw the path
    }
    
    //Blue grid line (100 meter interval)
    func strokeBLine(line: Line){
        //Use BezierPath to draw lines
        let path = UIBezierPath();
        path.lineWidth = CGFloat(bGridlineThickness);
        path.lineCapStyle = CGLineCap.round;
        
        path.move(to: line.begin);
        path.addLine(to: line.end);
        path.stroke(); //actually draw the path
    }
    
    //Draw the circle
    func strokeCircle(circle: Circle){
        //Use BezierPath to draw circle
        //Add its current coordinates to the array of points representing its path
        pathPoint = CGPoint(x: (circle.centre.x - circle.radius), y: (circle.centre.y + circle.radius));
        pathPoints.append(pathPoint!);
        
        let path = UIBezierPath(ovalIn: CGRect(x: (circle.centre.x - circle.radius)*pxlRatio!, y: (self.frame.height-((circle.centre.y + circle.radius)*pxlRatio!)), width: (circle.radius*pxlRatio!)*2, height: circle.radius*pxlRatio!*2))
        path.lineWidth = 10;
        path.fill()
        path.stroke(); //actually draw the path
    }
    
    //Draw the theoretical apex and ground, along with the points representing the path of the ball
    func strokePoint(point: CGPoint){
        let path = UIBezierPath(ovalIn: CGRect(x: point.x*(pxlRatio!), y: self.frame.height-(point.y*(pxlRatio!)), width: 4, height: 4));
        path.lineWidth = 5;
        path.fill();
        path.stroke();
    }

    //Empty strings which will be filled to print the dragged velocity and angle
    var angleWrite = "N" as NSString
    var velocityWrite = "N" as NSString
    var angleLine: Line?;
    
    override func draw(_ rect: CGRect) {
        
        // set the text color to dark gray
        let fieldColor: UIColor = UIColor.darkGray
        
        // set the font to Helvetica Neue 18
        let fieldFont = UIFont(name: "Helvetica Neue", size: 18)
        
        // set the line spacing to 6
        let paraStyle = NSMutableParagraphStyle()
        paraStyle.lineSpacing = 6.0
        
        // set the Obliqueness to 0.1
        let skew = 0.1
        
        //For grid 200 meter interval text
        let attributes: NSDictionary = [
            NSAttributedString.Key.foregroundColor: fieldColor,
            NSAttributedString.Key.paragraphStyle: paraStyle,
            NSAttributedString.Key.obliqueness: skew,
            NSAttributedString.Key.font: fieldFont!
        ]
        
        //For velocity and angle text
        let fieldFont2 = UIFont(name: "Helvetica Neue", size: 13.5)
        
        let attributes2: NSDictionary = [
            NSAttributedString.Key.foregroundColor: fieldColor,
            NSAttributedString.Key.paragraphStyle: paraStyle,
            NSAttributedString.Key.obliqueness: skew,
            NSAttributedString.Key.font: fieldFont2!
        ]
        
        //If currently dragging, aka mouse begin event
        if (initialized) {
            //Clear the points from previous flight
            pathPoints.removeAll();
            theoreticalPoints.removeAll();
            
            if let line = currentLine {
                currentLineColor.setStroke(); //current line in red
                strokeLine(line: line);
            }
            
            //Depending on direction of dragged line/velocity, move text
            let xOffset: CGFloat
            if ((currentLine?.end.x.isLess(than: (currentLine?.begin.x)!))!) {
                xOffset = 33;
            } else {
                xOffset = -72;
            }
            
            //Draw the angle and velocity numbers on screen, used grid intervals to visually decide how big the text should be
            angleWrite.draw(in: CGRect(x: currentLine!.end.x + xOffset, y: ((currentLine?.end.y)! - 22), width: self.frame.height/50*10, height: self.frame.height/50*2.2), withAttributes: attributes2 as? [NSAttributedString.Key : Any])
            
            let xDistance = (currentLine!.end.x + currentLine!.begin.x)/2;
            let yDistance = (currentLine!.end.y + currentLine!.begin.y)/2;
            velocityWrite.draw(in: CGRect(x: xDistance, y: yDistance, width: self.frame.height/50*9, height: self.frame.height/50*2.5), withAttributes: attributes2 as? [NSAttributedString.Key : Any])
            
            if let line = angleLine {
                currentLineColor.setStroke(); //current line in red
                strokeLine(line: line);
            }
        }
        
        //Check orientation of phone in order to accurately draw the grid
        if(rect.height > rect.width) {
            pxlRatio = self.frame.height/1000;
            let grayLineInterval = self.frame.height/50;
            gGridLineColor.setStroke(); //current line in red
            for i in stride(from: 0, to: self.frame.height, by: grayLineInterval) {
                let drawLine = Line(begin: CGPoint(x:0,y:i), end: CGPoint(x:self.frame.width,y:i));
                strokeGLine(line: drawLine)
            }
            
            for i in stride(from: 0, to: self.frame.width, by: grayLineInterval) {
                let drawLine = Line(begin: CGPoint(x:i,y:0), end: CGPoint(x:i,y:self.frame.height));
                strokeGLine(line: drawLine)
            }
            
            
            let blueLineInterval = self.frame.height/10;
            bGridLineColor.setStroke();
            
            for i in stride(from: 0, to: self.frame.height, by: blueLineInterval) {
                let drawLine = Line(begin: CGPoint(x:0,y:i), end: CGPoint(x:self.frame.width, y:i));
                strokeBLine(line: drawLine)
            }
            
            var hundreds = 0;
            for i in stride(from:0, to: self.frame.width, by: blueLineInterval) {
                let drawLine = Line(begin: CGPoint(x:i, y:0), end: CGPoint(x:i, y:self.frame.height));
                strokeBLine(line: drawLine)
                if(hundreds%200 == 0) {
                    let s: NSString = "\(hundreds)" as NSString
                    s.draw(in: CGRect(x: i-(grayLineInterval*1.2), y: self.frame.height-30, width: grayLineInterval*3, height: grayLineInterval*1.5), withAttributes: attributes as? [NSAttributedString.Key : Any])
                }
                hundreds += 100
            }
        } else if (rect.width > rect.height) {
            pxlRatio = self.frame.width/1000;
            let grayLineInterval = self.frame.width/50;
            gGridLineColor.setStroke(); //current line in red
            for i in stride(from: self.frame.height, to: 0, by: -grayLineInterval) {
                let drawLine = Line(begin: CGPoint(x:0,y:i), end: CGPoint(x:self.frame.width,y:i));
                strokeGLine(line: drawLine)
            }
            
            for i in stride(from: 0, to: self.frame.width, by: grayLineInterval) {
                let drawLine = Line(begin: CGPoint(x:i,y:0), end: CGPoint(x:i,y:self.frame.height));
                strokeGLine(line: drawLine)
            }
            
            
            let blueLineInterval = self.frame.width/10;
            bGridLineColor.setStroke();
            
            for i in stride(from: self.frame.height, to: 0, by: -blueLineInterval) {
                let drawLine = Line(begin: CGPoint(x:0,y:i), end: CGPoint(x:self.frame.width, y:i));
                strokeBLine(line: drawLine)
            }
            
            var hundreds = 0;
            for i in stride(from:0, to: self.frame.width, by: blueLineInterval) {
                let drawLine = Line(begin: CGPoint(x:i, y:0), end: CGPoint(x:i, y:self.frame.height));
                strokeBLine(line: drawLine)
                if(hundreds%200 == 0) {
                    let s: NSString = "\(hundreds)" as NSString
                    s.draw(in: CGRect(x: i-(grayLineInterval*1.2), y: self.frame.height-30, width: grayLineInterval*3, height: grayLineInterval*1.5), withAttributes: attributes as? [NSAttributedString.Key : Any])
                    
                }
                hundreds += 100;
            }
        }
        
      
        
        //If the ball is released/launched, aka touch end event
        if(launched) {
            if timer == nil {runTimer()}
            
            //Points representing path of ball
            for pt in pathPoints{
                pathPointColor.setStroke();
                strokePoint(point: pt);
            }
            
            //Theoretical apex and ground
            for pt in theoreticalPoints{
                apexPointColor.setStroke();
                strokePoint(point: pt);
            }
        }
        
        //Draw circle
        if let circle = currentCircle {
            currentCircleColor.setStroke();
            strokeCircle(circle: circle);
        }
    }
    
    
    
    var locationBegin = CGPoint()
    var touched = false;
    var realLifeStarting = CGPoint()
    var horizontalVelocity: Double?
    var verticalVelocity: Double?
    
    //Override Touch Functions
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!; //get first touch event and unwrap optional
        let location = touch.location(in: self); //get location in view co-ordinate
        launched = false;
        initialized = true;
        currentCircle = Circle(centre: CGPoint(x:location.x/pxlRatio!,y:(self.frame.height-location.y)/pxlRatio!), radius: 15, velocity: CGPoint(x: 0, y: 0));
        realLifeStarting.x = location.x/pxlRatio!;
        realLifeStarting.y = (self.frame.height-location.y)/pxlRatio!;

        locationBegin = location;
        touched = true;
        currentLine = Line(begin:locationBegin, end: locationBegin)
        angleLine = Line(begin: locationBegin, end: locationBegin)
        setNeedsDisplay(); //this view needs to be updated
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!;
        let location = touch.location(in: self);
        currentLine?.end = location;
        angleLine?.begin.y = location.y;
        angleLine?.end = CGPoint(x: location.x, y: location.y);
        let realX = location.x/pxlRatio!;
        let realY = (self.frame.height-location.y)/pxlRatio!;
        let hypoteneuse = currentCircle?.distanceToPoint(point: CGPoint(x: realX, y: realY));
        let realLifeMoving = CGPoint(x: realX, y: realY);
        var launchAngle = acos(Double(abs(realLifeMoving.x-realLifeStarting.x)/hypoteneuse!)) * 180/Double.pi;
        //Quick rounding of degree
        launchAngle *= 10;
        launchAngle.round();
        launchAngle /= 10;
        let angleInRadians = launchAngle*Double.pi/180;
        var draggedVelocity = hypoteneuse!/6; //Arbitrary division of hypoteneuse to make an appealing corresponding velocity
        draggedVelocity *= 10; //Rounding to 2 digits
        draggedVelocity.round();
        draggedVelocity /= 10;
        //Filling the strings here to print on screen
        angleWrite = "\(launchAngle) deg" as NSString;
        velocityWrite = "\(draggedVelocity) m/s" as NSString;
        
        //Calculate initial  velocity components
        verticalVelocity = Double(draggedVelocity) * sin(angleInRadians)
        horizontalVelocity = Double(draggedVelocity) * cos(angleInRadians)
        currentCircle?.velocity = CGPoint(x: horizontalVelocity!, y: verticalVelocity!);
        
        setNeedsDisplay();
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!;
        let location = touch.location(in: self);
        
        //**Theoretical calculations of apex and ground:**
        
        //Time it takes to get to the highest point of its flight (apex)
        let timeToHighest = -(verticalVelocity!/Double(gravity))
       
        ///heightAbove represents the distance between the initial height and the highest point of the projectile
        let heightAbove = verticalVelocity! * (timeToHighest) + (Double(gravity) * (timeToHighest*timeToHighest)/2)
        
        ///highestPoint represents the distance between the ground and the highest point of the projectile
        let highestPoint = heightAbove + Double((self.frame.height-locationBegin.y)/pxlRatio!);

        //Horizontal point of apex of flight
        let highestPointX = Double((currentCircle?.velocity.x)!)*timeToHighest + Double(locationBegin.x/pxlRatio!);
        
        //Add apex of flight to print to screen later
        theoreticalPoints.append(CGPoint(x: highestPointX-Double((currentCircle?.radius)!), y: highestPoint+Double((currentCircle?.radius)!)));

        //Flight time from launch to ground
        let timeToGround = abs(highestPoint*2/Double(gravity)).squareRoot() + timeToHighest;
        //Horizontal coordinate where ball lands on the ground
        let lowestPointX = Double((currentCircle?.velocity.x)!)*timeToGround + Double(locationBegin.x/pxlRatio!);
        let tempRadius = Double((currentCircle?.radius)!);
        theoreticalPoints.append(CGPoint(x: lowestPointX-tempRadius, y: tempRadius));
        initialized = false;
        currentLine?.end = location;
        launched = true;
        
        setNeedsDisplay();
    }
    
}
