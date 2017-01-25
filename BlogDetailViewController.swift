//
//  BlogDetailViewController.swift
//  NacdNews
//
//  Created by Gregory Weiss on 8/31/16.
//  Copyright © 2016 Gregory Weiss. All rights reserved.
//

import UIKit
import WebKit
import SDWebImage

class BlogDetailViewController: UIViewController
{
    
    @IBOutlet weak var blogScrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    var aBlogItem: Featured!
    var shareBody: String?
    var myFormatter = NSDateFormatter()
    
    @IBOutlet weak var blogImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var subTextLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    
    var hardCodeText = "Throughout my college career, I had the opportunity to complete several internships in many places around the United States. I spent time in the Cascade my future after Florida, I decided to find a church; I decided to allow myself to become a little more attached to Florida. This led me to Northland, and I guess I got a lot more attached than I intended. \n Here I am; it’s been over a year since I moved here, and my life looks wildly different from what I expected. I am working a full-time job, and in my spare time, I am involved both inside and , He is teaching me how to be the church in someone’s living room, and He is teaching me what it looks like to live life with other people, in community. \n Moving to a new city that I know nothing about has definitely been tough. However, I have been so fortunate to be surrounded by people who care about me and consider me a valuable part of their community. When I started coming to Northland, I pretty quickly got connected with a group of peers looking to find "
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        myFormatter.dateFormat = "yyyy-MM-dd"
       // myFormatter.timeStyle = .NoStyle
        
        configureView()
        
        //shareBody = aBlogItem.channel
        //contentView.layer.borderWidth = 1
        //contentView.layer.borderColor = UIColor.magentaColor().CGColor
        
    }
    
    override func viewWillLayoutSubviews()
    {
        super.viewWillLayoutSubviews()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func sharingTapped(sender: UIButton)
    {
        let vc = UIActivityViewController(activityItems: [shareBody!], applicationActivities: nil)
        self.presentViewController(vc, animated: true, completion: nil)
        
        
    }
    
    func configureView()
    {
        titleLabel.text = aBlogItem.title?.stringByDecodingXMLEntities()
        
   //************ CLOSING TEXT = AUTHOR OF BLOG **********************
        authorLabel.text = aBlogItem.closingText?.uppercaseString
        
        
        let arrayFromDate = aBlogItem.entry_date?.componentsSeparatedByString("T")
        let tempDate = arrayFromDate![0]
        
        let newDate = myFormatter.dateFromString(tempDate)
        myFormatter.dateFormat = "MMM d, y"
        let showDate = myFormatter.stringFromDate(newDate!)
        dateLabel.text = showDate

        
        
        //var convertedBody = aBlogItem.replaceBreakWithReturn(aBlogItem.body!)
        var convertedBody = aBlogItem.body!.stringByDecodingXMLEntities()
        convertedBody = aBlogItem.replaceBreakWithReturn(convertedBody)
        let attributedBody  = NSMutableAttributedString(string: convertedBody)
        // let attributedString = NSMutableAttributedString(string: "Your text")
        // *** Create instance of `NSMutableParagraphStyle`
        let paragraphStyle = NSMutableParagraphStyle()
        // *** set LineSpacing property in points ***
        paragraphStyle.lineSpacing = 12 // Whatever line spacing you want in points
        // *** Apply attribute to string ***
        attributedBody.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attributedBody.length))
        // *** Set Attributed String to your label ***
        // label.attributedText = attributedString;
        
        bodyLabel.attributedText = attributedBody

        subTextLabel.text = "" //aBlogItem.title?.stringByDecodingXMLEntities()
        
        let myURL = aBlogItem.image!
        
        let placeHolder = UIImage(named: "WhiteBack.png")
        // cell.featuredButton.setTitle(aFeaturedThing.webURL, forState: .Normal)
        
        // let myURL = featuredItems[indexPath.row].image!
        let realURL = NSURL(string: myURL)
        
        self.blogImage.sd_setImageWithURL(realURL, placeholderImage: placeHolder, options: [])
        
        let baseURL = "http://www.northlandchurch.net/"
        let urlPart2 = self.aBlogItem.channel!.lowercaseString
        let urlPart3 = self.aBlogItem.urltitle!
        self.shareBody = baseURL + urlPart2 + "/" + urlPart3
        
    }
    


}
