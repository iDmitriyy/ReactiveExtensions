//
//  Map.swift
//  ReactiveExtensions
//
//  Created by Dmitriy Ignatyev on 13.04.2025.
//

public import RxCocoa
public import RxSwift

extension ObservableType {
  public func compactMap<R>() -> Observable<R> where Element == R? { compactMap { $0 } }
}

extension SharedSequenceConvertibleType {
  public func compactMap<R>() -> RxCocoa.SharedSequence<Self.SharingStrategy, R> where Self.Element == R? {
    compactMap { $0 }
  }
}

extension ObservableType {
  public func mapAsVoid() -> Observable<Void> {
    map { _ in Void() }
  }
}

extension SharedSequenceConvertibleType {
  public func mapAsVoid() -> RxCocoa.SharedSequence<Self.SharingStrategy, Void> {
    map { _ in Void() }
  }
}
