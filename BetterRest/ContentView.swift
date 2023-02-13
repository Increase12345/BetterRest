//
//  ContentView.swift
//  temp1
//
//  Created by Nick Pavlov on 2/12/23.
//

import SwiftUI
import CoreML

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .font(.headline)
                        .labelsHidden()
                        .datePickerStyle(.wheel)
                } header: {
                    Text("When do you want to wake up?")
                }
                
                Section {
                    Stepper(sleepAmount == 1 ? "1 hour": "\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 1...12, step: 0.25)
                } header: {
                    Text("Desired amount of sleep")
                }
                
                Section {
                    Stepper(coffeAmount == 1 ? "1 cup": "\(coffeAmount) cups", value: $coffeAmount, in: 0...20)
                } header: {
                    Text("Daily coffe intake")
                }
                
                Section {
                    VStack(alignment: .center, spacing: 20) {
                        Text("You should go to bed at")
                        Button(action: {
                            calculateBedTime()
                        }, label: {
                                Text("☀️   \(alertMessage)   🌘")
                                .font(.largeTitle)
                                .bold()
                        })
                    }
                    .frame(maxWidth: .infinity)
                }
                .navigationTitle("BetterRest")
            }
            .task {
                calculateBedTime()
            }
        }
    }
    
    func calculateBedTime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            alertTitle = "Your ideal bedtime is..."
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem caclulating your bedtime."
        }
        
        showingAlert = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

