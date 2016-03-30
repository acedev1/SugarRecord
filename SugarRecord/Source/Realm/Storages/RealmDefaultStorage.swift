import Foundation
import RealmSwift

public class RealmDefaultStorage: Storage {
    
    // MARK: - Attributes
    
    private let configuration: Realm.Configuration?
    
    
    ///  MARK: - Init
    
    public init(configuration: Realm.Configuration? = nil) {
        self.configuration = configuration
    }
    
    
    // MARK: - Storage
    
    public var description: String {
        get {
            return "RealmDefaultStorage"
        }
    }
    
    public var type: StorageType {
        get {
            return .Realm
        }
    }
    
    public var mainContext: Context! {
        get {
            if let configuration = self.configuration {
                return try? Realm(configuration: configuration)
            }
            else {
                return try? Realm()
            }
        }
    }
    
    public var saveContext: Context! {
        get {
            if let configuration = self.configuration {
                return try? Realm(configuration: configuration)
            }
            else {
                return try? Realm()
            }
        }
    }
    
    public var memoryContext: Context! {
        get {
            return try? Realm(configuration: Realm.Configuration(inMemoryIdentifier: "MemoryRealm"))
        }
    }
    
    public func removeStore() throws {
        try NSFileManager.defaultManager().removeItemAtPath(Realm().path)
    }

    public func operation(operation: (context: Context, save: () -> Void) -> Void) {
        let context: Realm = self.saveContext as! Realm
        context.beginWrite()
        var save: Bool = false
        operation(context: context, save: { save = true })
        if save {
            _ = try? context.commitWrite()
        }
        else {
            context.cancelWrite()
        }
    }
    
}
