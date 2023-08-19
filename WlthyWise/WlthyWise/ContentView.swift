//
//  ContentView.swift
//  WlthyWise
//
//  Created by LARRY COMBS on 7/8/23.
//

import SwiftUI
import OpenAISwift

struct CalculatorView: View {
    @State private var creditCardName = ""
    @State private var number1: String = ""
    @State private var number2: String = ""
    @State private var numbers: [[String]] = []
    @State private var result: String = ""
    @State private var isKeyboardVisible: Bool = false
    @State private var highlightedSliceIndex: Int = 1 // Default index for highlighting the first slice

    private let authToken = ""
    
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    
    struct RingView: View {
        let data = [30.0, 40.0, 20.0, 10.0]
        let colors: [Color] = [.red, .blue, .green, .orange]
        
        var body: some View {
            GeometryReader { geometry in
                ZStack {
                    ForEach(0..<data.count, id: \.self) { index in
                        let startAngle = calculateAngle(for: data[0..<index].reduce(0, +))
                        let endAngle = calculateAngle(for: data[0...index].reduce(0, +))
                        Path { path in
                            let centerX = geometry.size.width / 2
                            let centerY = geometry.size.height / 4 // Adjust value to change the vertical position
                            let radius = min(geometry.size.width, geometry.size.height) / 3
                            path.move(to: CGPoint(x: centerX, y: centerY))
                            path.addArc(center: CGPoint(x: centerX, y: centerY), radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
                        }
                        .fill(colors[index])
                    }
                }
            }
        }
        
        private func calculateDataTotal() -> Double {
            return data.reduce(0, +)
        }
        
        private func calculateAngle(for value: Double) -> Angle {
            let total = calculateDataTotal()
            return Angle(degrees: value / total * 360)
        }
    }
    
    var totalLiabilities: Int {
        var total = 0
        if let num1 = Int(number1) {
            total += num1
        }
        for row in numbers {
            for column in row {
                if let num = Int(column) {
                    total += num
                }
            }
        }
        return total
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Text("WlthyWise")
                    .font(.title)
                    .padding()
                
                VStack {
                    VStack {
                        
                        TextField("Credit Card Name", text: $creditCardName)
                            .padding(3)
                        
                        TextField("Credit Balance", text: $number1)
                            .keyboardType(.numberPad)
                            .padding(3)
                            .onTapGesture {
                                hideKeyboard()
                            }
                        
                        TextField("APR", text: $number2)
                            .keyboardType(.numberPad)
                            .padding(3)
                            .onTapGesture {
                                hideKeyboard()
                            }
                    }
                    
                    ForEach(numbers.indices, id: \.self) { row in
                        HStack {
                            ForEach(numbers[row].indices, id: \.self) { column in
                                TextField("Credit Info \(row * 2 + column + 3)", text: $numbers[row][column])
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
                            .foregroundColor(.white)
                    
                    .padding(EdgeInsets(top: 15, leading: 60, bottom: 15, trailing: 60))
                    .background(Color.blue)
                    .cornerRadius(10)
                }
                    
                    NavigationLink(destination: RingView()) {
                        VStack(alignment: .center, spacing: 4) {
                            Text("Open Networth Chart")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .padding(EdgeInsets(top: 15, leading: 10, bottom: 15, trailing: 10))
                        .background(Color.blue)
                        .cornerRadius(10)
                    }

                    
                    Text("Total Liabilities: \(totalLiabilities)")
                        .font(.headline)
                        .padding()
                    
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
    }
    
    func addNumberField() {
        numbers.append(["", "", ""])
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
        
        let calculation = "If \(number1) is the amount of my credit card balance and \(number2)% is my interest rate of the same credit card and I am making the mminimum payments, how long will it take me to pay off the card? Also say something encouring"
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
