# <center>![xcres](https://github.com/swiftreactive/SugarRecord/raw/master/Assets/Banner.png)</center>

# SugarRecord

[![Twitter: @pepibumur](https://img.shields.io/badge/contact-@pepibumur-blue.svg?style=flat)](https://twitter.com/pepibumur)
[![Language: Swift](https://img.shields.io/badge/lang-Swift-yellow.svg?style=flat)](https://developer.apple.com/swift/)
[![Language: Swift](https://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat)](http://opensource.org/licenses/MIT)
[![Build Status](https://travis-ci.org/SwiftReactive/SugarRecord.svg)](https://travis-ci.org/SwiftReactive/SugarRecord)
[![Slack Status](https://sugarrecord-slack.herokuapp.com/badge.svg)](https://sugarrecord-slack.herokuapp.com)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

**If you want to receive updates about the status of SugarRecord, you can subscribe to our mailing list [here](http://eepurl.com/57tqX)**

## What is SugarRecord?
SugarRecord is a persistence wrapper designed to make working with persistence solutions like CoreData/Realm/... in a much easier way. Thanks to SugarRecord you'll be able to use CoreData with just a few lines of code: Just choose your stack and start playing with your data.

The library is maintained by [@pepibumur](https://github.com/pepibumur) under [SwiftReactive](https://github.com/swiftreactive). You can reach me at [pepibumur@gmail.com](mailto://pepibumur@gmail.com) for help or whatever you need to commend about the library.

## Features
- Swift 2.1 compatible (XCode 7.1).
- Fully rewritten from the version 1.0.
- Reactive API (using ReactiveCocoa).
- Protocols based design.
- For **beginners** and **advanced** users
- Fully customizable. Build your own stack!
- Friendly syntax (fluent)
- Away from Singleton patterns! No shared states :tada:
- Compatible with OSX/iOS/watchOS/tvOS
- Fully tested (thanks Nimble and Quick)
- Actively supported

## Setup

### [Cocoapods](https://cocoapods.org)

1. Install [CocoaPods](https://cocoapods.org). You can do it with `gem install cocoapods`
2. Edit your `Podfile` file and add the following line `pod 'SugarRecord'
3. Update your pods with the command `pod install`
4. Open the project from the generated workspace (`.xcworkspace` file).

*Note: You can also test the last commits by specifying it directly in the Podfile line*

### [Carthage](https://carthage)
1. Install [Carthage](https://github.com/carthage/carthage) on your computer using `brew install carthage`
3. Edit your `Cartfile` file adding the following line `github 'swiftreactive/sugarrecord'`
4. Update and build frameworks with `carthage update`
5. Add generated frameworks to your app main target following the steps [here](https://github.com/carthage/carthage)
6. Link your target with **CoreData** library *(from Build Phases)*

#### Notes
- The CocoaPods integration doesn't support Realm yet. Use Realm instead.
- Carthage integration includes both, CoreData and Carthage. We're planning to separate it in multiple frameworks. [Task](https://trello.com/c/hyhN1Tp2/11-create-separated-frameworks-for-foundation-coredata-and-realm)
- SugarRecord 2.0 is not compatible with the 1.x interface. If you were using that version you'll have to update your project to support this version.

## Reference
You can check generated SugarRecord documentation [here](http://cocoadocs.org/docsets/SugarRecord/2.0.0/) generated automatically with [CocoaDocs](http://cocoadocs.org/) 

# How to use

#### Creating your Storage
A storage represents your database, Realm, or CoreData. The first step to start using SugarRecord is initializing the storage. SugarRecord provides two default storages, one for CoreData, `CoreDataDefaultStorage` and another one for Realm, `RealmDefaultStorage`.

```swift
// Initializing CoreDataDefaultStorage
func coreDataStorage() -> CoreDataDefaultStorage {
    let store = CoreData.Store.Named("db")
    let bundle = NSBundle(forClass: CoreDataDefaultStorageTests.classForCoder())
    let model = CoreData.ObjectModel.Merged([bundle])
    let defaultStorage = try! CoreDataDefaultStorage(store: store, model: model)
    return defaultStorage
}

// Initializing RealmDefaultStorage
func realmStorage() -> RealmDefaultStorage {
  return RealmDefaultStorage()
}
```

#### Contexts
Storages offer multiple kind of contexts that are the entry points to the database. For curious developers, in case of CoreData a context is a wrapper around `NSManagedObjectContext`, in case of Realm a wrapper around `Realm`. The available contexts are:

- **MainContext:** Use it for main thread operations, for example fetches whose data will be presented in the UI.
- **SaveContext:** Use this context for background operations, the property `saveContext` of the storage is a computed property so every time you call it you get a new fresh context to be used.
- **MemoryContext:** Use this context when you want to do some tests and you don't want your changes to be persisted.

#### Fetching data
Once you know that the context is the point to access the storage let's see how we can request objects since SugarRecord also provides a fluent interface to make things easier:

1. Use the context `request()` method passing the type of object you want to fetch.
2. Specify filters and sort descriptors for that request. We'll expand this in the future to include more request features Realm/CoreData related.
3. Once you have your request, just use the fetch method which will return a `Result<[Value], Error>` object that wraps both your result or an error in case of something went wrong with the request. You can unwrap the value with `result.value!`.

```swift
let pedros: [Person] = db.mainContext.request(Person.self).filteredWith("name", equalTo: "Pedro").fetch().value!
let tasks: [Task] = db.mainContext.request(Task.self).fetch().value!
let citiesByName: [City] = db.mainContext.request(City.self).sortedWith("name", ascending: true).fetch().value!

let predicate: NSPredicate = NSPredicate(format: "id == %@", "AAAA")
let john: User? = db.mainContext.request(User.self).filteredWith(predicate: predicate).fetch().value!.first
```

#### Remove/Insert/Update operations

Although `Context`s offer `insertion` and `deletion` methods that you can use it directly SugarRecords aims at using the `operation` method method provided by the storage for operations that imply modifications of the database models:

- **Context**: You can use it for fetching, inserting, deleting. Whatever you need to do with your data.
- **Save**: All the changes you apply to that context are in a memory state unless you call the `save()` method. That method will persist the changes to your store and propagate them across all the available contexts.

```swift
db?.operation({ (context, save) -> Void in
  // Do your operations here
  save()
}, completed: {
  // Everything was completed. :tada:
})
```
##### Inserting a model
You can use the `insert()` method of context that needs the type of object you want to insert:

```swift
db?.operation({ (context, save) -> Void in
  let newTask: Track = memoryContext.insert().value!
  newTask.name = "Make CoreData easier!"
  save()
}, completed: {
  // Everything was completed. :tada:
})
```

##### Delete a model
In a similar way you can use the `remove()` method from the context passing the objects you want to remove from the database:

```swift
db?.operation({ (context, save) -> Void in
  guard let john = db.mainContext.request(User.self).filteredWith("id", equalTo: "1234").fetch().value!.first else { return }
  context.remove([john])
  save()
}, completed: {
  // Everything was completed. :tada:
})
```

<br>
<br>
> This is the first approach of SugarRecord for the  interface. We'll improve it with the feedback you can report and according to the use of the framework. Do not hesitate to reach us with your proposals. Everything that has to be with making the use of CoreData/Realm easier, funnier, and enjoyable is welcome! :tada:

# Contributing

## Trello board :white_check_mark:
We :heart: love transparency and decided to make the Trello board that use for organization public. You can access it [here](https://trello.com/c/BovsGc0E/4-contribution-document). You can check there the upcoming features and bugs pending to be fixed. You can also contribute proposing yours.

## Support

If you want to communicate any issue, suggestion or even make a contribution, you have to keep in mind the flow bellow:

- If you need help, ask your doubt in Stack Overflow using the tag 'sugarrecord'
- If you want to ask something in general, use Stack Overflow too.
- Open an issue either when you have an error to report or a feature request.
- If you want to contribute, submit a pull request, and remember the rules to follow related with the code style, testing, ...

## Contribution
- You'll find more details about contribution with SugarRecord in [contribution](CONTRIBUTION.md)

## Resources
- [Quick](https://github.com/quick/quick)
- [Nimble](https://github.com/quick/nimble)
- [CoreData and threads with GCD](http://www.cimgf.com/2011/05/04/core-data-and-threads-without-the-headache/)
- [Jazzy](https://github.com/realm/jazzy)
- [iCloud + CoreData (objc.io)](http://www.objc.io/issue-10/icloud-core-data.html)

## License
The MIT License (MIT)

Copyright (c) <2014> <Pedro Piñera>

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

## Who uses SugarRecord?
Are you using SugarRecord? Let us know, and we'll list you here. We :heart: to hear about companies, apps that are using us with CoreData.
