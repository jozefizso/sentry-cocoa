import XCTest

final class MetricKitConverterTests: XCTestCase {

    func testExample() throws {
        let payload = try contentsOfResource(resource: "metric-kit-diagnostic-payload-2")
        
        let mxCallStacks = try flattenStacktrace(diagnosticsPayload: payload)
        
        XCTAssertEqual(16, mxCallStacks.count)
        
        convert(mxCallStacks: mxCallStacks)
    }
    
    func contentsOfResource(resource: String, ofType: String = "json") throws -> Data {
        let path = Bundle(for: type(of: self)).path(forResource: resource, ofType: "json")
        return try Data(contentsOf: URL(fileURLWithPath: path ?? ""))
    }
}
