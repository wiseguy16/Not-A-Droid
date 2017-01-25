//
//  WebViewController.swift
//  Northland News
//
//  Created by Greg Wise on 10/17/16.
//  Copyright © 2016 Northland Church. All rights reserved.
//

import UIKit
import WebKit
import MessageUI

class GiveViewController: UIViewController, WKUIDelegate, WKNavigationDelegate, MFMessageComposeViewControllerDelegate
{
//    var aFeaturedItem: Featured?
//    var passThruWebString: String?
//    
      var nacdWebView: WKWebView!
    var webViewURL = NSURL()
    
    @IBOutlet weak var giveButton: UIButton!
    
    @IBOutlet weak var textOfferingButton: UIButton!
    
    
//    override func loadView() {
//        let webConfiguration = WKWebViewConfiguration()
//        nacdWebView = WKWebView(frame: .zero, configuration: webConfiguration)
//        nacdWebView.UIDelegate = self
//        view = nacdWebView
//    }
    
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        textOfferingButton.layer.cornerRadius = 8
        // giveButton.clipsToBounds = true
        textOfferingButton.layer.shadowOffset = CGSizeMake(10, 10)
        textOfferingButton.layer.shadowColor = UIColor.blackColor().CGColor
        textOfferingButton.layer.shadowRadius = 3
        textOfferingButton.layer.shadowOpacity = 0.14
        
        textOfferingButton.clipsToBounds = false
        
        let shadowFrame1: CGRect = (textOfferingButton.layer.bounds)
        let shadowPath1: CGPathRef = UIBezierPath(rect: shadowFrame1).CGPath
        textOfferingButton.layer.shadowPath = shadowPath1

        
        
        giveButton.layer.cornerRadius = 8
       // giveButton.clipsToBounds = true
        giveButton.layer.shadowOffset = CGSizeMake(10, 10)
        giveButton.layer.shadowColor = UIColor.blackColor().CGColor
        giveButton.layer.shadowRadius = 3
        giveButton.layer.shadowOpacity = 0.14
        
        giveButton.clipsToBounds = false
        
        let shadowFrame: CGRect = (giveButton.layer.bounds)
        let shadowPath: CGPathRef = UIBezierPath(rect: shadowFrame).CGPath
        giveButton.layer.shadowPath = shadowPath

        
        
       // loadWebPage()

        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
       // loadWebPage()
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBarHidden = false
    }
    
    
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func goToGivePageTapped(sender: UIButton)
    {
        //loadWebPage()
        let url : NSURL = NSURL(string: "https://giving.northlandchurch.net/")!
        if UIApplication.sharedApplication().canOpenURL(url) {
            UIApplication.sharedApplication().openURL(url)
        }
        
    }
    
    
    @IBAction func textOfferingTapped(sender: UIButton)
    {
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = ""
            controller.recipients = ["45777"]
            controller.messageComposeDelegate = self
            self.presentViewController(controller, animated: true, completion: nil)
        }
        
    }
    
    /*
    let arbitraryValue: Int = 5
    if let newPosition = textField.position(from: textField.beginningOfDocument, offset: arbitraryValue) {
        
        textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
    }
    */
    
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        //... handle sms screen actions
        
               controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func loadWebPage()
    {
//        var config = WKWebViewConfiguration()
//       // config.userContentController = contentController
//        
//        let svc = WKWebView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height), configuration: config)
//        //svc.delegate = self
//        self.presentViewController(svc, animated: true, completion: nil)
        
        //nacdWebView = WKWebView()
        nacdWebView.navigationDelegate = self
       // view = nacdWebView
        webViewURL = NSURL(string: "https://giving.northlandchurch.net/")!
        let request = NSURLRequest(URL: webViewURL)
        nacdWebView.loadRequest(request)
        
    }
    
//        let myWebView:UIWebView = UIWebView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height))
//        myWebView.loadRequest(NSURLRequest(URL: NSURL(string: "http://www.sourcefreeze.com")!))
//        self.presentViewController(myWebView, animated: true, completion: nil) // addSubview(myWebView)
        
        
       //self.presentViewController(nacdWebView, animated: true) {
            
  //  }
    

    


    
//    func webView(webView: WKWebView, createWebViewWithConfiguration configuration: WKWebViewConfiguration, forNavigationAction navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
//        let url: NSURL = navigationAction.request.URL!
//        
//        
//            //let newBrowser: WebBrowserViewController = WebBrowserViewController(configuration: configuration)
//           // self.presentViewController(newBrowser, animated: true, completion: nil)
//           // return newBrowser.webView;
//        
//        
//       // return nil
//    }


    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
