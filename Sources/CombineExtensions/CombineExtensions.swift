//
//  CombineExtensions.swift
//  ReactiveExtensions
//
//  Created by Dmitriy Ignatyev on 13.04.2025.
//

import Combine

func foo(bar: AnyPublisher<Int, Never>) {
  bar.makeConnectable().autoconnect()
}
