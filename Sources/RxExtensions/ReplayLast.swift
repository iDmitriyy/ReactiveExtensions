//
//  ReplayLast.swift
//  ReactiveExtensions
//
//  Created by Dmitriy Ignatyev on 13.04.2025.
//

extension ObservableType {
  public func replayLast(waitingFor event: some ObservableType) -> Observable<Element> {
    let sourceObservable = self
    let shutter = event.take(prefix: 1) // после того как от signal поступит 1-й элемент – можно пропускать элементы из SO
    
    let combined = Observable.combineLatest(sourceObservable, shutter)
    let resultObservable = combined.map { element, _ in element }
    return resultObservable
  }
  
  public func replayLastPending<G>(whenGateOpened gateSignal: G) -> Observable<Element> where G: ObservableType,
    G.Element == Bool {
    let sourceObservable = self
    let gate = gateSignal.distinctUntilChanged()
    
    let resultSource: Observable<(Self.Element?, Bool)> = Observable
      .combineLatest(sourceObservable, gate)
      .scan(mapFirstToAccumulator: { firstElement -> (Element?, Bool) in
        firstElement
      }, accumulator: { previous, current -> (Element?, Bool) in
        let (accumulatedElement, previousGateOpened) = previous
        let (latestElement, isGateOpened) = current
        
        return switch (previousGateOpened, isGateOpened) {
        case (false, false): (latestElement, isGateOpened)
        case (true, true): (latestElement, isGateOpened)
        case (false, true): (accumulatedElement, isGateOpened) // открытие
        case (true, false): (nil, isGateOpened) // закрытие затвора. В качестве элемента ставим nil, чтобы при
        }
      })
    
    let resultObservable = resultSource.compactMap { maybeElement, isGateOpened -> Element? in
      guard isGateOpened else { return nil }
      return maybeElement
    }
    
    return resultObservable
  }
}
