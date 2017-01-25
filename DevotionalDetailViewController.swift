//
//  DevotionalDetailViewController.swift
//  NacdFeatured
//
//  Created by Gregory Weiss on 1/4/17.
//  Copyright © 2017 NorthlandChurch. All rights reserved.
//

import UIKit

class DevotionalDetailViewController: UIViewController
{
    
    @IBOutlet weak var dailyTitle: UILabel!
    @IBOutlet weak var scripRef: UILabel!
    @IBOutlet weak var devoOfDayLabel: UILabel!
    @IBOutlet weak var actionStepsLabel: UILabel!
   // @IBOutlet weak var moreVersesLabel: UILabel!
    
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var seriesImageView: UIImageView!
    
    
    var todayString: String?
    var devoStringRef: String?
    var devoStringRead: String?
    var devoStringReflect: String?
    var devoSeries: SeriesItem!
    var configSettings: SeriesItem!
    var shareBody: String?

    override func viewDidLoad()
    {
        super.viewDidLoad()
        setUpTheBackground()
        configureView()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func shareTapped(sender: UIButton)
    {
        let vc = UIActivityViewController(activityItems: [shareBody!], applicationActivities: nil)
        self.presentViewController(vc, animated: true, completion: nil)

        
        
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
//        if let shortTitle = aSeries.title
//        {
//            
//            SessionTitle.text = shortTitle.stringByDecodingXMLEntities()
//        }
        
    }

    
    func configureView()
    {
        let noDayRead = "No Scripture reading for today."

        dailyTitle.text = todayString
        scripRef.attributedText = convertTextStyling(devoStringRef)
        if devoStringRead == nil
        {
            devoOfDayLabel.attributedText = convertTextStyling(noDayRead)
            shareBody = devoStringReflect
        }
        else
        {
            shareBody = devoStringRef! + " - " + devoStringRead! + " Reflection: " + devoStringReflect!
            devoOfDayLabel.attributedText = convertTextStyling(devoStringRead)
        }
        
        actionStepsLabel.attributedText = convertTextStyling(devoStringReflect)
       // moreVersesLabel.attributedText = convertTextStyling(devoSeries.session_memory_verse)
        
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
