//
//  ThirdCollectionViewController.swift
//  NacdNews
//
//  Created by Gregory Weiss on 9/9/16.
//  Copyright © 2016 Gregory Weiss. All rights reserved.
//

import UIKit
import CoreMedia
import Foundation
import AVKit
import AVFoundation
import SDWebImage
import RealmSwift




private let reuseIdentifier = "ThirdCollectionViewCell"

class ThirdCollectionViewController: UICollectionViewController, APIControllerProtocol, MenuTransitionManagerDelegate
{
    let defaultsAudio = NSUserDefaults.standardUserDefaults()
    let audioObserver = NSNotificationCenter.defaultCenter()
    var todayCheck: NSDate?

    
    var myDateFormatter = NSDateFormatter()
    
    var incrementer = 1
    
    let secondsInMin = 60
    let minInHour = 60
    let hoursInDay = 24
    let daysInWeek = 7
    var thisWeek: Int = 0
    
    
    let loadingIndicator = UIActivityIndicatorView()
    let smallLoader = UIActivityIndicatorView()
    let reallySmallLoader = UIActivityIndicatorView()
    
    var podcastItems = [Podcast]()
    var myFormatter = NSDateFormatter()
    
    var anApiController: APIController!
    let menuTransitionManager = MenuTransitionManager()
    
    //************************  REALM  *****************************
    let audioRealm = Realm.sharedInstance
    var audioRlmItems: Results<SermonAudioRlm>!
    var nowPlayingRlmItems: Results<SermonAudioRlm>!
    var notificationToken: NotificationToken? = nil
    var checkArrayAudioRlm = [Int]()
    
    //************************  REALM  *****************************
    
    
    var arrayOfPlayButton = [UIButton]()
    var arrayOfIndexPaths = [NSIndexPath]()
    var arrayForUpdateVideos = [Video]()
    
    var arrayOfSermonVideos = [Video]()
    var animatingVideos = [Video]()
    var perPage = 15
    var theseVideosString = "/users/northlandchurch/albums/3446210/videos?per_page=15"
    
    
    var audioPlayer: AVAudioPlayer!
    var streamPlayer: AVPlayer!
    var isPlaying = false

    var player: AVPlayer?
    var player2 = AVPlayer()
    var playerItem2: AVPlayerItem?
    
    let refresher = UIRefreshControl()
    
    var unavailableSquare = UILabel()
    var unavailableSquare2 = UILabel()
    
    var dateBarBoundsY: CGFloat?
    var controlsHeight: CGFloat?
    var controlsWidth: CGFloat?
    var controlsYPos: CGFloat?
    var controlsView = UIView()
    let playImage = UIImage(named: "playAudio.png")
    let pauseImage = UIImage(named: "pauseAudio.png")
    var playSlider: UISlider?
    let sliderThumb = UIImage(named: "white_ball_small_flat.png")
    var playLabelStart = UILabel()
    var playLabelEnd = UILabel()
    var playTitleLabel = UILabel()
    var hideButton = UIButton()
    let hideImage = UIImage(named: "Arrow-Down-2-small.png")
    
    var unHideXPos: CGFloat?
    var unHideYPos: CGFloat?
    var unHideButton = UIButton()
    let unHideImage = UIImage(named: "Arrow-Up-2-small.png")
    var controlsAreHidden = true
    var audioHasPlayed = false

    var arrayOfOnePlaying = [Video]()

    var pButtn = UIButton()
    var timer = NSTimer()
    var playingTimer = NSTimer()
    
    

    
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        audioObserver.addObserver(self, selector: #selector(pauseFromAnotherView), name: "StopAudio", object: nil)
        //ncObserver.addObserver(self, selector: #selector(self.stopMusic), name: Notification.Name("StopMusic"), object: nil)
        
        
        todayCheck = NSDate()
        playSlider = UISlider()
        
        makePlayControls()
        makeUnHideControl()
        
        

        myDateFormatter.dateFormat = "yyyy-MM-dd"
        
         makeUnavailableLabel(unavailableSquare, unavailableBar2: unavailableSquare2)
         makeLoadActivityIndicator()
        
        anApiController = APIController(delegate: self)
        
        let config = Realm.Configuration()
        Realm.Configuration.defaultConfiguration = config
        
        let audSermonRlm = audioRealm.objects(SermonAudioRlm.self)
        audioRlmItems = audSermonRlm.sorted("tagForAudioRef", ascending: false)
        
        presentAsRealm()
        
        
        NSKernAttributeName.capitalizedString
        myFormatter.dateStyle = .ShortStyle
        myFormatter.timeStyle = .NoStyle
        
        self.collectionView!.alwaysBounceVertical = true
        //refresher.tintColor = UIColor.grayColor()
        refresher.addTarget(self, action: #selector(ThirdCollectionViewController.reloadFromAPI), forControlEvents: .ValueChanged)
        collectionView!.addSubview(refresher)
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        smallLoader.stopAnimating()
        
        let audSermonRlm = audioRealm.objects(SermonAudioRlm.self).filter("isNowPlaying == true")
        nowPlayingRlmItems = audSermonRlm
        
        let dateAudio_get = defaultsAudio.objectForKey("DateAudio") as? NSDate ?? todayCheck
        let result = Int(todayCheck!.timeIntervalSinceDate(dateAudio_get!))
        if result > 43200
        {
            makeLoadActivityIndicator()
            reloadFromAPI()
        }
//        let viewControllers = self.navigationController?.viewControllers
//        let count = viewControllers?.count
//        if count > 1 {
//            if let sourceVC = viewControllers?[count! - 2] as? DownloadsTableViewController
//            {
//                makeLoadActivityIndicator()
//                reloadFromAPI()
//            }
//        }

    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        if arrayOfSermonVideos.count > 0
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
        //reloadFromAPI()
        defaultsAudio.setObject(todayCheck, forKey: "DateAudio")

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if arrayOfSermonVideos.count > 0
        {
            unavailableSquare.alpha = 0
            unavailableSquare2.alpha = 0
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        refresher.endRefreshing()
       // print("Rate of item is \(player2.rate)")
    }
    
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        if player2.currentItem != nil && player2.rate == 0
        {
            audioObserver.postNotificationName("DontGoToAudio", object: nil)

        }
        if player2.currentItem != nil && player2.rate >= 0.01
        {
            audioObserver.postNotificationName("GoToAudio", object: nil)
  
        }

        

    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //************************  REALM  *****************************
    
    func presentAsRealm()
    {
        if audioRlmItems.count > 0
        {
            perPage = audioRlmItems.count
            for audRlm in audioRlmItems
            {
                if let rAudio = Video.makeAudioFromRlmObjct(audRlm)
                {
                    arrayOfSermonVideos.append(rAudio)
                }
            }
            loadingIndicator.stopAnimating()
            if refresher.refreshing
            {
                stopRefresher()
            }
            anApiController.syncTheSermons(arrayOfSermonVideos)
            
            collectionView?.reloadData()
            print("Already have items \(audioRlmItems.count)")
        }
        else
        {
            // page=\(incrementer)&per_page=15
            theseVideosString = "/users/northlandchurch/albums/3446210/videos?per_page=\(perPage)"
          //  theseVideosString = "/users/northlandchurch/albums/3446210/videos?page=\(incrementer)&per_page=15"

            anApiController.getVideoSermonsDataFromVimeo(theseVideosString)
        }
    }
    
    func getFromRealm()
    {
        do
        {
            audioRlmItems = audioRealm.objects(SermonAudioRlm).sorted("tagForAudioRef", ascending: false)
            print("Got Realm items maybe??")
        }
        catch
        {
            print("Didn't save in Realm")
        }
    }
    
    func makePlayControls ()
    {
        self.dateBarBoundsY = (self.navigationController?.navigationBar.frame.size.height)! + UIApplication.sharedApplication().statusBarFrame.size.height
        self.controlsWidth = view.frame.width
        self.controlsHeight = 80
        self.controlsYPos = view.frame.height - (self.navigationController?.navigationBar.frame.size.height)! - 80
        //let touchHere = UITapGestureRecognizer(target: self, action: #selector(moveTheBox))
        
        
        controlsView.frame = CGRect(x: 0, y: controlsYPos! + (self.controlsHeight! + (self.navigationController?.navigationBar.frame.size.height)!), width: controlsWidth!, height: controlsHeight!)
        print(controlsView.center)
        print(controlsWidth!/2)
        print(controlsYPos! + (controlsHeight!/2))
        // (160.0, 484.0)
        
        
        controlsView.backgroundColor = UIColor(red: 237/255.0, green: 235/255.0, blue: 232/255.0, alpha: 1)
        controlsView.alpha = 1
       // controlsView.userInteractionEnabled = true
       // controlsView.addGestureRecognizer(touchHere)
        
        view.addSubview(controlsView)
        pButtn.frame = CGRectMake(10, 20, 40, 40)
        pButtn.setImage(pauseImage, forState: .Normal)
        pButtn.addTarget(self, action:#selector(newPlayButtonAction), forControlEvents: .TouchUpInside)
        controlsView.addSubview(pButtn)
        
        hideButton.frame = CGRectMake((controlsWidth! - 72), 8, 60, 23)
        //hideButton.setImage(hideImage, forState: .Normal)
        hideButton.setTitle("Hide", forState: .Normal)
        hideButton.titleLabel?.font = UIFont(name: "FormaDJRText-Regular", size: 16.0)
        hideButton.tintColor = UIColor.blackColor()
        hideButton.backgroundColor = UIColor.lightGrayColor()
        hideButton.layer.cornerRadius = 10.0
        hideButton.clipsToBounds = true
        hideButton.addTarget(self, action: #selector(doHideControls), forControlEvents: .TouchUpInside)
        controlsView.addSubview(hideButton)
        
        playSlider?.frame = CGRectMake(60, 25, controlsWidth! - 70, 30)
        playSlider?.setThumbImage(sliderThumb, forState: .Normal)
        playSlider?.addTarget(self, action: #selector(scrubAudio), forControlEvents: .ValueChanged)
        controlsView.addSubview(playSlider!)
        
        //playTitleLabel.frame = CGRectMake(4, controlsYPos! - (self.controlsHeight! + (self.navigationController?.navigationBar.frame.size.height)!), controlsWidth! - 8, 15)
        playTitleLabel.frame = CGRectMake(60, 12, controlsWidth! - 134, 15)
        playTitleLabel.text = "Hello everybody today is a good Sermon!"
        playTitleLabel.font = UIFont(name: "FormaDJRText-Regular", size: 14.0)
        playTitleLabel.textAlignment = .Left
        playTitleLabel.textColor = UIColor.blackColor()
       // playTitleLabel.backgroundColor = UIColor.clearColor()
        controlsView.addSubview(playTitleLabel)
        
        playLabelStart.frame = CGRectMake(60, 50, 35, 15)
        playLabelStart.text = "00:00"
        playLabelStart.font = UIFont(name: "FormaDJRText-Regular", size: 11.0)
        playLabelStart.textColor = UIColor.darkGrayColor()
        controlsView.addSubview(playLabelStart)
        
        playLabelEnd.frame = CGRectMake(60 + controlsWidth! - 70 - 28, 50, 35, 15)
        playLabelEnd.text = "00:00"
        playLabelEnd.font = UIFont(name: "FormaDJRText-Regular", size: 11.0)
        playLabelEnd.textColor = UIColor.darkGrayColor()
        controlsView.addSubview(playLabelEnd)
        
    }
    
    func makeUnHideControl()
    {
        self.unHideXPos = (controlsWidth! - 72)
        self.unHideYPos = view.frame.height
        unHideButton.frame = CGRectMake(unHideXPos!, unHideYPos!, 60, 23)
        //unHideButton.setImage(unHideImage, forState: .Normal)
        unHideButton.setTitle("Show", forState: .Normal)
        unHideButton.titleLabel?.font = UIFont(name: "FormaDJRText-Regular", size: 16.0)
        unHideButton.tintColor = UIColor.blackColor()
        //unHideButton.backgroundColor = UIColor(red: 237/255.0, green: 235/255.0, blue: 232/255.0, alpha: 1)
        unHideButton.backgroundColor = UIColor.lightGrayColor()
        unHideButton.addTarget(self, action: #selector(unHideControls), forControlEvents: .TouchUpInside)
        unHideButton.layer.cornerRadius = 10.0
        unHideButton.clipsToBounds = true
        view.addSubview(unHideButton)
    
    }
    
    @IBAction func pauseFromAnotherView(sender: AnyObject)
    {
        if player2.currentItem != nil
        {
            let aSermon = arrayOfOnePlaying[0]
            if !aSermon.isNowPlaying == true
            {
                aSermon.isNowPlaying = !aSermon.isNowPlaying
                player2.pause()
                pButtn.setImage(playImage, forState: .Normal)
            }
        }

        
    }
    
    @IBAction func newPlayButtonAction(sender: AnyObject)
    {
        let aSermon = arrayOfOnePlaying[0]
        aSermon.isNowPlaying = !aSermon.isNowPlaying
        if aSermon.isNowPlaying
        {
            player2.pause()
            pButtn.setImage(playImage, forState: .Normal)
        }
        else
        {
            player2.play()
            pButtn.setImage(pauseImage, forState: .Normal)
        }
    }
    
    @IBAction func scrubAudio(sender: UISlider)
    {
        let seekTime = CMTimeMakeWithSeconds(Double(sender.value) * CMTimeGetSeconds(player2.currentItem!.asset.duration), 600)
        
       // player2.seekToTime(seekTime)
        
        player2.seekToTime(seekTime) { (true) in
            self.reallySmallLoader.stopAnimating()
            self.player2.play()
        }
        makeReallySmallLoadIndicator()
        
    }

    
    
    // MARK: - Timer update status of player
    func startTimer() {
        playingTimer.invalidate() // just in case this button is tapped multiple times
        
        // start the timer
        playingTimer = NSTimer.scheduledTimerWithTimeInterval(0.25, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    }
    
    // stop timer
    func cancelTimer() {
        playingTimer.invalidate()
    }
    
    func timerAction() {
        let aSermon = arrayOfOnePlaying[0]
        playLabelEnd.text = CMTimeMakeWithSeconds(CMTimeGetSeconds(player2.currentItem!.asset.duration) - CMTimeGetSeconds(player2.currentTime()), 600).drrationText
        playLabelStart.text = CMTimeMakeWithSeconds(CMTimeGetSeconds(player2.currentItem!.currentTime()), 600).drrationText
        let rate = Float(CMTimeGetSeconds(player2.currentTime())/CMTimeGetSeconds(player2.currentItem!.asset.duration))
        
        playSlider!.setValue(rate, animated: false)
        print(player2.rate)
        if playLabelEnd.text! == player2.currentItem!.asset.duration.drrationText && !smallLoader.isAnimating() && player2.rate <= 0.98
        {
            makeSmallLoadIndicator()
            
        }
       // else if playLabelEnd.text! != player2.currentItem!.asset.duration.drrationText && smallLoader.isAnimating() && player2.rate >= 0.95
        else if smallLoader.isAnimating() && player2.rate >= 0.98
        {
            smallLoader.stopAnimating()
        }
     //   theTime = CMTimeMakeWithSeconds(CMTimeGetSeconds(player.currentItem!.currentTime()), 1)
     //   print(theTime)
        
      /*         *************** Consider this for when player is done!!! ***************************
        @IBAction func buttonAction(sender : AnyObject) {
            if (self.audioPlayer.currentItem != nil)
            {
                if state == .Playing
                {
                    self.audioPlayer.pause()
                }
                else
                {
                    if (self.audioPlayer.currentItem?.currentTime().durationText == self.audioPlayer.currentItem?.asset.duration.durationText)
                    {
                        self.audioPlayer.seekToTime(kCMTimeZero)
                    }
                
                    self.audioPlayer.play()
                }
            }
        }
        */

        
        // Call delegate
        if (CMTimeGetSeconds(player2.currentItem!.asset.duration) - CMTimeGetSeconds(player2.currentTime()) < 1.0)
        {
            cancelTimer()
            
           // player2.seekToTime(CMTime(seconds: 0, preferredTimescale: 1))
           // startTimer()
            
           // player2.pause()
            pButtn.setImage(playImage, forState: .Normal)
            print("playerDidFinishPlaying")
            aSermon.isNowPlaying = !aSermon.isNowPlaying
            // self.delegate.playerDidFinishPlaying(self)
        }
        
        //        if self.delegate != nil {
        //            self.delegate.playerDidUpdateCurrentTimePlaying(self, currentTime: (self.audioPlayer.currentItem?.currentTime())!)
        //        }
    }
    
    func unHideControls()
    {
        UIView.animateWithDuration(0.2, animations: {
            // Fade the Button first
            self.unHideButton.alpha = 0
          //  let newButtonPoint = CGPoint(x: self.controlsWidth!/2, y: self.controlsYPos! + (self.controlsHeight!/2) + 300)
          //  self.unHideButton.center = newButtonPoint
            self.view.layoutIfNeeded()
            }) { (true) in
                UIView.animateWithDuration(0.2) {
                    // Move the Controls second
                    let newControlsPoint = CGPoint(x: self.controlsWidth!/2, y: self.controlsYPos! + (self.controlsHeight!/2))
                    self.controlsView.center = newControlsPoint
                    
                    // Park the Button off screen
                    self.unHideButton.alpha = 0.2
                    let newButtonPoint = CGPoint(x: self.unHideXPos! + 30, y: self.controlsYPos! + 150) //+ (self.navigationController?.navigationBar.frame.size.height)!)
                    self.unHideButton.center = newButtonPoint

                    self.view.layoutIfNeeded()
                }
        }
    }
    
    func doHideControls()
    {
        UIView.animateWithDuration(0.3, animations:  {
            // Move the Controls down first
           // let newControlsPoint = CGPoint(x: (self.controlsWidth!/2), y: (self.controlsYPos! + (self.controlsHeight!/2)) - (self.controlsHeight! - (self.navigationController?.navigationBar.frame.size.height)!))
            let newControlsPoint = CGPoint(x: (self.controlsWidth!/2), y: self.controlsYPos! + 150)

            self.controlsView.center = newControlsPoint
            self.view.layoutIfNeeded()
        }) { (true) in
            UIView.animateWithDuration(0.3) {
                // Move the Button second
                let newButtonPoint = CGPoint(x: self.unHideXPos! + 30, y: self.view.frame.height - (self.navigationController?.navigationBar.frame.size.height)! - 58)
                self.unHideButton.alpha = 1
                self.unHideButton.center = newButtonPoint
                self.view.layoutIfNeeded()
            }
        }
    }


    
    
    
//    @IBAction func hidePressed(sender: UIBarButtonItem)
//    {
//        moveTheBox()
//    }

    
    
    func reloadFromAPI()
    {

        //code to execute during refresher
        resetIncrementer()

            for aAudRlm in audioRlmItems
            {
                if !checkArrayAudioRlm.contains(aAudRlm.id)
                {
                    checkArrayAudioRlm.append(aAudRlm.id)
                }
                print(aAudRlm.id)
            }

        theseVideosString = "/users/northlandchurch/albums/3446210/videos?per_page=\(perPage)"

        anApiController.syncTheSermons(arrayOfSermonVideos)
        anApiController.purgeSermons()
        anApiController.getVideoSermonsDataFromVimeo(theseVideosString)
        
    }
    
    
    func convertArrayToSharedRealmObjcts(arrayOfAudios: [Video])
    {
        var sorter = 1
        try! audioRealm.write({
            
            for audio in arrayOfAudios
            {
                let aRlmAudio = SermonAudioRlm()
                aRlmAudio.id = audio.convertToURINumber(audio.uri!)
                
                if !checkArrayAudioRlm.contains(aRlmAudio.id)
                {
                    aRlmAudio.sortOrder = sorter
                    aRlmAudio.descript = audio.descript
                    aRlmAudio.duration = audio.duration
                    aRlmAudio.fileURLString = audio.fileURLString
                    aRlmAudio.imageURLString = audio.imageURLString
                    aRlmAudio.isDownloading = audio.isDownloading
                    aRlmAudio.isNowPlaying = audio.isNowPlaying
                    aRlmAudio.m3u8file = audio.m3u8file
                    aRlmAudio.name = audio.name
                    aRlmAudio.showingTheDownload = audio.showingTheDownload
                    aRlmAudio.tagForAudioRef = audio.tagForAudioRef
                    aRlmAudio.videoLink = audio.videoLink
                    aRlmAudio.uri = audio.uri
                    aRlmAudio.videoURL = audio.videoURL
                    sorter = sorter + 1
                    audioRealm.add(aRlmAudio, update: true)
                }
            }
        })
        
    }
    
    
    func gotTheVideos(theVideos: [Video])
    {
        smallLoader.stopAnimating()
        for aVid in theVideos
        {
            if !checkArrayAudioRlm.contains(aVid.convertToURINumber(aVid.uri!))
            {
                arrayOfSermonVideos.append(aVid)
            }
        }
      //  arrayOfSermonVideos = theVideos //TODO: Something here is messing with UI losing track of download status. Things are getting reset!!
        print("array of audio has \(arrayOfSermonVideos.count)")
        
        //if incrementer == 0
        //{
        convertArrayToSharedRealmObjcts(theVideos)
        getFromRealm()
        arrayOfSermonVideos = []
        for audRlm in audioRlmItems
        {
            if let rAudio = Video.makeAudioFromRlmObjct(audRlm)
            {
                arrayOfSermonVideos.append(rAudio)
            }
        }


       // presentAsRealm()
        //}
        
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
    }
    
    
    func loadMoreAutoRetrieve()
    {
        if incrementer < 6
        {
            makeSmallLoadIndicator()
            //incrementer = incrementer + 1
            
            
            for aAudRlm in audioRlmItems
            {
                if !checkArrayAudioRlm.contains(aAudRlm.id)
                {
                    checkArrayAudioRlm.append(aAudRlm.id)
                }
                print(aAudRlm.id)
            }
            
            theseVideosString = "/users/northlandchurch/albums/3446210/videos?per_page=\(perPage)"
            
            anApiController.syncTheSermons(arrayOfSermonVideos)
            anApiController.purgeSermons()
            anApiController.getVideoSermonsDataFromVimeo(theseVideosString)
        }
    }
    //************************  REALM  *****************************

    
    func stopRefresher()
    {
        refresher.endRefreshing()
    }
    
    
    
    func dismiss() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func downloadsTapped(sender: UIBarButtonItem)
    {
        let detailVC = self.storyboard?.instantiateViewControllerWithIdentifier("DownloadsTableViewController") as! DownloadsTableViewController
        navigationController?.pushViewController(detailVC, animated: true)
        
    }
    
    
    @IBAction func nowPlayingTapped(sender: UIBarButtonItem)
    {
//        let playingVC = self.storyboard?.instantiateViewControllerWithIdentifier("NowPlayingViewController") as! NowPlayingViewController
//        navigationController?.presentViewController(playingVC, animated: true, completion: nil)
        
        let detailVC = self.storyboard?.instantiateViewControllerWithIdentifier("NowPlayingViewController") as! NowPlayingViewController
        navigationController?.pushViewController(detailVC, animated: true)
       // aSermon.isNowPlaying = true
        if let playingSermon = nowPlayingRlmItems.last
        {
           if let aSermon = Video.makeAudioFromRlmObjct(playingSermon)
           {
             detailVC.aSermon = aSermon
           }
        }
        
        
    }
    
    
    
    @IBAction func unwindToHome(segue: UIStoryboardSegue)
    {
        let sourceController = segue.sourceViewController as! MenuTableViewController
        //self.title = sourceController.currentItem
    }
    
    
    
    /*
     func addLoadingIndicator()
     {
     self.view.addSubview(activityIndicator)
     activityIndicator.alpha = 0.75
     activityIndicator.center = self.view.center
     }
     */
    
    func setupAudioSession()
    {
        
        var mySession = AVAudioSession()
        // mySession.setActive(true, withOptions: .)
        //  try? mySession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, withOptions: [])
        // try! AVAudioSession.sharedInstance().setActive(true)
        
        
    }

    
    
    func makeLoadActivityIndicator()
    {
        loadingIndicator.activityIndicatorViewStyle = .WhiteLarge
        loadingIndicator.color = UIColor.grayColor()
        loadingIndicator.frame = CGRect(x: self.view.frame.width / 2 - 75, y: self.view.frame.height / 2 - 75, width: 150, height: 150)
        loadingIndicator.startAnimating()
        view.addSubview(loadingIndicator)
        
    }
    
    func makeSmallLoadIndicator()
    {
        smallLoader.activityIndicatorViewStyle = .White
        smallLoader.color = UIColor.grayColor()
        smallLoader.frame = CGRect(x: self.view.frame.width / 2 - 30, y: self.view.frame.height * 0.80 + 20, width: 60, height: 60)
        smallLoader.startAnimating()
        view.addSubview(smallLoader)
        
    }
    
    
    
    func makeReallySmallLoadIndicator()
    {
        reallySmallLoader.activityIndicatorViewStyle = .White
        
        reallySmallLoader.color = UIColor.lightGrayColor()
        reallySmallLoader.frame = CGRect(x: self.view.frame.width / 2 - 30, y: self.view.frame.height * 0.80 + 20, width: 60, height: 60)
        reallySmallLoader.clipsToBounds = true
        reallySmallLoader.startAnimating()
        view.addSubview(reallySmallLoader)
        
    }


    
    
    
    
    func resetIncrementer()
    {
        incrementer = 1
        
        theseVideosString = "/users/northlandchurch/albums/3446210/videos?page=\(incrementer)&per_page=\(perPage)"
        
    }

    
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return arrayOfSermonVideos.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! ThirdCollectionViewCell
        
        // Configure the cell
        
        cell.loadingView.alpha = 0
      //  cell.downloadButton.alpha = 1
      //  cell.downloadButton.userInteractionEnabled = true
      //  let downloadCloudImage = UIImage(named: "Download From Cloud-50.png")
       //  DONT USE THIS let finishedDownloadImage = UIImage(named: "blackDot.png")
        
        
      //  cell.downloadButton.setImage(downloadCloudImage, forState: .Normal)
        
//        let playImage = UIImage(named: "btn-play.png")
//        let pauseImage = UIImage(named: "pause-button-new.png")
//        cell.playPauseButton.setImage(playImage, forState: .Normal)
//        cell.deleteButton.alpha = 0
//        cell.deleteButton.userInteractionEnabled = false
        
        
        //let aPodcast = podcastItems[indexPath.row]
        let aVid = arrayOfSermonVideos[indexPath.row]
       // let origSermon = arrayOfSermonVideos[indexPath.row]
        
//        if aVid.isNowPlaying == true
//        {
//            cell.playPauseButton.setImage(pauseImage, forState: .Normal)
//        }
        
        
        let part1Name = aVid.name?.componentsSeparatedByString("(")
        
        cell.titleLabel.text = part1Name![0]
        cell.speakerLabel.text = aVid.descript
        cell.podcastImageView.image = UIImage(named: "WhiteBack.png")
        cell.listenNowLabel.setTitle("LISTEN NOW", forState: .Normal)
        cell.listenNowLabel.titleLabel?.font = UIFont(name: "FormaDJRText-Bold", size: 17.0)
        cell.listenNowLabel.tintColor = UIColor.darkGrayColor()
        cell.listenNowLabel.userInteractionEnabled = true
        
        
        
        if arrayOfOnePlaying.count > 0
        {
        if aVid.tagForAudioRef! == arrayOfOnePlaying[0].tagForAudioRef!
        {
            cell.listenNowLabel.setTitle("NOW PLAYING", forState: .Normal)
            cell.listenNowLabel.titleLabel?.font = UIFont(name: "FormaDJRText-Bold", size: 17.0)
            cell.listenNowLabel.tintColor = UIColor.redColor()
            cell.listenNowLabel.userInteractionEnabled = true

            
        }
        }
        
        
        
        //**********************************************************************************
        //**********************************************************************************
        // STUFF FOR LOADING INDICATOR & PLAYBAR
       /*
        if aVid.isDownloading == true // && aVid.showingTheDownload == false
        {
            cell.loadingView.alpha = 1
        }
        */
        
//        if aVid.showingTheDownload == true
//        {
//            cell.downloadButton.userInteractionEnabled = false
//            cell.downloadButton.alpha = 0
//            cell.deleteButton.alpha = 1.0
//            cell.deleteButton.userInteractionEnabled = false
//        }
        
        
        //        let weekNumber = thisWeek - indexPath.row
        //        cell.initComponent("https://s3.amazonaws.com/nacdvideo/2016/2016Week\(weekNumber).mp3")
        //**********************************************************************************
        //**********************************************************************************
        
        
        //let myURL = arrayOfSermonVideos[indexPath.row].imageURLString!
        
        
        let placeHolder = UIImage(named: "WhiteBack.png")
        let myURL = arrayOfSermonVideos[indexPath.row].imageURLString!
        let realURL = NSURL(string: myURL)
        cell.podcastImageView.sd_setImageWithURL(realURL, placeholderImage: placeHolder, options: .ProgressiveDownload)
        
        
        
        cell.layer.shadowOffset = CGSizeMake(10, 10)
        cell.layer.shadowColor = UIColor.blackColor().CGColor
        cell.layer.shadowRadius = 3
        cell.layer.shadowOpacity = 0.14
        
        cell.clipsToBounds = false
        
        let shadowFrame: CGRect = (cell.layer.bounds)
        let shadowPath: CGPathRef = UIBezierPath(rect: shadowFrame).CGPath
        cell.layer.shadowPath = shadowPath
        
                if indexPath.row == arrayOfSermonVideos.count - 1
                {
                    if arrayOfSermonVideos.count < 100
                    {
                    perPage = audioRlmItems.count + 15
                   // incrementer = incrementer + 1
                    loadMoreAutoRetrieve()
                    }
                }
        
        // print(aVid.tagForAudioRef!)
        
        return cell
    }
    
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        
//        let aSermonItem = arrayOfSermonVideos[indexPath.row]
//        let detailVC = self.storyboard?.instantiateViewControllerWithIdentifier("NowPlayingViewController") as! NowPlayingViewController
//        navigationController?.pushViewController(detailVC, animated: true)
//        detailVC.aSermon = aSermonItem
        
        
    }

    
    
    @IBAction func listenNowTapped(sender: UIButton)
    {
        
        let contentView = sender.superview
        let cell = contentView?.superview as! ThirdCollectionViewCell
        let thisIndexPath = collectionView?.indexPathForCell(cell)
        let aSermon = arrayOfSermonVideos[thisIndexPath!.row]
        sender.setTitle("NOW PLAYING", forState: .Normal)
        sender.titleLabel?.font = UIFont(name: "FormaDJRText-Bold", size: 17.0)
        sender.tintColor = UIColor.redColor()

        for sermonX in arrayOfSermonVideos
        {
            sermonX.isNowPlaying = false
        }
        arrayOfOnePlaying.removeAll()
        arrayOfOnePlaying.append(aSermon)
        makeSmallLoadIndicator()
        
        if player2.currentItem != nil
        {
           // player2.pause()
           // cancelTimer()
        }
        pButtn.setImage(pauseImage, forState: .Normal)
        playFromControls()
        unHideControls()
        
        let incomingButton: UIButton = sender
        arrayOfPlayButton.append(incomingButton)
        arrayOfIndexPaths.append(thisIndexPath!)
        arrayForUpdateVideos.append(aSermon)

        if arrayOfPlayButton.count > 1
        {
            if arrayOfPlayButton[0] == arrayOfPlayButton.last
            {
                arrayOfPlayButton.removeAll()
                arrayOfIndexPaths.removeAll()
                arrayForUpdateVideos.removeAll()
            }
            else
            {
                let changeButtonAtPath = arrayOfIndexPaths[0]
               // arrayForUpdateVideos[0].isNowPlaying = !arrayForUpdateVideos[0].isNowPlaying
                arrayOfPlayButton[0].setTitle("LISTEN NOW", forState: .Normal)
                arrayOfPlayButton[0].titleLabel?.font = UIFont(name: "FormaDJRText-Bold", size: 17.0)
                arrayOfPlayButton[0].tintColor = UIColor.darkGrayColor()
                arrayOfPlayButton[0].userInteractionEnabled = true
                self.collectionView?.reloadItemsAtIndexPaths([changeButtonAtPath])
                arrayOfPlayButton.removeAtIndex(0)
                arrayOfIndexPaths.removeAtIndex(0)
                arrayForUpdateVideos.removeAtIndex(0)
            }
        }

        
//        let detailVC = self.storyboard?.instantiateViewControllerWithIdentifier("NowPlayingViewController") as! NowPlayingViewController
//        navigationController?.pushViewController(detailVC, animated: true)
//        aSermon.isNowPlaying = true
//        detailVC.aSermon = aSermon

        
        
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        guard keyPath != nil else { // a safety precaution
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
            return
        }
        
        switch keyPath! {
        case "playbackBufferEmpty" :
            if player2.currentItem!.playbackBufferEmpty {
                print("no buffer")
                //let playerItem = player2.currentItem!
                
//                if object == playerItem && keyPath.isEqualToString("playbackBufferEmpty")
//                {
//                    if (playerItem.playbackBufferEmpty)
//                    {
//                        NSNotificationCenter.defaultCenter.postNotificationName:("message" object:@"Buffering...")
//                        
//                        if([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground)
//                        {
//                            task = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^(void) {
//                                }];
//                        }
//                    }
//                }
                
                // do something here to inform the user that the file is buffering
            }
            
        case "playbackLikelyToKeepUp" :
            if player2.currentItem!.playbackLikelyToKeepUp {
                self.player2.play()
                // remove the buffering inidcator if you added it
            }
        default :
            print("Buffer status unknown?!")
        }
    }
    
     func playFromControls()
    {
        let aSermon = arrayOfOnePlaying[0]
        let part1Name = aSermon.name?.componentsSeparatedByString("(")
        playTitleLabel.text = part1Name![0]

        
            if let audioUrl = NSURL(string: "https://s3.amazonaws.com/nacdvideo/\(aSermon.tagForAudioRef!).mp3")
            {
    
                // then lets create your document folder url
                let documentsDirectoryURL =  NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    
                // lets create your destination file url
                let destinationUrl = documentsDirectoryURL.URLByAppendingPathComponent(audioUrl.lastPathComponent ?? "audio.mp3")
                print("This is the destURL-->> \(destinationUrl)")
    
                // to check if it exists before downloading it
                if NSFileManager().fileExistsAtPath(destinationUrl.path!) {
                    print("The file already exists at path")
    
    
                    let audioFilePath =  destinationUrl.path!
    
                    let audioFileUrl = NSURL.fileURLWithPath(audioFilePath) //   .fileURL(withPath: audioFilePath!)
    
                    //*********Sets up audio session to play in backGround********
                    do {
                        try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                        print("AVAudioSession Category Playback OK")
                        do {
                            try AVAudioSession.sharedInstance().setActive(true)
                            print("AVAudioSession is Active")
                        } catch let error as NSError {
                            let alertController1 = UIAlertController(title: "Sorry, could not start playback.", message: "Please try again.", preferredStyle: .Alert)
                            // Add the actions
                            alertController1.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
                            alertController1.addAction(UIAlertAction(title: "Delete", style: .Default, handler: nil))
                            // Present the controller
                            self.presentViewController(alertController1, animated: true, completion: nil)
    
                            print(error.localizedDescription)
                        }
                    } catch let error as NSError {
                        print(error.localizedDescription)
                    }
                    //***********************************************************
    
    
                    do {
    //                    if audioPlayer.playing
    //                    {
    //                        audioPlayer.stop()
    //                       // audioPlayer.prepareToPlay()
    //                    }
                        audioPlayer =  try AVAudioPlayer(contentsOfURL: audioFileUrl)      //(contentsOf: audioFileUrl)
                        print("playing from disk")
    
                    } catch let error1 as NSError {
                        let alertController1 = UIAlertController(title: "Sorry, could not start playback.", message: "Please try again.", preferredStyle: .Alert)
                        // Add the actions
                        alertController1.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
                        alertController1.addAction(UIAlertAction(title: "Delete", style: .Default, handler: nil))
                        // Present the controller
                        self.presentViewController(alertController1, animated: true, completion: nil)
                        print(error1)
                    }
    
    
                    if !aSermon.isNowPlaying
                    {
                        audioPlayer.play()
                        //sender.setImage(pauseImage, forState: .Normal)
                    }
                    else
                    {
                        audioPlayer.stop()
                        //sender.setImage(playImage, forState: .Normal)
                    }
    
                    // if the file doesn't exist
                }
                    
                else
                    
    // ************ SEEMS LIKE THIS IS THE ONLY CASE WORKING FOR NOW ******************
                {
                    let playerItem2 = AVPlayerItem(URL: NSURL(string: "https://s3.amazonaws.com/nacdvideo/\(aSermon.tagForAudioRef!).mp3")! )

                   // player2.pause()
                    if player2.currentItem == nil
                    {
                        player2 = AVPlayer(playerItem: playerItem2)
                       // player2.currentItem?.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .New, context: nil)
                       // player2.currentItem?.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .New, context: nil)
                    }
                    else
                    {
                        //player2.removeObserver(self, forKeyPath: "playbackBufferEmpty")
                        //player2.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
                        player2.replaceCurrentItemWithPlayerItem(playerItem2)
                        //player2.currentItem?.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .New, context: nil)
                        //player2.currentItem?.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .New, context: nil)

                        
                    }
    
    

                    print("streaming audio")
                    // player.volume = 1
    
                    player2.rate = 1.0
    
                    if !aSermon.isNowPlaying
                    {
                        player2.play()
                        startTimer()
                    }
                    else if aSermon.isNowPlaying
                    {
                        player2.pause()
                    }
                    
                   // aSermon.isNowPlaying = !aSermon.isNowPlaying

                    
                    if aSermon.isNowPlaying
                    {
                        // streamPlayer.play()
                        //self.audioPlayer.play()
                       // sender.setImage(pauseImage, forState: .Normal)
                    }
                    else
                    {
                        //streamPlayer.pause()
                        //self.audioPlayer.stop()
                       // sender.setImage(playImage, forState: .Normal)
                    }
                }
                
                
            }

        
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
        if segue.identifier == "NowSegue"
        {
            let navVC = segue.destinationViewController as! UINavigationController
            let nowPlayViewController = navVC.viewControllers[0] as! NowPlayingViewController
           // navVC.pushViewController(nowPlayViewController, animated: true)
            //nowPlayViewController.skipSetup = true
           // nowPlayViewController.aSermon = arrayOfSermonVideos[2]
            
            
        }
        
//        if segue.identifier == "GoToDownloadSegue2"
//        {
//            let dwnldVC = segue.destinationViewController as! DownloadsTableViewController
//            self.parentViewController?.presentViewController(dwnldVC, animated: true, completion: nil)
//           // navigationController?.presentViewController(dwnldVC, animated: true, completion: nil)
//            
//            //let presentStyle = UIModalPresentationStyle.OverFullScreen
//           // self.presentViewController(dwnldVC, animated: true, completion: nil)  // (() -> Void)?)
//            
//        }
//         if segue.identifier == "GoToNowPlayingSegue"
//        {
//            let destVC = segue.destinationViewController as! UINavigationController
//            let nowPlayingViewController = destVC.viewControllers[0] as! DownloadsTableViewController
//            navigationController?.showViewController(nowPlayingViewController, sender: sender)//  pushViewController(nowPlayingViewController, animated: true)
//            
////            let detailVC = self.storyboard?.instantiateViewControllerWithIdentifier("DownloadsTableViewController") as! DownloadsTableViewController
////            navigationController?.pushViewController(detailVC, animated: true)
//
//
//            
//        }
        
    }
    
    
    
    
    @IBAction func downloadTapped(sender: UIButton)
    {
        
        
        let contentView = sender.superview
        let cell = contentView?.superview as! ThirdCollectionViewCell
        let thisIndexPath = collectionView?.indexPathForCell(cell)
        let aSermon = arrayOfSermonVideos[thisIndexPath!.row]
        let origSermon = audioRlmItems[thisIndexPath!.row]
        
        let detailVC = self.storyboard?.instantiateViewControllerWithIdentifier("DownloadsTableViewController") as! DownloadsTableViewController
        navigationController?.pushViewController(detailVC, animated: true)
        //aSermon.isNowPlaying = true
        
        aSermon.isDownloading = !aSermon.isDownloading
        detailVC.aSermon = aSermon

        collectionView?.reloadItemsAtIndexPaths([thisIndexPath!])
        
        
//        if let audioUrl = NSURL(string: "https://s3.amazonaws.com/nacdvideo/\(aSermon.tagForAudioRef!).mp3")
//        {
//            
//            // then lets create your document folder url
//            let documentsDirectoryURL =  NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
//            
//            // lets create your destination file url
//            let destinationUrl = documentsDirectoryURL.URLByAppendingPathComponent(audioUrl.lastPathComponent ?? "audio.mp3")
//            print("This is the destURL-->> \(destinationUrl)")
//            
//            // to check if it exists before downloading it
//            if NSFileManager().fileExistsAtPath(destinationUrl.path!) {
//                print("The file already exists at path")
//                
//                
//                // if the file doesn't exist
//            } else {
//                
//                // you can use NSURLSession.sharedSession to download the data asynchronously
//                NSURLSession.sharedSession().downloadTaskWithURL(audioUrl, completionHandler: { (location, response, error) -> Void in
//                    guard let location = location where error == nil else { return }
//                    do {
//                        // after downloading your file you need to move it to your destination url
//                        try NSFileManager().moveItemAtURL(location, toURL: destinationUrl)
//                        print("Finished downloading")
//                        
//                        aSermon.isDownloading = !aSermon.isDownloading
//                        aSermon.showingTheDownload = !aSermon.showingTheDownload
//                        
//                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                            
//                            self.collectionView?.reloadItemsAtIndexPaths([thisIndexPath!])
//                            self.updateRLMForDownload(origSermon)
//                            
//                            
//                        })
//                        
//                        
//                    } catch let error as NSError {
//                        let alertController1 = UIAlertController(title: "Sorry, there was a problem downloading \(aSermon.name!)", message: "Please try again.", preferredStyle: .Alert)
//                        // Add the actions
//                        alertController1.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
//                        alertController1.addAction(UIAlertAction(title: "Delete", style: .Default, handler: nil))
//                        // Present the controller
//                        self.presentViewController(alertController1, animated: true, completion: nil)
//
//                        print(error.localizedDescription)
//                    }
//                }).resume()
//               
//                
//                
//
//                
//
//            }
//        }
        
    }
    
    func updateRLMForDownload(origSermon: SermonAudioRlm)
    {
        try! audioRealm.write({
            origSermon.showingTheDownload = !origSermon.showingTheDownload
            audioRealm.add(origSermon, update: true)
            print("downloaded: \(origSermon.name)")
        })

        
    }
    
    
    
    
    @IBAction func deleteTapped(sender: UIButton)
    {
        let contentView = sender.superview
        let cell = contentView?.superview as! ThirdCollectionViewCell
        let thisIndexPath = collectionView?.indexPathForCell(cell)
        let aSermon = arrayOfSermonVideos[thisIndexPath!.row]
        //let origSermon = arrayOfSermonVideos[thisIndexPath!.row]
        
        if let audioUrl = NSURL(string: "https://s3.amazonaws.com/nacdvideo/\(aSermon.tagForAudioRef!).mp3")
        {
            
            // then lets create your document folder url
            let documentsDirectoryURL =  NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
            
            // lets create your destination file url
            let destinationUrl = documentsDirectoryURL.URLByAppendingPathComponent(audioUrl.lastPathComponent ?? "audio.mp3")
            print("This is the destURL-->> \(destinationUrl)")
            
            // to check if it exists before deleting it
            if NSFileManager().fileExistsAtPath(destinationUrl.path!) {
                print("The file already exists at path")
                
                 // Create the alert controller
                 let alertController1 = UIAlertController(title: "Are you sure you want to delete this sermon?", message: "\(aSermon.name!)", preferredStyle: .Alert)
                 // Add the actions
                 alertController1.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
                 alertController1.addAction(UIAlertAction(title: "Delete", style: .Default, handler: nil))
                 // Present the controller
                 self.presentViewController(alertController1, animated: true, completion: nil)
                
                do
                {
                    
                    try NSFileManager().removeItemAtPath(destinationUrl.path!)
                    print("Audio deleted from disk")
                    
                    aSermon.showingTheDownload = !aSermon.showingTheDownload
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        self.collectionView?.reloadItemsAtIndexPaths([thisIndexPath!])
                        
                    })
                    /*
                    try! audioRealm.write({
                        aSermon.showingTheDownload = !aSermon.showingTheDownload
                        audioRealm.add(aSermon, update: true)
                    })
                    */

                    
                } catch let error1 as NSError {
                    let alertController1 = UIAlertController(title: "Sorry, there was a problem deleting \(aSermon.name!)", message: "Please try again.", preferredStyle: .Alert)
                    // Add the actions
                    alertController1.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
                    alertController1.addAction(UIAlertAction(title: "Delete", style: .Default, handler: nil))
                    // Present the controller
                    self.presentViewController(alertController1, animated: true, completion: nil)
                    print(error1)
                }
            }
            else
            {
                // create the alert
                let alert = UIAlertController(title: "\(aSermon.name!)", message: "This sermon has not been downloaded", preferredStyle: .Alert)
                
                // add an action (button)
                alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                
                // show the alert
                self.presentViewController(alert, animated: true, completion: nil)
            }
            
            let origSermon = audioRlmItems[thisIndexPath!.row]
            
            try! audioRealm.write({
                origSermon.showingTheDownload = !origSermon.showingTheDownload
                audioRealm.add(origSermon, update: true)
            })

        }
        
        
    }
    
    
//    @IBAction func playPauseTapped(sender: UIButton)
//    {
//        
//      
//       // isPlaying = !isPlaying
//        let contentView = sender.superview
//        let cell = contentView?.superview as! ThirdCollectionViewCell
//        let thisIndexPath = collectionView?.indexPathForCell(cell)
//        let aSermon = arrayOfSermonVideos[thisIndexPath!.row]
//        //let origSermon = arrayOfSermonVideos[thisIndexPath!.row]
//        let incomingButton: UIButton = sender
//        
//        let playImage = UIImage(named: "btn-play.png")
//        let pauseImage = UIImage(named: "pause-button-new.png")
//
//        arrayOfPlayButton.append(incomingButton)
//        arrayOfIndexPaths.append(thisIndexPath!)
//        arrayForUpdateVideos.append(aSermon)
//
//        if arrayOfPlayButton.count > 1
//        {
//        
//            if arrayOfPlayButton[0] == arrayOfPlayButton.last
//            {
//                arrayOfPlayButton.removeAll()
//                arrayOfIndexPaths.removeAll()
//                arrayForUpdateVideos.removeAll()
//            }
//            else
//            {
//                let changeButtonAtPath = arrayOfIndexPaths[0]
//                arrayForUpdateVideos[0].isNowPlaying = !arrayForUpdateVideos[0].isNowPlaying
//               // arrayOfPlayButton[0].setImage(playImage, forState: .Normal)
//                self.collectionView?.reloadItemsAtIndexPaths([changeButtonAtPath])
//                arrayOfPlayButton.removeAtIndex(0)
//                arrayOfIndexPaths.removeAtIndex(0)
//                arrayForUpdateVideos.removeAtIndex(0)
//                
//            }
//        }
//        
//        
//        //TODO: THIS WILL BREAK HERE!!!**********************FIXED!!
//            aSermon.isNowPlaying = !aSermon.isNowPlaying
//        
//        if let audioUrl = NSURL(string: "https://s3.amazonaws.com/nacdvideo/\(aSermon.tagForAudioRef!).mp3")
//        {
//        
//            // then lets create your document folder url
//            let documentsDirectoryURL =  NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
//            
//            // lets create your destination file url
//            let destinationUrl = documentsDirectoryURL.URLByAppendingPathComponent(audioUrl.lastPathComponent ?? "audio.mp3")
//            print("This is the destURL-->> \(destinationUrl)")
//            
//            // to check if it exists before downloading it
//            if NSFileManager().fileExistsAtPath(destinationUrl.path!) {
//                print("The file already exists at path")
//                
//                
//                let audioFilePath =  destinationUrl.path!
//                
//                let audioFileUrl = NSURL.fileURLWithPath(audioFilePath) //   .fileURL(withPath: audioFilePath!)
//                
//                //*********Sets up audio session to play in backGround********
//                do {
//                    try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
//                    print("AVAudioSession Category Playback OK")
//                    do {
//                        try AVAudioSession.sharedInstance().setActive(true)
//                        print("AVAudioSession is Active")
//                    } catch let error as NSError {
//                        let alertController1 = UIAlertController(title: "Sorry, could not start playback.", message: "Please try again.", preferredStyle: .Alert)
//                        // Add the actions
//                        alertController1.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
//                        alertController1.addAction(UIAlertAction(title: "Delete", style: .Default, handler: nil))
//                        // Present the controller
//                        self.presentViewController(alertController1, animated: true, completion: nil)
//
//                        print(error.localizedDescription)
//                    }
//                } catch let error as NSError {
//                    print(error.localizedDescription)
//                }
//                //***********************************************************
//                
//                
//                do {
////                    if audioPlayer.playing
////                    {
////                        audioPlayer.stop()
////                       // audioPlayer.prepareToPlay()
////                    }
//                    audioPlayer =  try AVAudioPlayer(contentsOfURL: audioFileUrl)      //(contentsOf: audioFileUrl)
//                    print("playing from disk")
//                    
//                } catch let error1 as NSError {
//                    let alertController1 = UIAlertController(title: "Sorry, could not start playback.", message: "Please try again.", preferredStyle: .Alert)
//                    // Add the actions
//                    alertController1.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
//                    alertController1.addAction(UIAlertAction(title: "Delete", style: .Default, handler: nil))
//                    // Present the controller
//                    self.presentViewController(alertController1, animated: true, completion: nil)
//                    print(error1)
//                }
//                
//                
//                if !aSermon.isNowPlaying
//                {
//                    audioPlayer.play()
//                    sender.setImage(pauseImage, forState: .Normal)
//                }
//                else
//                {
//                    audioPlayer.stop()
//                    sender.setImage(playImage, forState: .Normal)
//                }
//                
//                // if the file doesn't exist
//            }
//            else
//                
//            {
//               // player2.pause()
//                
//                
//                let playerItem2 = AVPlayerItem(URL: NSURL(string: "https://s3.amazonaws.com/nacdvideo/\(aSermon.tagForAudioRef!).mp3")! )
//                player2 = AVPlayer(playerItem: playerItem2)
//                print("streaming audio")
//                // player.volume = 1
//                
//                player2.rate = 1.0
//                
//                if aSermon.isNowPlaying
//                {
//                    player2.play()
//                }
//                else if !aSermon.isNowPlaying
//                {
//                    player2.pause()
//                }
//                
//                if aSermon.isNowPlaying
//                {
//                    // streamPlayer.play()
//                    //self.audioPlayer.play()
//                    sender.setImage(pauseImage, forState: .Normal)
//                }
//                else
//                {
//                    //streamPlayer.pause()
//                    //self.audioPlayer.stop()
//                    sender.setImage(playImage, forState: .Normal)
//                }
//            }
//            
//            
//        }
// 
//    }
 
    
    
 // END OF CLASS
}


