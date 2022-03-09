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
            dataStoreManager.saveNoteInViewContext(content: getFirstNote(), date: Date())
            print("firstLaunch")
            dataStoreManager.saveContext()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getNoteWhenFirstLaunchApp()
        dataStoreManager.configureFetchResultController()
        dataStoreManager.fetchResultController.delegate = self
    }
    
    //Заметка, которая появится при первом запуске
    func getFirstNote() -> NSMutableAttributedString {
            
        let fontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body)
        let boldFontDescriptor = fontDescriptor.withSymbolicTraits(.traitBold)
    
        let boldFont = UIFont(descriptor: boldFontDescriptor!, size: 24)
        let normalFont = UIFont(descriptor: fontDescriptor, size: 20)
        
        let contentNote = NSMutableAttributedString(string: "Заголовок заметки\nСодержание заметки")
        
        //Нужно для определения длинны первого параграфа и остальных параграфов
        let firstParagraph = contentNote.mutableString.paragraphRange(for: NSRange(location: 0, length: 0))
        let otherParagraphs = NSString(string: getNoteContent(text: contentNote))
        
        //Атрибуты заголовка заметки (Первый абзац)
        let titleNoteParagraphStyle = NSMutableParagraphStyle()
        contentNote.addAttribute(NSAttributedString.Key.paragraphStyle, value: titleNoteParagraphStyle, range: firstParagraph)
        contentNote.addAttribute(NSAttributedString.Key.font, value: boldFont, range: firstParagraph)
        
        //Атрибуты содержания заметки (Текст начиная со второго абзаца)
        let contentNoteParagraphsStyle = NSMutableParagraphStyle()
        if contentNote.string.contains("\n") {
            contentNote.addAttribute(NSAttributedString.Key.paragraphStyle, value: contentNoteParagraphsStyle, range: NSRange(location: firstParagraph.length - 1, length: otherParagraphs.length + 1))
            contentNote.addAttribute(NSAttributedString.Key.font, value: normalFont, range: NSRange(location: firstParagraph.length - 1, length: otherParagraphs.length + 1))
        }
        return contentNote
    }
    
    func editNoteCell(content: NSMutableAttributedString, date: Date, indexPath: IndexPath) {
        let _ = tableView.dequeueReusableCell(withIdentifier: "noteCell", for: indexPath) as! NoteCell
        let note = dataStoreManager.fetchResultController.object(at: indexPath)
        note.content = content
        note.dateCreate = date
        dataStoreManager.saveContext()
        tableView.reloadData()
    }
    
    private func getConfigurateNotesCell(for indexPath: IndexPath) -> UITableViewCell {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "noteCell", for: indexPath) as! NoteCell
        let note = dataStoreManager.fetchResultController.object(at: indexPath)

        cell.titileLabel.text = getNoteTitle(text: note.content!)
        cell.contentLabel.text = getNoteContent(text: note.content!)
        cell.dateLabel.text = dateFormatter.string(from: note.dateCreate!)
        
        cell.titileLabel.textColor = .black
        cell.contentLabel.textColor = .systemGray
        cell.dateLabel.textColor = .systemGray
            
        return cell
    }
    
    @IBAction func goToTextNoteViewController(_ sender: UIBarButtonItem) {
        let noteEditingViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NoteEditingViewController") as? NoteEditingViewController
        noteEditingViewController?.noteData = { [unowned self] contentNote, dateCreateNote, indexPath in
            if indexPath == nil {
                dataStoreManager.saveNoteInViewContext(content: contentNote, date: dateCreateNote)
            }
        }
        
        
        noteEditingViewController?.isOldNote = false
        navigationController?.pushViewController(noteEditingViewController!, animated: true)
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
    
    private func getNoteTitle(text: NSAttributedString) -> String {
        var firstParagraph: String
        if let endIndexOfFirstParagraph = text.string.firstIndex(of: "\n") {
            firstParagraph = String(text.string[..<endIndexOfFirstParagraph])
        } else {
            firstParagraph = text.string
        }
        return firstParagraph
    }
    
    //Нужен для выделения содержания - им является текст после первого параграфа заметки
    private func getNoteContent(text: NSAttributedString) -> String {
        var contentNote: String
        if let endIndexOfFirstParagraph = text.string.firstIndex(of: "\n") {
            let firstIndexOfContent = text.string.index(endIndexOfFirstParagraph, offsetBy: 1)
            contentNote = String(text.string[firstIndexOfContent...])
        } else {
            contentNote = ""
        }
        return contentNote
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let note = dataStoreManager.fetchResultController.object(at: indexPath)
        let noteEditingViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NoteEditingViewController") as? NoteEditingViewController
        noteEditingViewController?.titleNote = getNoteTitle(text: note.content!)
        noteEditingViewController?.contentNote = getNoteContent(text: note.content!)
        noteEditingViewController?.indexPath = indexPath
        noteEditingViewController?.isOldNote = true
        noteEditingViewController?.noteData = { [unowned self] contentNote, dateCreateNote, indexPath in
            if indexPath != nil {
                editNoteCell(content: contentNote, date: dateCreateNote, indexPath: indexPath!)
            }
        }
        navigationController?.pushViewController(noteEditingViewController!, animated: true)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let note = dataStoreManager.fetchResultController.object(at: indexPath)
        dataStoreManager.viewContext.delete(note)
        dataStoreManager.saveContext()
    }
}
