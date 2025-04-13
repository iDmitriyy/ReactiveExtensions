//
//  HotObservableTypeTests.swift
//  ReactiveExtensions
//
//  Created by Dmitriy Ignatyev on 13.04.2025.
//

import Testing
import RxTest
@testable import RxExtensions

struct HotObservableTypeTests {
  @Test func storeElementEmitedBeforeSubscription() throws {
    let scheduler = TestScheduler(initialClock: 0)
    
    let testObservable = scheduler.createHotObservable([ // all elements are emited before subccription
      .next(194, 4),
      .next(195, 5),
      .next(196, 6), // last element before subscription should stored and emited
    ])
    
    let result = scheduler.start(disposed: 1000) {
      testObservable.asHotObservable()
    }
    
    #expect(result.events == [
      .next(200, 6),
    ])
  }
  
  @Test func storeElementsEmitedBeforeAndAfterSubscription() throws {
    let scheduler = TestScheduler(initialClock: 0)
    let bufferSize = 3
    
    let testObservable = scheduler.createHotObservable([
      .next(101, 2), // emission just after observable creation time
      .next(102, 3), // emission just after observable creation time
      .next(198, 4), // emission just before subscription
      .next(199, 5), // emission at the time subscription
      .next(201, 6), // emission just after subscription
    ])
    
    let result = scheduler.start(disposed: 1000) {
      testObservable.asHotObservable(replay: bufferSize)
    }
    
    // element 2 must be dropped because biffer size == 3
    // elements 3, 4, 5 are emited before subscription, must be stored at biffer and emited when subscription made (at time 200)
    // element 6 is emited after subscription
    
    #expect(result.events == [
      .next(200, 3),
      .next(200, 4),
      .next(200, 5),
      .next(201, 6),
    ])
  }
}
