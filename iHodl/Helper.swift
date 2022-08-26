//
//  Helper.swift
//  iHodl
//
//  Created by Leo Friskey on 10.08.2022.
//

import SwiftUI

// MARK: Get screen size data
extension UIScreen {
   static let screenWidth = UIScreen.main.bounds.size.width
   static let screenHeight = UIScreen.main.bounds.size.height
   static let screenSize = UIScreen.main.bounds.size
}

extension View {
    // MARK: Show an error alert
    func errorAlert(error: Binding<Market.Error?>, remainingTime: Binding<Int>) -> some View {
        let localizedAlertError = LocalizedAlertError(error: error.wrappedValue)
        
        return ZStack {
            self
                .blur(radius: error.wrappedValue != nil ? 2 : 0)
                .disabled(error.wrappedValue != nil ? true : false)
            if error.wrappedValue != nil {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                        .frame(width: UIScreen.screenWidth * 0.7, height: UIScreen.screenHeight * 0.2)
                    VStack {
                        Text("\(localizedAlertError?.errorDescription ?? "")")
                            .font(.title3)
                        Text("\(localizedAlertError?.recoverySuggestion ?? "")")
                            .padding()
                            .fontWeight(.light)
                        Spacer()
                        Divider()
                        Button {
                            error.wrappedValue = nil
                            remainingTime.wrappedValue = 120
                        } label: {
                            if remainingTime.wrappedValue != 0 {
                                Text("\(remainingTime.wrappedValue)")
                                    .font(.system(size: 20))
                                    .foregroundColor(.secondary)
                            } else {
                                Text("OK")
                                    .font(.system(size: 20))
                                    .foregroundColor(.blue)
                            }
                        }
                        .disabled(remainingTime.wrappedValue != 0 ? true : false)
                    }
                    .padding()
                }
                .frame(width: UIScreen.screenWidth * 0.7, height: UIScreen.screenHeight * 0.2)
            }
        }
    }
}

//MARK: Localized Error
struct LocalizedAlertError: LocalizedError {
    let underlyingError: LocalizedError
    var errorDescription: String? {
        underlyingError.errorDescription
    }
    var recoverySuggestion: String? {
        underlyingError.recoverySuggestion
    }

    init?(error: Error?) {
        guard let localizedError = error as? LocalizedError else { return nil }
        underlyingError = localizedError
    }
}

//MARK: Strip zeroes at the end
extension Double {
    var stringWithoutZeroFraction: String {
        return truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}
