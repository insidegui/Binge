//
//  Binder.swift
//  BingeUI
//
//  Created by Guilherme Rambo on 20/06/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Foundation
import TMDBCore
import RxSwift

public enum BinderState<T> {
    case Loading
    case Loaded(entity: T)
    case LoadedMore(entity: T)
    case Error(error: ErrorType)
}

public class Binder<ViewModelType> {
    
    public var state = Variable<BinderState<ViewModelType>>(.Loading)
    
    public var supportsPagination: Bool {
        return false
    }
    
    public func load() {
        fatalError("Binder is an abstract superclass, subclasses must override load()")
    }
    public func loadMore() {
        fatalError("Binder is an abstract superclass, subclasses must override loadMore()")
    }
    
}