import Foundation
import Quick
import Nimble
import RealmSwift
import Result

@testable import SugarRecord

class RequestTests: QuickSpec {
    
    override func spec() {
        
        describe("builders") {
            
            it("-filteredWithPredicate") {
                let predicate: NSPredicate = NSPredicate(format: "name == TEST")
                let request: Request<Issue> = Request(context: testRealm()).filteredWith(predicate: predicate)
                expect(request.predicate) == predicate
            }
            
            it("-filteredWith(key:value:)") {
                let predicate: NSPredicate = NSPredicate(format: "name == %@", "TEST")
                let request: Request<Issue> = Request(context: testRealm()).filteredWith("name", equalTo: "TEST")
                expect(request.predicate) == predicate
            }
            
            it("-sortedWith(key:ascending:comparator)") {
                let descriptor: NSSortDescriptor = NSSortDescriptor(key: "name", ascending: true, comparator: { _ in return NSComparisonResult.OrderedSame})
                let request: Request<Issue> = Request(context: testRealm()).sortedWith("name", ascending: true, comparator: {_ in return NSComparisonResult.OrderedSame})
                expect(descriptor.key) == request.sortDescriptor?.key
                expect(descriptor.ascending) == request.sortDescriptor?.ascending
            }
            
            it("-sortedWith(key:ascending)") {
                let descriptor: NSSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
                let request: Request<Issue> = Request(context: testRealm()).sortedWith("name", ascending: true)
                expect(descriptor.key) == request.sortDescriptor?.key
                expect(descriptor.ascending) == request.sortDescriptor?.ascending
            }
            
            it("sortedWith(key:ascending:selector)") {
                let descriptor: NSSortDescriptor = NSSortDescriptor(key: "name", ascending: true, selector: "selector")
                let request: Request<Issue> = Request(context: testRealm()).sortedWith("name", ascending: true, selector: "selector")
                expect(descriptor.key) == request.sortDescriptor?.key
                expect(descriptor.ascending) == request.sortDescriptor?.ascending
                expect(descriptor.selector) == request.sortDescriptor?.selector
            }
        }
        
    }
    
}