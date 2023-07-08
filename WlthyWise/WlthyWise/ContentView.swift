//
//  ContentView.swift
//  WlthyWise
//
//  Created by LARRY COMBS on 7/8/23.
//

import SwiftUI

struct CalculatorView: View {
    @State private var number1: String = ""
    @State private var number2: String = ""
    @State private var numbers: [[String]] = []
    @State private var result: String = ""
    
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    
    var body: some View {
        VStack {
            Text("WlthyWise")
                .font(.title)
                .padding()
            
            VStack {
                HStack {
                    TextField("Credit Card 1", text: $number1)
                        .keyboardType(.numberPad)
                        .padding()
                    
                    TextField("APR", text: $number2)
                        .keyboardType(.numberPad)
                        .padding()
                }
                
                ForEach(numbers.indices, id: \.self) { row in
                    HStack {
                        ForEach(numbers[row].indices, id: \.self) { column in
                            TextField("Same as above \(row * 2 + column + 3)", text: $numbers[row][column])
                                .keyboardType(.numberPad)
                                .padding()
                        }
                    }
                }
                
                
                HStack {
                    Button(action: {
                        addNumberField()
                    }) {
                        Image(systemName: "plus.circle")
                            .font(.title)
                            .foregroundColor(.blue)
                    }
                    .padding()
                    
                    Button(action: {
                        removeNumberField()
                    }) {
                        Image(systemName: "minus.circle")
                            .font(.title)
                            .foregroundColor(.red)
                    }
                    .padding()
                }
                
                
                
                Button(action: {
                    calculateSum()
                }) {
                    Text("Calculate")
                        .font(.headline)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Text("Months to Pay Off: \(result)")
                    .font(.title)
                    .padding()
                
                Toggle(isOn: $isDarkMode) {
                    Text("Dark Mode Setting")
                }
                .padding()
            }
            .padding()
            .preferredColorScheme(isDarkMode ? .dark : .light)
        }
        
    }
    func addNumberField() {
        numbers.append(["", ""])
    }
    
    func removeNumberField() {
        if !numbers.isEmpty {
            numbers.removeLast()
        }
    }
    
    
    func calculateSum() {
        var product = 1
        if let num1 = Int(number1), let num2 = Int(number2) {
            product *= num1 * num2
        }
        
        for row in numbers {
            for numberString in row {
                if let number = Int(numberString) {
                    product *= number
                }
            }
        }
        
        result = "\(product)"
    }
}

    
    struct CalculatorView_Previews: PreviewProvider {
        static var previews: some View {
            CalculatorView()
        }
    }
    
    
    
    struct ContentView: View {
        var body: some View {
            CalculatorView()
        }
    }
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
