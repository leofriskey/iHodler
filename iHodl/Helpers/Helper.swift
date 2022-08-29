//
//  Helper.swift
//  iHodl
//
//  Created by Leo Friskey on 10.08.2022.
//

import SwiftUI

//MARK: Get screen size data
extension UIScreen {
   static let screenWidth = UIScreen.main.bounds.size.width
   static let screenHeight = UIScreen.main.bounds.size.height
   static let screenSize = UIScreen.main.bounds.size
}

extension View {
    //MARK: Show an error alert
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
    
    func copySuccessPopover(_ visible: Bool, label: String) -> some View {
        
        return self
                .overlay(
                    visible ?
                    VStack {
                        Spacer()
                        Text(label)
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(.ultraThinMaterial)
                            )
                    }
                    :
                    nil
                )
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

//MARK: Create readable date for PriceViewerInfo
func createDateTime(timestamp: Date, interval: String) -> String {
    let dateFormatter = DateFormatter()
    let timezone = TimeZone.current.abbreviation() ?? "CET"  // get current TimeZone abbreviation or set to CET
    dateFormatter.timeZone = TimeZone(abbreviation: timezone) //Set timezone that you want
    dateFormatter.locale = NSLocale.current
    if interval == "1D" {
        dateFormatter.dateFormat = "EEEE dd, HH:mm" //Specify your format that you want
    }
    if interval == "7D" {
        dateFormatter.dateFormat = "EEEE dd, HH:mm" //Specify your format that you want
    }
    if interval == "30D" {
        dateFormatter.dateFormat = "EEEE, MMMM dd" //Specify your format that you want
    }
    if interval == "1Y" {
        dateFormatter.dateFormat = "MMMM dd, YYYY" //Specify your format that you want
    }
    if interval == "All" {
        dateFormatter.dateFormat = "MMMM dd, YYYY" //Specify your format that you want
    }
    var strDate = dateFormatter.string(from: timestamp)
       
    strDate = strDate.capitalizingFirstLetter()
    
    return strDate
}

//MARK: Capitilize first letter
extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
}

//MARK: Format as price
extension Double {
    func formatAsPrice(currency: String, afterZero: Int = 2) -> String {
        let priceFormatter = NumberFormatter()
        priceFormatter.numberStyle = .currency
        priceFormatter.currencySymbol = ""
        priceFormatter.maximumFractionDigits = afterZero
        
        
        
        let price = priceFormatter.string(from: NSNumber(value: self)) ?? String(self)
        let symbol = currency == "usd" ? "$" : "₽"
        
        let result = currency == "usd" ? "\(symbol)\(price)" : "\(price)\(symbol)"
        
        return result
    }
}

//MARK: center 'Price' caption in Watchlist and Top10
extension HorizontalAlignment {
    struct CustomAlignment: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            return context[HorizontalAlignment.center]
        }
    }

    static let custom = HorizontalAlignment(CustomAlignment.self)
}
