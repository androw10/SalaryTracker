//
//  workDM.swift
//  MyReallHUApp
//
//  Created by androw on 06/07/2016.
//  Copyright © 2016 androw_S. All rights reserved.
//

import Foundation

class wkManager {
    var month = 0
    var year = 0
    
    func DateFill (year1 : Int , month1 : Int){
        year = year1
        month = month1
    }
    
    var workarr = [WorkDay]()
    
    var totalMoney : Double = 0
    
    var daysW = 0

    func addToArr(wd : WorkDay){
        workarr.append(wd)
    }
    
    func TotalMoney(){
        totalMoney = 0
        for wd in workarr{
            totalMoney += wd.Total()
        }
        totalMoney = (round(100*totalMoney)/100)

        daysW = workarr.count
    }

}