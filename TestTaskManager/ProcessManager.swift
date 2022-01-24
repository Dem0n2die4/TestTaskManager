//
//  ProcessManager.swift
//  TestTaskManager
//
//  Created by Dmitriy Bashkalin on 23.01.2022.
//

import Foundation
import AppKit
import Darwin

public class ProcessManager : NSObject
{
    var _processList: [pid_t : String] = [:]
    var _configuration: ConfigInfo
    
    var _notificationCenter: NotificationCenter
    var _notifyCenter: DistributedNotificationCenter
    
    struct ConfigInfo: Codable {
        var OnlyUser: Bool
    }

    public override init() {
        _notificationCenter = NSWorkspace.shared.notificationCenter
        _notifyCenter = DistributedNotificationCenter()
        _configuration = ConfigInfo(OnlyUser: false)
        
        super.init()
        
        ReadConfiguration()
        _processList = GetCmdProcessList()
        InitObservers()
    }
    
    private func InitObservers()
    {
        _notifyCenter.suspended = false
        // don't forget to add _notifyCenter.postNotificationName(Notification.Name(rawValue:"TTMConfigurationChanged") on PrefPane
        _notifyCenter.addObserver(forName: Notification.Name(rawValue: "TTMConfigurationChanged"), object: nil, queue: nil, using: OnConfiguarationChanged)
        
        _notificationCenter.addObserver(self, selector: #selector(OnProcessStart), name: NSWorkspace.didLaunchApplicationNotification, object: nil)
        _notificationCenter.addObserver(self, selector: #selector(OnProcessTerminate), name: NSWorkspace.didTerminateApplicationNotification, object: nil)
        // subscribe to message from Pref Pane to update configuration
    }
    
    private func ReadConfiguration()
    {
        let fm = FileManager.default
        let configPath = "/etc/ttm.plist"
        
        if let cfgPlist = fm.contents(atPath: configPath), let config = try? PropertyListDecoder().decode(ConfigInfo.self, from: cfgPlist)
        {
            _configuration = config
        }
        else
        {
            let cfgData = try? PropertyListEncoder().encode(_configuration)
            fm.createFile(atPath: configPath, contents: cfgData, attributes: nil)
        }
    }
    
    @objc func OnConfiguarationChanged(notification: Notification) -> Void
    {
        ReadConfiguration()
        _processList = GetCmdProcessList()
    }
    
    // works only for app with GUI
    // for command line process need to call 'ps' in loop
    @objc func OnProcessStart(notification: NSNotification) -> Void
    {
        // insert to proc list
        if let userInfo = notification.userInfo, let terminatedPid = userInfo["NSApplicationProcessIdentifier"]
        {
            print(userInfo["NSApplicationPath"])
            _processList[terminatedPid as! Int32] = userInfo["NSApplicationPath"] as! String // check pid for correct cast
        }
    }
    
    @objc func OnProcessTerminate(notification: NSNotification) -> Void
    {
        // remove from proc list
        if let userInfo = notification.userInfo, let terminatedPid = userInfo["NSApplicationProcessIdentifier"]
        {
            print(userInfo["NSApplicationPath"])
            _processList[terminatedPid as! Int32] = nil // check pid for correct cast
        }
    }
    
    // need for prepare data for UI
    func GetProcesInfoList() -> [ProcessInfo]
    {
        var result: [ProcessInfo] = []
        
        let procList = GetCmdProcessList()
        
        procList.forEach({
            result.append(ProcessInfo.init(pid: $0.key, processName: $0.value))
        })
        
        return result.sorted{
            return $0.pid < $1.pid
        }
    }
    
    func GetCmdProcessList() -> [pid_t : String]
    {
        var processes = [pid_t : String]()
        
        let task = Process()
        task.launchPath = "/bin/ps" // What if doesn't exist in system?
        task.arguments = [_configuration.OnlyUser ? "-x" : "-e", "-o pid=,comm="] // ps -x -o ... user's processes
        
        let outPipe = Pipe()
        task.standardOutput = outPipe
        
        task.launch()
        task.waitUntilExit()
        
        let data = outPipe.fileHandleForReading.readDataToEndOfFile()
        let str = String(decoding: data, as: UTF8.self)
        
        str.components(separatedBy: "\n").forEach({
            let PidProcNameStr = $0.trimmingCharacters(in: .whitespacesAndNewlines)
            if let firstEntry = PidProcNameStr.firstIndex(of: " ")
            {
                if let pid = Int32(String(PidProcNameStr.prefix(upTo: firstEntry)))
                {
                    processes[pid] = String(PidProcNameStr.suffix(from: firstEntry))
                }
            }
        })
        
        return processes
    }
    
    public static func TerminateProcess(pid: pid_t) -> Bool
    {
        if(kill(pid, SIGTERM) == 0) // What if doesn't terminate? Need to send SIGKILL?
        {
            return true
        }
        else if(kill(pid, SIGKILL) == 0)
        {
            return true
        }
        
        let app = NSRunningApplication.init(processIdentifier: pid)
        app?.forceTerminate()
        
        return false
    }
    
//    public func GetUserProcessList()
//    {
//        // NSWorkspace | NSApplication - only userspace
//    }
//
//    // How to update process list?
//    // Call GetProcessList by timeout?
//    // Does notification show running root processes?
//    public func OnStartProcess()
//    {
//        // add to list
//    }
//
//    public func OnStopProcess()
//    {
//        // remove from list
//    }
//
//    public func SubscribeOnNotifications()
//    {
//        // notification center - only userspace
//    }
}
