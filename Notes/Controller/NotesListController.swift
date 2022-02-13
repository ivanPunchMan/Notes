//
//  NotesListController.swift
//  Notes
//
//  Created by Admin on 30.01.2022.
//

import UIKit
import CoreData

class NotesListController: UITableViewController, NSFetchedResultsControllerDelegate {
    

    var dataStoreManager = DataStoreManager()
    
    //MARK: - Methods
    //Нужен для отображения заметки при первом запуске
    private func getNoteWhenFirstLaunchApp() {
        if dataStoreManager.isFirstLaunch {
            dataStoreManager.saveNoteInViewContext(title: "Заголовок заметки", content: "Содержание заметки", date: Date())
            dataStoreManager.saveContext()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getNoteWhenFirstLaunchApp()
        dataStoreManager.configureFetchResultController()
        dataStoreManager.fetchResultController.delegate = self
    }
    
    func editNoteCell(title: String, content: String, date: Date, indexPath: IndexPath) {
        let _ = tableView.dequeueReusableCell(withIdentifier: "noteCell", for: indexPath) as! NoteCell
        let note = dataStoreManager.fetchResultController.object(at: indexPath)
        note.title = title
        note.content = content
        note.dateCreate = date
        dataStoreManager.saveContext()
        tableView.reloadData()
    }
    
    private func getConfigurateNotesCell(for indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "noteCell", for: indexPath) as! NoteCell
        let note = dataStoreManager.fetchResultController.object(at: indexPath)

        cell.titileLabel.text = note.title
        cell.contentLabel.text = note.content
        
        if #available(iOS 15.0, *) {
            cell.dateLabel.text = note.dateCreate?.formatted(date: .numeric, time: .shortened)
        } else {
            cell.dateLabel.text = note.dateCreate?.description(with: .autoupdatingCurrent)
        }
        
        cell.titileLabel.textColor = .black
        cell.contentLabel.textColor = .systemGray
        cell.dateLabel.textColor = .systemGray
            
        return cell
    }
    
    @IBAction func goToTextNoteViewController(_ sender: UIBarButtonItem) {
        let textNoteController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TextNoteViewController") as? TextNoteViewController
        textNoteController?.noteData = { [unowned self] titleNote, contentNote, dateCreateNote, indexPath in
            if indexPath == nil {
                dataStoreManager.saveNoteInViewContext(title: titleNote, content: contentNote, date: dateCreateNote)
            }
        }
        textNoteController?.oldNote = false
        navigationController?.pushViewController(textNoteController!, animated: true)
    }
    
    //MARK: - NSFetchedResultsControllerDelegate
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        default:
            break
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfObjectInSection = dataStoreManager.fetchResultController.sections?[section]
        return numberOfObjectInSection?.numberOfObjects ?? 0
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return getConfigurateNotesCell(for: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let note = dataStoreManager.fetchResultController.object(at: indexPath)
        let textNoteController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TextNoteViewController") as? TextNoteViewController
        let title = note.title ?? ""
        let content = note.content ?? ""
        textNoteController?.titleNote = title
        textNoteController?.contentNote = content
        textNoteController?.indexPath = indexPath
        textNoteController?.oldNote = true
        textNoteController?.noteData = { [unowned self] titleNote, contentNote, dateCreateNote, indexPath in
            if indexPath != nil {
                editNoteCell(title: titleNote, content: contentNote, date: dateCreateNote, indexPath: indexPath!)
            }
        }
//        textNoteController?.getTextForNote()
        navigationController?.pushViewController(textNoteController!, animated: true)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let note = dataStoreManager.fetchResultController.object(at: indexPath)
        dataStoreManager.viewContext.delete(note)
        dataStoreManager.saveContext()
    }
}
