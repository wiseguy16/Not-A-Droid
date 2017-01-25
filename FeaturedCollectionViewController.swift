//
//  FeaturedCollectionViewController.swift
//  NacdNews
//
//  Created by Gregory Weiss on 10/11/16.
//  Copyright © 2016 Gregory Weiss. All rights reserved.
//

import UIKit
import SDWebImage
import CoreMedia
import AVKit
import AVFoundation
import RealmSwift
//import ContentfulDeliveryAPI

protocol FeaturedAPIControllerProtocol
{
    func gotTheFeatured(theFeatured: [Featured])
}




private let reuseIdentifier = "FeaturedCell"

class FeaturedCollectionViewController: UICollectionViewController, FeaturedAPIControllerProtocol, MenuTransitionManagerDelegate, UICollectionViewDelegateFlowLayout
{
    let defaultsFeatured = NSUserDefaults.standardUserDefaults()
    let audioNotification = NSNotificationCenter.defaultCenter()
    let micImage = UIImage(named: "micIconUnhighlighted.png")
    
    @IBOutlet weak var micTabButton: UIBarButtonItem!
    
    var todayCheck: NSDate?

    var featuredItems = [Featured]()
    var noPlay = ThirdCollectionViewController().player2
    
    
//************************  REALM  *****************************
    let featuredRealm = Realm.sharedInstance
    var featuredRlmItems: Results<FeaturedRlm>!
    var notificationToken: NotificationToken? = nil

    
//************************  REALM  *****************************
    
    var myFormatter = NSDateFormatter()
    var anApiController: FeaturedAPIController!
    
    let loadingIndicator = UIActivityIndicatorView()
    
    let menuTransitionManager = MenuTransitionManager()
    
    var dateBarBoundsY:CGFloat?
    var extraBoundsY: CGFloat?
    var extraCover = UIView()
    var dateBar = UILabel()
    
    var unavailableSquare = UILabel()
    var unavailableSquare2 = UILabel()

    let refresher = UIRefreshControl()
    
    var controlsWidth: CGFloat?
    var unHideXPos: CGFloat?
    var unHideYPos: CGFloat?
    var unHideButton = UIButton()
    let unHideImage = UIImage(named: "Arrow-Up-2-small.png")

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeExtraCoverView()
        makeDateLabel()
        
        audioNotification.addObserver(self, selector: #selector(jumpToAudioContoller), name: "GoToAudio", object: nil)
        audioNotification.addObserver(self, selector: #selector(dontShowAudioJump), name: "DontGoToAudio", object: nil)

         todayCheck = NSDate()

        self.collectionView!.alwaysBounceVertical = true
        //refresher.tintColor = UIColor.grayColor()
        refresher.addTarget(self, action: #selector(FeaturedCollectionViewController.reloadFromAPI), forControlEvents: .ValueChanged)
        collectionView!.addSubview(refresher)
        refresher.endRefreshing()
        
        anApiController = FeaturedAPIController(delegate: self)
        
        let config = Realm.Configuration()
        Realm.Configuration.defaultConfiguration = config
        
        let ftrRlm = featuredRealm.objects(FeaturedRlm.self)
        featuredRlmItems = ftrRlm.sorted("sortOrder", ascending: true)
    
      
        if featuredRlmItems.count > 0
        {
            for ftrdRlm in featuredRlmItems
            {
                if let rFeatrd = Featured.makeFeaturedHomeItemFromRlmObjct(ftrdRlm)
                {
                    featuredItems.append(rFeatrd)
                }
            }
            
            loadingIndicator.stopAnimating()
            if refresher.refreshing
            {
                stopRefresher()
            }
            
            collectionView?.reloadData()
//            UIView.animateWithDuration(1.75, animations: {
//                self.extraCover.alpha = 0
//            })
            // getFromRealm()
            print("Already have Video items \(featuredRlmItems.count)")
            
        }
        else
        {
            anApiController.getFeaturedDataFromNACD()
        }
        
        
        makeUnHideControl()

        
        
        //self.collectionView!.contentOffset = CGPoint(x: 0, y: 8)


    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        establishTheTime()
        
        let dateFeatured_get = defaultsFeatured.objectForKey("DateFeatured") as? NSDate ?? todayCheck
        let result = Int(todayCheck!.timeIntervalSinceDate(dateFeatured_get!))
        if result > 14400
        {
    //*********Second Call to cet current Featured********

            makeLoadActivityIndicator()
            reloadFromAPI()
        }
        
    }
    
    override func viewDidAppear(animated: Bool)
    {
        if featuredItems.count > 0
        {
            unavailableSquare.alpha = 0
            unavailableSquare2.alpha = 0
        }
        else
        {
            unavailableSquare.alpha = 0
            unavailableSquare2.alpha = 0.5
        }
        
        defaultsFeatured.setObject(todayCheck, forKey: "DateFeatured")

        
       // reloadFromAPI()
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        refresher.endRefreshing()
    }

    

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showLiveBar()
    {
        dateBar.alpha = 0.9
        dateBar.userInteractionEnabled = true
    }
    
    func hideLiveBar()
    {
        dateBar.alpha = 0
        dateBar.userInteractionEnabled = false
    }
    
    
//************************  REALM  *****************************
    func getFromRealm()
    {
        do
        {
           // let featurRealm = try Realm()
            featuredRlmItems = featuredRealm.objects(FeaturedRlm)
            print("Got Realm items maybe??")
            print(featuredRlmItems.count)
            let aRLM = featuredRlmItems[0]
            print(aRLM.channel)
            print(aRLM.closingText)
            print(aRLM.mediaFileM3U8)
            print(aRLM.title)
        }
        catch
        {
            print("Didn't save in Realm")
        }
    }
//************************  REALM  *****************************
    
    
    

    
    @IBAction func jumpToAudioContoller(sender: AnyObject)
    {
        print("Got notified from audio mic")
        micTabButton.tintColor = UIColor.redColor()
        
        
        
    }
    
    @IBAction func dontShowAudioJump(sender: AnyObject)
    {
        micTabButton.tintColor = UIColor.clearColor()
        
    }
    
    @IBAction func goToAudioTab(sender: UIBarButtonItem)
    {
        if micTabButton.tintColor == UIColor.redColor()
        {
            if let myTabBarController = view.window!.rootViewController as? UITabBarController
            {
                myTabBarController.selectedIndex = 6
            }
        }
    }
    
    @IBAction func videoGoNowTapped(sender: UIButton)
    {
        let contentView = sender.superview
        let cell = contentView!.superview as! FeaturedCollectionViewCell           //sender?.superview as! FeaturedCollectionViewCell
        let thisIndexPath = collectionView?.indexPathForCell(cell)
        let aFeaturedThing = featuredItems[thisIndexPath!.row]
        let videoURL = NSURL(string: aFeaturedThing.mediaFileM3U8!)
        let player = AVPlayer(URL: videoURL!)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        audioNotification.postNotificationName("StopAudio", object: nil)
        
        self.presentViewController(playerViewController, animated: true) {
            
            playerViewController.player?.play()
        }
    }
    
    
//*******************Disable Selection when refreshig!!!!!!!!!  **************
    func reloadFromAPI()
    {
        self.collectionView?.allowsSelection = false
        //code to execute during refresher
        
        var tempSorter = 1000
        try! featuredRealm.write({
            for aRlmOnDisk in featuredRlmItems
            {
                aRlmOnDisk.sortOrder = tempSorter
                tempSorter = tempSorter + 1
                featuredRealm.add(aRlmOnDisk, update: true)
            }
        })

        anApiController.purgeFeatured()
        anApiController.getFeaturedDataFromNACD()
        
        try! featuredRealm.write({
            for aNewRlmOnDisk in featuredRlmItems
            {
                if aNewRlmOnDisk.sortOrder >= 1000
                {
                    featuredRealm.delete(aNewRlmOnDisk)
                }
            }
        })
    }
    
    
    
    func stopRefresher()
    {
        refresher.endRefreshing()
    }

    
    func dismiss() {
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    
    @IBAction func unwindToHome(segue: UIStoryboardSegue)
    {
        let sourceController = segue.sourceViewController as! MenuTableViewController
        //self.title = sourceController.currentItem
    }
    
    
    func establishTheTime()
    {
        let today = NSDate()
        let calender = NSCalendar.currentCalendar()
        let components = calender.components([.Weekday, .Hour, .Minute], fromDate: today)
        let weekday = components.weekday
        let hour = components.hour
        let minute = components.minute
        let checkTime = (hour * 100) + minute
        switch weekday
        {
            case 7:
                if case 1645...1830 = checkTime
                {
                    showLiveBar()
                }
                else
                    {
                        hideLiveBar()
                    }
            case 1:
                if case 845...1230 = checkTime
                {
                    showLiveBar()
                }
                else if case 1645...1830 = checkTime
                {
                    showLiveBar()
                }
                else
                {
                    hideLiveBar()
                }
            case 2:
                if case 1845...2030 = checkTime
                {
                    showLiveBar()
                }
                else
                {
                    hideLiveBar()
                }
            default:
                    hideLiveBar()
                print("not live")
            
        }
    }
    
    func makeExtraCoverView()
    {
        self.extraBoundsY = (self.navigationController?.navigationBar.frame.size.height)! + UIApplication.sharedApplication().statusBarFrame.size.height

        //let extraCover = UIView()
        self.extraCover.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        let extraBgColor = UIColor(red: 241/255.0, green: 239/255.0, blue: 237/255.0, alpha: 1.0)
        extraCover.backgroundColor = extraBgColor
        self.view.addSubview(extraCover)
        let hoverImage = UIImage(named: "Logo-Northland-Distributed-black-frame.png")
        let hoverView = UIImageView(frame: CGRectMake(0, self.extraBoundsY! + 50, self.view.frame.width, 125))
        hoverView.image = hoverImage
        hoverView.contentMode = .ScaleAspectFit
        extraCover.addSubview(hoverView)
    }


    

    
    
    func makeLoadActivityIndicator()
    {
        loadingIndicator.activityIndicatorViewStyle = .WhiteLarge
        loadingIndicator.color = UIColor.grayColor()
        loadingIndicator.frame = CGRect(x: self.view.frame.width / 2 - 75, y: self.view.frame.height * 0.75, width: 150, height: 150)
        loadingIndicator.startAnimating()
        view.addSubview(loadingIndicator)
        
    }

    
    func gotTheFeatured(theFeatured: [Featured])
    {
        featuredItems = theFeatured
        
        var sorter = 1
        try! featuredRealm.write({
            
        for aFeatured in featuredItems
            {
                let aRlmFeatured = FeaturedRlm()
                aRlmFeatured.sortOrder = sorter
                aRlmFeatured.id = aFeatured.entry_id!
                aRlmFeatured.body = aFeatured.replaceBreakWithReturn(aFeatured.body!)
                aRlmFeatured.channel = aFeatured.channel
                aRlmFeatured.closingText = aFeatured.closingText
                aRlmFeatured.entry_date = aFeatured.entry_date
                aRlmFeatured.image = aFeatured.image
                aRlmFeatured.mediaFileM3U8 = aFeatured.mediaFileM3U8
                aRlmFeatured.title = aFeatured.title?.stringByDecodingXMLEntities()
                aRlmFeatured.urltitle = aFeatured.urltitle
                aRlmFeatured.webURL = aFeatured.webURL
                    
                sorter = sorter + 1
                featuredRealm.add(aRlmFeatured, update: true)
            }
        })
        
        
        loadingIndicator.stopAnimating()


        
        UIView.animateWithDuration(1.75, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.unavailableSquare.alpha = 0
            self.unavailableSquare2.alpha = 0
            self.view.layoutIfNeeded()
            }, completion: nil)
        

        
        if refresher.refreshing
        {
            stopRefresher()
        }
        
        //*************  REALM CALL  ****************
        getFromRealm()
        
        //*************  REALM CALL  ****************
        
        collectionView?.reloadData()
//        UIView.animateWithDuration(1.75, animations: {
//            self.extraCover.alpha = 0
//        })

        self.collectionView?.allowsSelection = true
        
       // print("conforming to protocol")
    }

    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
         if segue.identifier == "SubLogoSegue"
        {
            let navVC = segue.destinationViewController as! UINavigationController
            let menuTableViewController = navVC.viewControllers[0] as! MenuTableViewController
            navVC.transitioningDelegate = menuTransitionManager
            menuTransitionManager.delegate = self

            //let menuTableViewController = segue.destinationViewController as! MenuTableViewController
           // menuTableViewController.currentItem = self.title!
           // menuTableViewController.transitioningDelegate = menuTransitionManager
        }

    }

    
    @IBAction func webButtonTapped(sender: UIButton)
    {
        
        let contentView = sender.superview
        let cell = contentView!.superview as! FeaturedCollectionViewCell           //sender?.superview as! FeaturedCollectionViewCell
        let thisIndexPath = collectionView?.indexPathForCell(cell)
        let aFeaturedURL = featuredItems[thisIndexPath!.row]
        let vc = self.storyboard!.instantiateViewControllerWithIdentifier("WebViewController") as! WebViewController
        vc.aFeaturedItem = aFeaturedURL
        self.showViewController(vc, sender: vc)
        
    }
    
    func makeUnHideControl()
    {
        self.controlsWidth = view.frame.width
        self.unHideXPos = (controlsWidth! - 72)
        self.unHideYPos = view.frame.height
        unHideButton.frame = CGRectMake(unHideXPos!, unHideYPos!, 60, 23)
        unHideButton.setImage(unHideImage, forState: .Normal)
       // unHideButton.setTitle("Show", forState: .Normal)
       // unHideButton.titleLabel?.font = UIFont(name: "FormaDJRText-Regular", size: 16.0)
       // unHideButton.tintColor = UIColor.whiteColor()
        //unHideButton.backgroundColor = UIColor(red: 237/255.0, green: 235/255.0, blue: 232/255.0, alpha: 1)
        unHideButton.backgroundColor = UIColor.lightGrayColor()
        unHideButton.addTarget(self, action: #selector(scrollToTop), forControlEvents: .TouchUpInside)
        unHideButton.layer.cornerRadius = 10.0
        unHideButton.clipsToBounds = true
        view.addSubview(unHideButton)
        
    }
    
    func moveDownNavAssist()
    {
            UIView.animateWithDuration(0.3) {

                // Park the Button off screen
                //self.unHideButton.alpha = 0.2
                let newButtonPoint = CGPoint(x: self.unHideXPos! + 30, y: self.unHideYPos! + 150) //+ (self.navigationController?.navigationBar.frame.size.height)!)
                self.unHideButton.center = newButtonPoint
                
                self.view.layoutIfNeeded()
            }
        
    }
    
    func bringUpNavAssist()
    {
            UIView.animateWithDuration(0.3) {
                // Move the Button second
                let newButtonPoint = CGPoint(x: self.unHideXPos! + 30, y: self.view.frame.height - (self.navigationController?.navigationBar.frame.size.height)! - 58)
                self.unHideButton.alpha = 1
                self.unHideButton.center = newButtonPoint
                self.view.layoutIfNeeded()
            }
        
    }
    

    
    
    func scrollToTop()
    {
        

        self.collectionView?.scrollToItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1),
                                                     atScrollPosition: .Top,
                                                     animated: true)
    }
    
    /*
     self.collectionView?.scrollToItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0),
     atScrollPosition: .Top,
     animated: true)
     */

    
    
 

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
    {
        return 2
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        if section == 0
        {
            return 1
        }
        else
        {
            return featuredItems.count
        }
    }
    
    
    // MARK: - UICollectionViewFlowLayout
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        let leftRightInset = self.view.frame.size.width / 14.0
//        return UIEdgeInsetsMake(0, leftRightInset, 0, leftRightInset)
//    }


    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
    {
        let width : CGFloat
        let height : CGFloat
        
        if indexPath.section == 0
        {
            // First section
            width = collectionView.frame.width
            height = collectionView.frame.height - ((self.navigationController?.navigationBar.frame.size.height)! * 2)
            
            return CGSizeMake(width, height)
        }
        else
        {
            // Second section
           // width = collectionView.frame.width/3
            width = 280
            height = 280
            return CGSizeMake(width, height)
        }
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        if indexPath.section == 0
        {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("WelcomeCell", forIndexPath: indexPath) as! WelcomeCollectionViewCell
            
            
            let placeHolder = UIImage(named: "lightGreyBG.png")
         //   let myURL = "http://www.northlandchurch.net/_assets/img/v2/series/bg-series-1-2-3-Go-1920x1080-reversed.jpg"
            let myURL2 = "http://www.northlandchurch.net/_assets/img/v2/series/bg-series-1-2-3-Go-iPhoneSizeTest.jpg"
        

            let realURL = NSURL(string: myURL2)
            
         //   cell.backingImageView.sd_setImageWithURL(realURL, placeholderImage: placeHolder, options: [.HighPriority, .DelayPlaceholder, .CacheMemoryOnly])
            
            
             NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: myURL2)!, completionHandler: { (data, response, error) -> Void in
             
             if error != nil {
             print(error)
             return
             }
             
             dispatch_async(dispatch_get_main_queue(), { () -> Void in
             let image = UIImage(data: data!)
             cell.backingImageView.image = image
             UIView.animateWithDuration(1.75, animations: {
             self.extraCover.alpha = 0
             })

             
             })
             
             }).resume()
             
            

            
            
//            cell.backingImageView.sd_setImageWithURL(realURL, completed: { (placeHolder, error, nil, realURL) in
//                self.extraCover.alpha = 0
//            })
            
            //cell.backingImageView.sd_setImageWithURL(realURL, completed: { (placeHolder, error, .RefreshCached, realURL) in
           //     self.extraCover.alpha = 0
          //  })
            
            return cell
        }
        else
        {

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! FeaturedCollectionViewCell
    
        
        let aFeaturedThing = featuredItems[indexPath.row]
        // Configure the cell

         let convertedTitle = aFeaturedThing.title?.stringByDecodingXMLEntities()
         //let myLength = aFeaturedThing.title!.characters.count
         let attributedString = NSMutableAttributedString(string: convertedTitle!)
         attributedString.addAttribute(NSKernAttributeName, value: CGFloat(1.4), range: NSRange(location: 0, length: attributedString.length))
         
         cell.featuredTitleLabel.attributedText = attributedString
        
        cell.featuredPlayButton.alpha = 0
        cell.featuredPlayButton.userInteractionEnabled = false
        if aFeaturedThing.channel! == "Media"
        {
            cell.featuredPlayButton.alpha = 1.0
            cell.featuredPlayButton.userInteractionEnabled = true
            cell.tabBarButton.setTitle("Browse Videos", forState: .Normal)
            cell.tabBarButton.contentHorizontalAlignment = .Left
        }
        else if aFeaturedThing.channel! == "Blogs"
        {
            cell.tabBarButton.setTitle("Browse Articles", forState: .Normal)
            cell.tabBarButton.contentHorizontalAlignment = .Left
        }
            
        cell.featuredDetailsLabel.text = aFeaturedThing.closingText?.uppercaseString
        
        let placeHolder = UIImage(named: "WhiteBack.png")
        let myURL = featuredItems[indexPath.row].image!
        let realURL = NSURL(string: myURL)
        
        cell.featuredImageView.sd_setImageWithURL(realURL, placeholderImage: placeHolder, options: [.ProgressiveDownload, .RefreshCached])

        cell.layer.shadowOffset = CGSizeMake(10, 10)
        cell.layer.shadowColor = UIColor.blackColor().CGColor
        cell.layer.shadowRadius = 3
        cell.layer.shadowOpacity = 0.14
        cell.clipsToBounds = false
        let shadowFrame: CGRect = (cell.layer.bounds)
        let shadowPath: CGPathRef = UIBezierPath(rect: shadowFrame).CGPath
        cell.layer.shadowPath = shadowPath
            
            if indexPath.row >= 10
            {
                bringUpNavAssist()
            }
            else
            {
                moveDownNavAssist()
            }

            
            
        
        
        return cell
        }
    }
    
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        
        let thisFeaturedItem = featuredItems[indexPath.row] //as! Featured Item
        
        let detailVC = self.storyboard?.instantiateViewControllerWithIdentifier("FeaturedDetailViewController") as! FeaturedDetailViewController
        navigationController?.pushViewController(detailVC, animated: true)
        detailVC.aFeaturedItem = thisFeaturedItem
    }
    
    @IBAction func findMoreTapped(sender: UIButton)
    {
        let contentView = sender.superview
        let cell = contentView!.superview as! FeaturedCollectionViewCell           //sender?.superview as! FeaturedCollectionViewCell
        let thisIndexPath = collectionView?.indexPathForCell(cell)
        let aFeaturedThing = featuredItems[thisIndexPath!.row]
        if aFeaturedThing.channel! == "Media"
        {
            if let myTabBarController = view.window!.rootViewController as? UITabBarController
            {
                myTabBarController.selectedIndex = 1
            }
        }
        else
        {
            if let myTabBarController = view.window!.rootViewController as? UITabBarController
            {
                myTabBarController.selectedIndex = 5
            }
        }
    }
    
    func makeDateLabel ()
    {
        self.dateBarBoundsY = (self.navigationController?.navigationBar.frame.size.height)! + UIApplication.sharedApplication().statusBarFrame.size.height
        let touchHere = UITapGestureRecognizer(target: self, action: #selector(gotoLiveService))
        
        dateBar.frame = CGRect(x: 0, y: self.dateBarBoundsY! - 2 , width: view.frame.width, height: 45)
        
        dateBar.font = UIFont(name: "FormaDJRText-Bold", size: 16)
        // self.dateBar!.font = UIFont(name: "FormaDJRText-Bold", size: 15)
        
        dateBar.textColor = UIColor.whiteColor()
        dateBar.backgroundColor = UIColor.redColor()
        //dateBar!.backgroundColor = UIColor(red: 208/255.0, green: 198/255.0, blue: 181/255.0, alpha: 1)
        dateBar.numberOfLines = 2
        dateBar.textAlignment = .Center
        dateBar.alpha = 0
        dateBar.userInteractionEnabled = false
        dateBar.addGestureRecognizer(touchHere)
        dateBar.text = "LIVE SERVICE IN PROGRESS. \nCLICK TO WATCH NOW."
        view.addSubview(dateBar)
    }
    
    func gotoLiveService ()
    {
        print("GOING TO LIVE")
        let videoURL = NSURL(string: "http://WtIDGlE-lh.akamaihd.net/i/northlandlive_1@188060/master.m3u8?attributes=off")
        let player = AVPlayer(URL: videoURL!)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.presentViewController(playerViewController, animated: true) {
            
            playerViewController.player?.play()
            
        }
    }

    

}
