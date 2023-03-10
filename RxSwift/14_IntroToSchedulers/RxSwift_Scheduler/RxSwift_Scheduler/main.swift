/*
 * Copyright (c) 2014-2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import Foundation
import RxSwift

print("\n\n\n===== Schedulers =====\n")

let globalScheduler = ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global())
let bag = DisposeBag()
let animal = BehaviorSubject(value: "[dog]")

animal
    .dump()
    .dumpingSubscription()
    .disposed(by: bag)

let fruit = Observable<String>.create { observer in
    observer.onNext("[apple]")
    sleep(2)
    observer.onNext("[pineapple]")
    sleep(2)
    observer.onNext("[strawberry]")
    return Disposables.create()
}

// A. 프로젝트 확인
//fruit
//  .dump()
//  .dumpingSubscription()
//  .disposed(by: bag)


// B. subscribeOn
//fruit
//    .subscribe(on: globalScheduler)
//    .dump()
////    .observe(on: MainScheduler.instance) // C. observeOn
//    .dumpingSubscription()
//    .disposed(by: bag)
//

// D. 스케줄러와 스레드 전환의 함정
//let animalsThread = Thread() {
//    sleep(3)
//    animal.onNext("[cat]")
//    sleep(3)
//    animal.onNext("[tiger]")
//    sleep(3)
//    animal.onNext("[fox]")
//    sleep(3)
//    animal.onNext("[leopard]")
//}
//
//animalsThread.name = "Animals Thread"
//animalsThread.start()
//
//
//animal
////    .subscribe(on: MainScheduler.instance) // E
//    .dump()
//    .observe(on: globalScheduler)
//    .dumpingSubscription()
//    .disposed(by:bag)
//
//fruit
//    .subscribe(on: globalScheduler)
//    .dump()
//    .observe(on: MainScheduler.instance)
//    .dumpingSubscription()
//    .disposed(by:bag)


RunLoop.main.run(until: Date(timeIntervalSinceNow: 13))
