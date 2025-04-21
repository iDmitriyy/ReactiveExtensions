//
//  PreviousAndCurrentTests.swift
//  reactive-extensions
//
//  Created by Dmitriy Ignatyev on 21.04.2025.
//

import RxSwift
import RxTest
import Testing
@testable import RxExtensions
import struct FunctionalTypes.PreviousAndCurrent

struct PreviousAndCurrentTests {
  func testPreviousAndCurrent() {
    let scheduler = TestScheduler(initialClock: 0)
    
    let source = scheduler.createHotObservable([
      .next(220, 1),
      .next(240, 2),
      .next(260, 3),
      .next(280, 4),
      .next(300, 5),
      .completed(320),
    ])
    
    let res: TestableObserver<String> = scheduler.start {
      source.previousAndCurrent().map { "\($0.previous)-\($0.current)" }
    }
    
    XCTAssertEqual(res.events, [
      .next(220, "1-1"),
      .next(240, "1-2"),
      .next(260, "2-3"),
      .next(280, "3-4"),
      .next(300, "4-5"),
      .completed(320),
    ])
    
    XCTAssertEqual(source.subscriptions, [
      Subscription(200, 320),
    ])
  }
  
  func testPreviousAndCurrent2() {
    let scheduler = TestScheduler(initialClock: 0)
    
    let source = scheduler.createHotObservable([
      .next(190, 0), // этого элемента в RO быть не должно, т.к. он эмитится до создания подписки
      .next(220, 1),
      .next(240, 2),
      .next(260, 3),
      .next(280, 4),
      .next(300, 5),
      .completed(320),
    ])
    
    let res: TestableObserver<String> = scheduler.start {
      source.previousAndCurrent().map { "\($0)-\($1)" }
    }
    
    XCTAssertEqual(res.events, [
      .next(220, "1-1"),
      .next(240, "1-2"),
      .next(260, "2-3"),
      .next(280, "3-4"),
      .next(300, "4-5"),
      .completed(320),
    ])
    
    XCTAssertEqual(source.subscriptions, [
      Subscription(200, 320),
    ])
  }
}
