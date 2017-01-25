//
//  NewspaperViewController.swift
//  NacdFeatured
//
//  Created by Gregory Weiss on 12/21/16.
//  Copyright © 2016 NorthlandChurch. All rights reserved.
//

import UIKit
import WebKit


class NewspaperViewController: UIViewController
{
    
    var webViewURL = NSURL()
    var newspaperView: WKWebView?
    var shownOnce = false
    
    let defaultsPaper = NSUserDefaults.standardUserDefaults()
    var todayCheck: NSDate?
    var refreshPaperButton = UIButton()
    let refreshImage = UIImage(named: "refresh.png")
    var topBarBoundsY: CGFloat?

    
    

    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        todayCheck = NSDate()
       // self.topBarBoundsY = (self.navigationController?.navigationBar.frame.size.height)! + UIApplication.sharedApplication().statusBarFrame.size.height

            loadWebPage()
 
        

        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        let datePaper_get = defaultsPaper.objectForKey("DateForPaper") as? NSDate ?? todayCheck
        let result = Int(todayCheck!.timeIntervalSinceDate(datePaper_get!))
        print(result)
        print("result was")
        if result > 43200
        {
            print("paper trigger")
            newspaperView!.removeFromSuperview()
            loadFreshWebPage()
            // reloadFromAPI()
        }
        else if shownOnce == true
        {
            loadWebPage()
            
        }

        


    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        defaultsPaper.setObject(todayCheck, forKey: "DateForPaper")

    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        newspaperView!.removeFromSuperview()
        shownOnce = true

    }
    
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func makeRefreshButton()
    {
        self.topBarBoundsY = (self.navigationController?.navigationBar.frame.size.height)! + UIApplication.sharedApplication().statusBarFrame.size.height
        refreshPaperButton.frame = CGRectMake(self.view.frame.width - 40, self.topBarBoundsY! + 10, 30, 30)
        refreshPaperButton.setImage(refreshImage, forState: .Normal)
        refreshPaperButton.addTarget(self, action:#selector(refreshTapped), forControlEvents: .TouchUpInside)
        newspaperView!.addSubview(refreshPaperButton)
        
    }
    
    @IBAction func refreshTapped(sender: AnyObject)
    {
        loadFreshWebPage()
    }
    
    func loadWebPage()
    {
        
        
        webViewURL = NSURL(string: "https://s3.amazonaws.com/nacdvideo/misc/news_comp.pdf")!
        let request = NSURLRequest(URL: webViewURL)

         newspaperView = WKWebView(frame: UIScreen.mainScreen().bounds)
        // WKWebView(frame: CGRectMake(0, self.topBarBoundsY!, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height - (self.topBarBoundsY! * 1.5)))
        // WKWebView(frame: UIScreen.mainScreen().bounds)
        newspaperView!.loadRequest(request)
        self.view.addSubview(newspaperView!)
        makeRefreshButton()
       // newspaperWebView.loadRequest(request)
        
        // newspaperView.UIDelegate = self

    }
    
    func loadFreshWebPage()
    {
        webViewURL = NSURL(string: "https://s3.amazonaws.com/nacdvideo/misc/news_comp.pdf")!
        let request = NSURLRequest(URL: webViewURL, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 90.0)
        
        newspaperView = WKWebView(frame: UIScreen.mainScreen().bounds)
        // WKWebView(frame: CGRectMake(0, self.topBarBoundsY!, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height - (self.topBarBoundsY! * 1.5)))
        // WKWebView(frame: UIScreen.mainScreen().bounds)
        newspaperView!.loadRequest(request)
        self.view.addSubview(newspaperView!)
        makeRefreshButton()

        
        
        
    }
    
    func removeOldView()
    {
        
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
