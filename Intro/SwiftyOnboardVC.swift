//MIT License
//
//Copyright (c) 2017 Luke Chase
//
//Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
//documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
//rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit
//persons to whom the Software is furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all copies or substantial portions of the
//Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
//WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
//OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
//  SwiftyOnboardVC.swift
//  SwiftyOnboardVC
//
//  Created by luke on 26/07/2017.
//  Copyright © 2017 Luke Chase. All rights reserved. olala
//

import UIKit

@objc public protocol SwiftyOnboardVCDelegate: class {
    @objc optional func leftButtonPressed()
    @objc optional func rightButtonPressed()
    @objc optional func bottomButtonPressed()
    @objc optional func pageDidChange(currentPage: Int)
}

@objc open class SwiftyOnboardVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    //MARK: Public variables
    
    //Delegate
    open weak var delegate: SwiftyOnboardVCDelegate?
    
    //View controllers array
    public var viewControllers: [UIViewController]  = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    //Collection view settings
    public var backgroundColor: UIColor = .white
    public var bounces: Bool = true
    public var showHorizontalScrollIndicator = false
    
    //Page control settings
    public var showPageControl = true
    public var pageControlTintColor: UIColor = .lightGray
    public var currentPageControlTintColor: UIColor = .black
    public var pageControlBottomMargin: CGFloat = 50
    
    //Left button settings
    public var showLeftButton: Bool = true
    public var leftButtonText: String = "Previous"
    public var leftButtonTextColor: UIColor = .black
    public var leftButtonBackgroundColor: UIColor = .orange
    public var leftButtonCornerRadius: CGFloat = 0
    public var leftButtonHeightPadding: CGFloat = 0
    public var leftButtonWidthPadding: CGFloat = 0
    
    //Right button settings
    public var showRightButton: Bool = true
    public var rightButtonText: String = "Next"
    public var rightButtonTextColor: UIColor = .black
    public var rightButtonBackgroundColor: UIColor = .orange
    public var rightButtonCornerRadius: CGFloat = 0
    public var rightButtonHeightPadding: CGFloat = 0
    public var rightButtonWidthPadding: CGFloat = 0
    
    //Bottom button settings
    public var showBottomButton: Bool = true
    public var bottomButtonText: String = "Skip"
    public var bottomButtonTextColor: UIColor = .black
    public var bottomButtonBackgroundColor: UIColor = .clear
    public var bottomButtonCornerRadius: CGFloat = 0
    public var bottomButtonHeightPadding: CGFloat = 0
    public var bottomButtonWidthPadding: CGFloat = 0
    public var bottomButtonBottomMargin: CGFloat = 32
    public var bottomButtonHeight: CGFloat = 20
    public var bottomButtonFont: UIFont = UIFont.systemFont(ofSize: UIFont.systemFontSize)
    public var bottomButtonImage: UIImage = UIImage()
    public var bottomButtonImagePosition: ButtonImagePosition = .left
    
    //Button top margin
    public var buttonTopMargin: CGFloat = 5
    
    //Status bar
    public var hideStatusBar: Bool = false
    
    //MARK: Private variables
    private let navigationBar: UINavigationBar = UINavigationBar()
    private var buttonTopConstant: CGFloat = 5
    private var leftButtonTopConstriant: NSLayoutConstraint?
    private var rightButtonTopConstriant: NSLayoutConstraint?
    private var bottomButtonBottomConstriant: NSLayoutConstraint?
    private var pageControlBottomConstriant: NSLayoutConstraint?
    private let pageControl: UIPageControl = {
        let p = UIPageControl()
        p.translatesAutoresizingMaskIntoConstraints = false
        return p
    }()
    private lazy var leftButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(leftButtonPressed), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private lazy var rightButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(rightButtonPressed), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private lazy var bottomButton: UIButton = {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(bottomButtonPressed), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.isPagingEnabled = true
        cv.delegate = self
        cv.dataSource = self
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = .zero
        layout.footerReferenceSize = .zero
        layout.headerReferenceSize = .zero
        return cv
    }()
    
    //MARK: Set up status bar
    override open var prefersStatusBarHidden: Bool {
        return hideStatusBar
    }
    
    //MARK: initializers
    convenience public init(viewControllers: [UIViewController]) {
        self.init(nibName: nil, bundle: nil)
        self.viewControllers = viewControllers
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //MARK: View controller override
    override open func viewDidLoad() {
        super.viewDidLoad()
        
//        self.automaticallyAdjustsScrollViewInsets = false
        collectionView.collectionViewLayout.invalidateLayout()
        
        //Register cell
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        
        //Set the collection view constants and add to view
        self.view.addSubview(collectionView)
        collectionView.anchorToTop(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
        
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Remove the controls from the superview so we can reset there settings
        pageControl.removeFromSuperview()
        leftButton.removeFromSuperview()
        rightButton.removeFromSuperview()
        bottomButton.removeFromSuperview()
    
        //Check if we have a navigation bar and status bar
        if let navBar = self.navigationController?.navigationBar {
            if(navBar.isHidden) {
                if UIApplication.shared.isStatusBarHidden {
                    buttonTopConstant = buttonTopMargin
                } else {
                    buttonTopConstant = UIApplication.shared.statusBarFrame.height + buttonTopMargin
                }
            } else {
                if !UIApplication.shared.isStatusBarHidden {
                    self.edgesForExtendedLayout = []
                }
                buttonTopConstant = buttonTopMargin
            }
        } else {
            if UIApplication.shared.isStatusBarHidden {
                buttonTopConstant = buttonTopMargin
            } else {
                buttonTopConstant = UIApplication.shared.statusBarFrame.height + buttonTopMargin
            }
        }
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
        
        //Set the collection view settings
        collectionView.backgroundColor = backgroundColor
        collectionView.bounces = bounces
        collectionView.showsHorizontalScrollIndicator = showHorizontalScrollIndicator
        
        //Set the page control settings
        pageControl.numberOfPages = viewControllers.count
        pageControl.pageIndicatorTintColor = pageControlTintColor
        pageControl.currentPageIndicatorTintColor = currentPageControlTintColor
        //Check to see if we should show the page control
        if showPageControl {
            //Add the page control and constriants
            self.view.addSubview(pageControl)
            pageControlBottomConstriant = pageControl.anchor(nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: pageControlBottomMargin, rightConstant: 0, widthConstant: 0, heightConstant: 40)[1]
        }
        
        //Set the left button settings
        leftButton.setTitle(leftButtonText, for: .normal)
        leftButton.setTitleColor(leftButtonTextColor, for: .normal)
        leftButton.layer.backgroundColor = leftButtonBackgroundColor.cgColor
        leftButton.layer.cornerRadius = leftButtonCornerRadius
        leftButton.contentEdgeInsets = UIEdgeInsetsMake(leftButtonHeightPadding, leftButtonWidthPadding, leftButtonHeightPadding, leftButtonWidthPadding)
        //Check to see if we should show the left button
        if showLeftButton {
            //Add the left button and constriants
            self.view.addSubview(leftButton)
            leftButtonTopConstriant = leftButton.anchor(nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: nil, topConstant: buttonTopConstant, leftConstant: 5, bottomConstant: 0, rightConstant: 0, widthConstant: view.frame.width/2-10, heightConstant: leftButton.frame.height).first
        }
        
        //Set the right button settings
        rightButton.setTitle(rightButtonText, for: .normal)
        rightButton.setTitleColor(rightButtonTextColor, for: .normal)
        rightButton.layer.backgroundColor = rightButtonBackgroundColor.cgColor
        rightButton.layer.cornerRadius = rightButtonCornerRadius
        rightButton.contentEdgeInsets = UIEdgeInsetsMake(rightButtonHeightPadding, rightButtonWidthPadding, rightButtonHeightPadding, rightButtonWidthPadding)
        //Check to see if we should show the right button
        if showRightButton {
            //Add the right button and constriants
            self.view.addSubview(rightButton)
            rightButtonTopConstriant = rightButton.anchor(nil, left: nil, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: buttonTopConstant, leftConstant: 0, bottomConstant: 0, rightConstant: 5, widthConstant:  view.frame.width/2-10, heightConstant: rightButton.frame.height).first
        }
        
        //Set the bottom button settings
        bottomButton.setTitle(bottomButtonText, for: .normal)
        bottomButton.setTitleColor(bottomButtonTextColor, for: .normal)
        bottomButton.titleLabel?.font = bottomButtonFont
        bottomButton.layer.backgroundColor = bottomButtonBackgroundColor.cgColor
        bottomButton.layer.cornerRadius = bottomButtonCornerRadius
        bottomButton.contentEdgeInsets = UIEdgeInsetsMake(bottomButtonHeightPadding, bottomButtonWidthPadding, bottomButtonHeightPadding, bottomButtonWidthPadding)
        bottomButton.setImage(bottomButtonImage, for: .normal)
        if bottomButtonImagePosition == .right {
            //This is a hack to put the button image on the right
            bottomButton.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            bottomButton.titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            bottomButton.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        }
        
        //Check to see if we should show the bottom button
        if showBottomButton {
            //Add the bottom button and constriants
            self.view.addSubview(bottomButton)
            bottomButtonBottomConstriant = bottomButton.anchor(view.topAnchor, left: nil
                , bottom: nil, right: view.rightAnchor, topConstant: 50, leftConstant: 0, bottomConstant: bottomButtonBottomMargin, rightConstant: 20, widthConstant: 0, heightConstant: bottomButtonHeight)[1]
        }
        
        //Check if we have view controllers
        if(viewControllers.count == 0) {
            print("Warning: Please set the viewControllers array.")
        } else {
            //Set the collection view and page control to be at the start
            pageControl.currentPage = 0
            collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredHorizontally, animated: false)
        }
    }
    
    //MARK: Handle device rotation
    
    override open func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation.isLandscape {
            if UIApplication.shared.isStatusBarHidden {
                leftButtonTopConstriant?.constant = buttonTopMargin
                rightButtonTopConstriant?.constant = buttonTopMargin
            }
        } else {
            leftButtonTopConstriant?.constant = buttonTopConstant
            rightButtonTopConstriant?.constant = buttonTopConstant
        }
     
        collectionView.collectionViewLayout.invalidateLayout()
        let indexPath = IndexPath(item: pageControl.currentPage, section: 0)
            
        //scroll to indexPath after the rotation is going
        DispatchQueue.main.async {
            self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
            self.collectionView.reloadData()
        }
    }
    
    //MARK: Collection view datasource
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewControllers.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        display(contentController: viewControllers[indexPath.row], on: cell.contentView)
        return cell
    }
    
    //MARK: Collection view scrollview delegate
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let pageNumber = Int(targetContentOffset.pointee.x / self.view.frame.width)
        pageControl.currentPage = pageNumber
        delegate?.pageDidChange?(currentPage: pageNumber + 1)
    }
    
    //MARK: Collection view flow layout
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height)
    }
    
    //MARK: Custom functions
    private func display(contentController content: UIViewController, on view: UIView) {
        self.addChildViewController(content)
        content.view.frame = view.bounds
        view.addSubview(content.view)
        content.didMove(toParentViewController: self)
    }
    
    @objc private func leftButtonPressed() {
        delegate?.leftButtonPressed?()
    }
    
    @objc private func rightButtonPressed() {
        delegate?.rightButtonPressed?()
    }
    
    @objc private func bottomButtonPressed() {
        delegate?.bottomButtonPressed?()
    }
    
    public func nextPage() {
        //Check if we are on the last page
        if pageControl.currentPage == viewControllers.count - 1 {
            return
        }
        
        let indexPath = IndexPath(item: pageControl.currentPage + 1, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        pageControl.currentPage += 1
        delegate?.pageDidChange?(currentPage: pageControl.currentPage + 1)
    }
    
    public func previousPage() {
        //Check if we are on the first page
        if pageControl.currentPage == 0 {
            return
        }
        let indexPath = IndexPath(item: pageControl.currentPage - 1, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        pageControl.currentPage -= 1
        delegate?.pageDidChange?(currentPage: pageControl.currentPage + 1)
    }
    
    public func skip() {
        let indexPath = IndexPath(item: viewControllers.count - 1, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        pageControl.currentPage = viewControllers.count
        delegate?.pageDidChange?(currentPage: viewControllers.count)
    }
    
    public func moveLeftButtonOffScreen() {
        if showLeftButton {
            leftButtonTopConstriant?.constant = -40
        } else {
            print("Tried moving the left button off screen but the left button is set to hidden.")
        }
    }
    
    public func moveLeftButtonOnScreen() {
        if showLeftButton {
            leftButtonTopConstriant?.constant = buttonTopConstant
        } else {
            print("Tried moving the left button onto screen but the left button is hidden")
        }
    }
    
    public func moveRightButtonOffScreen() {
        if showRightButton {
            rightButtonTopConstriant?.constant = -40
        } else {
            print("Tried moving the right button off screen but the right button is set to hidden.")
        }
    }
    
    public func moveRightButtonOnScreen() {
        if showRightButton {
            rightButtonTopConstriant?.constant = buttonTopConstant
        } else {
            print("Tried moving the right button onto screen but the right button is hidden")
        }
    }
    
    public func moveBottomButtonOffScreen() {
        if showBottomButton {
            bottomButtonBottomConstriant?.constant = 40
        } else {
            print("Tried moving the bottom button off screen but the bottom button is set to hidden.")
        }
    }
    
    public func moveBottomButtonOnScreen() {
        if showBottomButton {
            bottomButtonBottomConstriant?.constant = -bottomButtonBottomMargin
        } else {
            print("Tried moving the bottom button onto screen but the bottom button is hidden")
        }
    }
    
    public func movePageControlOffScreen() {
        if showPageControl {
            pageControlBottomConstriant?.constant = 40
        } else {
            print("Tried moving the page control off screen but the page control is set to hidden.")
        }
    }
    
    public func movePageControlOnScreen() {
        if showPageControl {
            pageControlBottomConstriant?.constant = -pageControlBottomMargin
        } else {
            print("Tried moving the page control onto screen but the page control is set to hidden.")
        }
    }
    
    public func updateView() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}

private extension UIView {
    
    func anchorToTop(_ top: NSLayoutYAxisAnchor? = nil, left: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil) {
        anchorWithConstantsToTop(top, left: left, bottom: bottom, right: right, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0)
    }
    
    func anchorWithConstantsToTop(_ top: NSLayoutYAxisAnchor? = nil, left: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil, topConstant: CGFloat = 0, leftConstant: CGFloat = 0, bottomConstant: CGFloat = 0, rightConstant: CGFloat = 0) {
        _ = anchor(top, left: left, bottom: bottom, right: right, topConstant: topConstant, leftConstant: leftConstant, bottomConstant: bottomConstant, rightConstant: rightConstant)
    }
    
    func anchor(_ top: NSLayoutYAxisAnchor? = nil, left: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil, topConstant: CGFloat = 0, leftConstant: CGFloat = 0, bottomConstant: CGFloat = 0, rightConstant: CGFloat = 0, widthConstant: CGFloat = 0, heightConstant: CGFloat = 0) -> [NSLayoutConstraint] {
        translatesAutoresizingMaskIntoConstraints = false
        
        var anchors = [NSLayoutConstraint]()
        
        if let top = top {
            anchors.append(topAnchor.constraint(equalTo: top, constant: topConstant))
        }
        
        if let left = left {
            anchors.append(leftAnchor.constraint(equalTo: left, constant: leftConstant))
        }
        
        if let bottom = bottom {
            anchors.append(bottomAnchor.constraint(equalTo: bottom, constant: -bottomConstant))
        }
        
        if let right = right {
            anchors.append(rightAnchor.constraint(equalTo: right, constant: -rightConstant))
        }
        
        if widthConstant > 0 {
            anchors.append(widthAnchor.constraint(equalToConstant: widthConstant))
        }
        
        if heightConstant > 0 {
            anchors.append(heightAnchor.constraint(equalToConstant: heightConstant))
        }
        
        anchors.forEach({$0.isActive = true})
        
        return anchors
    }
}

public enum ButtonImagePosition {
    // The left position is a default
    case left
    // The right position is useful to display arrows
    case right
    // In case you don't have a title on the button, so above variants make no sense
    case buttonHasNoTitle
}
