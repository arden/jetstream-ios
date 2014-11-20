//
//  ChangeSetTests.swift
//  Jetstream
//
//  Copyright (c) 2014 Uber Technologies, Inc.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation
import UIKit
import XCTest

class ChangeSetTests: XCTestCase {
    var root = TestModel()
    var child = TestModel()
    var scope = Scope(name: "Testing")
    
    override func setUp() {
        root = TestModel()
        child = TestModel()
        scope = Scope(name: "Testing")
        root.setScopeAndMakeRootModel(scope)
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testBasicReversal() {
        root.int = 10
        root.float = 10.0
        root.string = "test"
        scope.getAndClearSyncFragments()
        
        root.int = 20
        root.float = 20.0
        root.string = "test 2"
        var changeSet = ChangeSet(syncFragments: scope.getAndClearSyncFragments(), atomic: false, scope: scope)
        changeSet.revertOnScope(scope)
        
        XCTAssertEqual(root.int, 10, "Change set reverted")
        XCTAssertEqual(root.float, Float(10.0), "Change set reverted")
        XCTAssertEqual(root.string!, "test", "Change set reverted")
    }
    
    func testModelReversal() {
        root.childModel = child
        var changeSet = ChangeSet(syncFragments: scope.getAndClearSyncFragments(), atomic: false, scope: scope)
        
        changeSet.revertOnScope(scope)
        
        XCTAssert(root.childModel == nil, "Change set reverted")
        XCTAssertEqual(scope.modelObjects.count, 1 , "Scope knows correct models")
    }
    
    func testModelReapplying() {
        root.childModel = child
        scope.getAndClearSyncFragments()
        
        root.childModel = nil
        var changeSet = ChangeSet(syncFragments: scope.getAndClearSyncFragments(), atomic: false, scope: scope)
        
        changeSet.revertOnScope(scope)
        
        XCTAssert(root.childModel == child, "Change set reverted")
        XCTAssertEqual(scope.modelObjects.count, 2 , "Scope knows correct models")
    }
}