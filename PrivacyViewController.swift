//
//  PrivacyViewController.swift
//  Northland Church
//
//  Created by Gregory Weiss on 1/18/17.
//  Copyright © 2017 NorthlandChurch. All rights reserved.
//

import UIKit

class PrivacyViewController: UIViewController
{

    @IBOutlet weak var longLabel: UILabel!
    
    let privacyPolString = "Thank you for visiting us at NorthlandChurch.net (the “Site”). The Site is provided by Northland, A Church Distributed (“Northland”).  Northland strongly believes that the protection of privacy is a critical issue when collecting and storing personal information via the internet. We have created this Privacy Policy (this “Privacy Policy”) to inform all visitors to the Site of the measures we employ to keep the information you may choose to share with us private and confidential. We are committed to protecting and safeguarding consumer privacy on the internet, especially for children. Please carefully review this Privacy Policy before using the Site. \n \n INFORMATION COLLECTED \n \n When you visit this Site, you may provide us with two types of information: (1) personal information you knowingly choose to disclose that is collected on an individual basis, and (2) website use information collected by us on an aggregate basis. Personal information is information that is personally identifiable to you such as your name, email address, mailing address, phone number and date of birth. We only gather personal information when it is voluntarily submitted by you. You are not required to disclose any personal information to visit this Site, however you may be required to disclose certain personal information before accessing or using certain features or areas of the Site. We do not collect any personal information about you through this Site without your knowledge. \n \n When you visit this Site we may automatically collect website use information about your visit. Website use information includes information such as the date and time of your visit, the pages you visited, the address of the website you came from when you came to visit this Site, etc. If you do not want us to collect website use information then please do not visit or use this Site. You may contact us at any time in order to update the personal information we have collected about you by sending an email to hello@northlandchurch.net. Please include your name and the information about you that you wish to update in the email so that we can better assist you with your request.\n \n USAGE AND COLLECTION OF INFORMATION\n \n We recognize and appreciate the importance of responsible use of personal information collected on this Site. Third party companies may be engaged by Northland to perform a variety of functions, such as providing technical services for this Site, etc. These companies may have access to personal information if necessary to perform such functions. However, these companies may only use such personal information for the purpose of performing these functions and may not use it for any other purpose. Other than as set forth in this Privacy Policy, we do not sell, transfer, share or disclose personal information to third parties.\n \n COOKIES\n \n “Cookies” are pieces of information that a website transfers to an individual’s hard drive for record-keeping purposes. Cookies allow websites to remember important information about visitors that make a visitor’s use of a website more convenient. Like most web sites, this Site uses cookies for a variety of purposes in order to improve your online experience. For example, we may use cookies to determine the number of unique visitors to our Site over a given period and to remember user screen names so that the need for multiple log-ins is eliminated. We do not store any personal information in cookies nor do we link or combine information collected through cookies to any personal information that users submit when participating in activities on this Site. Cookies cannot be executed as code or deliver viruses.\n \n Use the options in your web browser if you do not wish to receive a cookie or if you wish to set your browser to notify you when you receive a cookie. If you disable all cookies, you may not be able to take advantage of all of the features and activities available on this Site. \n \n LINKS TO OTHER WEBSITES\n \n We may offer links to sites that are not operated by Northland. If you visit one of these linked sites, you should review their privacy policy and all other policies. We are not responsible for the policies and practices of other websites, and any information you submit to those websites is subject to their privacy policies.\n \n NOTICES AND RESTRICTIONS\n \n We may be forced to disclose certain personal information you submit to us to the government or other law enforcement agencies. We reserve the right to, and by using this Site you authorize us to, use or disclose any personal information or other information we have collected about you as needed or necessary in order to satisfy any law, regulation or legal request, to protect the integrity of this Site, to fulfill your requests, or to cooperate in any law enforcement investigation. \n \n MISCELLANEOUS\n \n By accessing or using this Site you agree to the terms of this Privacy Policy. If you do not agree to the terms of this Privacy Policy please do not access or use this Site. We reserve the right to change the terms of this Privacy Policy from time to time in our sole discretion. You should periodically check this Site for any changes that may have been made to this Privacy Policy. Whether or not you actually review changes as they are made, your use of this Site signifies your acceptance of any such changes."
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        longLabel.text = privacyPolString

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func closeTapped(sender: UIButton)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
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
