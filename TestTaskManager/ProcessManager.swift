//
//  ProcessManager.swift
//  TestTaskManager
//
//  Created by Dmitriy Bashkalin on 23.01.2022.
//

import Foundation
import AppKit
import Darwin

public struct ProcessInfo: Identifiable {
    public let id = UUID()
    let pid: Int32
    let processName: String
}

public class ProcessManager : NSObject
{
    public static func GetProcesInfoList() -> [ProcessInfo]
    {
        var result: [ProcessInfo] = []
//        var procList: [pid_t : String] = [:]


        let procList = GetCmdProcessList();
        
        procList.forEach({
            result.append(ProcessInfo.init(pid: $0.key, processName: $0.value))
        })
        
        return result.sorted{
            return $0.pid < $1.pid
        }
    }
    
    private static func GetCmdProcessList() -> [pid_t : String]
    {
        var processes = [pid_t : String]()
        
        let task = Process()
        task.launchPath = "/bin/ps" // What if doesn't exist in system?
        task.arguments = ["-e", "-o pid=,comm="] // ps -x -o ... user's processes
        
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
