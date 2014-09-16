//
//  RLMObject+SugarRecord.swift
//  SugarRecord
//
//  Created by Pedro Piñera Buendia on 07/09/14.
//  Copyright (c) 2014 SugarRecord. All rights reserved.
//

import Foundation
import Realm

extension RLMObject: SugarRecordObjectProtocol
{
    //MARK - Custom Getter
    
    public func context() -> SugarRecordContext
    {
        if self.realm != nil {
            return SugarRecordRLMContext(realmContext: self.realm)
        }
        else {
            return SugarRecordRLMContext(realmContext: RLMRealm.defaultRealm())
        }
    }
    
    //MARK - Filtering
    
    public class func by(predicate: NSPredicate) -> SugarRecordFinder
    {
        var finder: SugarRecordFinder = SugarRecordFinder(predicate: predicate)
        finder.objectClass = self
        return finder
    }
    
    public class func by(predicateString: NSString) -> SugarRecordFinder
    {
        var finder: SugarRecordFinder = SugarRecordFinder()
        finder.setPredicate(predicateString)
        finder.objectClass = self
        return finder
    }
    
    public class func by(key: String, equalTo value: String) -> SugarRecordFinder
    {
        var finder: SugarRecordFinder = SugarRecordFinder()
        finder.setPredicate(byKey: key, andValue: value)
        finder.objectClass = self
        return finder
    }
    
    //MARK - Sorting
    
    public class func sorted(by sortingKey: String, ascending: Bool) -> SugarRecordFinder
    {
        var finder: SugarRecordFinder = SugarRecordFinder()
        finder.addSortDescriptor(byKey: sortingKey, ascending: ascending)
        finder.objectClass = self
        return finder
    }
    
    public class func sorted(by sortDescriptor: NSSortDescriptor) -> SugarRecordFinder
    {
        var finder: SugarRecordFinder = SugarRecordFinder()
        finder.addSortDescriptor(sortDescriptor)
        finder.objectClass = self
        return finder
    }
    
    public class func sorted(by sortDescriptors: [NSSortDescriptor]) -> SugarRecordFinder
    {
        var finder: SugarRecordFinder = SugarRecordFinder()
        finder.setSortDescriptors(sortDescriptors)
        finder.objectClass = self
        return finder
    }
    
    
    //MARK - All
    
    public class func all() -> SugarRecordFinder
    {
        var finder: SugarRecordFinder = SugarRecordFinder()
        finder.all()
        return finder
    }
    
    
    //MARK - Deletion
    
    public func delete() -> Bool
    {
        var deleted: Bool = false
        SugarRecord.operation {(context) -> () in
            context.beginWritting()
            deleted = context.deleteObject(self)
            context.endWritting()
        }
        return false
    }

    
    //MARK - Creation
    
    public class func create() -> AnyObject
    {
        var object: AnyObject?
        SugarRecord.operation { (context) -> () in
            object = context.createObject(self)
        }
        return object!
    }
    
    public class func create(inContext context: SugarRecordContext) -> AnyObject
    {
        return context.createObject(self)!
    }
    
    
    //MARK - Savingr
    
    public func save () -> Bool
    {
        var saved: Bool = false
        self.save(false, completion: { (error) -> () in
            saved = error == nil
        })
        return saved
    }
    
    public func save (asynchronously: Bool, completion: (error: NSError) -> ())
    {
        let context: SugarRecordContext = self.context()
        if asynchronously {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
                context.beginWritting()
                context.insertObject(self)
                context.endWritting()
            })
        }
        else {
            context.beginWritting()
            context.insertObject(self)
            context.endWritting()
        }
    }
}