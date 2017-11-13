//
//  ViewController.swift
//  Intro
//
//  Created by Toan Phan on 11/10/17.
//  Copyright © 2017 Toan Phan. All rights reserved.
//

import UIKit

class ViewController: UIViewController , SwiftyOnboardVCDelegate{

    let walkthough = SwiftyOnboardVC()
    
    @IBAction func showWalkthough() {
        if let storyboard = self.storyboard {
            let viewOne = storyboard.instantiateViewController(withIdentifier: "intro1")
            let viewTwo = storyboard.instantiateViewController(withIdentifier: "intro2")
            let viewThree = storyboard.instantiateViewController(withIdentifier: "intro3")
            walkthough.viewControllers = [viewOne, viewTwo, viewThree]
            walkthough.delegate = self
            //ScrollView
            walkthough.bounces = false
            walkthough.showHorizontalScrollIndicator = true
            //Left button
            walkthough.leftButtonText = "Sign up"
            walkthough.leftButtonBackgroundColor = .gray
            walkthough.leftButtonTextColor = .white
            walkthough.leftButtonCornerRadius = 0
            walkthough.leftButtonWidthPadding = 10
            walkthough.leftButtonHeightPadding = 20
            
            walkthough.moveLeftButtonOnScreen()
            //right button
            walkthough.rightButtonText = "Sign in"
            walkthough.rightButtonBackgroundColor = .gray
            walkthough.rightButtonTextColor = .white
            walkthough.rightButtonCornerRadius = 0
            walkthough.rightButtonWidthPadding = 10
            walkthough.rightButtonHeightPadding = 20
            self.present(walkthough, animated: true, completion: nil)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        showWalkthough()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func leftButtonPressed() {
        // Sign up button click
        print("Sign up button click")
    }
    
    func rightButtonPressed() {
        // Sign in button click
        print("Sign in button click")
    }
    
    func bottomButtonPressed(){
        // Skip button click
        print("Skip button click")
    }


}

