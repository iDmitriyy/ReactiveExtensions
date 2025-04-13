//
//  HotObservableType.swift
//  ReactiveExtensions
//
//  Created by Dmitriy Ignatyev on 13.04.2025.
//

public import RxSwift

public protocol HotObservableType<Element>: ObservableType {}

extension ObservableType {
  public func asHotObservable(replay bufferSize: Int = 1) -> Observable<Element> {
    let bufferSize = bufferSize < 1 ? 1 : bufferSize
    let replay = self.share(replay: bufferSize, scope: .forever)    
    return replay.autoConnect()
  }
  
  public func autoConnect() -> Observable<Element> {
    let source = self.asObservable()
    let subscription = source.subscribe()
    let conntect = Observable<Element>.create { _ in subscription }
    return Observable.merge(source, conntect)
  }
}
