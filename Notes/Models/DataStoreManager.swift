//
//  DataStoreManager.swift
//  Notes
//
//  Created by Admin on 02.02.2022.
//

import Foundation
import CoreData

extension UserDefaults {
    static func isFirstLaunch() -> Bool {
        let hasBeenLaunchedBeforeFlag = "hasBeenLaunchedBeforeFlag"
        let isFirstLaunch = !UserDefaults.standard.bool(forKey: hasBeenLaunchedBeforeFlag)
        if (isFirstLaunch) {
            UserDefaults.standard.set(true, forKey: hasBeenLaunchedBeforeFlag)
            UserDefaults.standard.synchronize()
        }
        return isFirstLaunch
    }
}

class DataStoreManager {

    let isFirstLaunch = UserDefaults.isFirstLaunch()
    
    
    
    // MARK: - Core Data stack
    
    
        
    var fetchResultController: NSFetchedResultsController<Notes>!
        
    func configureFetchResultController() {

        let fetchRequest: NSFetchRequest<Notes> = Notes.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "dateCreate", ascending: false)
        fetchRequest.fetchLimit = 15
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchResultController = {
            NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: viewContext, sectionNameKeyPath: nil, cacheName: nil)
        }()
            do {
                try fetchResultController.performFetch()
            } catch {
                print("Error: \(error)")
            }
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Notes")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    lazy var viewContext: NSManagedObjectContext = persistentContainer.viewContext
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func saveNoteInViewContext (title: String, content: String, date: Date) {
        
        let notes = Notes(context: viewContext)
        notes.title = title
        notes.content = content
        notes.dateCreate = date
        let date = date
        if #available(iOS 15.0, *) {
            notes.date = date.formatted()
        } else {
            notes.date = date.description(with: .current)
        }
        
        do {
            try viewContext.save()
        } catch let error {
            print("Error: \(error)")
        }
    }
}
