//
//  SecondCollectionViewController.swift
//  NacdNews
//
//  Created by Gregory Weiss on 9/9/16.
//  Copyright © 2016 Gregory Weiss. All rights reserved.
//

import UIKit
import SDWebImage
import RealmSwift

private let reuseIdentifier = "SecondCollectionViewCell"

class SecondCollectionViewController: UICollectionViewController, FeaturedAPIControllerProtocol, MenuTransitionManagerDelegate
{
    let defaultsBlog = NSUserDefaults.standardUserDefaults()
    var todayCheck: NSDate?

    
   // var blogItems = [BlogItem]()
    var myFormatter = NSDateFormatter()
    
    var arrayOfBlogs = [Featured]()
    var anApiController: FeaturedAPIController!
    
    //************************  REALM  *****************************
    let blogRealm = Realm.sharedInstance
    var blogRlmItems: Results<BlogRlm>!
    var notificationToken: NotificationToken? = nil
    
    
    //************************  REALM  *****************************
    
    let loadingIndicator = UIActivityIndicatorView()
    let smallLoader = UIActivityIndicatorView()
    let menuTransitionManager = MenuTransitionManager()
    
    let refresher = UIRefreshControl()
    
    var unavailableSquare = UILabel()
    var unavailableSquare2 = UILabel()
    var incrementer = 0
    
    var controlsWidth: CGFloat?
    var unHideXPos: CGFloat?
    var unHideYPos: CGFloat?
    var unHideButton = UIButton()
    let unHideImage = UIImage(named: "Arrow-Up-2-small.png")


    

    override func viewDidLoad()
    {
        super.viewDidLoad()
        todayCheck = NSDate()

        myFormatter.dateStyle = .ShortStyle
        myFormatter.timeStyle = .NoStyle
        
        makeUnavailableLabel(unavailableSquare, unavailableBar2: unavailableSquare2)
        makeLoadActivityIndicator()
        
        self.collectionView!.alwaysBounceVertical = true
        //      refresher.tintColor = UIColor.grayColor()
        refresher.addTarget(self, action: #selector(SecondCollectionViewController.reloadFromAPI), forControlEvents: .ValueChanged)
        collectionView!.addSubview(refresher)
        
        anApiController = FeaturedAPIController(delegate: self)
        
        let config = Realm.Configuration()
        Realm.Configuration.defaultConfiguration = config
        
        let blgRlm = blogRealm.objects(BlogRlm.self)
        blogRlmItems = blgRlm.sorted("entry_date", ascending: false)
        
        //self.collectionView!.contentOffset = CGPoint(x: 0, y: 8)
        
        if blogRlmItems.count > 0
        {
            for blgRlm in blogRlmItems
            {
                if let rBlog = Featured.makeFeaturedFromRlmObjct(blgRlm)
                {
                    arrayOfBlogs.append(rBlog)
                }
            }

            loadingIndicator.stopAnimating()
            if refresher.refreshing
            {
                stopRefresher()
            }
            anApiController.syncTheBlogs(arrayOfBlogs)
            
            collectionView?.reloadData()
            // getFromRealm()
            print("Already have Video items \(blogRlmItems.count)")
            
        }
        else
        {
          anApiController.getBlogsDataFromNACD(incrementer)
        }
        
        makeUnHideControl()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let dateBlog_get = defaultsBlog.objectForKey("DateBlog") as? NSDate ?? todayCheck
        let result = Int(todayCheck!.timeIntervalSinceDate(dateBlog_get!))
        if result > 14400
        {
            makeLoadActivityIndicator()
            reloadFromAPI()
        }
        smallLoader.stopAnimating()
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        if arrayOfBlogs.count > 0
        {
            unavailableSquare.alpha = 0
            unavailableSquare2.alpha = 0
        }
        else
        {
            //makeUnavailableLabel()
            unavailableSquare.alpha = 0.5
            unavailableSquare2.alpha = 0.5
        }
        
        defaultsBlog.setObject(todayCheck, forKey: "DateBlog")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if arrayOfBlogs.count > 0
        {
            unavailableSquare.alpha = 0
            unavailableSquare2.alpha = 0
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        refresher.endRefreshing()
        smallLoader.stopAnimating()
    }



    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //************************  REALM  *****************************
    func getFromRealm()
    {
        do
        {
            // let featurRealm = try Realm()
            blogRlmItems = blogRealm.objects(BlogRlm)
            print("Got Realm items maybe??")
        }
        catch
        {
            print("Didn't save in Realm")
        }
    }
    //************************  REALM  *****************************
    

    
    func reloadFromAPI()
    {
        resetIncrementer()
        
        anApiController.purgeBlogs()
        anApiController.getBlogsDataFromNACD(incrementer)
        
        //refresher.endRefreshing()
        //Call this to stop refresher
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

    
    func makeLoadActivityIndicator()
    {
        loadingIndicator.activityIndicatorViewStyle = .WhiteLarge
        loadingIndicator.color = UIColor.grayColor()
        loadingIndicator.frame = CGRect(x: self.view.frame.width / 2 - 75, y: self.view.frame.height / 2 - 75, width: 150, height: 150)
        loadingIndicator.startAnimating()
        view.addSubview(loadingIndicator)
        
    }

    
    func gotTheFeatured(theFeatured: [Featured])
    {
        smallLoader.stopAnimating()
        arrayOfBlogs = theFeatured
        
        if incrementer == 0
        {
        convertFeaturedToRealmObjects(theFeatured)
        getFromRealm()
        }
        
        loadingIndicator.stopAnimating()
       
        UIView.animateWithDuration(1.0, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.unavailableSquare.alpha = 0
            self.unavailableSquare2.alpha = 0
            self.view.layoutIfNeeded()
            }, completion: nil)

        
        if refresher.refreshing
        {
            stopRefresher()
        }
        
        collectionView?.reloadData()
        
        // print("conforming to protocol")
    }
    
    func convertFeaturedToRealmObjects(passArrayItems: [Featured])
    {
        var sorter = 1
        
        try! blogRealm.write({
            
            for aFeatured in passArrayItems
            {
                let aRlmFeatured = BlogRlm()
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
                blogRealm.add(aRlmFeatured, update: true)
            }
        })
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
        
        
        self.collectionView?.scrollToItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0),
                                                     atScrollPosition: .Top,
                                                     animated: true)
    }
    


  

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
    {
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return arrayOfBlogs.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! SecondCollectionViewCell
    
        // Configure the cell
        
        let aBlog = arrayOfBlogs[indexPath.row]
        
        cell.secondTitleLabel.text = aBlog.title?.stringByDecodingXMLEntities()
        cell.secondDescriptionLabel.text = aBlog.closingText?.uppercaseString
        
        let placeHolder = UIImage(named: "WhiteBack.png")
        // NACD_logo_mark2.png
       // let placeHolder = UIImage(named: "NACD_logo_mark2.png")
        
        let myURL = arrayOfBlogs[indexPath.row].image!
        print(myURL)
        let realURL = NSURL(string: myURL)
        
        //   cell.backingImageView.sd_setImageWithURL(realURL, placeholderImage: placeHolder, options: [.HighPriority, .DelayPlaceholder, .CacheMemoryOnly])

        
        cell.secondImageView.sd_setImageWithURL(realURL, placeholderImage: placeHolder, options: [.ProgressiveDownload, .RefreshCached])

        cell.layer.shadowOffset = CGSizeMake(10, 10)
        cell.layer.shadowColor = UIColor.blackColor().CGColor
        cell.layer.shadowRadius = 3
        cell.layer.shadowOpacity = 0.14
        
        cell.clipsToBounds = false
        
        let shadowFrame: CGRect = (cell.layer.bounds)
        let shadowPath: CGPathRef = UIBezierPath(rect: shadowFrame).CGPath
        cell.layer.shadowPath = shadowPath
        
        if indexPath.row == arrayOfBlogs.count - 1
        {
            incrementer = incrementer + 20
            loadMoreAutoRetrieve()
        }
        
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
    
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        
       let aBlog = arrayOfBlogs[indexPath.row]
            let detailVC = self.storyboard?.instantiateViewControllerWithIdentifier("BlogDetailViewController") as! BlogDetailViewController
            navigationController?.pushViewController(detailVC, animated: true)
            detailVC.aBlogItem = aBlog
 
        
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "SubLogoSegue"
        {
            let navVC = segue.destinationViewController as! UINavigationController
            let menuTableViewController = navVC.viewControllers[0] as! MenuTableViewController
            navVC.transitioningDelegate = menuTransitionManager
            menuTransitionManager.delegate = self
        }
        
    }
    
    
    func loadMoreAutoRetrieve()
    {
        //TODO: Check for network First!!
        makeSmallLoadIndicator()
        smallLoader.startAnimating()
         //incrementer = incrementer + 20
        
           // theseVideosString = "/users/northlandchurch/albums/\(videoIDAlbumNumber)/videos?page=\(incrementer)&per_page=15"
        
        
        anApiController.getBlogsDataFromNACD(incrementer)
        //collectionView?.reloadData()
    }
    
    func resetIncrementer()
    {
        incrementer = 0
             //     theseVideosString = "/users/northlandchurch/albums/\(videoIDAlbumNumber)/videos?page=\(incrementer)&per_page=15"
        
    }
    
    func makeSmallLoadIndicator()
    {
        smallLoader.activityIndicatorViewStyle = .White
        smallLoader.color = UIColor.grayColor()
        smallLoader.frame = CGRect(x: self.view.frame.width / 2 - 30, y: self.view.frame.height * 0.80 + 20, width: 60, height: 60)
        smallLoader.startAnimating()
        view.addSubview(smallLoader)
        
    }
    
    

    


    
    


    


}
