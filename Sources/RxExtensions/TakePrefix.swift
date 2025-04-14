//
//  TakePrefix.swift
//  ReactiveExtensions
//
//  Created by Dmitriy Ignatyev on 13.04.2025.
//

extension ObservableType {
  public func take(prefix count: Int) -> RxSwift.Observable<Self.Element> {
    if count < 1 {
      Observable.never()
    } else {
      enumerated().flatMapLatest { index, element -> Observable<Element> in
        index < count ? Observable.just(element) : Observable.never()
      }
    }
  }
}
