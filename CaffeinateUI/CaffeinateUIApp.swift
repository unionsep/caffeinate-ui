//
//  CaffeinateUIApp.swift
//  CaffeinateUI
//
//  Created by Masaya Bando on 2026/06/01.
//

import SwiftUI
import AppKit
import Foundation
import Combine

@main
struct CaffeinateUIApp: App {
    @StateObject private var caffeinate = CaffeinateController()
    var body: some Scene {
        MenuBarExtra("CaffeinateUI", systemImage: caffeinate.isRunning ? "cup.and.saucer.fill" : "cup.and.saucer") {
            Button("Start") {
                caffeinate.start()
            }
            .disabled(caffeinate.isRunning)
            
            Button("Stop") {
                caffeinate.stop()
            }
            .disabled(!caffeinate.isRunning)
            
            Divider()

            Button("Quit") {
                caffeinate.stop()
                NSApplication.shared.terminate(nil)
            }
        }
    }
}

final class CaffeinateController: ObservableObject {
    @Published private(set) var isRunning = false
    @Published var lastError: String?
    
    private var process: Process?
    
    func start() {
        guard process == nil else {
            return
        }
        
        let newProcess = Process()
        newProcess.executableURL = URL(fileURLWithPath: "/usr/bin/caffeinate")
        newProcess.arguments = ["-d", "-i"]
        
        do {
            try newProcess.run()
            process = newProcess
            isRunning = true
            lastError = nil
        } catch {
            lastError = error.localizedDescription
            isRunning = false
            process = nil
        }
    }
    
    func stop() {
        process?.terminate()
        process = nil
        isRunning = false
    }
    
    func toggle() {
        if isRunning {
            stop()
        } else {
            start()
        }
    }
}
