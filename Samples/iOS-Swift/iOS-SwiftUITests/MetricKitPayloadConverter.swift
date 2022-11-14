import Foundation
import Sentry

struct MXCallStack {
    var threadAttributed: Bool
    var callStackRootFrames: [MXCallStackRootFrame]
}

struct MXCallStackRootFrame {
    var binaryUUID: String
    var offsetIntoBinaryTextSegment: Int
    var sampleCount: Int
    var binaryName: String
    var address: Int
}

private func sentry_formatHexAddress(_ value: NSNumber?) -> String {
    return String(format: "0x%016llx", value?.uint64Value ?? 0)
}

func convert(mxCallStacks: [MXCallStack]) {
    var threads: [Sentry.Thread] = []
    
    var threadID = 0
    mxCallStacks.forEach { callStack in
        let thread = Thread(threadId: threadID as NSNumber)
        
        var frames: [Frame] = []
        callStack.callStackRootFrames.forEach { callStackRootFrame in
            let frame = Frame()
            frame.package = callStackRootFrame.binaryName
            frame.instructionAddress = sentry_formatHexAddress(callStackRootFrame.address as NSNumber)
            let imageAddress = callStackRootFrame.address - callStackRootFrame.offsetIntoBinaryTextSegment
            frame.imageAddress = sentry_formatHexAddress(imageAddress as NSNumber)
            frames.append(frame)
        }
        
        thread.stacktrace = Stacktrace(frames: frames, registers: [:])
        threads.append(thread)
        
        threadID += 1
    }
    
    let event = Event(level: .fatal)
    event.message = SentryMessage(formatted: "MetricKitCrashTest")
    event.threads = threads
    
    let options = Options()
    options.dsn = "https://6cc9bae94def43cab8444a99e0031c28@o447951.ingest.sentry.io/5428557"
    options.beforeSend = { event in
        return event
    }
    
    let client = Client(options: options)
    let hub = SentryHub(client: client, andScope: nil)
    hub.capture(event: event)
    hub.flush(timeout: 5.0)
}

/*
 * Docs on the JSON payload  https://developer.apple.com/documentation/metrickit/mxcallstacktree/3552293-jsonrepresentation
 */
func flattenStacktrace(diagnosticsPayload: Data) throws -> [MXCallStack] {
    var mxCallStacks: [MXCallStack] = []
    
    let jsonObject = try JSONSerialization.jsonObject(with: diagnosticsPayload)
    guard let dictionary = jsonObject as? [String: Any] else {
        return mxCallStacks
    }
    
    guard let crashDiagnostics = dictionary["crashDiagnostics"] as? [[String: Any]] else {
        return mxCallStacks
    }
    
    for crashDiagnostic in crashDiagnostics {
        guard let callStackTree = crashDiagnostic["callStackTree"] as? [String: Any] else {
            continue
        }
        
        guard let callStacks = callStackTree["callStacks"] as? [[String: Any]] else {
            continue
        }
        
        for callStack in callStacks {
            guard var callStackRootFrames = callStack["callStackRootFrames"] as? [[String: Any]] else {
                continue
            }
            
            var rootFrames: [MXCallStackRootFrame] = []
            
            while !callStackRootFrames.isEmpty {
                let callStackRootFrame = callStackRootFrames.removeFirst()
                
                rootFrames.append(getMXCallStackRootFrame(callStackRootFrame: callStackRootFrame))
                
                guard let subFrames = callStackRootFrame["subFrames"] as? [[String: Any]] else {
                    continue
                }
                
                subFrames.forEach { callStackRootFrames.append($0) }
            }
            
            let threadAttributed = callStack["threadAttributed"] as! Bool
            let mxCallStack = MXCallStack(threadAttributed: threadAttributed, callStackRootFrames: rootFrames)
            
            mxCallStacks.append(mxCallStack)
        }
    }
    
    return mxCallStacks
}
    
private func getMXCallStackRootFrame(callStackRootFrame: [String: Any]) -> MXCallStackRootFrame {
    let binaryUUID = callStackRootFrame["binaryUUID"] as! String
    let offsetIntoBinaryTextSegment = callStackRootFrame["offsetIntoBinaryTextSegment"] as! Int
    let sampleCount = callStackRootFrame["sampleCount"] as! Int
    let binaryName = callStackRootFrame["binaryName"] as! String
    let address = callStackRootFrame["address"] as! Int
    
    return MXCallStackRootFrame(binaryUUID: binaryUUID, offsetIntoBinaryTextSegment: offsetIntoBinaryTextSegment, sampleCount: sampleCount, binaryName: binaryName, address: address)
}
