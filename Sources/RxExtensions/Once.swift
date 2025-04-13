//
//  Once.swift
//  ReactiveExtensions
//
//  Created by Dmitriy Ignatyev on 13.04.2025.
//

public import RxSwift

extension ObservableType {
  public static func once(_ element: Self.Element) -> Observable<Self.Element> {
    Observable<Element>.create { observer -> any Disposable in
      observer.onNext(element)
      return Disposables.create()
    }
  }
}
