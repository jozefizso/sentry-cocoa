import XCTest

final class MetricKitPayloadConverterTests: XCTestCase {

    func testExample() throws {
        let payload = try contentsOfResource(resource: "metric-kit-diagnostic-payload-2")
        
        let mxCallStacks = try flattenStacktrace(diagnosticsPayload: payload)
        
        XCTAssertEqual(12, mxCallStacks.count)
        
        convert(mxCallStacks: mxCallStacks)

    }

}
