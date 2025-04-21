//
//  FilterConsecutiveNilValuesTests.swift
//  reactive-extensions
//
//  Created by Dmitriy Ignatyev on 21.04.2025.
//

@testable import RxExtensions
import RxSwift
import RxTest
import Testing

struct FilterConsecutiveNilValuesTests {
  func testSingleElement_Immediate() {
    let scheduler = TestScheduler(initialClock: 0)
    
    let source: TestableObservable<Int?> = scheduler.createHotObservable([
      .next(190, 0),
      .next(220, 1),
      .next(240, nil),
      .next(260, 2),
      .next(280, nil),
      .next(300, nil),
      .next(320, 3),
      .next(340, nil),
      .next(360, nil),
      .next(380, nil),
      .completed(400),
    ])
    
    let res = scheduler.start {
      source.filterConsecutiveNilValues()
    }
    
    XCTAssertEqual(res.events, [
      .next(220, 1),
      .next(240, nil),
      .next(260, 2),
      .next(280, nil),
      .next(320, 3),
      .next(340, nil),
      .completed(400),
    ])
    
    XCTAssertEqual(source.subscriptions, [
      Subscription(200, 400),
    ])
  }
}
