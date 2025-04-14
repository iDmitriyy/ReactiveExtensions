//
//  Filter.swift
//  ReactiveExtensions
//
//  Created by Dmitriy Ignatyev on 13.04.2025.
//

extension ObservableType {
  public func filterConsecutiveNilValues<R>() -> Observable<R?> where Element == R? {
    previousAndCurrent().compactMap { previous, current -> R?? in
      if current == nil, previous == nil {
        nil
      } else {
        current
      }
    }
  }
}
