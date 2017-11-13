//
//  DemoOneViewController.swift
//  SwiftyOnboardVC
//
//  Created by luke on 27/07/2017.
//  Copyright © 2017 Luke Chase. All rights reserved.
//
// Demo of a walkthough without a navigation bar

import UIKit

class DemoOneViewController: UIViewController, SwiftyOnboardVCDelegate {

    let walkthough = SwiftyOnboardVC()
    
    @IBAction func showWalkthough(_ sender: Any) {
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
            walkthough.leftButtonBackgroundColor = .purple
            walkthough.leftButtonTextColor = .green
            walkthough.leftButtonCornerRadius = 5
            walkthough.leftButtonWidthPadding = 20
            walkthough.leftButtonHeightPadding = 10
            
            walkthough.moveLeftButtonOnScreen()
            //right button
            walkthough.rightButtonText = "Sign in"
            walkthough.rightButtonBackgroundColor = .black
            walkthough.rightButtonTextColor = .white
            walkthough.rightButtonCornerRadius = 10
            walkthough.rightButtonWidthPadding = 10
            walkthough.rightButtonHeightPadding = 20
            self.present(walkthough, animated: true, completion: nil)
        }
    }
    
    @IBAction func pageControlSwitch(_ sender: UISwitch) {
        walkthough.showPageControl = sender.isOn
    }
    
    @IBAction func leftButtonSwitch(_ sender: UISwitch) {
        walkthough.showLeftButton = sender.isOn
    }
    
    @IBAction func rightButtonSwitch(_ sender: UISwitch) {
        walkthough.showRightButton = sender.isOn
    }
    
    @IBAction func statusBarSwitch(_ sender: UISwitch) {
        walkthough.hideStatusBar = sender.isOn
    }
    
    func leftButtonPressed() {
        walkthough.previousPage()
    }
    
    func rightButtonPressed() {
        walkthough.nextPage()
    }
    
    func pageDidChange(currentPage: Int) {
        let alert = UIAlertController(title: "Current Page", message: "Current Page Number: \(currentPage)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Thanks", style: .default, handler: nil))
        self.presentedViewController?.present(alert, animated: true, completion: nil)
    }
}
