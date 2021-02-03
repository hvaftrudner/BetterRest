//
//  ContentView.swift
//  betterRest
//
//  Created by Kristoffer Eriksson on 2021-02-01.
//

import SwiftUI

struct ContentView: View {
    
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var alertShowing = false
    
    var body: some View {
        
        NavigationView{
            Form{
                
                Section(header: Text("Recommended bedtime")){
                    Text("\(alertMessage)")
                        .font(.largeTitle)
                }
                
                Section(header: Text("When do you want to wake up?")){
                    VStack(alignment: .leading, spacing: 0){

                        Text("When do you want to wake up?")
                            .font(.headline)
                        
                        DatePicker("Please enter a time: ", selection: $wakeUp, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                            .datePickerStyle(WheelDatePickerStyle())
                            
                    }
                }
                
                VStack(alignment: .leading, spacing: 0){
                    Text("desired amount of sleep")
                        .font(.headline)
                    Stepper(value: $sleepAmount, in: 4...12, step: 0.25){
                        Text("Sleepamount: \(sleepAmount, specifier: "%g") hours")
                    }
                }
                VStack(alignment: .leading, spacing: 0){
                    Text("Daily coffee intake: ")
                        .font(.headline)
                    
                    //changed from stepper to picker from challenge 2
                    Picker("cups of coffee", selection: $coffeeAmount){
                        ForEach(0 ..< 20){
                            Text("\($0) cups")
                        }
                    }
//                    Stepper(value: $coffeeAmount, in: 1...20){
//                        if coffeeAmount == 1 {
//                            Text("1 cup")
//                        } else {
//                            Text("\(coffeeAmount) cups")
//                        }
//                    }
                }
            }
            .navigationBarTitle("Better rest")
            //Added onchange of values to update without button
            .onAppear(perform: calculateBedtime)
            .onChange(of: wakeUp) { newv in
                calculateBedtime()
            }
            .onChange(of: coffeeAmount) { newv in
                calculateBedtime()
            }
            .onChange(of: sleepAmount) { newv in
                calculateBedtime()
            }
//            .navigationBarItems(trailing:
//                Button(action: calculateBedtime) {
//                    Text("calculate")
//                }
//            )
//            .alert(isPresented: $alertShowing) {
//                Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
//            }
        }
    }
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        
        return Calendar.current.date(from: components) ?? Date()
    }
    
    func calculateBedtime(){
        let model = SleepCalculator()
        
        let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
        let hour = (components.hour ?? 0) * 60 * 60
        let minute = (components.minute ?? 0) * 60
        
        do {
           let prediction = try
            model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            
            alertTitle = "Your ideal bedtime is: "
            alertMessage = formatter.string(from: sleepTime)
            
        } catch {
            //something went wrong
            alertTitle = "Error"
            alertMessage = "Could not calculate bedtime"
        }
        
        alertShowing = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
