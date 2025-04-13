//
//  RxExtensions.swift
//  ReactiveExtensions
//
//  Created by Dmitriy Ignatyev on 13.04.2025.
//

public import RxCocoa
public import RxSwift

extension ObservableType {
  public func asSignalIgnoringError() -> Signal<Element> {
    let signal = map { element -> Element? in element }.asSignal(onErrorJustReturn: nil).compactMap()
    return signal
  }
  
  public func asDriverIgnoringError() -> Driver<Element> {
    let signal = map { element -> Element? in element }.asDriver(onErrorJustReturn: nil).compactMap()
    return signal
  }
  
  public func asInfallibleIgnoringError() -> Infallible<Element> {
    asInfallible { error in
      // TODO: - log error
//      logError(ConditionalError(code: .unexpectedCodeEntrance,
//                                underlyingError: AnyBaseError(error: error)))
      return Infallible<Element>.never()
    }
  }
}

extension ControlEvent<String?> {
  public func orEmpty() -> ControlEvent<String> {
    let event = map { maybeText in maybeText ?? "" }
    return ControlEvent<String>(events: event)
  }
}

extension PublishRelay {
  public func asControlEvent() -> ControlEvent<Element> {
    ControlEvent(events: self)
  }
}


extension ObservableType {
  public func waitingWithLatestFrom<S>(_ second: S) -> Observable<(Element, S.Element)> where S: ObservableType {
    let sourceObservable = self
    let secondEvent = second.enumerated()
    
    let result = Observable.combineLatest(sourceObservable, secondEvent)
      .previousAndCurrent()
      .compactMap { previous, current -> (Element, S.Element)? in
        let (_, (previousEventElementIndex, _)) = previous
        let (sourceElement, (eventElementIndex, eventElement)) = current
        
        guard eventElementIndex == previousEventElementIndex || eventElementIndex == 0 else { return nil }
        
        return (sourceElement, eventElement)
      }
    
    return result
  }
}

extension SharedSequenceConvertibleType {
  public func replayLast<Event, R>(waitingFor event: Event) -> RxCocoa.SharedSequence<Self.SharingStrategy, Element>
    where Event: SharedSequenceConvertibleType, Event.Element == R {
    asObservable().replayLast(waitingFor: event.asObservable())._asSharedSequenceIgnoringError()
  }
  
  public func replayLast<Event, R>(waitingFor event: Event) -> RxCocoa.SharedSequence<Self.SharingStrategy, Element>
    where Event: ObservableType, Event.Element == R {
    asObservable().replayLast(waitingFor: event)._asSharedSequenceIgnoringError()
  }
  
  public func enumerated() -> RxCocoa.SharedSequence<Self.SharingStrategy, (index: Int, element: Self.Element)> {
    asObservable().enumerated()._asSharedSequenceIgnoringError()
  }
}

extension ObservableType {
  public func _asSharedSequenceIgnoringError<SharingStrategy>() -> RxCocoa.SharedSequence<SharingStrategy, Element> {
    let signal = map { element -> Element? in element }
      .asSharedSequence(sharingStrategy: SharingStrategy.self, onErrorJustReturn: nil)
      .compactMap()
    return signal
  }
}

extension SharedSequenceConvertibleType where Self.SharingStrategy == DriverSharingStrategy {
  public func drive<Observer>(_ observer1: Observer, _ observer2: Observer)
    -> any Disposable where Observer: ObserverType, Self.Element == Observer.Element {
    CompositeDisposable(drive(observer1), drive(observer2))
  }
}

extension ObservableType {
  public func asHidableViewSignal<R>() -> Signal<R?> where Element == R? {
    filterConsecutiveNilValues().asSignalIgnoringError()
  }
  
  public func asHideableViewSignal<R>() -> Signal<R?> where Element == R?, R: Equatable {
    distinctUntilChanged().asSignalIgnoringError()
  }
  
  public func scan<A>(mapFirstToAccumulator: @escaping (Element) -> A,
                      accumulator accumulatorClosure: @escaping (A, Element) throws -> A) -> Observable<A> {
    let nilSeed: A? = nil
    
    let resultObservable = scan(nilSeed) { maybeAccumulator, element -> A? in
      guard let accumulator = maybeAccumulator else {
        return mapFirstToAccumulator(element)
      }
      
      return try accumulatorClosure(accumulator, element)
    }
    .compactMap()
    
    return resultObservable
  }
  
  public func scan<A>(mapFirstToAccumulator: @escaping (Element) -> A,
                      mutableAccumulator accumulatorClosure: @escaping (inout A, Element) -> Void) -> Observable<A> {
    let nilSeed: A? = nil
    
    let resultObservable = scan(into: nilSeed, accumulator: { mutableAccumulator, element in
      guard var tempAccumulator = mutableAccumulator else {
        mutableAccumulator = mapFirstToAccumulator(element)
        return
      }
      
      accumulatorClosure(&tempAccumulator, element)
      mutableAccumulator = tempAccumulator
    })
    .compactMap()
    
    return resultObservable
  }
  
  public func scan<A>(flatMapFirstToAccumulator: @escaping (Element) -> A?,
                      accumulator accumulatorClosure: @escaping (A, Element) throws -> A) -> Observable<A> {
    let nilSeed: A? = nil
    
    let resultObservable = scan(nilSeed) { maybeAccumulator, element -> A? in
      guard let accumulator = maybeAccumulator else {
        return flatMapFirstToAccumulator(element)
      }
      
      return try accumulatorClosure(accumulator, element)
    }
    .compactMap()
    
    return resultObservable
  }
  
  public func scan<A>(flatMapFirstToAccumulator: @escaping (Element) -> A?,
                      mutableAccumulator accumulatorClosure: @escaping (inout A, Element) -> Void) -> Observable<A> {
    let nilSeed: A? = nil
    
    let resultObservable = scan(into: nilSeed, accumulator: { mutableAccumulator, element in
      guard var tempAccumulator = mutableAccumulator else {
        mutableAccumulator = flatMapFirstToAccumulator(element)
        return
      }
      
      accumulatorClosure(&tempAccumulator, element)
      mutableAccumulator = tempAccumulator
    })
    .compactMap()
    
    return resultObservable
  }
  
  public func scan<A>(replayingInitial seed: A, accumulator: @escaping (inout A, Element) throws -> Void) -> Observable<A> {
    scan(into: seed, accumulator: accumulator)
      .startWith(seed)
      .share(replay: 1, scope: .forever)
  }
}

extension ObservableType {
  public func ignoreWhen(_ predicate: @escaping (Element) throws -> Bool) -> Observable<Element> {
    filter { try !predicate($0) }
  }
  
  public func split(_ predicate: @escaping (Element) throws -> Bool)
    -> (matches: Observable<Element>, nonMatches: Observable<Element>) {
    let stream = map { try ($0, predicate($0)) }.share()
    
    let hits = stream.filter { $0.1 }.map { $0.0 }
    let misses = stream.filter { !$0.1 }.map { $0.0 }
    
    return (hits, misses)
  }
  
  public func partitionMap<U1, U2>(_ predicate: @escaping (Element) throws -> Either<U1, U2>)
    -> (matches: Observable<U1>, nonMatches: Observable<U2>) {
    let stream = map(predicate).share()
    
    let hits = stream.compactMap { variant -> U1? in
      switch variant {
      case .left(let values): values
      case .right: nil
      }
    }
    
    let misses = stream.compactMap { variant -> U2? in
      switch variant {
      case .left: nil
      case .right(let element): element
      }
    }
    
    return (hits, misses)
  }
  
  public func splitMap<A, B, C>(_ predicate: @escaping (Element) throws -> OneOf3<A, B, C>)
    -> (Observable<A>, Observable<B>, Observable<C>) {
    let stream = map(predicate).share()
    
    let first = stream.compactMap { variant -> A? in
      switch variant {
      case .first(let element): element
      case .second, .third: nil
      }
    }
    
    let second = stream.compactMap { variant -> B? in
      switch variant {
      case .second(let element): element
      case .first, .third: nil
      }
    }
      
    let third = stream.compactMap { variant -> C? in
      switch variant {
      case .third(let element): element
      case .first, .second: nil
      }
    }
    
    return (first, second, third)
  }
  
  public func splitMap<A, B, C, D>(_ predicate: @escaping (Element) throws -> OneOf4<A, B, C, D>)
    -> (Observable<A>, Observable<B>, Observable<C>, Observable<D>) {
    let stream = map(predicate).share()
    
    let first = stream.compactMap { variant -> A? in
      switch variant {
      case .first(let element): element
      case .second, .third, .fourth: nil
      }
    }
    
    let second = stream.compactMap { variant -> B? in
      switch variant {
      case .second(let element): element
      case .first, .third, .fourth: nil
      }
    }
      
    let third = stream.compactMap { variant -> C? in
      switch variant {
      case .third(let element): element
      case .first, .second, .fourth: nil
      }
    }
      
    let fourth = stream.compactMap { variant -> D? in
      switch variant {
      case .fourth(let element): element
      case .first, .second, .third: nil
      }
    }
    
    return (first, second, third, fourth)
  }
}

extension ObservableType {
  public func withLatestFrom<S2, S3, ResultType>(_ second: S2,
                                                 _ third: S3,
                                                 resultSelector: @escaping (Element, S2.Element, S3.Element) throws -> ResultType)
    -> Observable<ResultType> where S2: ObservableConvertibleType, S3: ObservableConvertibleType {
    withLatestFrom(second, resultSelector: { ($0, $1) })
      .withLatestFrom(third, resultSelector: { ($0, $1) })
      .map { args -> ResultType in
        let ((a, b), c) = args
        return try resultSelector(a, b, c)
      }
  }
  
  public func withLatestFrom<S2, S3, S4, ResultType>(_ second: S2,
                                                     _ third: S3,
                                                     _ fourth: S4,
                                                     resultSelector: @escaping (Element,
                                                                                S2.Element,
                                                                                S3.Element,
                                                                                S4.Element) throws -> ResultType)
    -> Observable<ResultType> where S2: ObservableConvertibleType, S3: ObservableConvertibleType, S4: ObservableConvertibleType {
    withLatestFrom(second, resultSelector: { ($0, $1) })
      .withLatestFrom(third, fourth, resultSelector: { ($0, $1, $2) })
      .map { args -> ResultType in
        let ((a, b), c, d) = args
        return try resultSelector(a, b, c, d)
      }
  }
}

extension SharedSequence {
  public func withLatestFrom<S2, S3, ResultType>(_ second: S2,
                                                 _ third: S3,
                                                 resultSelector: @escaping (Element, S2.Element, S3.Element) -> ResultType)
    -> SharedSequence<SharingStrategy, ResultType>
    where S2: SharedSequenceConvertibleType, S3: SharedSequenceConvertibleType,
    Self.SharingStrategy == S2.SharingStrategy,
    S2.SharingStrategy == S3.SharingStrategy {
    withLatestFrom(second, resultSelector: { ($0, $1) })
      .withLatestFrom(third, resultSelector: { ($0, $1) })
      .map { args -> ResultType in
        let (a, b, c) = denestify(tuple: args)
        return resultSelector(a, b, c)
      }
  }
}

extension SharedSequence {
  public func split(_ predicate: @escaping (Element) -> Bool)
    -> (matches: SharedSequence<SharingStrategy, Element>, nonMatches: SharedSequence<SharingStrategy, Element>) {
    let stream = map { ($0, predicate($0)) }
    
    let hits = stream.filter { $0.1 }.map { $0.0 }
    let misses = stream.filter { !$0.1 }.map { $0.0 }
    
    return (hits, misses)
  }
}

public import Combine

extension Result {
  public func pass(successTo successSubject: some Combine.Subject<Success, Never>,
                   failureTo errorSubject: some Combine.Subject<Failure, Never>) {
    switch self {
    case .success(let element): successSubject.send(element)
    case .failure(let error): errorSubject.send(error)
    }
  }
  
  public func pass(successTo successSubject: PublishRelay<Success>,
                   failureTo errorSubject: PublishRelay<Failure>) {
    switch self {
    case .success(let element): successSubject.accept(element)
    case .failure(let error): errorSubject.accept(error)
    }
  }
  
  public func pass(successTo successSubject: BehaviorRelay<Success>,
                   failureTo errorSubject: BehaviorRelay<Failure>) {
    switch self {
    case .success(let element): successSubject.accept(element)
    case .failure(let error): errorSubject.accept(error)
    }
  }
  
  public func pass<SSubj, ESubj>(successTo successSubject: SSubj,
                                 failureTo errorSubject: ESubj)
    where SSubj: RxSwift.ObserverType, ESubj: RxSwift.ObserverType, SSubj.Element == Success, ESubj.Element == Failure {
    switch self {
    case .success(let element): successSubject.on(.next(element))
    case .failure(let error): errorSubject.on(.next(error))
    }
  }
}
