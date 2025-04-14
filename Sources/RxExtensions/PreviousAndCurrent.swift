//
//  PreviousAndCurrent.swift
//  ReactiveExtensions
//
//  Created by Dmitriy Ignatyev on 13.04.2025.
//

public import RxSwift
import FunctionalTypes

extension ObservableType {
  public func previousAndCurrent() -> Observable<(previous: Element, current: Element)> {
    let previousAndCurrent = map { element -> Element? in element }
      .scan(nil) { accumulator, newElement -> (previous: Element, current: Element)? in
        guard let newElement else {
//          assertionFailure(error: ConditionalError(code: .unexpectedCodeEntrance))
          return nil
        }
        
        return if let accumulator {
          (previous: accumulator.current, current: newElement)
        } else {
          (previous: newElement, current: newElement)
        }
      }
      .compactMap()
    
    return previousAndCurrent
  }
}
