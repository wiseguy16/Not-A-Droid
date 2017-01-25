//
//  PickSessionTableViewController.swift
//  NacdFeatured
//
//  Created by Gregory Weiss on 1/9/17.
//  Copyright © 2017 NorthlandChurch. All rights reserved.
//

import UIKit

class PickSessionTableViewController: UITableViewController
{
    
//    var sessionInstances = [Session]()
//    
//    let sessionOne = Session()
//    let sessionTwo = Session()
//    let sessionThree = Session()
//    let sessionFour = Session()
//    let sessionFive = Session()
//    let sessionSix = Session()
//    let sessionSeven = Session()
//    let sessionEight = Session()
//    let sessionNine = Session()
//    let sessionTen = Session()
    
    var sessionsForTable: [StudySession]!
    
    var devoSeries: SeriesItem!
    var configSettings: SeriesItem!
    
    var currentItem: Int?
    
    var delegate: PickSessionWeek?
    

    override func viewDidLoad() {
        super.viewDidLoad()
       // loadSessions()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60.0
    }


    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return sessionsForTable.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SessionWeekCell", forIndexPath: indexPath) 

        // Configure the cell...
        let aSess = sessionsForTable[indexPath.row]
        cell.textLabel?.text = aSess.studyWeekTitle
        // cell.tintColor = UIColor.grayColor()
        print(aSess.studyWeekTitle)
        print("Current Item")
        print(currentItem)
        
        if currentItem == aSess.studyWeekNumber
        {
            cell.accessoryType = .Checkmark
        }
        else
        {
            cell.accessoryType = .None
        }


        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let theIndex: Int = indexPath.row
        let theSession = sessionsForTable[indexPath.row]
        //delegate!.gotTheCategory(theCategory.albumIDNumber, categoryTitle: theCategory.categoryName)
        
        delegate!.gotTheSessionWeek(theIndex + 1, sessionTitle: theSession.studyWeekTitle!, sessionURL: theSession.studyWeekURL!)
        
        
        if let selectedRow = tableView.indexPathForSelectedRow?.row {
            currentItem = theSession.studyWeekNumber
        }
        //dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    @IBAction func unwindToHome(segue: UIStoryboardSegue)
    {
        let sourceController = segue.sourceViewController as! CurrentSeriesMainViewController
        
        //  self.title = sourceController.currentItem
        
    }
    
//    func loadSessions()
//    {
//        sessionOne.weekToUse = "one"
//        sessionOne.sessionTitle = "Session one"
//        sessionTwo.weekToUse = "two"
//        sessionTwo.sessionTitle = "Session two"
//        sessionThree.weekToUse = "three"
//        sessionThree.sessionTitle = "Session three"
//        sessionFour.weekToUse = "four"
//        sessionFour.sessionTitle = "Session four"
//        sessionFive.weekToUse = "five"
//        sessionFive.sessionTitle = "Session five"
//        sessionSix.weekToUse = "six"
//        sessionSix.sessionTitle = "Session six"
//        sessionSeven.weekToUse = "seven"
//        sessionSeven.sessionTitle = "Session seven"
//        sessionEight.weekToUse = "eight"
//        sessionEight.sessionTitle = "Session eight"
//        sessionNine.weekToUse = "nine"
//        sessionNine.sessionTitle = "Session nine"
//        sessionTen.weekToUse = "ten"
//        sessionTen.sessionTitle = "Session ten"
//        
//        sessionInstances = [sessionOne, sessionTwo, sessionThree, sessionFour, sessionFive, sessionSix]
//
//        
//    }

    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

//class Session
//{
//    var weekToUse: String = ""
//    var sessionTitle: String = ""
//    var tempSession: String = "series"
//   // weekToUse: String, sessionTitle: String)
//}

