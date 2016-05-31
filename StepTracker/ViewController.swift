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


class ViewController: UIViewController {

    var healthStore = HKHealthStore()
    @IBOutlet weak var stepsLabel :UILabel!
    var dailyStepsArray = [String:Double]()
    var dailyStepInt: Int!
    
    //MARK: - Pull Data Method
    
    func updateUserDailyStepsLabel (day: Int) {
        let stepsType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)! // copied from Authorization methods
        print("set steptype")
        
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
                //print("sent info back to main queue")
//                let dailyDict = ["\(day)": totalSteps]
                self.dailyStepsArray["\(day)"] = totalSteps
                print("Steps for day \(day): \(totalSteps) count:\(self.dailyStepsArray.count)")
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "recvDailyData", object: nil))
            })
        }
        healthStore.executeQuery(query)
        
    }

    
    //MARK: - HealthKit Methods
    
    func getUserData() {
        print("getting data")
        updateUserDailyStepsLabel(0)
        updateUserDailyStepsLabel(1)
        updateUserDailyStepsLabel(2)
        updateUserDailyStepsLabel(3)
        updateUserDailyStepsLabel(4)
        updateUserDailyStepsLabel(5)
        updateUserDailyStepsLabel(6)
        
        
    }
    
    func printInfo() {
        if dailyStepsArray.count == 7 {
            for (key, value) in dailyStepsArray {
                print("THC \(key): \(value)")
            }
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
                    dispatch_async(dispatch_get_main_queue(), {
                        self.getUserData()
                    })
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(printInfo), name: "recvDailyData", object: nil)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

