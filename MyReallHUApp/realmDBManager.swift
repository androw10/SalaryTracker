//
//  realmDBManager.swift
//  MyReallHUApp
//
//  Created by androw on 06/07/2016.
//  Copyright © 2016 androw_S. All rights reserved.
//

import Foundation
import RealmSwift

class WorkDay : Object {
    
   dynamic var year = 0
    dynamic var month = 0
    dynamic var day = 0
    
    func DateFill (year1 : Int , month1 : Int , day1 : Int){
        year = year1
        month = month1
        day = day1
    }
    
    //default time spent on the
   dynamic var work1s : Double = 0000
   dynamic var work1e : Double = 0
    
   dynamic var work2s : Double = 0000
   dynamic var work2e : Double = 0
    
   dynamic var totalMoney : Double = 0
    
    
    //return total money earned from two jobs(or one)
    func Total()-> Double{
        var work1t = work1e - work1s
        
        var work2t = work2e - work2s
    
        var work1m : Double = 0 , work2m : Double = 0
        
        if(work1t > 0) {
            work1e = 0
            work1s = 0
            if( work1t > 8)
            {
            var temp : Double = work1t - 8
             work1m = ( 8 * 25) + (temp * (25 * 1.5))
            }
            else {
            work1m = work1t * 25
            }
        }
        if(work2t > 0) {
            work2e = 0
            work2s = 0
            if( work2t > 8)
            {
                var temp : Double = work2t - 8
                work2m = ( 8 * 25) + (temp * (25 * 1.5))
            }
            else {
                work2m = work2t * 25
            }
        }
       totalMoney += work2m + work1m
        
        if(work1t == 0){
            work1e = 0
            work1s = 0
        }
        if(work2t == 0){
            work2e = 0
            work2s = 0
        }
        totalMoney = (round(100*totalMoney)/100)
        
       return totalMoney
    }
}
