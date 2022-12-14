# <center>![SugarRecord](Assets/Caramba.png)</center>

[![Twitter: @carambalabs](https://img.shields.io/badge/contact-@carambalabs-blue.svg?style=flat)](https://twitter.com/carambalabs)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/SugarRecord.svg)](https://img.shields.io/cocoapods/v/SugarRecord.svg)
[![Language: Swift](https://img.shields.io/badge/lang-Swift-yellow.svg?style=flat)](https://developer.apple.com/swift/)
[![Language: Swift](https://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat)](http://opensource.org/licenses/MIT)
[![Build Status](https://travis-ci.org/carambalabs/SugarRecord.svg)](https://travis-ci.org/carambalabs/SugarRecord)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

## What is SugarRecord?
SugarRecord is a persistence wrapper designed to make working with persistence solutions like CoreData in a much easier way. Thanks to SugarRecord you'll be able to use CoreData with just a few lines of code: Just choose your stack and start playing with your data.

The library is maintained by [@carambalabs](https://github.com/carambalabs). You can reach me at [pepibumur@gmail.com](mailto://pepibumur@gmail.com) for help or whatever you need to commend about the library.

[![paypal](https://www.paypal.com/en_US/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=2AUKNEW4JLPXQ)


## Features
- Swift 3.0 compatible (Xcode 8.0).
- Protocols based design.
- For **beginners** and **advanced** users
- Fully customizable. Build your own stack!
- Friendly syntax (fluent)
- Away from Singleton patterns! No shared states :tada:
- Compatible with OSX/iOS/watchOS/tvOS
- Fully tested (thanks Nimble and Quick)
- Actively supported

## Setup

### [CocoaPods](https://cocoapods.org)

1. Install [CocoaPods](https://cocoapods.org). You can do it with `gem install cocoapods`
2. Edit your `Podfile` file and add the following line `pod 'SugarRecord'`
3. Update your pods with the command `pod install`
4. Open the project from the generated workspace (`.xcworkspace` file).

*Note: You can also test the last commits by specifying it directly in the Podfile line*

**Available specs**
Choose the right one depending ton the configuration you need for you app.

```ruby
pod "SugarRecord/CoreData"
pod "SugarRecord/CoreData+iCloud"
```

### [Carthage](https://github.com/carthage)

1. Install [Carthage](https://github.com/carthage). You can do it with `brew install carthage`.
2. Edit your `Cartfile` file and add the following line `github "carambalabs/sugarrecord".
3. Execute `carthage update`
4. Add the frameworks to your project as explained on the [Carthage repository](https://github.com/carthage).

## Reference
You can check generated SugarRecord documentation [here](http://cocoadocs.org/docsets/SugarRecord/2.0.0/) generated automatically with [CocoaDocs](http://cocoadocs.org/)

# How to use

#### Creating your Storage
A storage represents your database. The first step to start using SugarRecord is initializing the storage. SugarRecord provides a default storages, `CoreDataDefaultStorage`.

```swift
// Initializing CoreDataDefaultStorage
func coreDataStorage() -> CoreDataDefaultStorage {
    let store = CoreDataStore.named("db")
    let bundle = Bundle(for: self.classForCoder)
    let model = CoreDataObjectModel.merged([bundle])
    let defaultStorage = try! CoreDataDefaultStorage(store: store, model: model)
    return defaultStorage
}
```

##### Creating an iCloud Storage

SugarRecord supports the integration of CoreData with iCloud. It's very easy to setup since it's implemented in its own storage that you can use from your app, `CoreDataiCloudStorage`:

```swift
// Initializes the CoreDataiCloudStorage
func icloudStorage() -> CoreDataiCloudStorage {
    let bundle = Bundle(for: self.classForCoder)
    let model = CoreDataObjectModel.merged([bundle])
    let icloudConfig = CoreDataiCloudConfig(ubiquitousContentName: "MyDb", ubiquitousContentURL: "Path/", ubiquitousContainerIdentifier: "com.company.MyApp.anothercontainer")
    let icloudStorage = try! CoreDataiCloudStorage(model: model, iCloud: icloudConfig)
    return icloudStorage
}
```

#### Contexts
Storages offer multiple kind of contexts that are the entry points to the database. For curious developers, in case of CoreData a context is a wrapper around `NSManagedObjectContext`. The available contexts are:

- **MainContext:** Use it for main thread operations, for example fetches whose data will be presented in the UI.
- **SaveContext:** Use this context for background operations. The context is initialized when the storage instance is created. That context is used for storage operations.
- **MemoryContext:** Use this context when you want to do some tests and you don't want your changes to be persisted.

#### Fetching data

```swift
let pedros: [Person] = try! db.fetch(FetchRequest<Person>().filtered(with: "name", equalTo: "Pedro"))
let tasks: [Task] = try! db.fetch(FetchRequest<Task>())
let citiesByName: [City] = try! db.fetch(FetchRequest<City>().sorted(with: "name", ascending: true))
let predicate: NSPredicate = NSPredicate(format: "id == %@", "AAAA")
let john: User? = try! db.fetch(FetchRequest<User>().filtered(with: predicate)).first
```

#### Remove/Insert/Update operations

Although `Context`s offer `insertion` and `deletion` methods that you can use it directly SugarRecords aims at using the `operation` method method provided by the storage for operations that imply modifications of the database models:

- **Context**: You can use it for fetching, inserting, deleting. Whatever you need to do with your data.
- **Save**: All the changes you apply to that context are in a memory state unless you call the `save()` method. That method will persist the changes to your store and propagate them across all the available contexts.

```swift
do {
  db.operation { (context, save) throws in
    // Do your operations here
    try save()
  }
} catch {
  // There was an error in the operation
}
```

##### New model
You can use the context `new()` method to initialize a model **without inserting it in the context**:

```swift
do {
  db.operation { (context, save) throws in
    let newTask: Track = try context.new()
    newTask.name = "Make CoreData easier!"
    try context.insert(newTask)
    try save()
  }
} catch {
  // There was an error in the operation
}
```
> In order to insert the model into the context you use the insert() method.

##### Creating a model
You can use the `create()` for initializing and inserting in the context in the same operation:

```swift
do {
  db.operation { (context, save) throws -> Void in
    let newTask: Track = try! context.create()
    newTask.name = "Make CoreData easier!"
    save()
  }
}
catch {
  // There was an error in the operation
}
```

##### Delete a model
In a similar way you can use the `remove()` method from the context passing the objects you want to remove from the database:

```swift
do {
  db.operation { (context, save) throws in
    let john: User? = try context.request(User.self).filteredWith("id", equalTo: "1234").fetch().first
    if let john = john {
      try context.remove([john])
      try save()
    }
  }
} catch {
  // There was an error in the operation
}
```

<br>
> This is the first approach of SugarRecord for the  interface. We'll improve it with the feedback you can report and according to the use of the framework. Do not hesitate to reach us with your proposals. Everything that has to be with making the use of CoreData easier, funnier, and enjoyable is welcome! :tada:

### RequestObservable

SugarRecord provides a component, `RequestObservable` that allows observing changes in the DataBase. It uses `NSFetchedResultsController` under the hood.

**Observing**

```swift
class Presenter {
  var observable: RequestObservable<Track>!

  func setup() {
      let request: FetchRequest<Track> = FetchRequest<Track>().filtered(with: "artist", equalTo: "pedro")
      self.observable = storage.instance.observable(request)
      self.observable.observe { changes in
        case .Initial(let objects):
          print("\(objects.count) objects in the database")
        case .Update(let deletions, let insertions, let modifications):
          print("\(deletions.count) deleted | \(insertions.count) inserted | \(modifications.count) modified")
        case .Error(let error):
          print("Something went wrong")
      }
  }
}
```
> **Retain**: RequestObservable must be retained during the observation lifecycle. When the `RequestObservable` instance gets released from memory it stops observing changes from your storage.

> **NOTE**: This was renamed from Observable -> RequestObservable so we are no longer stomping on the RxSwift Observable namespace.

**:warning: `RequestObservable` is only available for CoreData + OSX since MacOS 10.12**

## Resources
- [Quick](https://github.com/quick/quick)
- [Nimble](https://github.com/quick/nimble)
- [CoreData and threads with GCD](http://www.cimgf.com/2011/05/04/core-data-and-threads-without-the-headache/)
- [Jazzy](https://github.com/realm/jazzy)
- [iCloud + CoreData (objc.io)](http://www.objc.io/issue-10/icloud-core-data.html)

## Contributors

[<img alt="glebo" src="https://avatars3.githubusercontent.com/u/3298239?v=4&s=117" width="117">](https://github.com/glebo)[<img alt="sushichop" src="https://avatars3.githubusercontent.com/u/5669641?v=4&s=117" width="117">](https://github.com/sushichop)[<img alt="foxling" src="https://avatars3.githubusercontent.com/u/506125?v=4&s=117" width="117">](https://github.com/foxling)[<img alt="ZevEisenberg" src="https://avatars2.githubusercontent.com/u/464574?v=4&s=117" width="117">](https://github.com/ZevEisenberg)[<img alt="konyu" src="https://avatars2.githubusercontent.com/u/1217706?v=4&s=117" width="117">](https://github.com/konyu)

[<img alt="yuuki1224" src="https://avatars2.githubusercontent.com/u/1756640?v=4&s=117" width="117">](https://github.com/yuuki1224)[<img alt="YTN01" src="https://avatars3.githubusercontent.com/u/5421955?v=4&s=117" width="117">](https://github.com/YTN01)[<img alt="gitter-badger" src="https://avatars2.githubusercontent.com/u/8518239?v=4&s=117" width="117">](https://github.com/gitter-badger)[<img alt="sergigracia" src="https://avatars3.githubusercontent.com/u/1061658?v=4&s=117" width="117">](https://github.com/sergigracia)[<img alt="adityatrivedi" src="https://avatars0.githubusercontent.com/u/1791760?v=4&s=117" width="117">](https://github.com/adityatrivedi)

[<img alt="Adlai-Holler" src="https://avatars2.githubusercontent.com/u/2466893?v=4&s=117" width="117">](https://github.com/Adlai-Holler)[<img alt="akshaynhegde" src="https://avatars0.githubusercontent.com/u/3814615?v=4&s=117" width="117">](https://github.com/akshaynhegde)[<img alt="goingreen" src="https://avatars2.githubusercontent.com/u/16046834?v=4&s=117" width="117">](https://github.com/goingreen)[<img alt="startupthekid" src="https://avatars3.githubusercontent.com/u/3139429?v=4&s=117" width="117">](https://github.com/startupthekid)[<img alt="ctotheameron" src="https://avatars0.githubusercontent.com/u/3002968?v=4&s=117" width="117">](https://github.com/ctotheameron)

[<img alt="davidahouse" src="https://avatars2.githubusercontent.com/u/140127?v=4&s=117" width="117">](https://github.com/davidahouse)[<img alt="A8-Moke" src="https://avatars2.githubusercontent.com/u/12935988?v=4&s=117" width="117">](https://github.com/A8-Moke)[<img alt="Arasthel" src="https://avatars1.githubusercontent.com/u/480955?v=4&s=117" width="117">](https://github.com/Arasthel)[<img alt="LuizZak" src="https://avatars3.githubusercontent.com/u/6502879?v=4&s=117" width="117">](https://github.com/LuizZak)[<img alt="literator" src="https://avatars1.githubusercontent.com/u/242131?v=4&s=117" width="117">](https://github.com/literator)

[<img alt="madeinqc" src="https://avatars0.githubusercontent.com/u/7191124?v=4&s=117" width="117">](https://github.com/madeinqc)[<img alt="kolisko" src="https://avatars0.githubusercontent.com/u/460056?v=4&s=117" width="117">](https://github.com/kolisko)[<img alt="dukemike" src="https://avatars3.githubusercontent.com/u/11562781?v=4&s=117" width="117">](https://github.com/dukemike)[<img alt="rafalwojcik" src="https://avatars3.githubusercontent.com/u/512353?v=4&s=117" width="117">](https://github.com/rafalwojcik)[<img alt="thad" src="https://avatars1.githubusercontent.com/u/139789?v=4&s=117" width="117">](https://github.com/thad)

[<img alt="chrispix" src="https://avatars0.githubusercontent.com/u/190962?v=4&s=117" width="117">](https://github.com/chrispix)[<img alt="ReadmeCritic" src="https://avatars3.githubusercontent.com/u/15367484?v=4&s=117" width="117">](https://github.com/ReadmeCritic)[<img alt="avielg" src="https://avatars3.githubusercontent.com/u/5012557?v=4&s=117" width="117">](https://github.com/avielg)[<img alt="rdougan" src="https://avatars3.githubusercontent.com/u/28582?v=4&s=117" width="117">](https://github.com/rdougan)[<img alt="grangej" src="https://avatars0.githubusercontent.com/u/604788?v=4&s=117" width="117">](https://github.com/grangej)

[<img alt="fjbelchi" src="https://avatars2.githubusercontent.com/u/626713?v=4&s=117" width="117">](https://github.com/fjbelchi)[<img alt="dcvz" src="https://avatars0.githubusercontent.com/u/2475932?v=4&s=117" width="117">](https://github.com/dcvz)[<img alt="pepibumur" src="https://avatars3.githubusercontent.com/u/663605?v=4&s=117" width="117">](https://github.com/pepibumur)

## About

<img src="https://github.com/carambalabs/Foundation/blob/master/ASSETS/logo-salmon.png?raw=true" width="200" />

This project is funded and maintained by [Caramba](http://caramba.io). We ???? open source software!

Check out our other [open source projects](https://github.com/carambalabs/), read our [blog](http://blog.caramba.io) or say :wave: on twitter [@carambalabs](http://twitter.com/carambalabs).

## Contribute

Contributions are welcome :metal: We encourage developers like you to help us improve the projects we've shared with the community. Please see the [Contributing Guide](https://github.com/carambalabs/Foundation/blob/master/CONTRIBUTING.md) and the [Code of Conduct](https://github.com/carambalabs/Foundation/blob/master/CONDUCT.md).

## License
The MIT License (MIT)

Copyright (c) 2017 Caramba

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
