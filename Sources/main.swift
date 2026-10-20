import AppKit

final class PetPanel: NSPanel {
    override var canBecomeKey: Bool { true }
}

enum PetStyle: Int, CaseIterable {
    case cat, fox, bunny, bear, panda, frog, penguin, robot, dragon, owl
    var name: String { ["Cloud cat", "Ember fox", "Moon bunny", "Honey bear", "Bamboo panda", "Mochi frog", "Pip penguin", "Bolt robot", "Sprout dragon", "Cocoa owl"][rawValue] }
    var color: NSColor {
        let colors: [(CGFloat, CGFloat, CGFloat)] = [(0.78,0.88,0.91),(0.95,0.52,0.22),(0.91,0.81,0.94),(0.72,0.50,0.28),(0.94,0.94,0.88),(0.48,0.78,0.43),(0.34,0.43,0.57),(0.58,0.65,0.91),(0.39,0.74,0.66),(0.66,0.48,0.38)]
        let c = colors[rawValue]; return NSColor(calibratedRed: c.0, green: c.1, blue: c.2, alpha: 1)
    }
}

final class PetView: NSView {
    var style: PetStyle = PetStyle(rawValue: UserDefaults.standard.integer(forKey: "petStyle")) ?? .cat
    var onClick: (() -> Void)?
    var onMenu: (() -> Void)?
    var tick = 0
    var timer: Timer?
    var start = NSPoint.zero
    var origin = NSPoint.zero
    var dragged = false
    override init(frame: NSRect) {
        super.init(frame: frame)
        setAccessibilityElement(true)
        setAccessibilityRole(.button)
        setAccessibilityLabel("Habibi-Pet-Bot. Click for assistants. Drag to move.")
        toolTip = "Click for assistants · Drag to move"
        timer = Timer.scheduledTimer(withTimeInterval: 0.18, repeats: true) { [weak self] _ in
            self?.tick += 1
            self?.needsDisplay = true
        }
    }
    required init?(coder: NSCoder) { fatalError() }
    override func accessibilityPerformPress() -> Bool { onClick?(); return true }
    override func draw(_ dirtyRect: NSRect) {
        let reduced = NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
        let bob: CGFloat = reduced ? 0 : (tick % 12 < 6 ? 0 : 2)
        let ink = NSColor(calibratedRed: 0.16, green: 0.21, blue: 0.25, alpha: 1)
        let fur = style.color
        NSColor.black.withAlphaComponent(0.12).setFill()
        NSBezierPath(ovalIn: NSRect(x: 23, y: 10, width: 62, height: 9)).fill()
        func block(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat, _ color: NSColor) {
            color.setFill(); NSRect(x: x, y: y + bob, width: w, height: h).fill()
        }
        // Deliberate pixel silhouette: little ears, paws, and a waving tail.
        block(21, 30, 66, 51, ink); block(27, 24, 54, 63, ink)
        switch style {
        case .cat, .fox:
            block(27, 81, 18, 15, ink); block(63, 81, 18, 15, ink)
            block(33, 81, 6, 9, fur); block(69, 81, 6, 9, fur)
        case .bunny:
            block(30, 78, 15, 30, ink); block(63, 78, 15, 30, ink)
            block(33, 81, 9, 24, fur); block(66, 81, 9, 24, fur)
            block(36, 87, 3, 15, .systemPink); block(69, 87, 3, 15, .systemPink)
        case .bear, .panda:
            block(21, 72, 21, 21, ink); block(66, 72, 21, 21, ink)
            block(27, 78, 9, 9, style == .panda ? ink : fur); block(72, 78, 9, 9, style == .panda ? ink : fur)
        case .frog:
            block(24, 75, 24, 18, ink); block(60, 75, 24, 18, ink)
            block(27, 78, 18, 12, fur); block(63, 78, 18, 12, fur)
        case .robot:
            block(51, 81, 6, 15, ink); block(48, 96, 12, 6, .systemYellow)
            block(12, 48, 9, 21, ink); block(87, 48, 9, 21, ink)
        case .dragon:
            block(27, 81, 12, 18, .systemYellow); block(69, 81, 12, 18, .systemYellow)
            block(9, 33, 15, 27, ink); block(87, 33, 15, 27, ink)
            block(12, 39, 9, 15, fur); block(90, 39, 9, 15, fur)
        case .owl:
            block(21, 75, 15, 18, ink); block(72, 75, 15, 18, ink)
        case .penguin: break
        }
        block(27, 33, 54, 45, fur); block(33, 30, 42, 51, fur)
        block(30, 18, 18, 12, ink); block(60, 18, 18, 12, ink)
        block(33, 21, 12, 9, fur); block(63, 21, 12, 9, fur)
        if style == .penguin || style == .owl || style == .fox {
            block(36, 33, 36, 39, NSColor(calibratedWhite: 0.94, alpha: 1))
        }
        if style == .panda { block(30, 51, 18, 21, ink); block(60, 51, 18, 21, ink) }
        if style == .robot { block(30, 48, 48, 24, ink) }
        if style == .frog {
            block(30, 75, 12, 9, .white); block(66, 75, 12, 9, .white)
            block(33, 75, 6, 6, ink); block(69, 75, 6, 6, ink)
        }
        if style == .owl { block(30, 51, 21, 21, .white); block(57, 51, 21, 21, .white) }
        if style == .penguin { block(24, 18, 24, 6, .systemOrange); block(60, 18, 24, 6, .systemOrange) }
        let tail: CGFloat = reduced || tick % 8 < 4 ? 0 : 6
        if [.cat, .fox, .dragon].contains(style) {
            block(84, 36, 12, 9, ink); block(90, 42, 9, 15 + tail, ink)
            if style == .fox { block(90, 51 + tail, 9, 9, .white) }
        }
        let blink = !reduced && tick % 27 == 0
        let eye: NSColor = style == .panda ? .white : (style == .robot ? .systemMint : ink)
        if style != .frog { block(36, 57, 6, blink ? 3 : 9, eye); block(66, 57, 6, blink ? 3 : 9, eye) }
        if style == .penguin || style == .owl { block(48, 45, 12, 9, .systemOrange) }
        block(48, 45, 12, 3, ink); block(51, 42, 6, 3, ink)
        block(30, 48, 9, 3, .systemPink.withAlphaComponent(0.55))
        block(69, 48, 9, 3, .systemPink.withAlphaComponent(0.55))
    }
    override func mouseDown(with event: NSEvent) {
        start = NSEvent.mouseLocation; origin = window?.frame.origin ?? .zero; dragged = false
    }
    override func mouseDragged(with event: NSEvent) {
        let p = NSEvent.mouseLocation
        let dx = p.x - start.x, dy = p.y - start.y
        if abs(dx) + abs(dy) > 4 { dragged = true }
        if dragged { window?.setFrameOrigin(NSPoint(x: origin.x + dx, y: origin.y + dy)) }
    }
    override func mouseUp(with event: NSEvent) {
        if dragged, let frame = window?.frame {
            UserDefaults.standard.set(NSStringFromPoint(frame.origin), forKey: "position")
        } else { onClick?() }
    }
    override func rightMouseDown(with event: NSEvent) { onMenu?() }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    var panel: PetPanel!
    var status: NSStatusItem!
    var bubble: PetPanel!
    var titleLabel = NSTextField(labelWithString: "Ready when you are")
    var detailLabel = NSTextField(wrappingLabelWithString: "Open an assistant below. Activity from Claude sessions launched here appears in this bubble.")
    var gallery: NSWindow?
    var launcher: PetPanel!
    var checkingUpdates = false
    var trackingPaused = false
    var activityFile: URL?
    var lastActivity = Data()
    var pollTimer: Timer?
    let prefs = UserDefaults.standard
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        panel = PetPanel(contentRect: NSRect(x: 0, y: 0, width: 112, height: 112), styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false)
        panel.isOpaque = false; panel.backgroundColor = .clear; panel.hasShadow = false
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.isMovableByWindowBackground = false
        let pet = PetView(frame: NSRect(x: 0, y: 0, width: 112, height: 112))
        pet.onClick = { [weak self] in self?.toggleBubble() }
        pet.onMenu = { [weak self] in self?.showMenu() }
        panel.contentView = pet
        let savedPosition = prefs.string(forKey: "position")
        resetPosition()
        if let saved = savedPosition {
            let point = NSPointFromString(saved)
            if NSScreen.screens.contains(where: { $0.visibleFrame.contains(NSPoint(x: point.x + 56, y: point.y + 56)) }) { panel.setFrameOrigin(point); prefs.set(saved, forKey: "position") }
        }
        panel.orderFrontRegardless()
        status = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        status.button?.image = NSImage(systemSymbolName: "pawprint.fill", accessibilityDescription: "Habibi-Pet-Bot")
        status.menu = makeMenu()
        buildBubble()
        buildLauncher()
        NotificationCenter.default.addObserver(self, selector: #selector(positionBubble), name: NSWindow.didMoveNotification, object: panel)
        pollTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in self?.readActivity() }
        showActivity("Your AI assistant", "Pick an assistant below. Let’s make something!")
        if CommandLine.arguments.contains("--choose-pet") { changePet() }
    }
    func buildBubble() {
        bubble = PetPanel(contentRect: NSRect(x: 0, y: 0, width: 440, height: 88), styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false)
        bubble.backgroundColor = .clear; bubble.isOpaque = false; bubble.hasShadow = true
        bubble.level = .floating; bubble.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        let content = NSView(frame: NSRect(x: 0, y: 0, width: 440, height: 88))
        content.wantsLayer = true
        bubble.contentView = content
        let pill = NSVisualEffectView(frame: NSRect(x: 0, y: 0, width: 440, height: 76))
        pill.material = .hudWindow; pill.state = .active; pill.appearance = NSAppearance(named: .darkAqua)
        pill.wantsLayer = true; pill.layer?.cornerRadius = 38; pill.layer?.masksToBounds = true
        pill.layer?.borderWidth = 1; pill.layer?.borderColor = NSColor.white.withAlphaComponent(0.13).cgColor
        content.addSubview(pill)
        titleLabel.frame = NSRect(x: 22, y: 39, width: 292, height: 23)
        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold); titleLabel.textColor = .white
        titleLabel.maximumNumberOfLines = 1; titleLabel.lineBreakMode = .byTruncatingTail
        detailLabel = NSTextField(labelWithString: "Waiting for a task")
        detailLabel.frame = NSRect(x: 22, y: 17, width: 292, height: 22)
        detailLabel.font = .systemFont(ofSize: 14); detailLabel.textColor = NSColor.white.withAlphaComponent(0.62)
        detailLabel.lineBreakMode = .byTruncatingTail
        pill.addSubview(titleLabel); pill.addSubview(detailLabel)
        func control(_ symbol: String, _ label: String, _ action: Selector, _ frame: NSRect, _ parent: NSView) {
            let button = NSButton(image: NSImage(systemSymbolName: symbol, accessibilityDescription: label)!, target: self, action: action)
            button.isBordered = false; button.contentTintColor = .white.withAlphaComponent(0.8)
            button.frame = frame; button.wantsLayer = true
            button.layer?.backgroundColor = NSColor.white.withAlphaComponent(0.07).cgColor
            button.layer?.cornerRadius = frame.height / 2
            button.toolTip = label; button.setAccessibilityLabel(label); parent.addSubview(button)
        }
        control("arrow.turn.down.left", "Return to assistant", #selector(returnToAssistant), NSRect(x: 326, y: 16, width: 44, height: 44), pill)
        control("pause.fill", "Pause or resume activity updates", #selector(toggleTracking(_:)), NSRect(x: 380, y: 16, width: 44, height: 44), pill)
        control("xmark", "Close activity pill", #selector(toggleBubble), NSRect(x: 0, y: 61, width: 25, height: 25), content)
    }
    func buildLauncher() {
        launcher = PetPanel(contentRect: NSRect(x: 0, y: 0, width: 196, height: 38), styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false)
        launcher.backgroundColor = .clear; launcher.isOpaque = false; launcher.hasShadow = true
        launcher.level = .floating; launcher.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        let bar = NSVisualEffectView(frame: NSRect(x: 0, y: 0, width: 196, height: 38))
        bar.material = .hudWindow; bar.state = .active; bar.appearance = NSAppearance(named: .darkAqua)
        bar.wantsLayer = true; bar.layer?.cornerRadius = 19; bar.layer?.masksToBounds = true
        launcher.contentView = bar
        for (index, item) in [("terminal", "Start Claude Code in a folder", #selector(openClaude)), ("sparkles", "Open Apple Intelligence", #selector(openSiri)), ("pawprint", "Change pet", #selector(changePet)), ("chevron.up", "Show or hide activity", #selector(toggleBubble))].enumerated() {
            let button = NSButton(image: NSImage(systemSymbolName: item.0, accessibilityDescription: item.1)!, target: self, action: item.2)
            button.isBordered = false; button.contentTintColor = index == 0 ? .systemPurple : .white
            button.frame = NSRect(x: 8 + index * 46, y: 4, width: 42, height: 30)
            button.toolTip = item.1; button.setAccessibilityLabel(item.1); bar.addSubview(button)
        }
        launcher.orderFrontRegardless()
    }
    @objc func changePet() {
        if let gallery { NSApp.activate(ignoringOtherApps: true); gallery.makeKeyAndOrderFront(nil); return }
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 650, height: 410), styleMask: [.titled, .closable], backing: .buffered, defer: false)
        window.title = "Pick your little sidekick"; window.isReleasedWhenClosed = false
        window.appearance = NSAppearance(named: .darkAqua)
        let content = window.contentView!
        let heading = NSTextField(labelWithString: "Who’s joining you today?")
        heading.font = .systemFont(ofSize: 23, weight: .bold); heading.frame = NSRect(x: 26, y: 350, width: 590, height: 32)
        content.addSubview(heading)
        let subtitle = NSTextField(labelWithString: "10 little companions. Click one to take them home.")
        subtitle.textColor = .secondaryLabelColor; subtitle.frame = NSRect(x: 26, y: 326, width: 590, height: 22); content.addSubview(subtitle)
        for style in PetStyle.allCases {
            let button = NSButton(title: style.name, target: self, action: #selector(selectPet(_:)))
            button.tag = style.rawValue; button.bezelStyle = .regularSquare; button.isBordered = false
            button.imagePosition = .imageAbove; button.font = .systemFont(ofSize: 12, weight: .medium)
            button.frame = NSRect(x: 24 + (style.rawValue % 5) * 122, y: 164 - (style.rawValue / 5) * 146, width: 114, height: 136)
            button.wantsLayer = true; button.layer?.cornerRadius = 16
            let selected = style.rawValue == prefs.integer(forKey: "petStyle")
            button.layer?.backgroundColor = NSColor.white.withAlphaComponent(selected ? 0.14 : 0.04).cgColor
            button.layer?.borderWidth = selected ? 2 : 0
            button.layer?.borderColor = NSColor.systemPurple.cgColor
            let preview = PetView(frame: NSRect(x: 0, y: 0, width: 112, height: 112))
            preview.timer?.invalidate(); preview.timer = nil; preview.style = style
            button.image = NSImage(size: NSSize(width: 112, height: 112), flipped: false) { rect in preview.draw(rect); return true }
            button.setAccessibilityLabel("Choose " + style.name)
            content.addSubview(button)
        }
        gallery = window; window.center(); NSApp.activate(ignoringOtherApps: true); window.makeKeyAndOrderFront(nil)
    }
    @objc func selectPet(_ sender: NSButton) {
        guard let style = PetStyle(rawValue: sender.tag), let pet = panel.contentView as? PetView else { return }
        prefs.set(style.rawValue, forKey: "petStyle"); pet.style = style; pet.needsDisplay = true
        pet.setAccessibilityLabel(style.name + ". Click for activity. Drag to move.")
        for case let button as NSButton in gallery?.contentView?.subviews ?? [] {
            button.layer?.borderWidth = button.tag == style.rawValue ? 2 : 0
            button.layer?.backgroundColor = NSColor.white.withAlphaComponent(button.tag == style.rawValue ? 0.14 : 0.04).cgColor
        }
        showActivity(style.name + " says hi!", "Your new sidekick is ready for an adventure.")
    }
    @objc func returnToAssistant() {
        let isSiri = titleLabel.stringValue.contains("Apple")
        let path = isSiri ? "/System/Applications/Siri.app" : "/System/Applications/Utilities/Terminal.app"
        NSWorkspace.shared.openApplication(at: URL(fileURLWithPath: path), configuration: .init()) { _, _ in }
    }
    @objc func toggleTracking(_ sender: NSButton) {
        trackingPaused.toggle()
        sender.image = NSImage(systemSymbolName: trackingPaused ? "play.fill" : "pause.fill", accessibilityDescription: trackingPaused ? "Resume updates" : "Pause updates")
        if trackingPaused { detailLabel.stringValue = "Activity updates paused" }
        else { lastActivity = Data(); readActivity() }
    }
    @objc func positionBubble() {
        guard bubble != nil else { return }
        let area = panel.screen?.visibleFrame ?? NSScreen.main!.visibleFrame
        if let launcher {
            launcher.setFrameOrigin(NSPoint(x: min(max(panel.frame.midX - 98, area.minX + 8), area.maxX - 204), y: max(area.minY + 4, panel.frame.minY - 32)))
        }
        let x = min(max(panel.frame.minX + 8, area.minX + 8), area.maxX - 448)
        var y = panel.frame.maxY + 12
        if y + 88 > area.maxY { y = panel.frame.minY - 100 }
        bubble.setFrameOrigin(NSPoint(x: x, y: max(area.minY + 8, y)))
    }
    @objc func toggleBubble() {
        if bubble.isVisible { bubble.orderOut(nil) } else { positionBubble(); bubble.orderFrontRegardless() }
    }
    func showActivity(_ title: String, _ detail: String) {
        titleLabel.stringValue = title; detailLabel.stringValue = detail
        if panel.isVisible { positionBubble(); bubble.orderFrontRegardless() }
    }
    func readActivity() {
        guard !trackingPaused, let file = activityFile, let data = try? Data(contentsOf: file), data != lastActivity,
              let object = try? JSONSerialization.jsonObject(with: data) as? [String: String] else { return }
        lastActivity = data
        showActivity(object["task"] ?? "Claude Code", object["title"] ?? "Waiting for activity")
    }
    func makeMenu() -> NSMenu {
        let menu = NSMenu()
        func add(_ title: String, _ action: Selector) {
            let item = NSMenuItem(title: title, action: action, keyEquivalent: "")
            item.target = self; menu.addItem(item)
        }
        add("Change pet…", #selector(changePet))
        add("Show activity bubble", #selector(showBubble))
        add("Apple Intelligence · Open Siri", #selector(openSiri))
        add("Claude Code · Open Terminal", #selector(openClaude))
        if !(prefs.string(forKey: "shortcut") ?? "").isEmpty { add("Run Apple Intelligence shortcut", #selector(runShortcut)) }
        menu.addItem(.separator())
        add("Choose Claude project folder…", #selector(chooseFolder))
        add("Set Apple Intelligence shortcut…", #selector(configureShortcut))
        add(panel.isVisible ? "Hide pet" : "Show pet", #selector(togglePet))
        add("Reset pet position", #selector(resetPosition))
        menu.addItem(.separator())
        add("Check for updates…", #selector(checkForUpdates))
        add("Set GitHub repository…", #selector(configureRepository))
        add("About Habibi-Pet-Bot", #selector(about))
        menu.addItem(.separator())
        add("Quit Habibi-Pet-Bot", #selector(quit))
        return menu
    }
    func refresh() { status.menu = makeMenu() }
    func showMenu() {
        let menu = makeMenu()
        menu.popUp(positioning: nil, at: NSPoint(x: 10, y: 105), in: panel.contentView)
    }
    @objc func showBubble() { positionBubble(); bubble.orderFrontRegardless() }
    @objc func openSiri() {
        showActivity("Apple Intelligence", "Opening Siri · Live progress unavailable")
        NSWorkspace.shared.openApplication(at: URL(fileURLWithPath: "/System/Applications/Siri.app"), configuration: .init()) { _, error in
            if let error { DispatchQueue.main.async { self.message("Siri could not open", error.localizedDescription) } }
        }
    }
    @objc func openClaude() {
        guard let folder = pickProject(startingSession: true) else { return }
        launchClaude(in: folder)
    }
    func launchClaude(in folder: String) {
        let quoted = "'" + folder.replacingOccurrences(of: "'", with: "'\\''") + "'"

        // A .command file opens a real interactive login shell without Apple Events permissions.
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent("HabibiPetBot-" + UUID().uuidString, isDirectory: true)
        do {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: [.posixPermissions: 0o700])
            let file = directory.appendingPathComponent("Claude Code.command")
            let state = directory.appendingPathComponent("activity.json")
            activityFile = state; lastActivity = Data()
            func quote(_ text: String) -> String { "'" + text.replacingOccurrences(of: "'", with: "'\\''") + "'" }
            let hook = quote(Bundle.main.executablePath!) + " --pet-hook " + quote(state.path)
            var hooks: [String: Any] = [:]
            for event in ["SessionStart", "UserPromptSubmit", "PreToolUse", "PostToolUse", "PostToolUseFailure", "PermissionRequest", "Notification", "Stop", "SessionEnd"] {
                hooks[event] = [["hooks": [["type": "command", "command": hook, "timeout": 3]]]]
            }
            let settings = directory.appendingPathComponent("pet-settings.json")
            try JSONSerialization.data(withJSONObject: ["hooks": hooks]).write(to: settings)
            let command = "cd -- " + quoted + " && claude --settings " + quote(settings.path)
            let exitCommand = "printf '%s' '{\"title\":\"Session ended\",\"detail\":\"Claude Code exited. Open a new session when you are ready.\"}' > " + quote(state.path)
            let script = "#!/bin/zsh -l\n" + command + "\n" + exitCommand + "\n"
            showActivity("Let’s build something!", "Opening " + URL(fileURLWithPath: folder).lastPathComponent + " in Claude Code…")
            try script.write(to: file, atomically: true, encoding: .utf8)
            try FileManager.default.setAttributes([.posixPermissions: 0o700], ofItemAtPath: file.path)
            NSWorkspace.shared.open([file], withApplicationAt: URL(fileURLWithPath: "/System/Applications/Utilities/Terminal.app"), configuration: .init()) { _, error in
                if error != nil { DispatchQueue.main.async { self.message("Could not open Terminal", "Open Terminal and run: claude") } }
            }
        } catch { message("Could not launch Claude Code", error.localizedDescription) }
    }
    func pickProject(startingSession: Bool) -> String? {
        NSApp.activate(ignoringOtherApps: true)
        let picker = NSOpenPanel()
        picker.canChooseDirectories = true; picker.canChooseFiles = false; picker.allowsMultipleSelection = false
        picker.title = "Where are we working today?"
        picker.message = "Pick a project folder and I’ll bring Claude Code along."
        picker.prompt = startingSession ? "Let’s go!" : "Use this folder"
        picker.directoryURL = URL(fileURLWithPath: prefs.string(forKey: "folder") ?? NSHomeDirectory())
        guard picker.runModal() == .OK, let url = picker.url else { return nil }
        prefs.set(url.path, forKey: "folder")
        return url.path
    }
    @objc func chooseFolder() { _ = pickProject(startingSession: false) }
    @objc func configureShortcut() {
        NSApp.activate(ignoringOtherApps: true)
        let alert = NSAlert(); alert.messageText = "Apple Intelligence shortcut"
        alert.informativeText = "In Shortcuts, create a shortcut using Ask for Input → Use Model → Show Result. Enter its exact name here. Leave empty to remove."
        let field = NSTextField(frame: NSRect(x: 0, y: 0, width: 320, height: 24))
        field.stringValue = prefs.string(forKey: "shortcut") ?? ""
        alert.accessoryView = field; alert.addButton(withTitle: "Save"); alert.addButton(withTitle: "Cancel")
        alert.window.initialFirstResponder = field
        if alert.runModal() == .alertFirstButtonReturn { prefs.set(field.stringValue.trimmingCharacters(in: .whitespacesAndNewlines), forKey: "shortcut"); refresh() }
    }
    @objc func runShortcut() {
        guard let name = prefs.string(forKey: "shortcut"), !name.isEmpty else { return }
        var parts = URLComponents(); parts.scheme = "shortcuts"; parts.host = "run-shortcut"
        parts.queryItems = [URLQueryItem(name: "name", value: name)]
        if let url = parts.url, !NSWorkspace.shared.open(url) { message("Could not open Shortcuts", "Check that Shortcuts is installed and the saved shortcut name matches.") }
    }
    @objc func togglePet() { if panel.isVisible { panel.orderOut(nil); bubble.orderOut(nil); launcher.orderOut(nil) } else { panel.orderFrontRegardless(); positionBubble(); launcher.orderFrontRegardless() }; refresh() }
    @objc func resetPosition() {
        let screen = NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1000, height: 700)
        panel.setFrameOrigin(NSPoint(x: screen.maxX - 160, y: screen.minY + 24))
        prefs.removeObject(forKey: "position")
    }
    var releaseRepository: String {
        prefs.string(forKey: "releaseRepository") ?? (Bundle.main.object(forInfoDictionaryKey: "HabibiPetBotRepository") as? String ?? "")
    }
    func validRepository(_ value: String) -> Bool {
        value.range(of: "^[A-Za-z0-9][A-Za-z0-9_.-]*/[A-Za-z0-9][A-Za-z0-9_.-]*$", options: .regularExpression) != nil
    }
    @objc func configureRepository() {
        NSApp.activate(ignoringOtherApps: true)
        let alert = NSAlert(); alert.messageText = "Where does your pet get updates?"
        alert.informativeText = "Enter the public GitHub repository as owner/repository. Update checks contact GitHub only when you ask."
        let field = NSTextField(frame: NSRect(x: 0, y: 0, width: 340, height: 24))
        field.stringValue = releaseRepository; field.placeholderString = "yourname/habibi-pet-bot"
        alert.accessoryView = field; alert.addButton(withTitle: "Save"); alert.addButton(withTitle: "Cancel")
        alert.window.initialFirstResponder = field
        guard alert.runModal() == .alertFirstButtonReturn else { return }
        let value = field.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard validRepository(value) else { message("Check the repository name", "Use owner/repository, for example yourname/habibi-pet-bot."); return }
        prefs.set(value, forKey: "releaseRepository")
    }
    @objc func checkForUpdates() {
        guard !checkingUpdates else { return }
        let repo = releaseRepository
        guard validRepository(repo) else { configureRepository(); return }
        checkingUpdates = true
        var request = URLRequest(url: URL(string: "https://api.github.com/repos/" + repo + "/releases/latest")!)
        request.timeoutInterval = 20
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("HabibiPetBot", forHTTPHeaderField: "User-Agent")
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self else { return }
                self.checkingUpdates = false
                guard error == nil, let http = response as? HTTPURLResponse else {
                    self.message("Couldn’t check for updates", "Check your internet connection and try again."); return
                }
                guard http.statusCode == 200, let data,
                      let release = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let tag = release["tag_name"] as? String else {
                    let detail = http.statusCode == 404 ? "No public release is available yet. Check the repository name or try again after the first release." : "GitHub returned HTTP \(http.statusCode). Try again later."
                    self.message("Updates unavailable", detail); return
                }
                let latest = tag.hasPrefix("v") ? String(tag.dropFirst()) : tag
                guard latest.range(of: "^[0-9]+\\.[0-9]+\\.[0-9]+$", options: .regularExpression) != nil else {
                    self.message("Unsupported release version", "The latest release must use a version such as v1.0.1."); return
                }
                let current = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0.0.0"
                guard current.compare(latest, options: .numeric) == .orderedAscending else {
                    self.message("Your pet is up to date!", "You’re running Habibi-Pet-Bot \(current)."); return
                }
                NSApp.activate(ignoringOtherApps: true)
                let alert = NSAlert(); alert.messageText = "A new adventure awaits: \(latest)"
                alert.informativeText = "You have \(current). Download the latest release, quit the pet, then replace the app. Your pet choice and preferences stay with you."
                alert.addButton(withTitle: "Open download page"); alert.addButton(withTitle: "Later")
                if alert.runModal() == .alertFirstButtonReturn {
                    NSWorkspace.shared.open(URL(string: "https://github.com/" + repo + "/releases/latest")!)
                }
            }
        }.resume()
    }
    @objc func about() {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.0"
        message("Habibi-Pet-Bot \(version)", "A little sidekick for big ideas.\n10 original pixel pets for Claude Code and Apple Intelligence.\n\nUpdate checks are manual. No analytics or API keys.")
    }
    func message(_ title: String, _ detail: String) {
        NSApp.activate(ignoringOtherApps: true)
        let alert = NSAlert(); alert.messageText = title; alert.informativeText = detail; alert.runModal()
    }
    @objc func quit() { NSApp.terminate(nil) }
}

// Claude invokes this lightweight mode with hook JSON on stdin. Only a short task title is saved; tool input is not saved.
if CommandLine.arguments.count == 3 && CommandLine.arguments[1] == "--pet-hook" {
    let input = FileHandle.standardInput.readDataToEndOfFile()
    if let event = try? JSONSerialization.jsonObject(with: input) as? [String: Any] {
        let name = event["hook_event_name"] as? String ?? ""
        let tool = String((event["tool_name"] as? String ?? "tool").prefix(80))
        let labels: [String: (String, String)] = [
            "SessionStart": ("Ready! What shall we build?", "Connected. Send a message in Terminal to start working."),
            "UserPromptSubmit": ("On it! Working on your request…", "Processing your request…"),
            "PreToolUse": ("Claude is using " + tool, "A tool operation is starting. See Terminal for its details."),
            "PostToolUse": ("On it! Working on your request…", tool + " finished. Claude is continuing your request."),
            "PostToolUseFailure": ("Tool operation failed", tool + " reported an error. Check Terminal for details."),
            "PermissionRequest": ("A little help? Approval needed", "Review the permission request in Terminal."),
            "Notification": ("Psst… check Terminal", "Check Terminal for a notification or input request."),
            "Stop": ("All done! Your response is ready", "Your response is ready in Terminal."),
            "SessionEnd": ("Session ended", "Open a new Claude Code session from the pet.")
        ]
        let destination = URL(fileURLWithPath: CommandLine.arguments[2])
        let previous = (try? Data(contentsOf: destination)).flatMap { try? JSONSerialization.jsonObject(with: $0) as? [String: String] }
        var task = previous?["task"] ?? "Claude Code"
        if name == "UserPromptSubmit", let prompt = event["prompt"] as? String {
            task = String(prompt.components(separatedBy: .newlines).joined(separator: " ").prefix(100))
        }
        if let value = labels[name], let data = try? JSONSerialization.data(withJSONObject: ["title": value.0, "detail": value.1, "task": task, "updated": UUID().uuidString]) {
            try? data.write(to: destination, options: .atomic)
        }
    }
    exit(0)
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
