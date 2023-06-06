//
//  ContentView.swift
//  StepCountExample
//
//  Created by Bryan Langslet on 6/6/23.
//

import SwiftUI
import HealthKit
import SQLite3

struct ContentView: View {
    @State private var stepCount = 0
    @State private var randomNumber = 0
    
    let healthStore = HKHealthStore()
    @State private var db: OpaquePointer?
    
    var body: some View {
        VStack {
            Text("Step Count: \(stepCount)")
            Button(action: {
                let random = Int.random(in: 1..<100)
                randomNumber = random
                persistNumber(random)
            }) {
                Text("Generate and Save Random Number")
            }
            Text("Random Number: \(randomNumber)")
        }
        .onAppear(perform: {
            getStepsCount()
            createTable()
            fetchNumber()
        })
    }
    
    func getStepsCount() {
        // Specify the data types that the app needs to access
        let readDataTypes: Set<HKObjectType> = [HKObjectType.quantityType(forIdentifier: .stepCount)!]

        // Request authorization for those data types
        healthStore.requestAuthorization(toShare: [], read: readDataTypes) { success, error in
            if success {
                // If the authorization was successful, query the step count
                let type = HKQuantityType.quantityType(forIdentifier: .stepCount)!
                
                let now = Date()
                let startOfDay = Calendar.current.startOfDay(for: now)
                let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
                
                let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: .cumulativeSum) { (_, result, error) in
                    guard let result = result, let sum = result.sumQuantity() else {
                        print("Failed to fetch steps count: \(error?.localizedDescription ?? "N/A")")
                        return
                    }
                    
                    DispatchQueue.main.async {
                        self.stepCount = Int(sum.doubleValue(for: HKUnit.count()))
                    }
                }
                
                healthStore.execute(query)
            } else if let error = error {
                // If the authorization was not successful, log any error that occurred
                print("Failed to request authorization: \(error.localizedDescription)")
            }
        }
    }

    
    func createTable() {
        let fileURL = try! FileManager.default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("numbers.sqlite")
        
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
        }
        
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS Numbers (id INTEGER PRIMARY KEY AUTOINCREMENT, num INTEGER)", nil, nil, nil) != SQLITE_OK {
            print("error creating table")
        }
    }
    
    func persistNumber(_ number: Int) {
        var stmt: OpaquePointer?
        
        if sqlite3_prepare(db, "INSERT INTO Numbers (num) VALUES (?)", -1, &stmt, nil) != SQLITE_OK {
            print("error preparing insert")
        }
        
        sqlite3_bind_int(stmt, 1, Int32(number))
        
        if sqlite3_step(stmt) != SQLITE_DONE {
            print("failure inserting number")
        }
        
        fetchNumber()
    }
    
    func fetchNumber() {
        var stmt: OpaquePointer?
        
        if sqlite3_prepare(db, "SELECT num FROM Numbers ORDER BY id DESC LIMIT 1", -1, &stmt, nil) != SQLITE_OK {
            print("error preparing select")
            return
        }
        
        if sqlite3_step(stmt) == SQLITE_ROW {
            randomNumber = Int(sqlite3_column_int(stmt, 0))
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
