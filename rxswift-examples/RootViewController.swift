//
//  RootViewController.swift
//  rxswift-examples
//
//  Created by Jeytery on 11.11.2022.
//

import UIKit
import Eureka
import RxSwift

class RootViewController: UIViewController {
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "RxSwift Examples"
        navigationController?.navigationBar.prefersLargeTitles = true

        formVC.form +++
            Section(
                header: "Subjects can save and emite events",
                footer: "Subsribers gets only new events and values"
            )
            <<< ButtonRow() {
                $0.title = "PublishSubject"
            }
            .onCellSelection {
                _, _ in
                let publishedSubject = PublishSubject<Int>()
                self.emitEvents(publishedSubject, count: 5)
            }
        
        formVC.form +++
            Section(header: "", footer: "Subsribers gets only new events and values + 1")
            <<< ButtonRow() {
                $0.title = "BehaviourSubject"
            }
            .onCellSelection {
                _, _ in
                let bs = BehaviorSubject<Int>(value: -1)
                self.emitEvents(bs, count: 5)
            }
            addVC(formVC)
        
        let numberRow = IntRow() {
            $0.title = "Enter a count of stored values"
        }
        
        formVC.form +++
            Section(header: "", footer: "Subsribers gets only new events and values + 1")
            <<< numberRow
            <<< ButtonRow() {
                $0.title = "RelaySubject"
            }
            .onCellSelection {
                _, _ in
                let bs = ReplaySubject<Int>.create(bufferSize: numberRow.value ?? 0)
                self.emitEvents(bs, count: 5)
            }

        addColdObservable()
        addConnectObservable()
        addRefcountObservable()
        
        addSharedObservable_WhileConnected()
        addSharedObservable_Forever()
        
        addVC(formVC)
    }
    
    private let bag = DisposeBag()
    private let formVC = FormViewController(style: .insetGrouped)

    private var coldObservable: Observable<String>!
    private var connectedObservable: ConnectableObservable<String>! = nil
    
    private var subscriptions: Array<Disposable> = []
}

private extension RootViewController {
    func addColdObservable() {
        formVC.form +++
            Section(header: "Observable", footer: "")
            <<< ButtonRow() {
                $0.title = "Create Cold Observable"
            }
            .onCellSelection {
                _, _ in
                print("\nCreate cold observable\n\n")
                self.coldObservable = Observable<String>.create {
                    observer in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        print("[emited 1] cold obs emitted first element")
                        observer.onNext("cold obs first element")
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
                        print("[emited 2] cold obs emitted second element")
                        observer.onNext("cold obs second element")
                    }
                    return Disposables.create()
                }
            }
            <<< ButtonRow() {
                $0.title = "Subcribe"
            }
            .onCellSelection {
                _, _ in
                self.coldObservable.subscribe(
                    onNext: {
                        print($0 + "\n")
                    }
                )
                .disposed(by: self.bag)
            }
            <<< LabelRow() {
                $0.title = "Cold observer emite elements only after subription on it. Each time it recieves an subription it will emite events again"
                $0.cell.textLabel?.numberOfLines = 0
            }
            <<< LabelRow() {
                $0.title = "Cold observable is all standard and created by method create()"
                $0.cell.textLabel?.numberOfLines = 0
            }
    }
    
    func addConnectObservable() {
        let observerRow = LabelRow() {
            $0.title = "Observer doesn't created"
            $0.cell.textLabel?.numberOfLines = 0
        }
        .cellUpdate { cell, _ in
            cell.textLabel?.textColor = .red
        }
        
        formVC.form +++
            Section(header: "", footer: "")
            <<< observerRow
            <<< LabelRow() {
                $0.title = "You can make it hot by adding one of this methods to it"
                $0.cell.textLabel?.numberOfLines = 0
            }
            <<< ButtonRow() { $0.title = "publish()" }
            .onCellSelection {
                _, _ in
                observerRow.cell.textLabel?.text = "publish connectable observable"
                observerRow.cell.textLabel?.textColor = .systemGreen
                
                self.connectedObservable = Observable<String>.create {
                    observer in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        print("cold obs emitted first element")
                        observer.onNext("cold obs first element")
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
                        print("cold obs emitted second element")
                        observer.onNext("cold obs second element")
                    }
                    return Disposables.create()
                }
                .publish()
            }
            <<< ButtonRow() { $0.title = "relay(bufferSize: Int)" }
            .onCellSelection {
                _, _ in
                observerRow.cell.textLabel?.text = "relay connectable observable"
                observerRow.cell.textLabel?.textColor = .systemGreen
                
                self.connectedObservable = Observable<String>.create {
                    observer in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        print("relay() obs emitted first element")
                        observer.onNext("replay() obs first element")
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
                        print("relay() obs emitted second element")
                        observer.onNext("replay() obs second element")
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 9) {
                        print("relay() obs emitted second element")
                        observer.onNext("replay() obs second element")
                    }
                    return Disposables.create()
                }
                .replay(2)
            }
            <<< ButtonRow() { $0.title = "relayAll()"}
            .onCellSelection {
                _, _ in
                observerRow.cell.textLabel?.text = "relayAll connectable observable"
                observerRow.cell.textLabel?.textColor = .systemGreen
                
                self.connectedObservable = Observable<String>.create {
                    observer in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        print("replayAll() obs emitted first element")
                        observer.onNext("relay() obs first element")
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
                        print("replayAll() obs emitted second element")
                        observer.onNext("relay() obs second element")
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 9) {
                        print("replayAll() obs emitted second element")
                        observer.onNext("replayAll() obs second element")
                    }
                    return Disposables.create()
                }
                .replayAll()
            }
            <<< LabelRow() {
                $0.title = "Hot observers is all Subjects, Connectable Observable"
                $0.cell.textLabel?.numberOfLines = 0
            }
            <<< ButtonRow() { $0.title = "connect()" }
            .onCellSelection {
                _, _ in
                let _ = self.connectedObservable.connect()
                observerRow
                    .cell
                    .textLabel?
                    .text = "connected " + (observerRow.cell.textLabel?.text ?? "")
                observerRow
                    .cell
                    .textLabel?
                    .numberOfLines = 0
            }
            <<< ButtonRow() { $0.title = "subscribe" }
            .onCellSelection {
                _, _ in
                self.connectedObservable.subscribe(
                    onNext: {
                        value in
                        print("\(value)")
                    }
                )
                .disposed(by: self.bag)
            }
    }
    
    func addRefcountObservable() {
        formVC.form +++ Section(header: "refCount()", footer: nil)
        <<< ButtonRow() {
            $0.title = "refCount() observable"
        }
        .onCellSelection {
            _, _ in
            self.coldObservable = Observable<String>.create {
                observer in
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    print("refCount() obs emitted first element")
                    observer.onNext("relay() obs first element")
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
                    print("refCount() obs emitted second element")
                    observer.onNext("refCount() obs second element")
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 9) {
                    print("refCount() obs emitted second element")
                    observer.onNext("refCount() obs second element")
                }
                return Disposables.create()
            }
            .publish()
            .refCount()
        }
        <<< ButtonRow() {
            $0.title = "subscribe"
        }
        .onCellSelection {
            _, _ in
            let sub = self.coldObservable.subscribe(onNext: { value in
                print(value)
            })
            self.subscriptions.append(sub)
            sub.disposed(by: self.bag)
        }
        <<< ButtonRow() {
            $0.title = "unsubscribe ALL"
        }
        .onCellSelection {
            _, _ in
            self.subscriptions.forEach { $0.dispose() }
        }
    }
        
    func addSharedObservable_WhileConnected() {
        formVC.form +++ Section(header: "shared()", footer: nil)
        <<< ButtonRow() {
            $0.title = "shared(replay: 5, scope: .whileConnected) hot observable"
        }
        .onCellSelection {
            _, _ in
            self.coldObservable = Observable<String>.create {
                observer in
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    print("shared whileConnected obs emitted first element")
                    observer.onNext("shared whileConnected obs 1 element")
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
                    print("shared whileConnected obs emitted second element")
                    observer.onNext("shared whileConnected obs 2 element")
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 9) {
                    print("shared whileConnected obs emitted second element")
                    observer.onNext("shared whileConnected obs 3 element")
                }
                return Disposables.create()
            }
            .share(replay: 5, scope: .whileConnected)
        }
        <<< ButtonRow() {
            $0.title = "subscribe"
        }
        .onCellSelection {
            _, _ in
            let sub = self.coldObservable.subscribe(onNext: { value in
                print(value)
            })
            self.subscriptions.append(sub)
            sub.disposed(by: self.bag)
        }
        <<< ButtonRow() {
            $0.title = "unsubscribe ALL"
        }
        .onCellSelection {
            _, _ in
            self.subscriptions.forEach { $0.dispose() }
            self.subscriptions.removeAll()
        }
    }
     
    func addSharedObservable_Forever() {
        formVC.form +++ Section(header: "shared()", footer: nil)
        <<< ButtonRow() {
            $0.title = "shared(replay: 5, scope: .forever) hot observable"
        }
        .onCellSelection {
            _, _ in
            self.coldObservable = Observable<String>.create {
                observer in
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    print("shared forever obs emitted first element")
                    observer.onNext("shared forever obs 1 element")
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
                    print("shared forever obs emitted second element")
                    observer.onNext("shared forever obs 2 element")
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 9) {
                    print("shared forever obs emitted second element")
                    observer.onNext("shared forever obs 3 element")
                }
                return Disposables.create()
            }
            .share(replay: 5, scope: .forever)
        }
        <<< ButtonRow() {
            $0.title = "subscribe"
        }
        .onCellSelection {
            _, _ in
            let sub = self.coldObservable.subscribe(onNext: { value in
                print(value)
            })
            self.subscriptions.append(sub)
            sub.disposed(by: self.bag)
        }
        <<< ButtonRow() {
            $0.title = "unsubscribe ALL"
        }
        .onCellSelection {
            _, _ in
            self.subscriptions.forEach { $0.dispose() }
            self.subscriptions.removeAll()
        }
    }
}

private extension RootViewController {
    func emitEvents<T>(_ subject: T, count: Int) where T: SubjectType, T.Observer.Element == Int {
        var result: [String] = []
        print("\n\n-------- \(subject.self) -----------")
        for i in 0 ... 5 {
            result.append("--")
            subject.subscribe(
                onNext: {
                    value in
                    result[i] += " \(value) --"
                },
                onCompleted: {
                    let full = "sub\(i): \(result[i])> \n"
                    print(full)
                }
            )
            .disposed(by: self.bag)
            subject.asObserver().onNext(i)
        }
        subject.asObserver().onCompleted()
    }
    
    func addVC(_ vc: UIViewController) {
        addChild(vc)
        view.addSubview(vc.view)
        vc.view.frame = self.view.frame
        vc.didMove(toParent: self)
    }
}

