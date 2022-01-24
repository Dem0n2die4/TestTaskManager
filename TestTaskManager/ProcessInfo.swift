//
//  ProcessInfo.swift
//  TestTaskManager
//
//  Created by Dmitriy Bashkalin on 24.01.2022.
//

import Foundation

public struct ProcessInfo: Identifiable {
    public let id = UUID()
    let pid: Int32
    let processName: String
}
