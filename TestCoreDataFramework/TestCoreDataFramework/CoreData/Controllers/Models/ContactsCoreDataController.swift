//
//  ContactsCoreDataController.swift
//  TestCoreDataFramework
//
//  Created by Gene Backlin on 7/13/15.
//  Copyright (c) 2015 Gene Backlin. All rights reserved.
//

import UIKit
import CoreData
import CoreDataFoundation

class ContactsCoreDataController: CoreDataController {
    
    override init() {
        super.init()
        self.dataModel = "Contacts"
        self.bundleName = "CoreDataFoundation"
        self.entityName = "Person"
    }

    func addPersonUsingEmail(email: String!, firstName: String!, lastName: String!, phone: String?, error: NSErrorPointer?) {
        let results: [String : AnyObject]? = self.fetchPersonUsingEmail(email, error: error)
        
        if results == nil {
            var newPerson: NSManagedObject = NSEntityDescription.insertNewObjectForEntityForName(self.entityName, inManagedObjectContext: self.managedObjectContext!) as! NSManagedObject
            
            newPerson.setValue(email, forKey: "email")
            newPerson.setValue(firstName, forKey: "firstName")
            newPerson.setValue(lastName, forKey: "lastName")
            if phone != nil {
                newPerson.setValue(phone, forKey: "phone")
            }
            
            error!.memory = self.saveContext()
        }
    }
    
    func updatePersonUsingEmail(email: String!, firstName: String!, lastName: String!, phone: String?, error: NSErrorPointer?) {
        let context: NSManagedObjectContext? = self.managedObjectContext
        let request: NSFetchRequest = self.fetchRequestForEntityName(self.entityName, predicateFormat: "email = %@", predicateValue: email)
        let results: [AnyObject]? = context?.executeFetchRequest(request, error: error!)
        
        if results != nil {
            if results?.count > 0 {
                for person: NSManagedObject in results as! [NSManagedObject] {
                    person.setValue(email, forKey: "email")
                    person.setValue(firstName, forKey: "firstName")
                    person.setValue(lastName, forKey: "lastName")
                    if phone != nil {
                        person.setValue(phone, forKey: "phone")
                    }
                    
                    error!.memory = self.saveContext()
                }
            }
        }
    }
    
    func deletePersonUsingEmail(email: String!, error: NSErrorPointer?) {
        let context: NSManagedObjectContext? = self.managedObjectContext
        let request: NSFetchRequest = self.fetchRequestForEntityName(self.entityName, predicateFormat: "email = %@", predicateValue: email)
        let results: [AnyObject]? = context?.executeFetchRequest(request, error: error!)
        
        if results != nil {
            if results?.count > 0 {
                for person: NSManagedObject in results as! [NSManagedObject] {
                    context?.deleteObject(person)
                }
                error!.memory = self.saveContext()
            }
        }
    }
    
    func fetchPersonUsingEmail(email: String?, error: NSErrorPointer?) -> [String : AnyObject]? {
        var resultsDict: [String : AnyObject]? = nil
        let context: NSManagedObjectContext? = self.managedObjectContext
        var request: NSFetchRequest? = nil
        
        if email == "" {
            request = self.fetchRequestForEntityName(self.entityName)
        } else {
            request = self.fetchRequestForEntityName(self.entityName, predicateFormat: "email = %@", predicateValue: email)
        }
        
        let results: [AnyObject]? = context?.executeFetchRequest(request!, error: error!)
        
        if results != nil {
            if results?.count > 0 {
                resultsDict = [String : AnyObject]()
                
                for person: NSManagedObject in results as! [NSManagedObject] {
                    let key: String = person.valueForKey("email")!.description
                    var newPerson: [String : AnyObject] = [String : AnyObject]()
                    newPerson["email"] = key
                    newPerson["firstName"] = person.valueForKey("firstName")!.description
                    newPerson["lastName"] = person.valueForKey("lastName")!.description
                    newPerson["phone"] = person.valueForKey("phone")!.description
                    
                    resultsDict![key] = newPerson
                }
            }
        }
        
        return resultsDict
    }

}
