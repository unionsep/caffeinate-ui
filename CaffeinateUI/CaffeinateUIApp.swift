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
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let caffeinate = CaffeinateController()
    private var statusItem: NSStatusItem?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        if let button = statusItem?.button {
            button.target = self
            button.action = #selector(statusItemClicked(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        
        updateIcon()
    }
    
    @objc private func statusItemClicked(_ sender: NSStatusBarButton) {
        if NSApp.currentEvent?.type == .rightMouseUp {
            showMenu()
        } else {
            caffeinate.toggle()
            updateIcon()
        }
    }
    
    private func showMenu() {
        let menu = NSMenu()
        menu.autoenablesItems = false
        
        let startItem = NSMenuItem(title: "Start", action: #selector(startCaffeinate), keyEquivalent: "")
        startItem.target = self
        startItem.isEnabled = !caffeinate.isRunning
        menu.addItem(startItem)
        
        let stopItem = NSMenuItem(title: "Stop", action: #selector(stopCaffeinate), keyEquivalent: "")
        stopItem.target = self
        stopItem.isEnabled = caffeinate.isRunning
        menu.addItem(stopItem)
        
        menu.addItem(.separator())
        
        let quitItem = NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        
        statusItem?.menu = menu
        statusItem?.button?.performClick(nil)
        statusItem?.menu = nil
    }
    
    @objc private func startCaffeinate() {
        caffeinate.start()
        updateIcon()
    }
    
    @objc private func stopCaffeinate() {
        caffeinate.stop()
        updateIcon()
    }
    
    @objc private func quit() {
        caffeinate.stop()
        NSApplication.shared.terminate(nil)
    }
    
    private func updateIcon() {
        let symbolName = caffeinate.isRunning ? "cup.and.saucer.fill" : "cup.and.saucer"
        
        if let image = NSImage(systemSymbolName: symbolName, accessibilityDescription: "Caffeinate UI") {
            image.isTemplate = true
            statusItem?.button?.image = image
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
