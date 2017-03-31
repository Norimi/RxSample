//
//  ViewController.swift
//  RxSample
//
//  Created by netNORIMINGCONCEPTION on 2017/03/28.
//  Copyright © 2017年 flatLabel56. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    
    @IBOutlet weak var rxButton: UIButton!
    @IBOutlet weak var confirmBtn: UIButton!
    
    let disposeBag = DisposeBag()
    
    //rx methods
    //BehaviorSubject:今の状態を反映した上で変化があったらそれを反映する
    fileprivate let buttonHiddenSubject = BehaviorSubject(value: false)
    var buttonHiddenObs: Observable<Bool> { return buttonHiddenSubject }
    
    var hiddenEvent: Observable<Void> {
        //rxのfilterはtrueのときのみ結果を返す
        return buttonHiddenObs.filter{ $0 }.map{_ in ()}
    }
    
    fileprivate var eventSubject = PublishSubject<Int>()
    //Observable:外部に公開する用にObservableに変換している例
    //Subjectを公開するとOnNextなどが外部から呼び出せるので
    var event: Observable<Int> { return eventSubject }
    
    fileprivate let targetSubj = PublishSubject<String>()
    var targetName: Observable<String>{ return targetSubj }
    
    //var startButtonEnabled: Observable<Bool> {
        //return confirmBtn.targetname.map {!$0.isEmpty}
    //}
    
    fileprivate var singleEvent = PublishSubject<Bool>()
    var singleEvObs : Observable<Bool> { return singleEvent }
    
    fileprivate var skipEvent = PublishSubject<Bool>()
    var skipEvObs: Observable<Bool>{ return skipEvent }
    
    fileprivate var mergedEvent = PublishSubject<Bool>()
    //var mergedEvObs: Observable<Bool>{ return Observable.of(singleEvObs, skipEvObs) }

    
    var combined1: Observable<Bool> {
        return singleEvent.asObservable()
    }
    
    var combined2: Observable<Bool> {
        return skipEvent.asObservable()
    }
    
//    var result: Observable<Bool> {
//        return Observable.combineLatest(combined1,combined2){some,arg in
//           
//            print("combined")
//        }
//    }
    
    fileprivate var sampleEvent = PublishSubject<Bool>()
    var sampleEvObs: Observable<Bool>{ return sampleEvent }
    
    func doSomething() {
        eventSubject.onNext(1)
    }
    
    func start() {
        buttonHiddenSubject.onNext(true)
        sampleEvent.onNext(false)
    }
    
    func stop() {
        buttonHiddenSubject.onNext(false)
        sampleEvent.onNext(false)
    }
    
    func takeSingleEvent() {
        singleEvent.onNext(true)
    }
    
    func forwardSkipEvent() {
        skipEvent.onNext(false)
    }
    
    func confirmValue() {
        do {
            let buttonHiddenBool = try buttonHiddenSubject.value()
            print(buttonHiddenBool)
            if(buttonHiddenBool == true){
                stop()
            }
        } catch {
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        doSomething()
        subscribeButton()
        subscribeConfirmBtn()
        confirmValue()
        
        
        //Observerが公開しているイベントへの購読を開始する
        _ = singleEvObs
            .filter{$0}
            //イベントを最初の一つに絞る
            .take(1)
            .subscribe(onNext:{ _
                in
                print("single event occured")
            })
        
        _ = skipEvent
        .skip(3)
            .subscribe(onNext: { skipEvent
            in
                print("skipped event")
            })
        
        
        
        //disposeの使用法を練習する
        let disposable0 = hiddenEvent.subscribe(onNext:{_
        in
            print("filterでtrueが透過しました")
        })
        
        let disposable = buttonHiddenObs.subscribe(onNext: {[rxButton]
            in
            //start, stopで定義したonNextの実装内容を記述する
            self.rxButton.isHidden = $0 })
        //disposable.dispose()
        
        let disposable3 = sampleEvObs
            .sample(sampleEvObs.filter{!$0})
            .subscribe(onNext:{ _
            in
                print("sample obs: trueのときのみ通知します")
            })
        
        
    }
    
    fileprivate func subscribeButton() {
        //ViewControllerがButtonのイベントをSubscribeする
        rxButton.rx.tap
            //.sample(rxButton.pressed.filter{!$0})
            .subscribe(onNext:{[weak self] _
                in
                self?.start()
                self?.takeSingleEvent()
                print("tapped")
            })
            .addDisposableTo(disposeBag)
    }
    
    fileprivate func subscribeConfirmBtn() {
        confirmBtn.rx.tap
            //.sample(rxButton.pressed.filter{!$0})
            .subscribe(onNext: {[weak self] _
                in
                self?.confirmValue()
                self?.forwardSkipEvent()
                
            })
        .addDisposableTo(disposeBag)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

