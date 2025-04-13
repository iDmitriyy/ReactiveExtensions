//
//  _.swift
//  ReactiveExtensions
//
//  Created by Dmitriy Ignatyev on 13.04.2025.
//

public enum Either<L: ~Copyable, R: ~Copyable>: ~Copyable {
  case left(L)
  case right(R)
}

extension Either: Copyable where L: Copyable, R: Copyable {}

extension Either {
  public var leftValue: L? {
    switch self {
    case .left(let leftValue): leftValue
    case .right: nil
    }
  }

  public var rightValue: R? {
    switch self {
    case .right(let rightValue): rightValue
    case .left: nil
    }
  }
}

extension Either where L == R {
  /// Когда L == R, можно получить неопциональный underlying value
  public var wrappedValue: L {
    switch self {
    case .left(let value): value
    case .right(let value): value
    }
  }
}

extension Either {
  public func mapLeft<NewLeft>(_ transform: (L) -> NewLeft) -> Either<NewLeft, R> {
    switch self {
    case .left(let value): .left(transform(value))
    case .right(let value): .right(value)
    }
  }
  
  public func mapRight<NewRight>(_ transform: (R) -> NewRight) -> Either<L, NewRight> {
    switch self {
    case .left(let value): .left(value)
    case .right(let value): .right(transform(value))
    }
  }
  
  public func swap() -> Either<R, L> {
    switch self {
    case .left(let value): .right(value)
    case .right(let value): .left(value)
    }
  }
}

extension Either {
  public var isLeft: Bool {
    guard case .left = self else { return false }; return true
  }
  
  public var isRight: Bool { !isLeft }
}

extension Either where R: Error {
  public func asResult() -> Result<L, R> {
    switch self {
    case .left(let leftValue): .success(leftValue)
    case .right(let rightValue): .failure(rightValue)
    }
  }
}

extension Either where L: Error {
  public func asResult() -> Result<R, L> {
    switch self {
    case .left(let leftValue): .failure(leftValue)
    case .right(let rightValue): .success(rightValue)
    }
  }
}

public enum OneOf2<A: ~Copyable, B: ~Copyable, C: ~Copyable>: ~Copyable {
  case first(A)
  case second(B)
}

extension OneOf2: Copyable where A: Copyable, B: Copyable {}

extension OneOf2: Equatable where A: Equatable, B: Equatable {}

extension OneOf2: Hashable where A: Hashable, B: Hashable {}

extension OneOf2: Comparable where A: Comparable, B: Comparable {}

extension OneOf2: Sendable where A: Sendable, B: Sendable {}

public enum OneOf3<A, B, C> {
  case first(A)
  case second(B)
  case third(C)
}

extension OneOf3: Equatable where A: Equatable, B: Equatable, C: Equatable {}

extension OneOf3: Hashable where A: Hashable, B: Hashable, C: Hashable {}

extension OneOf3: Sendable where A: Sendable, B: Sendable, C: Sendable {}

public enum OneOf4<A, B, C, D> {
  case first(A)
  case second(B)
  case third(C)
  case fourth(D)
}

extension OneOf4: Equatable where A: Equatable, B: Equatable, C: Equatable, D: Equatable {}

extension OneOf4: Hashable where A: Hashable, B: Hashable, C: Hashable, D: Hashable {}

extension OneOf4: Sendable where A: Sendable, B: Sendable, C: Sendable, D: Sendable {}
