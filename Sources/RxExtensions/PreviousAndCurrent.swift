//
//  PreviousAndCurrent.swift
//  ReactiveExtensions
//
//  Created by Dmitriy Ignatyev on 13.04.2025.
//

public import struct FunctionalTypes.PreviousAndCurrent

extension ObservableType {
  public func previousAndCurrent() -> Observable<PreviousAndCurrent<Element>> {
    let previousAndCurrent = map { element -> Element? in element }
      .scan(nil) { accumulator, newElement -> PreviousAndCurrent<Element>? in
        guard let newElement else { return nil }
        
        return if let accumulator {
          accumulator.updated(by: newElement)
        } else {
          PreviousAndCurrent(seed: newElement)
        }
      }
      .compactMap()
    return previousAndCurrent
  }
}
