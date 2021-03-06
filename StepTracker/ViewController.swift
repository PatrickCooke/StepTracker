//
//  ViewController.swift
//  StepTracker
//
//  Created by Patrick Cooke on 5/31/16.
//  Copyright © 2016 Patrick Cooke. All rights reserved.
//

import UIKit
import HealthKit
import PNChart


class ViewController: UIViewController, PNChartDelegate {

    var healthStore = HKHealthStore()
    var dailyStepsArray = [String:Double]()
    var weeklyStepsArray = [String:Double]()
    var monthlyStepsArray = [String:Double]()
    var orderedArray = [(String,Double)]()
    
    var dailyStepInt                        :Int!
    @IBOutlet weak var graphTypeSegControl  :UISegmentedControl!
    
    
    
    //MARK: - Graphing Function
    
    func displayBarChart() {
        let myBarChart = PNBarChart(frame: CGRectMake(10,50,350,550))
        var tempXArray = [String]()
        var tempYArray = [Double]()
        for (key, value) in orderedArray {
            tempXArray.append(key)
            tempYArray.append(value)
        }
        myBarChart.xLabels = tempXArray
        myBarChart.yValues = tempYArray
        
        switch graphTypeSegControl.selectedSegmentIndex {
        case 0:
            myBarChart.barWidth = 40.0
        case 1:
            myBarChart.barWidth = 20.0
        case 2:
            myBarChart.barWidth = 40.0
        default:
            print("nothing)")
        }
        myBarChart.barBackgroundColor = UIColor.clearColor()
        myBarChart.barRadius = 3.0
        myBarChart.isShowNumbers = true
        myBarChart.chartMarginTop = 10
        myBarChart.chartMarginBottom = 35
        myBarChart.showChartBorder = true
        myBarChart.strokeColor = UIColor.greenColor()
        myBarChart.isGradientShow = true
        
        myBarChart.strokeChart()
        myBarChart.delegate = self
        self.view.addSubview(myBarChart)
    }
    
    func userClickedOnBarAtIndex(barIndex: Int) {
        print("bar \(barIndex)")
    }

    
    //MARK: - Pull Data Method
    
    func updateUserDailyStepsLabel (day: Int) {
        let stepsType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)!
        let endDate = NSDate().dateByAddingTimeInterval(Double(day) * -60 * 60 * 24)
        let dayCount = -1
        let startDate = NSCalendar.currentCalendar().dateByAddingUnit(.Day , value: dayCount, toDate: endDate, options: [])
        let predicate = HKQuery.predicateForSamplesWithStartDate(startDate, endDate: endDate, options: .None)
        let limit = abs(dayCount) * 100
        let query = HKSampleQuery(sampleType: stepsType, predicate: predicate, limit: limit, sortDescriptors: nil) { (query, results, error) in
            var totalSteps = 0.0
            for steps in results as! [HKQuantitySample] {
                totalSteps += steps.quantity.doubleValueForUnit(HKUnit.countUnit())
            }
            dispatch_async(dispatch_get_main_queue(), {
                self.dailyStepsArray["\(day)"] = totalSteps
                //print("Steps for day \(day): \(totalSteps) count:\(self.dailyStepsArray.count)")
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "recvDailyData", object: nil))
            })
        }
        healthStore.executeQuery(query)
        
    }
    
    func updateUserWeeklyStepsLabel (day: Int) {
        let stepsType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)!
        let endDate = NSDate().dateByAddingTimeInterval(Double(day) * -60 * 60 * 24 * 7)
        let dayCount = -7
        let startDate = NSCalendar.currentCalendar().dateByAddingUnit(.Day , value: dayCount, toDate: endDate, options: [])
        let predicate = HKQuery.predicateForSamplesWithStartDate(startDate, endDate: endDate, options: .None)
        let limit = abs(dayCount) * 100
        let query = HKSampleQuery(sampleType: stepsType, predicate: predicate, limit: limit, sortDescriptors: nil) { (query, results, error) in
            var totalSteps = 0.0
            for steps in results as! [HKQuantitySample] {
                totalSteps += steps.quantity.doubleValueForUnit(HKUnit.countUnit())
            }
            dispatch_async(dispatch_get_main_queue(), {
                self.weeklyStepsArray["\(day)"] = totalSteps
                //print("Steps for week \(day): \(totalSteps) count:\(self.weeklyStepsArray.count)")
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "recvWeeklyData", object: nil))
            })
        }
        healthStore.executeQuery(query)
        
    }

    func updateUserMonthlyStepsLabel (day: Int) {
        let stepsType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)!
        let endDate = NSDate().dateByAddingTimeInterval(Double(day) * -60 * 60 * 24 * 30)
        let dayCount = -30
        let startDate = NSCalendar.currentCalendar().dateByAddingUnit(.Day , value: dayCount, toDate: endDate, options: [])
        let predicate = HKQuery.predicateForSamplesWithStartDate(startDate, endDate: endDate, options: .None)
        let limit = abs(dayCount) * 100
        let query = HKSampleQuery(sampleType: stepsType, predicate: predicate, limit: limit, sortDescriptors: nil) { (query, results, error) in
            var totalSteps = 0.0
            for steps in results as! [HKQuantitySample] {
                totalSteps += steps.quantity.doubleValueForUnit(HKUnit.countUnit())
            }
            dispatch_async(dispatch_get_main_queue(), {
                self.monthlyStepsArray["\(day)"] = totalSteps
                //print("Steps for month \(day): \(totalSteps) count:\(self.monthlyStepsArray.count)")
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "recvMonthlyData", object: nil))
            })
        }
        healthStore.executeQuery(query)
        
    }

    
    //MARK: - HealthKit Methods
    
    @IBAction func getUserData(segControl: UISegmentedControl) {
        print("getting data")
        if segControl.selectedSegmentIndex == 0 {
            updateUserDailyStepsLabel(0)
            updateUserDailyStepsLabel(1)
            updateUserDailyStepsLabel(2)
            updateUserDailyStepsLabel(3)
            updateUserDailyStepsLabel(4)
            updateUserDailyStepsLabel(5)
            updateUserDailyStepsLabel(6)
        } else if segControl.selectedSegmentIndex == 1 {
            updateUserWeeklyStepsLabel(0)
            updateUserWeeklyStepsLabel(1)
            updateUserWeeklyStepsLabel(2)
            updateUserWeeklyStepsLabel(3)
            updateUserWeeklyStepsLabel(4)
            updateUserWeeklyStepsLabel(5)
            updateUserWeeklyStepsLabel(6)
            updateUserWeeklyStepsLabel(7)
            updateUserWeeklyStepsLabel(8)
            updateUserWeeklyStepsLabel(9)
            updateUserWeeklyStepsLabel(10)
            updateUserWeeklyStepsLabel(11)
        } else if segControl.selectedSegmentIndex == 2 {
            updateUserMonthlyStepsLabel(0)
            updateUserMonthlyStepsLabel(1)
            updateUserMonthlyStepsLabel(2)
            updateUserMonthlyStepsLabel(3)
            updateUserMonthlyStepsLabel(4)
            updateUserMonthlyStepsLabel(5)
        }
    }
    
    func printDailyInfo() {
        if dailyStepsArray.count == 7 {
            print("Daily Data In")
            orderedArray = dailyStepsArray.sort {$0.0 < $1.0}
            for (key, value) in orderedArray {
                print("day \(key): \(value)")
            }
            displayBarChart()
        }
    }
    
    func printWeeklyInfo() {
        if weeklyStepsArray.count == 12 {
            print("Weekly Data In")
            orderedArray = weeklyStepsArray.sort {Int($0.0) < Int($1.0)}
            for (key, value) in orderedArray {
                print("week \(key): \(value)")
            }
            displayBarChart()
        }
    }
    
    func printMonthlyInfo() {
        if monthlyStepsArray.count == 6 {
            print("Monthly Data In")
            orderedArray = monthlyStepsArray.sort {$0.0 < $1.0}
            for (key, value) in orderedArray {
                print("Month \(key): \(value)")
            }
            displayBarChart()
       }
    }
    
    //MARK: - HealthKit Authorization Methods
    
    func dataTypesToRead() -> Set<HKObjectType> {
        let stepsType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)!
        return [stepsType]
    }
    
    func requestAuthorization() {
        if HKHealthStore .isHealthDataAvailable() {
            healthStore.requestAuthorizationToShareTypes(nil, readTypes: dataTypesToRead(), completion: { (success, error) in
                if success {
                    print("Success")
//                    dispatch_async(dispatch_get_main_queue(), {
//                        self.getUserData()
//                    })
                } else {
                    print("Error: \(error)")
                }
            })
        } else {
            print("sorry, this won't work with your device, thanks for the download anyways")
        }
    }
    
    //MARK: - Life Cycle Method
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestAuthorization()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(printDailyInfo), name: "recvDailyData", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(printWeeklyInfo), name: "recvWeeklyData", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(printMonthlyInfo), name: "recvMonthlyData", object: nil)

    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

