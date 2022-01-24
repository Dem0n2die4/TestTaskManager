//
//  ContentView.swift
//  TestTaskManager
//
//  Created by Dmitriy Bashkalin on 22.01.2022.
//

import SwiftUI

struct ContentView: View {
    @State private var procList: [ ProcessInfo ] = []
//    @State private var procList: [ pid_t : String ] = [:]
    var body: some View {
        VStack {
            NavigationView {
                
                List {
                    ForEach(procList) { process in
//                        let item = procList[process]
                        
                        NavigationLink(destination: Button("Terminate"){
                                        TerminateProcess(pid: process.pid)
                            
                        })
                        {
                            Text("\(process.pid): \(process.processName)")
                        }

                    }
                    

//                    ForEach(procList) { process in
//                        NavigationLink(destination: Text("\(process.pid)")) {
//                            Text("\(process.pid): \(process.processName)")
//                        }
//                    }
                }
                
            }
            .onAppear {
                self.GetProcList()
            }
            
//
//            Button("Terminate") {
//                Text("Terminate")
//            }
//            .padding(.vertical)

        }
    }
    
    func GetProcList() {
        procList = ProcessManager.GetProcesInfoList()
    }
    
    func TerminateProcess(pid: Int32) {
        ProcessManager.TerminateProcess(pid: pid)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
