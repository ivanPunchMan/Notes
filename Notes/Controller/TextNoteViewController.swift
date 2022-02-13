//
//  TextNoteViewController.swift
//  Notes
//
//  Created by Admin on 03.02.2022.
//

import UIKit
import CoreData



class TextNoteViewController: UIViewController, UITextViewDelegate {
    
    private var dataStoreManager = DataStoreManager()
    var titleNote: String = ""
    var contentNote: String = ""
    var dateNote: Date = Date()
    var indexPath: IndexPath?
    var oldNote = false
    
    @IBOutlet var textNoteTextView: UITextView!

    //Нужен для передачи данных между контроллерами
    var noteData: ((_ titleNote: String,_ contentNote: String,_ dateCreateNote: Date, IndexPath?) -> Void)?
    
    
    
    //MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataStoreManager.configureFetchResultController()
        getTextForNote()
        textNoteTextView.delegate = self
        textNoteTextView.attributedText = configuringAttributedStringFor(text: textNoteTextView.text)
    }
    
    func getTextForNote() {
        if oldNote {
            textNoteTextView.text = titleNote + "\n" + contentNote
        } else {
            textNoteTextView.text = ""
        }
    }
    
    @IBAction func saveNote(_ sender: UIBarButtonItem) {
        goBackToNoteListController()
    }
    
    private func goBackToNoteListController() {
            let firstParagraph = getNoteTitle(text: textNoteTextView.text)
            let secondParagraph = getNoteContent(text: textNoteTextView.text)
            let dateCreate = Date()
            noteData?(firstParagraph, secondParagraph, dateCreate, indexPath)
            indexPath = nil
            navigationController?.popViewController(animated: true)
    }

    //Нужен для выделения заголовка - им является первый параграф заметки
    private func getNoteTitle(text: String) -> String {
        var firstParagraph: String
        if let endIndexOfFirstParagraph = text.firstIndex(of: "\n") {
            firstParagraph = String(text[..<endIndexOfFirstParagraph])
        } else {
            firstParagraph = text
        }
        return firstParagraph
    }
    
    //Нужен для выделения содержания - им является текст после первого параграфа заметки
    private func getNoteContent(text: String) -> String {
        var contentNote: String
        if let endIndexOfFirstParagraph = text.firstIndex(of: "\n") {
            let firstIndexOfContent = text.index(endIndexOfFirstParagraph, offsetBy: 1)
            contentNote = String(text[firstIndexOfContent...])
        } else {
            contentNote = ""
        }
        return contentNote
    }
    
    
    func configuringAttributedStringFor(text: String) -> NSMutableAttributedString {
        
        let mutableAttributedString = NSMutableAttributedString(string: text)

        //Нужно для определения длинны первого параграфа и остальных параграфов
        let firstParagraph = NSString(string: getNoteTitle(text: text))
        let otherParagraphs = NSString(string: getNoteContent(text: text))
        
        let titleNoteParagraphStyle = NSMutableParagraphStyle()
        titleNoteParagraphStyle.alignment = .center
        let contentNoteParagraphsStyle = NSMutableParagraphStyle()
        
        let fontForTitleNote = UIFont(name: "Helvetica-Bold", size: 24)!
        let fontForContentNote = UIFont(name: "Helvetica", size: 20)!
        
        mutableAttributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: titleNoteParagraphStyle, range: NSRange(location: 0, length: firstParagraph.length))
        mutableAttributedString.addAttribute(NSAttributedString.Key.font, value: fontForTitleNote, range: NSRange(location: 0, length: firstParagraph.length))
        
        if text.contains("\n") {
            mutableAttributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: contentNoteParagraphsStyle, range: NSRange(location: firstParagraph.length, length: otherParagraphs.length + 1))
            mutableAttributedString.addAttribute(NSAttributedString.Key.font, value: fontForContentNote, range: NSRange(location: firstParagraph.length, length: otherParagraphs.length + 1))
        }
        return mutableAttributedString
    }
    
    //MARK: - UITextViewDelegate

    func textViewDidChange(_ textView: UITextView) {
        textView.attributedText = configuringAttributedStringFor(text: textNoteTextView.text)
    }
    
}

    


