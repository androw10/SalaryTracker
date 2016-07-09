//
//  ViewController.swift
//  MyReallHUApp
//
//  Created by androw on 06/07/2016.
//  Copyright © 2016 androw_S. All rights reserved.
//

import UIKit
import RealmSwift

// Setting up my calendar----------------------------------------------------------------
let date = NSDate()

let calendar = NSCalendar.currentCalendar()

let components = calendar.components([.Year,.Month,.Day,.Hour,.Minute], fromDate: date)
//----------------------------------------------------------------------------------------


class ViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    
    // 
    var indexer = 0
    var currentwdmrr = -1
    var currentwdmrrworkarr = -1
    
    //Back Button outlet
    @IBOutlet weak var backAcc: UIButton!
    
    
    // Label fo2 el TableView
    @IBOutlet weak var showS: UILabel!
    
    
    //array or Work Manager class  which manages our workdays
    var wdmarr : [wkManager] = []
    
    //pull down refresh object
    var rfrsh = UIRefreshControl()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Work1.layer.cornerRadius = 5
        Work2.layer.cornerRadius = 5
        backAcc.layer.cornerRadius = 5

        //object that lets us acces the realm database we created
        let realm = try! Realm()
        
    
        
        //this adds the pulldown to the tableview
        rfrsh.addTarget(self, action: "rfrshfunc", forControlEvents: .ValueChanged)
        tableView.addSubview(rfrsh)
        //---------------------------------------------------------------------------
      
        
        
        //Object that checks if the button work1 and work2 are clicked or not
        let oneAndOnly  = realm.objects(ButtonsO3).first
   
        
        
        
        // cheks if the buttons(Work1 Work2) are on or off using the oneAndOnly object and color them
        if(oneAndOnly == nil ){
            print("in catch")
        var temp = ButtonsO3()
            try! realm.write{
                realm.add(temp)
            }
            Work1.backgroundColor = UIColor.redColor()
            Work2.backgroundColor = UIColor.redColor()
        }
            else {
            if(oneAndOnly!.work1){
                Work1.backgroundColor = UIColor.greenColor()
            }
            else{
                Work1.backgroundColor = UIColor.redColor()
            }
            
            if(oneAndOnly!.work2){
                Work2.backgroundColor = UIColor.greenColor()
            }
            else{
                Work2.backgroundColor = UIColor.redColor()
            }
            }
        //------------------------end-----------------------------
        
       
        
        getRealmData()
 
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    // convert the regular array we get from realm DataBase to a workManager array
    func Convert(wd : [WorkDay] )-> [wkManager]{
        let realm = try! Realm()
        var wm = [wkManager]()
        for days in wd {
            if(wm.isEmpty || !checkIfDayIsInWM(days, wm: wm) ){
                var temp = wkManager()
                temp.month = days.month
                temp.year = days.year
                temp.addToArr(days)
                wm.append(temp)
            }
            else {
                for wm1 in wm{
                    if(wm1.month == days.month && wm1.year == days.year){
                        wm1.addToArr(days)
                    }
                }
            }
        }
        for day in wm{
            try! realm.write{
            day.TotalMoney()
            }
        }
        
        return wm
    }

    // check if the date exists inside the  WorkManager array
    func checkIfDayIsInWM(wd : WorkDay , wm : [wkManager])-> Bool{
        for date in wm{
            if(date.month == wd.month && date.year == wd.year){
                return true
            }
        }
        return false
    }
    
    //sort the array from oldest to newest
    func sortArray(wd : [WorkDay])-> [WorkDay]{
        var day = wd
        var returned = [WorkDay]()
        for var j = 0 ; j < wd.count ; j += 1 {
            for var i = wd.count-1 ; i > 0 ; i -= 1 {
                if(
                    (day[i-1].year < day[i].year)
                    ||
                    (day[i-1].year == day[i].year && day[i-1].month < day[i].month)
                    ||
                    (day[i-1].year == day[i].year && day[i-1].month == day[i].month && day[i-1].day < day[i].day)
                    ){}
                else {
                    var temp = day[i]
                    day[i] = day[i-1]
                    day[i-1] = temp
                }
            }
        }
        returned = day
        return returned
    }
    
    
    // func used for the rfrsh add Target below which will reload tableview data when we pull down
    func rfrshfunc(){
        getRealmData()
        tableView.reloadData()
        rfrsh.endRefreshing()
    }
    
    
    //functio that will turn 14:30 to this -> 14.5
    func TimeConvert(hours : Int , minutes : Int)-> Double{
        var returned : Double = 0
        
        
        returned = Double(hours)
        returned += Double(minutes) / 60
        
        //  returned = (round(10000*returned)/10000)
        
        print(returned)
        
        return returned
    }
    
    
    
    //Work1 and Work2 ------------------------ Buttons ---------------------
    // In and out of work for work1
    @IBOutlet weak var Work1: UIButton!
    @IBAction func Work1StartWork(sender: AnyObject) {
        let date = NSDate()
        
        let calendar = NSCalendar.currentCalendar()
        
        let components = calendar.components([.Year,.Month,.Day,.Hour,.Minute], fromDate: date)
        
        let hours = components.hour
        let minutes = components.minute
        let day = components.day
        let month = components.month
        let year = components.year
        
        let realm = try! Realm()
        let oneAndOnly  = realm.objects(ButtonsO3).first
        if(!oneAndOnly!.work1){
            Work1.backgroundColor = UIColor.greenColor()
            try! realm.write{
                oneAndOnly?.work1 = true;
            }
            if(checkIfDateIsInDB(year, month1: month, day1: day)){
                let allDates = realm.objects(WorkDay)
                for date in allDates {
                    print("outside \(date)")
                    if (year == date.year && month == date.month && day == date.day) {
                        try! realm.write{
                            date.work1s = TimeConvert(hours, minutes: minutes)
                            print(date)
                        }
                    }
                }
            }
            else{
                var temp = WorkDay()
                temp.DateFill(year, month1: month, day1: day)
                temp.work1s = TimeConvert(hours, minutes: minutes)
                try! realm.write{
                    realm.add(temp)
                }
                print(temp)
            }
        }
        else{
            Work1.backgroundColor = UIColor.redColor()
            try! realm.write{
                oneAndOnly?.work1 = false;
            }
            let allDates = realm.objects(WorkDay)
            for date in allDates {
                if (year == date.year && month == date.month && day == date.day) {
                    try! realm.write{
                        date.work1e = TimeConvert(hours, minutes: minutes)
                        date.Total();
                    }
                    for wkm in wdmarr{
                        if(wkm.year == year && wkm.month == month){
                            try! realm.write{
                                wkm.TotalMoney()
                            }
                        }
                    }
                    print(date)
                    getRealmData()
                    
                }
            }
        }
        tableView.reloadData()
        
    }
    // In and out of work for work2
    @IBOutlet weak var Work2: UIButton!
    @IBAction func Work2StartWork(sender: AnyObject) {
    
        let date = NSDate()
        
        let calendar = NSCalendar.currentCalendar()
        
        let components = calendar.components([.Year,.Month,.Day,.Hour,.Minute], fromDate: date)
        
        let hours = components.hour
        let minutes = components.minute
        let day = components.day
        let month = components.month
        let year = components.year
        
        let realm = try! Realm()
        let oneAndOnly  = realm.objects(ButtonsO3).first
        if(!oneAndOnly!.work2){
            Work2.backgroundColor = UIColor.greenColor()
            try! realm.write{
                oneAndOnly?.work2 = true;
            }
            if(checkIfDateIsInDB(year, month1: month, day1: day)){
                let allDates = realm.objects(WorkDay)
                for date in allDates {
                    print("outside \(date)")
                    if (year == date.year && month == date.month && day == date.day) {
                        try! realm.write{
                        date.work2s = TimeConvert(hours, minutes: minutes)
                        print(date)
                        }
                        }
                }
            }
            else{
                var temp = WorkDay()
                temp.DateFill(year, month1: month, day1: day)
                temp.work2s = TimeConvert(hours, minutes: minutes)
                try! realm.write{
                    realm.add(temp)
                }
                print(temp)
            }
        }
        else{
            Work2.backgroundColor = UIColor.redColor()
            try! realm.write{
                oneAndOnly?.work2 = false;
            }
                let allDates = realm.objects(WorkDay)
                for date in allDates {
                    if (year == date.year && month == date.month && day == date.day) {
                        try! realm.write{
                        date.work2e = TimeConvert(hours, minutes: minutes)
                        date.Total();
                        }
                        for wkm in wdmarr{
                            if(wkm.year == year && wkm.month == month){
                                try! realm.write{
                                wkm.TotalMoney()
                                }
                            }
                        }
                        print(date)
                        getRealmData()
                }
                   
            }
        }
        tableView.reloadData()
        
    }
    //--------------------------------------------------------------------------------
    
    
    

    
    
    //-----------------------------TableView Functions --------------------------------
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    
        return 1
       
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(indexer == 0){
        return wdmarr.count
        }
        else{
            return wdmarr[currentwdmrr].workarr.count
        }
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if(indexer == 0){
        let realm = try! Realm()
        var cell : UITableViewCell
        cell = tableView.dequeueReusableCellWithIdentifier("andr1", forIndexPath: indexPath) as UITableViewCell
       showS.text = "Main View"
        
        cell.textLabel!.text = "\(wdmarr[indexPath.row].year)/\(wdmarr[indexPath.row].month) you've earned \(wdmarr[indexPath.row].totalMoney) in: \(wdmarr[indexPath.row].workarr.count) day"
            return cell
        }
            
            
        else {
            showS.text = "\(wdmarr[currentwdmrr].month)/\(wdmarr[currentwdmrr].year)"
            let realm = try! Realm()
            var cell : UITableViewCell
            cell = tableView.dequeueReusableCellWithIdentifier("andr1", forIndexPath: indexPath) as UITableViewCell
            
            cell.textLabel!.text = "\(wdmarr[currentwdmrr].workarr[indexPath.row].day)/\(wdmarr[currentwdmrr].month)/\(wdmarr[currentwdmrr].year) you've earned \(wdmarr[currentwdmrr].workarr[indexPath.row].totalMoney) "
            
            return cell
        }
    
    }
    
    // func that takes you back to the main tableview which shows the year and months
    @IBAction func backAC(sender: AnyObject) {
        indexer = 0
        getRealmData()
        tableView.reloadData()
    }
    
    //when a cell of the tableview is selected this func starts
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(indexer == 0){
            
            indexer = 1
            currentwdmrr = indexPath.row

            getRealmData()
            tableView.reloadData()
        }
        else {
        
            currentwdmrrworkarr = indexPath.row
            var alertTest = UIAlertView()
            alertTest.delegate = self
            alertTest.message = "Select one!"
            alertTest.addButtonWithTitle("Cancel")
            alertTest.addButtonWithTitle("Delete")
            alertTest.title = "Delete"
            alertTest.show()
        
        }
    }
    //----------------------------------------------------------------------------------

    
    
    
    
    
    //----------------------------------AlertView---------------------------------------------
    //when alertview button is pressed
    func alertView(alertView: UIAlertView!, clickedButtonAtIndex buttonIndex: Int)
    {
        let realm = try! Realm()
        switch buttonIndex
        {
        case 0:
            break;
        case 1:
            deleteFromRealm(wdmarr[currentwdmrr].year, month1: wdmarr[currentwdmrr].month, day1: wdmarr[currentwdmrr].workarr[currentwdmrrworkarr].day)
            wdmarr[currentwdmrr].workarr.removeAtIndex(currentwdmrrworkarr)
            if(wdmarr[currentwdmrr].workarr.count == 0){
            wdmarr.removeAtIndex(currentwdmrr)
                indexer = 0
            }
            else{
            try! realm.write{
                wdmarr[currentwdmrr].TotalMoney()
            }
            }
            getRealmData()
            tableView.reloadData()
        default:
            print("error")
        }
    }
    //----------------------------------------------------------------------------------

    
    
    
    
    //----------------------------------RealmDataBase-----------------------------
    //delete from RealmDataBase
    func deleteFromRealm(year1 : Int , month1 : Int , day1 : Int){
        let realm = try! Realm()
        var allDays = realm.objects(WorkDay)
        for day in allDays{
            if(day.year == year1 && day.month == month1 && day.day == day1){
                try! realm.write{
                    realm.delete(day)
                }
            }
        }
        
    }
    
    // check if object of this date exists in the database
    func checkIfDateIsInDB(year1 : Int , month1 : Int , day1 : Int)-> Bool{
        let realm = try! Realm()
        let allDate = realm.objects(WorkDay)
        if(allDate.isEmpty){return false}
        for dates in allDate {
            if(dates.year == year1 && dates.month == month1 && dates.day == day1){
                return true
            }
        }
        return false
    }
    
    //get the data from realmbase
    func getRealmData(){
        let realm = try! Realm()
        //  realm query 3shan atl3 el m3ra5   DONEEEEE
        let workDO = realm.objects(WorkDay)
        var arr = [WorkDay]()
        for wkd in workDO {
            arr.append(wkd)
            print(wkd)
        }
        arr = sortArray(arr)
        
        // wdmarr is a wkManager which manages all of the workdays to make it easier to control the data
        wdmarr  = Convert(arr)
        wdmarr = wdmarr.reverse()
        
    }
    //----------------------------------------------------------------------------------

    
}