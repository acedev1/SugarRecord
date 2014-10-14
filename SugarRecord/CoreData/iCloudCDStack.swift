//
//  iCloudCDStack.swift
//  SugarRecord
//
//  Created by Pedro Piñera Buendía on 12/10/14.
//  Copyright (c) 2014 SugarRecord. All rights reserved.
//

import Foundation

public struct iCloudData
{
    /// Is the full AppID (including the Team Prefix). It's needed to change tihs to match the Team Prefix found in the iOS Provisioning profile
    let iCloudAppID: String
    /// Is the name of the directory where the database will be stored in. It should always end with .nosync
    let iCloudDataDirectoryName: String
    /// Is the name of the directory where the database change logs will be stored in
    let iCloudLogsDirectory: String
    
    /**
    Note:
    iCloudData = iCloud + DataDirectory
    iCloudLogs = iCloud + LogsDirectory
    */
    
    /**
    Initializer for the struct
    
    :param: iCloudAppID             iCloud app identifier
    :param: iCloudDataDirectoryName Directory of the database
    :param: iCloudLogsDirectory     Directory of the database logs
    
    :returns: Initialized struct
    */
    public init (iCloudAppID: String, iCloudDataDirectoryName: String, iCloudLogsDirectory: String)
    {
        self.iCloudAppID = iCloudAppID
        self.iCloudDataDirectoryName = iCloudDataDirectoryName
        self.iCloudLogsDirectory = iCloudLogsDirectory
    }
}

public class iCloudCDStack: DefaultCDStack
{
    //MARK: - Properties
    /// iCloud Data struct with the information
    private let icloudData: iCloudData?
    
    //MARK: - Constructors
    
    /**
    Initialize the CoreData stack
    
    :param: databaseURL   NSURL with the database path
    :param: model         NSManagedObjectModel with the database model
    :param: automigrating Bool Indicating if the migration has to be automatically executed
    :param: icloudData    iCloudData information
    
    :returns: iCloudCDStack object
    */
    public init(databaseURL: NSURL, model: NSManagedObjectModel?, automigrating: Bool, icloudData: iCloudData)
    {
        super.init(databaseURL: databaseURL, model: model, automigrating: automigrating)
        self.icloudData = icloudData
        self.automigrating = automigrating
        self.databasePath = databaseURL
        self.managedObjectModel = model
        self.migrationFailedClosure = {}
        self.name = "iCloudCoreDataStack"
        self.stackDescription = "Stack to connect your local storage with iCloud"
    }
    
    /**
    Initialize the CoreData default stack passing the database name and a flag indicating if the automigration has to be automatically executed
    
    :param: databaseName  String with the database name
    :param: icloudData iCloud Data struct
    
    :returns: DefaultCDStack object
    */
    convenience public init(databaseName: String, icloudData: iCloudData)
    {
        self.init(databaseURL: iCloudCDStack.databasePathURLFromName(databaseName), icloudData: icloudData)
    }
    
    /**
    Initialize the CoreData default stack passing the database path in String format and a flag indicating if the automigration has to be automatically executed
    
    :param: databasePath  String with the database path
    :param: icloudData iCloud Data struct
    
    :returns: DefaultCDStack object
    */
    convenience public init(databasePath: String, icloudData: iCloudData)
    {
        self.init(databaseURL: NSURL(fileURLWithPath: databasePath), icloudData: icloudData)
    }
    
    /**
    Initialize the CoreData default stack passing the database path URL and a flag indicating if the automigration has to be automatically executed
    
    :param: databaseURL   NSURL with the database path
    :param: icloudData iCloud Data struct

    :returns: DefaultCDStack object
    */
    convenience public init(databaseURL: NSURL, icloudData: iCloudData)
    {
        self.init(databaseURL: databaseURL, model: nil, automigrating: true,icloudData: icloudData)
    }
    
    /**
    Initialize the CoreData default stack passing the database name, the database model object and a flag indicating if the automigration has to be automatically executed
    
    :param: databaseName  String with the database name
    :param: model         NSManagedObjectModel with the database model
    :param: icloudData iCloud Data struct

    :returns: DefaultCDStack object
    */
    convenience public init(databaseName: String, model: NSManagedObjectModel, icloudData: iCloudData)
    {
        self.init(databaseURL: DefaultCDStack.databasePathURLFromName(databaseName), model: model, automigrating: true, icloudData: icloudData)
    }
    
    /**
    Initialize the CoreData default stack passing the database path in String format, the database model object and a flag indicating if the automigration has to be automatically executed
    
    :param: databasePath  String with the database path
    :param: model         NSManagedObjectModel with the database model
    :param: icloudData iCloud Data struct
    
    :returns: DefaultCDStack object
    */
    convenience public init(databasePath: String, model: NSManagedObjectModel, icloudData: iCloudData)
    {
        self.init(databaseURL: NSURL(fileURLWithPath: databasePath), model: model, automigrating: true, icloudData: icloudData)
    }
    
    /**
    Initialize the stacks components and the connections between them
    */
    public override func initialize()
    {
        createManagedObjecModelIfNeeded()
        persistentStoreCoordinator = createPersistentStoreCoordinator()
        addDatabase(foriCloud: true) { [weak self] (error) -> () in
            if self == nil {
                SugarRecordLogger.logLevelFatal.log("The stack was released whil trying to initialize it")
                return
            }
            else if error != nil {
                SugarRecordLogger.logLevelFatal.log("Something went wrong adding the database")
                return
            }
            self!.rootSavingContext = self!.createRootSavingContext(self!.persistentStoreCoordinator)
            self!.mainContext = self!.createMainContext(self!.rootSavingContext)
        }
    }
    
    /**
    Add iCloud Database
    */
    internal func addDatabase(foriCloud icloud: Bool, completionClosure: (error: NSError?) -> ())
    {
        /**
        *  In case of not for iCloud
        */
        if !icloud {
            self.addDatabase(completionClosure)
            return
        }
        /**
        *  Database creation is an asynchronous process
        */
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { [weak self] () -> Void in
            
            // Ensuring that the stack hasn't been released
            if self == nil {
                SugarRecordLogger.logLevelFatal.log("The stack was initialized while trying to add the database")
                return
            }
            
            // Checking that the PSC exists before adding the store
            if self!.persistentStoreCoordinator == nil {
                SugarRecord.handle(NSError())
            }
            
            
            // Logging some data
            let fileManager: NSFileManager = NSFileManager()
            SugarRecordLogger.logLevelVerbose.log("Initializing iCloud with:")
            SugarRecordLogger.logLevelVerbose.log("iCloud App ID: \(self!.icloudData?.iCloudAppID)")
            SugarRecordLogger.logLevelVerbose.log("iCloud Data Directory: \(self!.icloudData?.iCloudDataDirectoryName)")
            SugarRecordLogger.logLevelVerbose.log("iCloud Logs Directory: \(self!.icloudData?.iCloudLogsDirectory)")
            
            //Getting the root path for iCloud
            let iCloudRootPath: NSURL? = fileManager.URLForUbiquityContainerIdentifier(self!.icloudData?.iCloudAppID)

            /**
            *  If iCloud if accesible keep creating the PSC
            */
            if iCloudRootPath != nil {
                let iCloudLogsPath: NSURL = NSURL(fileURLWithPath: iCloudRootPath!.path!.stringByAppendingPathComponent(self!.icloudData!.iCloudLogsDirectory))
                let iCloudDataPath: NSURL = NSURL(fileURLWithPath: iCloudRootPath!.path!.stringByAppendingPathComponent(self!.icloudData!.iCloudDataDirectoryName))

                // Creating data path in case of doesn't existing
                var error: NSError?
                if !fileManager.fileExistsAtPath(iCloudDataPath.path!) {
                    fileManager.createDirectoryAtPath(iCloudDataPath.path!, withIntermediateDirectories: true, attributes: nil, error: &error)
                }
                if error != nil {
                    completionClosure(error: error!)
                    return
                }
                
                /// Getting the database path
                /// iCloudPath + iCloudDataPath + DatabaseName
                self!.databasePath = NSURL(fileURLWithPath: iCloudRootPath!.path!.stringByAppendingPathComponent(self!.icloudData!.iCloudDataDirectoryName).stringByAppendingPathComponent(self!.databasePath!.lastPathComponent))
                
                
                // Adding store
                self!.persistentStoreCoordinator!.lock()
                error = nil
                var store: NSPersistentStore? = self!.persistentStoreCoordinator?.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: self!.databasePath, options: iCloudCDStack.icloudStoreOptions(contentNameKey: self!.icloudData!.iCloudAppID, contentURLKey: iCloudLogsPath), error: &error)
                self!.persistentStoreCoordinator!.unlock()
                self!.persistentStore = store!

                // Calling completion closure
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    completionClosure(error: nil)
                })
            }
            /**
            *  Otherwise use the local store
            */
            else {
                self!.addDatabase(foriCloud: false, completionClosure: completionClosure)
            }
        })
    }
    
    /**
    Returns the iCloud options to be used when the NSPersistentStore is initialized
    
    :returns: [NSObject: AnyObject] with the options
    */
    internal class func icloudStoreOptions(#contentNameKey: String, contentURLKey: NSURL) -> [NSObject: AnyObject]
    {
        var options: [NSObject: AnyObject] = [NSObject: AnyObject] ()
        options[NSMigratePersistentStoresAutomaticallyOption] = NSNumber(bool: true)
        options[NSInferMappingModelAutomaticallyOption] = NSNumber(bool: true)
        options[NSPersistentStoreUbiquitousContentNameKey] = contentNameKey
        options[NSPersistentStoreUbiquitousContentNameKey] = NSPersistentStoreUbiquitousContentURLKey
        return options
    }
}