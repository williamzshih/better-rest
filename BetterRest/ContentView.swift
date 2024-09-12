//
//  ContentView.swift
//  BetterRest
//
//  Created by William Shih on 8/28/23.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUpTime = defaultWakeUpTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    static var defaultWakeUpTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    var actualSleep: Double {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUpTime)
            let hourSeconds = (components.hour ?? 0) * 60 * 60
            let minuteSeconds = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hourSeconds + minuteSeconds), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            return prediction.actualSleep
        } catch {
            return 0
        }
    }
    
    var sleepTime: Date {
        wakeUpTime - actualSleep
    }
    
    var actualSleepHours: Int {
        Int(actualSleep / 60 / 60)
    }
    
    var actualSleepMinutes: Int {
        Int(round((actualSleep / 60 / 60).truncatingRemainder(dividingBy: 1) * 60))
    }
    
    var sleepPercentageIncrease: Double {
        let final = actualSleep
        let initial = sleepAmount * 3600
        return (final - initial) / initial
    }
        
    var body: some View {
        NavigationStack {
            Form {
                Section("When do you want to wake up?") {
                    DatePicker("Select a time to wake up", selection: $wakeUpTime, displayedComponents: .hourAndMinute)
                }
                
                Section("How much sleep do you want to get?") {
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                }
                
                Section("How much coffee do you drink?") {
                    Picker("Choose a coffee amount", selection: $coffeeAmount) {
                        ForEach(1...20, id: \.self) {
                            Text("^[\($0) cup](inflect: true)")
                        }
                    }
                }
                
                Section("Your ideal bedtime") {
                    Text(sleepTime.formatted(date: .omitted, time: .shortened))
                        .font(.largeTitle)
                    
                    Text("You will be sleeping for \(actualSleepHours) hours and \(actualSleepMinutes) minutes, which is \(actualSleepHours == Int(sleepAmount) ? "" : "\(actualSleepHours - Int(sleepAmount)) hours and ")\(actualSleepMinutes) minutes more than what you want to get, or a \(sleepPercentageIncrease.formatted(.percent)) increase.")
                }
            }
            .navigationTitle("BetterRest")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
