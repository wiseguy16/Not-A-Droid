//
//  SeriesDetailViewController.swift
//  NacdFeatured
//
//  Created by Gregory Weiss on 1/4/17.
//  Copyright © 2017 NorthlandChurch. All rights reserved.
//

import UIKit
import CoreMedia
import Foundation
import AVKit
import AVFoundation
import SDWebImage


class SeriesDetailViewController: UIViewController
{
    
    let audioNotification = NSNotificationCenter.defaultCenter()
    
    @IBOutlet weak var SessionTitle: UILabel!
    @IBOutlet weak var sciptRefLabel: UILabel!
    
    @IBOutlet weak var introLabel: UILabel!
    @IBOutlet weak var bgView: UIView!
    
    
    @IBOutlet weak var shareLabel: UILabel!
    
    @IBOutlet weak var videoImageView: UIImageView!
    
    @IBOutlet weak var seriesImageView: UIImageView!
    
    
    @IBOutlet weak var hearLabel: UILabel!
    @IBOutlet weak var createLabel: UILabel!
    @IBOutlet weak var diggingLabel: UILabel!
    
    @IBOutlet weak var resourcesLabel: UILabel!
    
    
  
    
 
    
    @IBOutlet weak var assetRes1Button: UIButton!
    @IBOutlet weak var assetRes2Button: UIButton!
    @IBOutlet weak var assetRes3Button: UIButton!
    @IBOutlet weak var assetRes4Button: UIButton!
    @IBOutlet weak var assetRes5Button: UIButton!
    
    
    
    
    @IBOutlet weak var res1ButtonHeight: NSLayoutConstraint!
    
    @IBOutlet weak var res2ButtonHeight: NSLayoutConstraint!
    
    @IBOutlet weak var res3ButtonHeight: NSLayoutConstraint!
    
    @IBOutlet weak var res4ButtonHeight: NSLayoutConstraint!
    
    @IBOutlet weak var res5ButtonHeight: NSLayoutConstraint!
    
    
    

    
    var aSeries: SeriesItem!
    var configSettings: SeriesItem!
    var assetsArray: [StudyAsset]? = []
    var realArray: [StudyAsset]? = []
    var urlStringArray: [String]? = []
    
    

    override func viewDidLoad()
    {
        super.viewDidLoad()
        print(assetsArray)
        
        initializeResourceButtons()
        
        //adjustButtonForText()
        
        setUpTheBackground()
        configureView()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func adjustButtonForText(aTag: Int, aTitle: String, aButton: UIButton, aConstraint: NSLayoutConstraint)
    {
        aConstraint.constant = 30
        let temptitle = aTitle
        let numOfChars = temptitle.characters.count
        if numOfChars >= 30
        {
            aConstraint.constant = 50
        }
        
        aButton.setTitle(temptitle, forState: .Normal)
        aButton.titleLabel?.font = UIFont(name: "FormaDJRText-Regular", size: 17)
        aButton.titleLabel?.lineBreakMode = .ByWordWrapping
        aButton.titleLabel?.textAlignment = .Center
        aButton.layer.borderColor = UIColor.whiteColor().CGColor
        // assetRes2Button.layer.borderWidth = 1
        aButton.layer.cornerRadius = 8
        aButton.titleLabel?.sizeToFit()
        aButton.tag = aTag

        aButton.addTarget(self, action: #selector(clickResourceTapped), forControlEvents: .TouchUpInside)

    }
    
    func initializeResourceButtons()
    {
        resourcesLabel.alpha = 0
        res1ButtonHeight.constant = 0
        res2ButtonHeight.constant = 0
        res3ButtonHeight.constant = 0
        res4ButtonHeight.constant = 0
        res5ButtonHeight.constant = 0
        let tempTitle = ""
        assetRes1Button.setTitle(tempTitle, forState: .Normal)
        assetRes1Button.titleLabel?.font = UIFont(name: "FormaDJRText-Regular", size: 0)
        assetRes2Button.setTitle(tempTitle, forState: .Normal)
        assetRes2Button.titleLabel?.font = UIFont(name: "FormaDJRText-Regular", size: 0)
        assetRes3Button.setTitle(tempTitle, forState: .Normal)
        assetRes3Button.titleLabel?.font = UIFont(name: "FormaDJRText-Regular", size: 0)
        assetRes4Button.setTitle(tempTitle, forState: .Normal)
        assetRes4Button.titleLabel?.font = UIFont(name: "FormaDJRText-Regular", size: 0)
        assetRes5Button.setTitle(tempTitle, forState: .Normal)
        assetRes5Button.titleLabel?.font = UIFont(name: "FormaDJRText-Regular", size: 0)
    }
    
    
    @IBAction func playVideoTapped(sender: UIButton)
    {
        audioNotification.postNotificationName("StopAudio", object: nil)
        
        var videoString = ""
        if let videoPathURL = aSeries.mediaFileM3U8
        {
           videoString = videoPathURL
        }

        let videoURL = NSURL(string: videoString)
       // let videoURL = NSURL(string: "https://player.vimeo.com/external/197967776.m3u8?s=0f8ecfbf4b7aa070c322bc327363eee372a692f3")

        let player = AVPlayer(URL: videoURL!)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.presentViewController(playerViewController, animated: true) {
            
            playerViewController.player?.play()
        }

        
    }
    
    
    @IBAction func clickResourceTapped(sender: AnyObject)
    {
        if sender.tag == 1
        {
            print(urlStringArray![0])
            if let theURL = urlStringArray?[0]
            {
                let url : NSURL = NSURL(string: theURL)!
                if UIApplication.sharedApplication().canOpenURL(url) {
                    UIApplication.sharedApplication().openURL(url)
                }
            }

        }
        else if sender.tag == 2
        {
            print(urlStringArray![1])
            if let theURL = urlStringArray?[1]
            {
                let url : NSURL = NSURL(string: theURL)!
                if UIApplication.sharedApplication().canOpenURL(url) {
                    UIApplication.sharedApplication().openURL(url)
                }
            }

        }
        else if sender.tag == 3
        {
            print(urlStringArray![2])
            if let theURL = urlStringArray?[2]
            {
                let url : NSURL = NSURL(string: theURL)!
                if UIApplication.sharedApplication().canOpenURL(url) {
                    UIApplication.sharedApplication().openURL(url)
                }
            }

        }
        else if sender.tag == 4
        {
            print(urlStringArray![3])
            if let theURL = urlStringArray?[3]
            {
                let url : NSURL = NSURL(string: theURL)!
                if UIApplication.sharedApplication().canOpenURL(url) {
                    UIApplication.sharedApplication().openURL(url)
                }
            }

        }
        else if sender.tag == 5
        {
            print(urlStringArray![4])
            if let theURL = urlStringArray?[4]
            {
                let url : NSURL = NSURL(string: theURL)!
                if UIApplication.sharedApplication().canOpenURL(url) {
                    UIApplication.sharedApplication().openURL(url)
                }
            }

        }
    }
    
    
    
    
    
    @IBAction func shareTapped(sender: UIButton)
    {
        
    }
    
    func setUpTheBackground()
    {
        if let bgColorString = configSettings.studyGuideBGColor
        {
            let bgColor = hexStringToUIColor(bgColorString)
            bgView.backgroundColor = bgColor
        }
        if let picURL = configSettings.studyImage
        {
            let placeHolder = UIImage(named: "WhiteBack.png")
            let realURL = NSURL(string: picURL)
            seriesImageView.sd_setImageWithURL(realURL, placeholderImage: placeHolder, options: .ProgressiveDownload)
        }
        if let shortTitle = aSeries.title
        {
            
            SessionTitle.text = shortTitle.stringByDecodingXMLEntities()
        }
        if assetsArray != nil && assetsArray?.count > 0
        {
            var indexer = 1
           resourcesLabel.alpha = 1
            for item in assetsArray!
            {
                let xTag = indexer
                let xTitle = item.assetTitle!
                let xURL = item.assetURL!
                urlStringArray?.append(xURL)
                switch xTag {
                case 1:
                    adjustButtonForText(xTag, aTitle: xTitle, aButton: assetRes1Button, aConstraint: res1ButtonHeight)
                case 2:
                    adjustButtonForText(xTag, aTitle: xTitle, aButton: assetRes2Button, aConstraint: res2ButtonHeight)
                case 3:
                    adjustButtonForText(xTag, aTitle: xTitle, aButton: assetRes3Button, aConstraint: res2ButtonHeight)
                case 4:
                    adjustButtonForText(xTag, aTitle: xTitle, aButton: assetRes4Button, aConstraint: res2ButtonHeight)
                case 5:
                    adjustButtonForText(xTag, aTitle: xTitle, aButton: assetRes5Button, aConstraint: res2ButtonHeight)

                default:
                    print("no Resource links")
                }
                
                
               realArray?.append(item)
                indexer = indexer + 1
                
            }
            //resourcesLabel.alpha = 1
        }
       
        
        
        
    }

    
    func configureView()
    {
        //SessionTitle.text = aSeries.title?.stringByDecodingXMLEntities()
        
        let lineBreak = NSMutableAttributedString(string: " \n")
        let verse = convertTextStyling(aSeries.replaceBreakWithReturn(aSeries.session_memory_verse!))
        let verseRef = convertTextStyling(aSeries.replaceBreakWithReturn(aSeries.session_memory_verse_ref!))
        verse.appendAttributedString(lineBreak)
        verse.appendAttributedString(verseRef)
        sciptRefLabel.attributedText = verse
        
        introLabel.attributedText = convertTextStyling(aSeries.replaceBreakWithReturn(aSeries.session_introduction!))
        introLabel.attributedText = convertTextStyling(aSeries.replaceBreakWithReturn(aSeries.session_introduction!))
        
        shareLabel.attributedText = convertTextStyling(aSeries.replaceBreakWithReturn(aSeries.session_share!))

        
        
        hearLabel.attributedText = convertTextStyling(aSeries.replaceBreakWithReturn(aSeries.session_hear!))
        createLabel.attributedText = convertTextStyling(aSeries.replaceBreakWithReturn(aSeries.session_create!))
        diggingLabel.attributedText = convertTextStyling(aSeries.replaceBreakWithReturn(aSeries.session_digging_deeper!))
        var picURL = ""
        let placeHolder = UIImage(named: "WhiteBack.png")

        if let seriesPic = aSeries.videoSessionImage
        {
            picURL = seriesPic
        }
        
        let realURL = NSURL(string: picURL)
        videoImageView.sd_setImageWithURL(realURL, placeholderImage: placeHolder, options: .ProgressiveDownload)

        
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
        paragraphStyle.lineSpacing = 6 // Whatever line spacing you want in points
        // *** Apply attribute to string ***
        attributedBody.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attributedBody.length))
        attributedBody.addAttribute(NSKernAttributeName, value:   CGFloat(0.05), range: NSRange(location: 0, length: attributedBody.length))
        // *** Set Attributed String to your label ***
        //fullBodyLabel.attributedText = attributedBody
        
        return attributedBody
    }
    
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


    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
