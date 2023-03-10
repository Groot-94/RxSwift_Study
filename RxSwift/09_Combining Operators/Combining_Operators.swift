import UIKit
import RxSwift

class ViewController: UIViewController {
    let disposeBag = DisposeBag()
    
    func startWith() {
        // 1
        let numbers = Observable.of(2, 3, 4)
        
        // 2
        let observable = numbers.startWith(1)
        observable.subscribe(onNext: {
            print($0)
        }).disposed(by: disposeBag)
    }
    
    func ObservableConcat() {
        // 1
        let first = Observable.of(1, 2, 3)
        let second = Observable.of(4, 5, 6)
        
        // 2
        let observable = Observable.concat([second, first])
        
        observable.subscribe(onNext: {
            print($0)
        }).disposed(by: disposeBag)
    }
    
    func concat() {
        let germanCities = Observable.of("Berlin", "Münich", "Frankfurt")
        let spanishCities = Observable.of("Madrid", "Barcelona", "Valencia")
        
        let observable = germanCities.concat(spanishCities)
        observable.subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
    }
    
    func concatMap() {
        // 1
        let sequences = ["Germany": Observable.of("Berlin", "Münich", "Frankfurt"),
                         "Spain": Observable.of("Madrid", "Barcelona", "Valencia")]
        
        // 2
        let observable = Observable.of("Germany", "Spain")
            .concatMap({ country in
                sequences[country] ?? .empty() })
        
        // 3
        _ = observable.subscribe(onNext: {
            print($0)
        }).disposed(by: disposeBag)
    }
    
    func merge() {
        // 1
        let left = PublishSubject<String>()
        let right = PublishSubject<String>()
        
        // 2
        let source = Observable.of(left.asObservable(), right.asObservable())
        
        // 3
        let observable = Observable.merge(left, right)
        //        let observable = source.merge(maxConcurrent: 2)
        observable.subscribe(onNext: {
            print($0)
        }).disposed(by: disposeBag)
        
        // 4
        var leftValues = ["Berlin", "Münich", "Frankfurt"]
        var rightValues = ["Madrid", "Barcelona", "Valencia"]
        
        repeat {
            if arc4random_uniform(2) == 0 { //난수 생성 0~2
                if !leftValues.isEmpty {
                    left.onNext("Left : " + leftValues.removeFirst())
                }
            } else if !rightValues.isEmpty {
                right.onNext("Right : " + rightValues.removeFirst())
            }
        } while !leftValues.isEmpty || !rightValues.isEmpty
    }
    
    func combineLast() {
        let left = PublishSubject<String>()
        let right = PublishSubject<String>()
        
        // 1
        let observable = Observable.combineLatest(left, right, resultSelector: { lastLeft, lastRight in
            "\(lastLeft) \(lastRight)"
        })
        
        //        let observable = Observable.combineLatest([left, right]) { strings in
        //                 strings.joined(separator: " ")
        //             }
        
        let disposable = observable.subscribe(onNext: {
            print($0)
        })
        
        // 2
        print("> Sending a value to Left")
        left.onNext("Hello,")
        print("> Sending a value to Right")
        right.onNext("world")
        print("> Sending another value to Right")
        right.onNext("RxSwift")
        print("> Sending another value to Left")
        left.onNext("Have a good day,")
        
        // 3
        disposable.dispose()
    }
    
    func combineLastResultSelector() {
        let choice:Observable<DateFormatter.Style> = Observable.of(.short, .long)
        let dates = Observable.of(Date())
        
        let observable = Observable.combineLatest(choice, dates, resultSelector: { (format, when) -> String in
            let formatter = DateFormatter()
            formatter.dateStyle = format
            
            return formatter.string(from: when)
        })
        
        observable.subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
    }
    
    func zip() {
        // 1
        enum Weather {
            case cloudy
            case sunny
        }
        
        let left:Observable<Weather> = Observable.of(.sunny, .cloudy, .cloudy, .sunny)
        let right = Observable.of("Lisbon", "Copenhagen", "London", "Madrid", "Vienna")
        
        // 2
        let observable = Observable.zip(left, right, resultSelector: { (weather, city) in
            return "It's \(weather) in \(city)"
        })
        
        observable.subscribe(onNext: {
            print($0)
        }).disposed(by: disposeBag)
    }
    
    // MARK: - Triggers
    
    func withLatestFrom() {
        // 1
        let button = PublishSubject<Void>()
        let textField = PublishSubject<String>()
        
        // 2
        let observable = button.withLatestFrom(textField)
        _ = observable.subscribe(onNext: { print($0) })
        
        // 3
        textField.onNext("Par")
        textField.onNext("Pari")
        textField.onNext("Paris")
        button.onNext(())
        button.onNext(())
    }
    
    func sample() {
        // 1
        let button = PublishSubject<Void>()
        let textField = PublishSubject<String>()
        
        // 2
        let observable = textField.sample(button) // withLatestFrom(_:)과 거의 똑같이 작동하지만, 한 번만 방출
        _ = observable
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
        
        // 3
        textField.onNext("Par")
        textField.onNext("Pari")
        textField.onNext("Paris")
        button.onNext(())
        button.onNext(())
    }
    
    // MARK: - Switches
    
    func ambiguous() {
        let left = PublishSubject<String>()
        let right = PublishSubject<String>()
        
        // 1
        let observable = left.amb(right) // 두 개중 어떤 것이든 요소를 모두 방출하는 것을 기다리다가 하나가 방출을 시작하면 나머지에 대해서는 구독을 중단
        let disposable = observable.subscribe(onNext: { value in
            print(value)
        })
        
        // 2
        //        right.onCompleted()
        right.onNext("Copenhagen")
        left.onNext("Lisbon")
        left.onNext("London")
        left.onNext("Madrid")
        right.onNext("Vienna")
        
        disposable.dispose()
    }
    
    func switchLatest() {
        // 1
        let one = PublishSubject<String>()
        let two = PublishSubject<String>()
        let three = PublishSubject<String>()
        
        let source = PublishSubject<Observable<String>>()
        
        // 2
        let observable = source.switchLatest()
        let disposable = observable.subscribe(onNext: { print($0) })
        
        // 3
        source.onNext(one)
        one.onNext("Some text from sequence one")
        two.onNext("Some text from sequence two")
        
        source.onNext(two)
        two.onNext("More text from sequence two")
        one.onNext("and also from sequence one")
        
        source.onNext(three)
        two.onNext("Why don't you see me?")
        one.onNext("I'm alone, help me")
        three.onNext("Hey it's three. I win")
        
        source.onNext(one)
        one.onNext("Nope. It's me, one!")
        
        disposable.dispose()
    }
    
    // MARK: -  sequence내의 요소들간 결합
    
    func reduce() {
        let source = Observable.of(1, 3, 5, 7, 9)
        
        // 1
        let observable = source.reduce(0, accumulator: +)
        observable.subscribe(onNext: { print($0) } )
            .disposed(by: disposeBag)
        
        // 주석 1은 다음과 같은 의미다.
        // 2
        let observable2 = source.reduce(0, accumulator: { summary, newValue in
            return summary + newValue
        })
        observable2.subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
    }
    
    func scan() {
        let source = Observable.of(1, 3, 5, 7, 9)
        let _ = source.scan((0,0), accumulator: { (current, total) in
            return (total, current.1 + total)
        })
            .subscribe(onNext: { tuple in
                print("\(tuple.0) \(tuple.1)")
            }).disposed(by: disposeBag)
    }
    
    // MARK: -  viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // startWith()
        // observableConcat()
        // concat()
        // concatMap()
        // merge()
        // combineLast()
        // combineLastResultSelector()
        // zip()
        // withLatestFrom()
        // sample()
        // ambiguous()
        // switchLatest()
        // reduce()
        // scan()
    }
}
