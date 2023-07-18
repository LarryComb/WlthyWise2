//
//  ContentView.swift
//  WlthyWise
//
//  Created by LARRY COMBS on 7/8/23.
//

import SwiftUI
import OpenAISwift

struct CalculatorView: View {
    @State private var number1: String = ""
    @State private var number2: String = ""
    @State private var numbers: [[String]] = []
    @State private var result: String = ""
    @State private var isKeyboardVisible: Bool = false
    
    private let authToken = ""
    
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
                        .onTapGesture {
                            hideKeyboard()
                        }
                    
                    TextField("APR", text: $number2)
                        .keyboardType(.numberPad)
                        .padding()
                        .onTapGesture {
                            hideKeyboard()
                        }
                }
                
                ForEach(numbers.indices, id: \.self) { row in
                    HStack {
                        ForEach(numbers[row].indices, id: \.self) { column in
                            TextField("Same as above \(row * 2 + column + 3)", text: $numbers[row][column])
                                .keyboardType(.numberPad)
                                .padding()
                                .onTapGesture {
                                    hideKeyboard()
                                }
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
                    calculateProduct()
                }) {
                    Text("Calculate")
                        .font(.headline)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                ScrollView{
                    Text("How Long Pay Off: \(result)")
                        .font(.title)
                        .padding()
                }
                
                Toggle(isOn: $isDarkMode) {
                    Text("Dark Mode Setting")
                }
                .padding()
            }
            .padding()
            .preferredColorScheme(isDarkMode ? .dark : .light)
            .onTapGesture {
                hideKeyboard()
            }
            .onAppear {
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { _ in
                    isKeyboardVisible = true
                }
                
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                    isKeyboardVisible = false
                }
            }
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
    
    func calculateProduct() {
        var product = 1
        
        if let num1 = Int(number1), let num2 = Int(number2) {
            product *= num1 * num2
        }
        
        let calculation = "If \(number1) is the amount of my credit card and \(number2)% is my interest rate and I am making the mminimum payments, how long will it take me to pay off the card?"
        let client = OpenAISwift(authToken: authToken)
        
        client.sendCompletion(with: calculation, maxTokens: 50) { result in
            switch result {
            case .success(let model):
                let response = model.choices?.first?.text ?? ""
                self.result = response
            case .failure(let error):
                self.result = "Error: \(error.localizedDescription)"
            }
        }
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
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




