//
//  ContentView.swift
//  TestTaskManager
//
//  Created by Dmitriy Bashkalin on 22.01.2022.
//

import SwiftUI

struct ContentView: View {
//    @State private var procList: [ ProcessInfo ] = []
    @State private var procList: [ pid_t : String ] = [:]
    var body: some View {
        VStack {
            NavigationView {
                
                List {
//                    ForEach(procList) { process in
//                        NavigationLink(destination: Text("\(process.processName)")) {
//                            Text("Link \(process.processName)")
//                        }
////                        NavigationLink(destination: Text("\(process.processName)) {
////                            Text(process.processName)
////                        }
//                    }
                }
                
            }
            .onAppear {
                self.GetProcList()
            }
            
            
            Button(action: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Action@*/{}/*@END_MENU_TOKEN@*/) {
                /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Content@*/Text("Button")/*@END_MENU_TOKEN@*/
            }

        }
    }
    
    func GetProcList() {
        procList = ProcessManager.GetCmdProcessList()
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
