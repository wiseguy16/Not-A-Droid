//
//  LoginMCAPIController.swift
//  Northland Church
//
//  Created by Gregory Weiss on 1/17/17.
//  Copyright © 2017 NorthlandChurch. All rights reserved.
//


import Foundation
import UIKit

class LoginMCAPIController
{
    
    
    init(delegate: LoginMCAPIControllerProtocol)
    {
        self.delegate = delegate
    }
    
    
    //var arrayOfFeatured = [Featured]()
    // var arrayOfBlogs = [Featured]()
    var arrayOfSeries = [SeriesItem]()
    var arrayOfConfiguration = [SeriesItem]()
    
    var delegate: LoginMCAPIControllerProtocol!
    let baseURLString = "http://www.northlandchurch.net/scripts/custom-mailchimp-signup/addToMCGroup.php?listID=c3a9944be4" //emailaddress=devtest%40northlandchurch.net&lname=Appleseed&fname=Johnny"
    let baseURLString2 = "http://www.northlandchurch.net/scripts/custom-mailchimp-signup/addToMCGroup.php?listID=e98621971a&emailaddress=devtest%40northlandchurch.net&lname=Appleseed&fname=Johnny"

    
    
    func removeSpecialCharsFromString(str: String) -> String {
        let chars = Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890+-*=(),.:!_/@[]{}".characters)
        return String(str.characters.filter { chars.contains($0) })
    }
    
    func removeBackslashes(str: String) -> String
    {
        var newStr = str
        newStr = newStr.stringByReplacingOccurrencesOfString("\t", withString: "")
        newStr = newStr.stringByReplacingOccurrencesOfString("\n", withString: "")
        newStr = newStr.stringByReplacingOccurrencesOfString("\\", withString: "")
        
        return newStr
    }
    
    
    func sendLoginToMailChimp(email: String, firstName: String, lastName: String)
    {
       // func sendRequest(url: String, parameters: [String: AnyObject], completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionTask {
           // let parameterString = parameters.stringFromHttpParameters()
            //let requestURL = URL(string:"\(url)?\(parameterString)")!
        
        //  "h ttp://www.northlandchurch.net/index.php/resources/iphone-app-getseries"
        let newEmail = "&emailaddress=" + email.stringByAddingPercentEncodingForURLQueryValue()!
        let newFirstName = "&fname=" + firstName.stringByAddingPercentEncodingForURLQueryValue()!
        let newLastName = "&lname=" + lastName.stringByAddingPercentEncodingForURLQueryValue()!
        
        let URLString = baseURLString + newEmail + newFirstName + newLastName
        print(URLString)
        let myURL = NSURL(string: URLString)
        let request = NSMutableURLRequest(URL: myURL!)
        
        request.HTTPMethod = "GET"  // Compose a query string
        //request.addValue("Bearer " + authToken, forHTTPHeaderField: "Authorization")
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                if let httpResponse = response as? NSHTTPURLResponse
                {   print(httpResponse)
                    if httpResponse.statusCode != 200
                    {
                        print("You got 404!!!???")
                        self.networkAlert()
                        return
                    }
                    else if httpResponse.statusCode == 200
                    {
                        self.delegate.userHasSignedUpSuccessfully()
                        
                    }
                }
                
//                if let apiData = data
//                {   //print(apiData)
//                    if let datastring = String(data: apiData, encoding: NSUTF8StringEncoding)
//                    {
//                        
//                        //print(datastring)
//                        let data2 = self.removeBackslashes(datastring)
//                        // print(data2)
//                        let data1 = data2.dataUsingEncoding(NSUTF8StringEncoding)
//                        //print(data1!)
//                        
//                        if let apiData = data1, let jsonOutput = try? NSJSONSerialization.JSONObjectWithData(apiData, options: []) as? [String: AnyObject], let myJSON = jsonOutput
//                        {
//                            let dataArray = myJSON["items"] as? [[String: AnyObject]]
//                            
//                            if let constArray = dataArray
//                            {
//                                for value in constArray
//                                {
//                                    let aSrs = SeriesItem(myDictionary: value)
//                                    self.arrayOfSeries.append(aSrs)
//                                }
//                                self.delegate.userHasSignedUpSuccessfully()
//                            }
//                        }
//                    }
//                }
//                else
//                {
//                    self.networkAlert()
//                    //  self.delegate.gotTheBible(self.arrayOfLiturgy)
//                }
                
            })
        })
        
        
        task.resume()
        
        return
    }
    
    func stringByAddingPercentEncodingForURLQueryValue(aString: String) -> String?
    {
        let allowedCharacters = NSCharacterSet(charactersInString: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~")
        
        return aString.stringByAddingPercentEncodingWithAllowedCharacters(allowedCharacters)
    }
    
    
    
    func networkAlert()
    {
        // Create the alert controller
        let alertController1 = UIAlertController(title: "Sorry, having trouble connecting to the network. Please try again later.", message: "Network Unavailable", preferredStyle: .Alert)
        // Add the actions
        alertController1.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        alertController1.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        // Present the controller
        alertController1.show()
    }
    
    
    
}

extension String
{
    func stringByAddingPercentEncodingForURLQueryValue() -> String?
    {
        let allowedCharacters = NSCharacterSet(charactersInString: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~")
        
        return self.stringByAddingPercentEncodingWithAllowedCharacters(allowedCharacters)
    }

    
}

extension Dictionary {
    
    /// Build string representation of HTTP parameter dictionary of keys and objects
    ///
    /// This percent escapes in compliance with RFC 3986
    ///
    /// http://www.ietf.org/rfc/rfc3986.txt
    ///
    /// :returns: String representation in the form of key1=value1&key2=value2 where the keys and values are percent escaped
    
    func stringFromHttpParameters() -> String {
        let parameterArray = self.map { (key, value) -> String in
            let percentEscapedKey = (key as! String).stringByAddingPercentEncodingForURLQueryValue()!
            let percentEscapedValue = (value as! String).stringByAddingPercentEncodingForURLQueryValue()!
            return "\(percentEscapedKey)=\(percentEscapedValue)"
        }
        
        return parameterArray.joinWithSeparator("&")
    }
    
}



