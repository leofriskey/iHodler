//
//  Network.swift
//  iHodl
//
//  Created by Leo Friskey on 18.08.2022.
//

import Foundation
import Network

@MainActor class Network: ObservableObject {
    let monitor = NWPathMonitor()
    let queue = DispatchQueue(label: "Monitor")
    @Published private(set) var connected: Bool = false
    
    func checkConnection() {
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                if path.status == .satisfied {
                        self.connected = true
                } else {
                        self.connected = false
                }
            }
        }
        monitor.start(queue: queue)
    }
}
