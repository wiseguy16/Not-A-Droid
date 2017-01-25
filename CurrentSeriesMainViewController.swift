//
//  CurrentSeriesMainViewController.swift
//  NacdFeatured
//
//  Created by Gregory Weiss on 1/4/17.
//  Copyright © 2017 NorthlandChurch. All rights reserved.
//

import UIKit
import SDWebImage
import CoreMedia
import AVKit
import AVFoundation
import RealmSwift

protocol CurrentSeriesAPIControllerProtocol
{
    func gotTheSeries(theSeries: [SeriesItem])
    func gotTheConfigSettings(theSettings: [SeriesItem])

}

protocol PickSessionWeek {
    func gotTheSessionWeek(weekToUse: Int, sessionTitle: String, sessionURL: String)
}

protocol LoginMCAPIControllerProtocol {
    func userHasSignedUpSuccessfully()
}




class CurrentSeriesMainViewController: UIViewController, CurrentSeriesAPIControllerProtocol, MenuTransitionManagerDelegate, PickSessionWeek, LoginMCAPIControllerProtocol, UITextFieldDelegate
{
    let defaultsSeries = NSUserDefaults.standardUserDefaults()
    let loginNotification = NSNotificationCenter.defaultCenter()
    

    var todayCheck: NSDate?
    var hasAlreadySignedUp = false
    
    
    
    var currentSeriesItems = [SeriesItem]()
    var configSettingArray = [SeriesItem]()
    var thisSeries: SeriesItem!
    var seriesConfigSettings: SeriesItem!
    var assetLinks: [StudyAsset]? = []
    
    
    //************************  REALM  *****************************
    let featuredRealm = Realm.sharedInstance
    var featuredRlmItems: Results<FeaturedRlm>!
    var notificationToken: NotificationToken? = nil
    
    
    //************************  REALM  *****************************
    
    var myFormatter = NSDateFormatter()
    var anApiController: CurrentSeriesAPIController!
    var loginController: LoginMCAPIController!
    
    let loadingIndicator = UIActivityIndicatorView()
    
    let menuTransitionManager = MenuTransitionManager()
    
    @IBOutlet weak var sessionPickerButton: UIButton!
    
    var dateBarBoundsY:CGFloat?
    var dateBar = UILabel()
    
    var unavailableSquare = UILabel()
    var unavailableSquare2 = UILabel()
    
    var refresher: UIRefreshControl!
    
    @IBOutlet weak var seriesScrollView: UIScrollView!
    
    @IBOutlet weak var firstNameConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var signupButtonOutlet: UIButton!
    
    
    @IBOutlet weak var loginBaseView: UIView!
    @IBOutlet weak var loginImageView: UIImageView!
    
    @IBOutlet weak var loginLabel1: UILabel!
    
//    @IBOutlet weak var emailTextField: UITextField!
//    @IBOutlet weak var firstNameTextField: UITextField!
//    @IBOutlet weak var lastNameTextField: UITextField!
    
    
    @IBOutlet weak var mainTitleLabel: UILabel!
    @IBOutlet weak var seriesImageView: UIImageView!
    @IBOutlet weak var mondayLabel: UILabel!
    @IBOutlet weak var tuesdayLabel: UILabel!
    @IBOutlet weak var wednesdayLabel: UILabel!
    @IBOutlet weak var thursdayLabel: UILabel!
    @IBOutlet weak var fridayLabel: UILabel!
    @IBOutlet weak var saturdayLabel: UILabel!
    @IBOutlet weak var weeklyVideoLabel: UILabel!
    
    @IBOutlet weak var sessionVideoImageView: UIImageView!
    @IBOutlet weak var theWeekOfLabel: UILabel!
    
    @IBOutlet weak var sessionWeekOfTitle: UILabel!
    
    @IBOutlet weak var miscLabel: UILabel!
    
    @IBOutlet weak var coverView: UIView!
    
    @IBOutlet weak var bgBaseView: UIView!
    
    
    let baseURLString = "http://www.northlandchurch.net/index.php/resources/iphone-app-getseries/"
    var thisSession = ""
    var weekNumber = "series"
    var currentWeek = "one"
    
    var studyAuthor: String = ""
    var studyTitle: String = ""
    var studyCurrentWeek = 1
    var studyTotalWeeks = 1
    
    
    var testInt = 1


    override func viewDidLoad()
    {
        super.viewDidLoad()
        todayCheck = NSDate()
        
        let loginWasDone = defaultsSeries.boolForKey("IsSignedUp")
        seriesScrollView.scrollEnabled = false
        loginNotification.addObserver(self, selector: #selector(giveAccessToContoller), name: "GoToStudy", object: nil)
       // signupButtonOutlet.layer.cornerRadius = 8.0


        if loginWasDone
        {
 // ***************  BE SURE TO UNCOMMENT THESE LINES !!!!! ************************
            loginBaseView.alpha = 0
            seriesScrollView.scrollEnabled = true
        }
        anApiController = CurrentSeriesAPIController(delegate: self)
        loginController = LoginMCAPIController(delegate: self)
        sessionPickerButton.userInteractionEnabled = false
        

       
        
        let config = Realm.Configuration()
        Realm.Configuration.defaultConfiguration = config
        
        makeLoadActivityIndicator()
        
        anApiController.getSeriesConfigurationDataFromNACD()
       // anApiController.getCurrentSeriesDataFromNACD(thisSession)
        
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(onRefresh), forControlEvents: .ValueChanged)
        seriesScrollView.insertSubview(refresher, atIndex: 0)


        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)

        
        resetDayLabels()
        checkDayOfWeek()
        let dateSeries_get = defaultsSeries.objectForKey("DateSeries") as? NSDate ?? todayCheck
        let result = Int(todayCheck!.timeIntervalSinceDate(dateSeries_get!))
        if result > 43200
        {
            makeLoadActivityIndicator()
           // if configSettingArray.count > 0
           // {
            reloadFromAPI()

           // }
        }

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        defaultsSeries.setObject(todayCheck, forKey: "DateSeries")
        
   //     defaultsSeries.setObject(hasAlreadySignedUp, forKey: "IsSignedUp")
        
        resetDayLabels()
        checkDayOfWeek()
        self.view.setNeedsDisplay()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        refresher.endRefreshing()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        checkDayOfWeek()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func giveAccessToContoller(sender: AnyObject)
    {
        print("Got notified from login")
       // if loginWasDone
       // {
            // ***************  BE SURE TO UNCOMMENT THESE LINES !!!!! ************************
            loginBaseView.alpha = 0
            seriesScrollView.scrollEnabled = true
       // }

        
        
        
    }

    
    func onRefresh()
    {
        print("refreshing")
        reloadFromAPI()
    }
    
    func resetDayLabels()
    {
        mondayLabel.numberOfLines = 1
        tuesdayLabel.numberOfLines = 1
        wednesdayLabel.numberOfLines = 1
        thursdayLabel.numberOfLines = 1
        fridayLabel.numberOfLines = 1
        saturdayLabel.numberOfLines = 1
    }
    
    
    func checkDayOfWeek()
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
        case 1:
            print("today is Sunday")
        case 2:
            mondayLabel.numberOfLines = 0
        case 3:
            tuesdayLabel.numberOfLines = 0
        case 4:
            wednesdayLabel.numberOfLines = 0
        case 5:
            thursdayLabel.numberOfLines = 0
        case 6:
            fridayLabel.numberOfLines = 0
        case 7:
            saturdayLabel.numberOfLines = 0

        default:
            //self.dateBar = UILabel()
            print("today is unknown")
            
 /*
            switch weekday
            {
            case 7:
                if case 1645...1830 = checkTime
                {
                    makeDateLabel()
                }
*/
            
        }
        
    }
    
    func userHasSignedUpSuccessfully()
    {
        print("HAS SIGNED UP!!!")
        defaultsSeries.setBool(true, forKey: "IsSignedUp")
        
        seriesScrollView.scrollEnabled = true
        
        UIView.animateWithDuration(1.0) {
            self.loginBaseView.alpha = 0
        }
        
        
    }
    
    // TextField delegate
    
//    func textFieldShouldReturn(textField: UITextField) -> Bool
//    {
//        if textField == emailTextField && emailTextField.text?.characters.count > 0
//        {
//            emailTextField.resignFirstResponder()
//            if firstNameTextField.text?.characters.count == 0
//            {
//                firstNameTextField.becomeFirstResponder()
//            }
//        }
//        else if textField == firstNameTextField && firstNameTextField.text?.characters.count > 0
//        {
//            firstNameTextField.resignFirstResponder()
//            if lastNameTextField.text?.characters.count == 0
//            {
//                //passwordTextField.text = "Please create a password"
//                lastNameTextField.becomeFirstResponder()
//            }
//        }
//        else if textField == lastNameTextField && lastNameTextField.text?.characters.count > 0
//        {
//           lastNameTextField.resignFirstResponder()
//           loginController.sendLoginToMailChimp(emailTextField.text!, firstName: firstNameTextField.text!, lastName: lastNameTextField.text!)
//            
//        }
//        return true
//    }

    
    
    func reloadFromAPI()
    {
        //code to execute during refresher

        
        anApiController.purgeSettings()
        anApiController.purgeSeries()
        
        anApiController.getSeriesConfigurationDataFromNACD()
      //  anApiController.getCurrentSeriesDataFromNACD(thisSession)
        
        refresher.endRefreshing()
        self.view.setNeedsDisplay()

        //Call this to stop refresher
    }

    
    
    @IBAction func mondayTapped(sender: UIButton)
    {
        
        let detailVC = self.storyboard?.instantiateViewControllerWithIdentifier("DevotionalDetailViewController") as! DevotionalDetailViewController
        navigationController?.pushViewController(detailVC, animated: true)
        detailVC.todayString = "Monday Devotional"
        detailVC.devoStringRef = thisSeries.session_devotional1_scripRef
        detailVC.devoStringRead = thisSeries.session_devotional1_scripture
        detailVC.devoStringReflect = thisSeries.session_devotional1_reflect
        detailVC.devoSeries = thisSeries
        detailVC.configSettings = seriesConfigSettings
        
    }
    
    @IBAction func tuesdayTapped(sender: UIButton) {
        let detailVC = self.storyboard?.instantiateViewControllerWithIdentifier("DevotionalDetailViewController") as! DevotionalDetailViewController
        navigationController?.pushViewController(detailVC, animated: true)
        detailVC.todayString = "Tuesday Devotional"
        detailVC.devoStringRef = thisSeries.session_devotional2_scripRef
        detailVC.devoStringRead = thisSeries.session_devotional2_scripture
        detailVC.devoStringReflect = thisSeries.session_devotional2_reflect
        detailVC.devoSeries = thisSeries
        detailVC.configSettings = seriesConfigSettings
    }
    
    @IBAction func wednesdayTapped(sender: UIButton) {
        let detailVC = self.storyboard?.instantiateViewControllerWithIdentifier("DevotionalDetailViewController") as! DevotionalDetailViewController
        navigationController?.pushViewController(detailVC, animated: true)
        detailVC.todayString = "Wednesday Devotional"
        detailVC.devoStringRef = thisSeries.session_devotional3_scripRef
        detailVC.devoStringRead = thisSeries.session_devotional3_scripture
        detailVC.devoStringReflect = thisSeries.session_devotional3_reflect
        detailVC.devoSeries = thisSeries
        detailVC.configSettings = seriesConfigSettings
    }
    
    @IBAction func thursdayTapped(sender: UIButton) {
        let detailVC = self.storyboard?.instantiateViewControllerWithIdentifier("DevotionalDetailViewController") as! DevotionalDetailViewController
        navigationController?.pushViewController(detailVC, animated: true)
        detailVC.todayString = "Thursday Devotional"
        detailVC.devoStringRef = thisSeries.session_devotional4_scripRef
        detailVC.devoStringRead = thisSeries.session_devotional4_scripture
        detailVC.devoStringReflect = thisSeries.session_devotional4_reflect
        detailVC.devoSeries = thisSeries
        detailVC.configSettings = seriesConfigSettings
    }
    
    @IBAction func fridayTapped(sender: UIButton) {
        let detailVC = self.storyboard?.instantiateViewControllerWithIdentifier("DevotionalDetailViewController") as! DevotionalDetailViewController
        navigationController?.pushViewController(detailVC, animated: true)
        detailVC.todayString = "Friday Devotional"
        detailVC.devoStringRef = thisSeries.session_devotional5_scripRef
        detailVC.devoStringRead = thisSeries.session_devotional5_scripture
        detailVC.devoStringReflect = thisSeries.session_devotional5_reflect
        detailVC.devoSeries = thisSeries
        detailVC.configSettings = seriesConfigSettings
    }
    
    @IBAction func saturdayTapped(sender: UIButton) {
        let detailVC = self.storyboard?.instantiateViewControllerWithIdentifier("DevotionalDetailViewController") as! DevotionalDetailViewController
        navigationController?.pushViewController(detailVC, animated: true)
        detailVC.todayString = "Saturday Devotional"
        detailVC.devoStringRef = thisSeries.session_devotional6_scripRef
        detailVC.devoStringRead = thisSeries.session_devotional6_scripture
        detailVC.devoStringReflect = thisSeries.session_devotional6_reflect
        detailVC.devoSeries = thisSeries
        detailVC.configSettings = seriesConfigSettings
    }
   
    
    @IBAction func sessionVideoTapped(sender: UIButton)
    {
        loginNotification.postNotificationName("StopAudio", object: nil)

        var videoFileString = ""
        if let trailerVideo = configSettingArray[0].trailerVideo
        {
            videoFileString = trailerVideo
        }

        
        let videoURL = NSURL(string: videoFileString)
       // let videoURL = NSURL(string: "https://player.vimeo.com/external/197967776.m3u8?s=0f8ecfbf4b7aa070c322bc327363eee372a692f3")

        let player = AVPlayer(URL: videoURL!)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.presentViewController(playerViewController, animated: true) {
            
            playerViewController.player?.play()
        }

    }
    
    @IBAction func goToWeeklySessionTapped(sender: UIButton)
    {
        
        let detailVC = self.storyboard?.instantiateViewControllerWithIdentifier("SeriesDetailViewController") as! SeriesDetailViewController
        navigationController?.pushViewController(detailVC, animated: true)
        
        detailVC.aSeries = thisSeries
        detailVC.configSettings = seriesConfigSettings
        detailVC.assetsArray = assetLinks
        //detailVC.categoryString = categoryButton.currentTitle!

        //
        //SeriesDetailViewController
    }
    
    
    @IBAction func shareButtonTapped(sender: UIButton)
    {
        // Not using!!
    }
    
    
    
    func gotTheSeries(theSeries: [SeriesItem])
    {
        assetLinks?.removeAll()
        currentSeriesItems = theSeries   //theSeries
        thisSeries = currentSeriesItems[0]
        
        checkDayOfWeek()
        
        if currentSeriesItems[0].studyAssets?.count > 0
        {
            assetLinks = currentSeriesItems[0].studyAssets
        }
        
//        if seriesConfigSettings.currentWeek! == thisSeries.studyWeekCount
//        {
//            sessionPickerButton.setTitle("Current Study▼", forState: .Normal)
//            //testInt = 1
//        }
//        else
//        {
//            sessionPickerButton.setTitle("\(thisSeries.title!)▼", forState: .Normal)
//        }

        
        configureView()
        
        
        UIView.animateWithDuration(1.0) {
            self.coverView.alpha = 0
            self.view.layoutIfNeeded()
        }
        loadingIndicator.stopAnimating()
        
        self.view.setNeedsLayout()
        
        //collectionView?.reloadData()
        
        // print("conforming to protocol")
    }
    
    func gotTheConfigSettings(theSettings: [SeriesItem])
    {
        configSettingArray = theSettings
        seriesConfigSettings = configSettingArray[0]
        testInt = seriesConfigSettings.currentWeek!
        if configSettingArray[0].studySessions != nil
        {
            if configSettingArray[0].studySessions!.count > 0
            {
                sessionPickerButton.userInteractionEnabled = true
            }
            
        }
        

        
        if let currentSeriesToGet = seriesConfigSettings.studySessions?[testInt - 1]
        {
            if let useThisSessionFirst = currentSeriesToGet.studyWeekURL
            {
                anApiController.getCurrentSeriesDataFromNACD(useThisSessionFirst)
            }
            
        }

        sessionPickerButton.setTitle("Current Study▼", forState: .Normal)
        
  // ******************** STUFF FOR LOGIN VIEW ************************
//        
//        if let picURL = configSettingArray[0].studyImage
//        {
//            let placeHolder = UIImage(named: "WhiteBack.png")
//            let realURL = NSURL(string: picURL)
//            loginImageView.sd_setImageWithURL(realURL, placeholderImage: placeHolder, options: .RefreshCached)
//        }
  // ******************** STUFF FOR LOGIN VIEW ************************


        
        setUpTheBackground()
        self.view.setNeedsLayout()
    }
    
    
    func makeLoadActivityIndicator()
    {
        loadingIndicator.activityIndicatorViewStyle = .WhiteLarge
        loadingIndicator.color = UIColor.lightGrayColor()
        loadingIndicator.frame = CGRect(x: self.view.frame.width / 2 - 75, y: self.view.frame.height / 2 - 75, width: 150, height: 150)
        loadingIndicator.startAnimating()
        view.addSubview(loadingIndicator)
        
    }
    
    func setUpTheBackground()
    {
        if let bgColorString = configSettingArray[0].studyGuideBGColor
        {
            let bgColor = hexStringToUIColor(bgColorString)
            coverView.backgroundColor = bgColor
            bgBaseView.backgroundColor = bgColor
        }
        if let picURL = configSettingArray[0].studyImage
        {
            let placeHolder = UIImage(named: "WhiteBack.png")
            let realURL = NSURL(string: picURL)
            seriesImageView.sd_setImageWithURL(realURL, placeholderImage: placeHolder, options: .RefreshCached)
        }
        if let shortTitle = configSettingArray[0].title
        {
            
            studyTitle = shortTitle.stringByDecodingXMLEntities()
        }
        if let theAuthor = configSettingArray[0].author
        {
            studyAuthor = theAuthor
        }
        
        mainTitleLabel.text = studyTitle + "\n " + studyAuthor
        
        weeklyVideoLabel.text = configSettingArray[0].trailerTitle
        
        var videoPicString = ""
        if let trailerPic = configSettingArray[0].trailerImage
        {
            videoPicString = trailerPic
        }
        
        let picURL = videoPicString
        let placeHolder = UIImage(named: "WhiteBack.png")
        let realURL = NSURL(string: picURL)
        sessionVideoImageView.sd_setImageWithURL(realURL, placeholderImage: placeHolder, options: .RefreshCached)
        sessionVideoImageView.layer.shadowOffset = CGSizeMake(1, 10)
        sessionVideoImageView.layer.shadowColor = UIColor.blackColor().CGColor
        sessionVideoImageView.layer.shadowRadius = 4
        sessionVideoImageView.layer.shadowOpacity = 0.14
        sessionVideoImageView.clipsToBounds = false
        let shadowFrame: CGRect = (sessionVideoImageView.layer.bounds)
        let shadowPath: CGPathRef = UIBezierPath(rect: shadowFrame).CGPath
        sessionVideoImageView.layer.shadowPath = shadowPath
        
        
// *********   Duplicate CODE HERE !!!!!!!!!!!!!!   **************************
        
//        UIView.animateWithDuration(1.0) {
//            self.coverView.alpha = 0
//            self.view.layoutIfNeeded()
//        }
//        loadingIndicator.stopAnimating()

// *********   Duplicate CODE HERE !!!!!!!!!!!!!!   **************************
  
    
        
        
    }
    
    
    
    func configureView()
    {

        if thisSeries != nil
        {
            let shorterTitle = seriesConfigSettings.title //  thisSeries.channel?.stringByDecodingXMLEntities() //.stringByReplacingOccurrencesOfString("Sessions", withString: "")
            let theAuthor = seriesConfigSettings.author
            let longerTitle = shorterTitle! + "\n " + theAuthor!
            mainTitleLabel.text = longerTitle
            
            let monString = NSMutableAttributedString(string: "Monday \n")
            
            let tueString = NSMutableAttributedString(string: "Tuesday \n")
            
            let wedString = NSMutableAttributedString(string: "Wednesday \n")
            
            let thuString = NSMutableAttributedString(string: "Thursday \n")
            
            let friString = NSMutableAttributedString(string: "Friday \n")
            
            let satString = NSMutableAttributedString(string: "Saturday \n")
        

            mondayLabel.attributedText = makeDevo(thisSeries.session_devotional1_scripRef, scrpRead: thisSeries.session_devotional1_scripture, scrpReflect: thisSeries.session_devotional1_reflect, dayOf: monString)
            tuesdayLabel.attributedText = makeDevo(thisSeries.session_devotional2_scripRef, scrpRead: thisSeries.session_devotional2_scripture, scrpReflect: thisSeries.session_devotional2_reflect, dayOf: tueString)
            wednesdayLabel.attributedText = makeDevo(thisSeries.session_devotional3_scripRef, scrpRead: thisSeries.session_devotional3_scripture, scrpReflect: thisSeries.session_devotional3_reflect, dayOf: wedString)
            thursdayLabel.attributedText = makeDevo(thisSeries.session_devotional4_scripRef, scrpRead: thisSeries.session_devotional4_scripture, scrpReflect: thisSeries.session_devotional4_reflect, dayOf: thuString)
            fridayLabel.attributedText = makeDevo(thisSeries.session_devotional5_scripRef, scrpRead: thisSeries.session_devotional5_scripture, scrpReflect: thisSeries.session_devotional5_reflect, dayOf: friString)
            saturdayLabel.attributedText = makeDevo(thisSeries.session_devotional6_scripRef, scrpRead: thisSeries.session_devotional6_scripture, scrpReflect: thisSeries.session_devotional6_reflect, dayOf: satString)
            
//            weeklyVideoLabel.text = thisSeries.title! + " - Session Video"
//            
//            let picURL = "https://i.vimeocdn.com/video/610825643_295x166.jpg?r=pad"
//            let placeHolder = UIImage(named: "WhiteBack.png")
//            let realURL = NSURL(string: picURL)
//            sessionVideoImageView.sd_setImageWithURL(realURL, placeholderImage: placeHolder, options: .ProgressiveDownload)
            
            theWeekOfLabel.text = thisSeries.channel?.stringByDecodingXMLEntities()
            sessionWeekOfTitle.text = (thisSeries.title?.stringByDecodingXMLEntities())! //+ " - Session 1"
        }
    
    }
    
    func convertTextStyling(wordToStyle: String?) -> NSMutableAttributedString
    {
        var attributedBody  = NSMutableAttributedString(string: "")
        if let decodedString = wordToStyle?.stringByDecodingXMLEntities()
        {
            attributedBody  = NSMutableAttributedString(string: decodedString)
        }
        // *** Create instance of `NSMutableParagraphStyle`
        let paragraphStyle = NSMutableParagraphStyle()
        // *** set LineSpacing property in points ***
        paragraphStyle.lineSpacing = 2 // Whatever line spacing you want in points
        // *** Apply attribute to string ***
        attributedBody.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attributedBody.length))
        attributedBody.addAttribute(NSKernAttributeName, value:   CGFloat(0.05), range: NSRange(location: 0, length: attributedBody.length))
        // *** Set Attributed String to your label ***
        //fullBodyLabel.attributedText = attributedBody
        
        return attributedBody
    }
    
    func makeDevo(scrpRef: String?, scrpRead: String?, scrpReflect: String?, dayOf: NSMutableAttributedString) -> NSMutableAttributedString
    {
        let noDayRead = "No Scripture reading for today."
        var dayRead: NSMutableAttributedString
        let lineBreak = NSMutableAttributedString(string: " \n")
        let italicsFont = UIFont(name: "FormaDJRText-Italic", size: 16.0)
        let darkGrayText = UIColor.darkGrayColor()
        
        let dayBase = dayOf
        let dayRef = convertTextStyling(scrpRef)
        if scrpRead == nil
        {
            dayRead = convertTextStyling(noDayRead)
        }
        else
        {
            dayRead = convertTextStyling(scrpRead)
        }

        
        
        
       // var range: NSRange = (self.text! as NSString).rangeOfString(scrpRead)
        dayRead.addAttribute(NSFontAttributeName, value: italicsFont!, range: NSRange(location: 0, length: dayRead.length))
       
        dayRead.addAttribute(NSForegroundColorAttributeName, value: darkGrayText, range: NSRange(location: 0, length: dayRead.length))
        
        let dayReflect = convertTextStyling(scrpReflect)
        dayBase.appendAttributedString(dayRef)
        dayBase.appendAttributedString(lineBreak)
        dayBase.appendAttributedString(dayRead)
        dayBase.appendAttributedString(lineBreak)
        dayBase.appendAttributedString(lineBreak)
        dayBase.appendAttributedString(dayReflect)
        
        return dayBase
        
    }
    
    func hasConnectivity() -> Bool
    {
        do {
            let reachability: Reachability = try Reachability.reachabilityForInternetConnection()
            let networkStatus: Int = reachability.currentReachabilityStatus.hashValue
            
            return (networkStatus != 0)
        }
        catch {
            
            // Handle error however you please
            return false
        }
    }
    
    func gotTheSessionWeek(weekToUse: Int, sessionTitle: String, sessionURL: String)
    {
        
        
      
//        if currentWeek != weekToUse
//        {
//            weekNumber = weekToUse
//            
//            currentSeriesItems.removeAll()
        
            makeLoadActivityIndicator()
            anApiController.purgeSeries()
            currentSeriesItems.removeAll()
            anApiController.getCurrentSeriesDataFromNACD(sessionURL)
        
        
        if seriesConfigSettings.currentWeek! == weekToUse
        {
            sessionPickerButton.setTitle("Current Study▼", forState: .Normal)
            testInt = weekToUse
        }
        else
        {
            sessionPickerButton.setTitle("Session \(weekToUse)▼", forState: .Normal)
            testInt = weekToUse
        }
            self.view.setNeedsDisplay()

       // }
        
        //print("got a category \(anAlbum)")
     
    }


    func showConnectionError()
    {
        let alertController1 = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet", preferredStyle: .Alert)
        // Add the actions
        alertController1.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        alertController1.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        
        print("Internet connection FAILED")
        alertController1.show()
        loadingIndicator.stopAnimating()
        
    }
    
    
    func dismiss()
    {
        dismissViewControllerAnimated(true, completion: nil)
    }

    
    @IBAction func unwindToHome(segue: UIStoryboardSegue) {
        let sourceController = segue.sourceViewController as! PickSessionTableViewController
        //self.title = sourceController.currentItem
    }


    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
       
        if segue.identifier == "PickSessionSegue"
        {
            if !hasConnectivity()
            {
                showConnectionError()
            }
            
            let pickVC = segue.destinationViewController as! PickSessionTableViewController
            pickVC.sessionsForTable = configSettingArray[0].studySessions

            
//            if testInt == 1
//            {
//                pickVC.currentItem = seriesConfigSettings.currentWeek!
//            }
//            else
//            {
                pickVC.currentItem = testInt
          //  }
            pickVC.devoSeries = thisSeries
            pickVC.configSettings = seriesConfigSettings
            pickVC.delegate = self
            pickVC.transitioningDelegate = menuTransitionManager
            menuTransitionManager.delegate = self
           // testInt = testInt + 1
        }
        
        if segue.identifier == "LoginSegue"
        {
            let vc = segue.destinationViewController as! LoginStudyViewController
            vc.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext //All objects and view are transparent
        }
        }
        
        //
    
    
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet() as NSCharacterSet).uppercaseString
        
        if (cString.hasPrefix("#")) {
            cString = cString.substringFromIndex(cString.startIndex.advancedBy(1))
        }
        
        if ((cString.characters.count) != 6) {
            return UIColor.grayColor()
        }
        
        var rgbValue:UInt32 = 0
        NSScanner(string: cString).scanHexInt(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }

}


extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}
