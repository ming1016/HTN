//
//  HTNStateMachine.swift
//  HTNSwift
//
//  Created by DaiMing on 2017/10/12.
//  Copyright © 2017年 Starming. All rights reserved.
//  Description 状态机

import Foundation

protocol HTNStateType: Hashable {}
protocol HTNEventType: Hashable {}

struct HTNTransition<S: HTNStateType, E: HTNEventType> {
    let event: E
    let fromState: S
    let toState: S
    
    init(event: E, fromState: S, toState: S) {
        self.event = event
        self.fromState = fromState
        self.toState = toState
    }
}

class HTNStateMachine<S: HTNStateType, E: HTNEventType> {
    //需要处理事件的结构
    private struct Operation<S: HTNStateType, E: HTNEventType> {
        let transition: HTNTransition<S, E>
        let triggerCallback: (HTNTransition<S, E>) -> Void
    }
    private var routes = [S: [E: Operation<S, E>]]() //字典结构做记录
    private(set) var currentState: S
    private(set) var lastState: S?
    
    init(_ currentState: S) {
        self.currentState = currentState
    }
    
    //一组状态监听
    func listen(_ event: E, transit fromStates:[S], to toState: S, callback: @escaping (HTNTransition<S, E>) -> Void) {
        for fromState in fromStates {
            listen(event, transit: fromState, to: toState, callback: callback)
        }
    }
    //当前状态是什么保持状态不变
    func listen(_ event: E, callback: @escaping (HTNTransition<S, E>) -> Void) {
        listen(event, transit: currentState, to: currentState, callback: callback)
    }
    //fromStates 是集合，当前集合里的具体是哪个 to 就是那个
    func listen(_ event: E, tansitHasSameFromAndToStates fromStates:[S], callback: @escaping (HTNTransition<S, E>) -> Void) {
        for fromState in fromStates {
            listen(event, transit: fromState, to: fromState, callback: callback)
        }
    }
    //单个监听
    func listen(_ event: E, transit fromState: S, to toState: S, callback: @escaping (HTNTransition<S, E>) -> Void) {
        var route = routes[fromState] ?? [:]
        let transition = HTNTransition(event: event, fromState: fromState, toState: toState)
        let operation = Operation(transition: transition, triggerCallback: callback)
        route[event] = operation
        routes[fromState] = route
    }
    
    func trigger(_ event: E) -> Bool {
        guard let operation = routes[currentState]?[event] else {
            return false
        }
        lastState = currentState
        currentState = operation.transition.toState
        operation.triggerCallback(operation.transition)
        return true
    }
    //适应相同动作在相同的当前状态下转成不同的toState
    func changeCurrentState(_ state: S) {
        currentState = state
    }
}
