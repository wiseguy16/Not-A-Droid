//
//  Liturgy.swift
//  NacdFeatured
//
//  Created by Gregory Weiss on 11/8/16.
//  Copyright © 2016 NorthlandChurch. All rights reserved.
//

import Foundation

class Liturgy
    
{
    
    var isExpanded = false
    let title: String
    var tranlation: String 
    let entry_date: String
    let sequence: String
    let scripture: String
    let urltitle: String
    var entry_id: Int? = 1
    
    
    
    init(myDictionary: [String: AnyObject])
    {
        
        tranlation = myDictionary["tranlation"] as! String
        sequence = myDictionary["sequence"] as! String
        scripture = myDictionary["scripture"] as! String
        title = myDictionary["title"] as! String
        urltitle = myDictionary["urltitle"] as! String
        entry_date = myDictionary["entry_date"] as! String
        entry_id = myDictionary["entry_id"] as? Int
        
    }
    
    func replaceBreakWithReturn(brString: String) -> String
    {
        var properRetun = brString.stringByReplacingOccurrencesOfString("<br />    ", withString: "\n")
        properRetun = properRetun.stringByReplacingOccurrencesOfString("<br />", withString: "\n")
        properRetun = properRetun.stringByReplacingOccurrencesOfString("<p style='text-align: center;'>", withString: "")
        properRetun = properRetun.stringByReplacingOccurrencesOfString("<p>", withString: "")
        properRetun = properRetun.stringByReplacingOccurrencesOfString("</p>", withString: "\n \n")
        properRetun = properRetun.stringByReplacingOccurrencesOfString("<strong>", withString: "")
        properRetun = properRetun.stringByReplacingOccurrencesOfString("</strong>", withString: "")
        
        //properRetun = properRetun.html2String
        
        // print(properRetun)
        
        
        return properRetun
    }
    
    
    static func makeLiturgyFromRlmObjct(litOnDisk: LiturgyRlm) -> Liturgy?
    {
        
        if let convertDict: [String: AnyObject] = ["tranlation": litOnDisk.tranlation!,
                                                   "sequence": litOnDisk.sequence!,
                                                   "scripture": litOnDisk.scripture!,
                                                   "title": litOnDisk.title!,
                                                   "urltitle": litOnDisk.urltitle!,
                                                   "entry_date": litOnDisk.entry_date!,
                                                   "entry_id": litOnDisk.entryID ]
        {
            let aLit = Liturgy(myDictionary: convertDict)
            
            return aLit
        }
        else
        {
            return nil
        }
    }

    
}


