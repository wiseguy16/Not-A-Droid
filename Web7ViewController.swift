//
//  WebViewController.swift
//  Northland News
//
//  Created by Greg Wise on 10/17/16.
//  Copyright © 2016 Northland Church. All rights reserved.
//

import UIKit
import WebKit

class Web7ViewController: UIViewController
{
    var aFeaturedItem: Featured?
    var passThruWebString: String?
    
    @IBOutlet weak var nacdWebView: UIWebView!
    var webViewURL = NSURL()
    
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        loadWebPage()

        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        loadWebPage()
    }

    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadWebPage()
    {
        webViewURL = NSURL(string: "http://www.northlandchurch.net/need-help/")!
        let request = NSURLRequest(URL: webViewURL)
        nacdWebView.loadRequest(request)
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
