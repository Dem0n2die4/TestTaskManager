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
    public func GetCmdProcessList() -> [String : String]
    {
        var processes = [String : String]()
        
        let task = Process()
        task.launchPath = "/bin/ps"
        task.arguments = ["-e", "-o pid=,comm="]
        
        let outPipe = Pipe()
        task.standardOutput = outPipe
        
        task.launch()
        task.waitUntilExit()
        
        let data = outPipe.fileHandleForReading.readDataToEndOfFile()
        let str = String(decoding: data, as: UTF8.self)
        
        let arr = str.components(separatedBy: "\n").map{$0.trimmingCharacters(in: .whitespacesAndNewlines)}
        arr.map{
            if let firstEntry = $0.firstIndex(of: " ")
            {
                processes[String($0.prefix(upTo: firstEntry))] = String($0.suffix(from: firstEntry))
            }
            
        }
        
        return processes
    }
    
    public func GetUserProcessList()
    {
        // NSWorkspace | NSApplication - only userspace
    }
    
    public func TerminateProcess(pid: pid_t) -> Bool
    {
        // terminate or run 'cmd kill'
        
        //only kills users app
//        if let runningProcess = NSRunningApplication.init(processIdentifier: pid)
//        {
//            runningProcess.forceTerminate();
//        }
        if(kill(pid, SIGTERM) == 0)
        {
            return true
        }
        
        return false
    }
    
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
