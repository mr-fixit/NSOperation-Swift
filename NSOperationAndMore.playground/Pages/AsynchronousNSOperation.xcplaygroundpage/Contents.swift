//: [Previous](@previous)

/*: 
 # Asynchronous NSOperation - Solution to run Asynchronous tasks as NSOperation
 
NSOperationQueue uses KVO feature of NSOperation to determine the status of an operation. 
This implementation detail influences important decisions that NSOperationQueue needs to take. For eg:
 
 * Can the dependent operations be initiated given the current status of operation?
 
 * Determine how many operations can be running concurrently on the NSOperationQueue
 
Given this important implementation detail, it is obvious that we need to take over the KVO of NSOperation and control how the status of NSOperation is reported for asynchronous tasks. 
 
 
 ### Playground code details
  Refer to the sources folder under this playground to get the custom subclass of NSOperation. 
 
 Below are the list of things that the custom subclass does:
 
 * Takes over the setting of state by creating a enum that references the different state that the operation can take.
 
 * Creates a **state** variable that can be updated to indicate change in operation state ( Set status to finished only in the callback of asynchronous task)
 
 * The **state** variable also fires required KVO notifications that are utilized by the NSOperationQueue to determine the state of the task
 
 * Overrides each of the KVO-enabled state indicators to utilize the custom enum defined inside the AsynchronousNSOperation class
 
 
 #### Note
 All the variables inside the Asynchronous NSOperation have been made public due to restrictions of XCPlayground. All of them can remian in internal state when actually used inside your app
 
 */

import Foundation
import XCPlayground

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

class PlaygroundOp: AsynchronousOperation {
    override func main() {
        if self.cancelled == false {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                defer {
                    self.state = .Finished
                    XCPlaygroundPage.currentPage.finishExecution()
                }
                if !self.cancelled {
                    print("\nFrom Inside NSOperation: Start of operation\n")
                    
                    sleep(5)
                    
                    print("\nFrom Inside NSOperation: Completion of operation\n")
                }
            }
        } else {
            self.state = .Finished
        }
    }
}



var operationQueue = NSOperationQueue()
operationQueue.qualityOfService = .Background
var op = PlaygroundOp()

// Add observer for NSOperation state KVO to keep track of the operation status
var observer = KeyValueObserver()
op.addObserver(observer, forKeyPath: "isFinished", options: .New, context: nil)
op.addObserver(observer, forKeyPath: "isReady", options: .New, context: nil)
op.addObserver(observer, forKeyPath: "isCancelled", options: .New, context: nil)
op.addObserver(observer, forKeyPath: "isExecuting", options: .New, context: nil)

// Operation is immediately checked for ready state as soon as it is added to the operation queue unless the queue is suspended
operationQueue.addOperation(op)

// Uncomment the below line to see the isCancelled KVO notifications and prevent the operation from executing
 op.cancel()

