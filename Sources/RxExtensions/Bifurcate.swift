//
//  Bifurcate.swift
//  ReactiveExtensions
//
//  Created by Dmitriy Ignatyev on 13.04.2025.
//

public import RxSwift

extension ObservableType {
  public func bifurcate<A, B>(_ predicate: @escaping (Element) throws -> (A, B))
    -> (Observable<A>, Observable<B>) {
    let stream = map(predicate).share()

    let roA = stream.map { $0.0 }
    let roB = stream.map { $0.1 }

    return (roA, roB)
  }
}
