//
//  Filter.swift
//  ReactiveExtensions
//
//  Created by Dmitriy Ignatyev on 13.04.2025.
//

private import struct FunctionalTypes.PreviousAndCurrent

extension ObservableType {
  public func filterConsecutiveNilValues<R>() -> Observable<R?> where Element == R? {
    previousAndCurrent().compactMap { accumulator -> R?? in
      if accumulator.current == nil, accumulator.previous == nil {
        nil
      } else {
        accumulator.current
      }
    }
  }
}
