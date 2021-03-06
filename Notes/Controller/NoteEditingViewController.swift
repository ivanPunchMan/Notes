//
//  TextNoteViewController.swift
//  Notes
//
//  Created by Admin on 03.02.2022.
//

import UIKit
import CoreData


class NoteEditingViewController: UIViewController, UITextViewDelegate {
    
    private var dataStoreManager = DataStoreManager()
    var titleNote: String = ""
    var contentNote: String = ""
    var dateNote: Date = Date()
    var indexPath: IndexPath?
    var isOldNote = false
    var window = UIApplication.shared.windows[0]
    var popUpView: PopUpView!
          
    //Для определения сдвига popUpView
    var keyboardFrameSize: CGRect?
    
    //Для корректной работы textViewDidChange. Чтобы не сбрасывались пользовательские атрибуты
    var isAnyButtonPressed = false
    
    @IBOutlet var textNoteTextView: UITextView!

    //Нужен для передачи данных между контроллерами
    var noteData: ((_ contentNote: NSMutableAttributedString,_ dateCreateNote: Date, IndexPath?) -> Void)?

    
    //MARK: - Methods
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerForKeyboardNotification()
        dataStoreManager.configureFetchResultController()
        getTextForNote()
        textNoteTextView.delegate = self

        if #available(iOS 15.0, *) {
            textNoteTextView.keyboardDismissMode = .interactive
        } else {
            textNoteTextView.keyboardDismissMode = .onDrag
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func loadView() {
        super.loadView()
    
        popUpView = PopUpView(frame: .zero)
        
        view.addSubview(popUpView)
        popUpView.setupConstraintsPopUpView()
        
        popUpView.boldButton.addTarget(self, action: #selector(makesTheFontBold), for: .touchUpInside)
        popUpView.underlineButton.addTarget(self, action: #selector(makesTheFontUnderlined), for: .touchUpInside)
        popUpView.strikethroughButton.addTarget(self, action: #selector(makesTheFontStrikethrough), for: .touchUpInside)
        popUpView.italicButton.addTarget(self, action: #selector(makesTheFontItalic), for: .touchUpInside)
        popUpView.plusFontSizeButton.addTarget(self, action: #selector(increaseTheFontSize), for: .touchUpInside)
        popUpView.minusFontSizeButton.addTarget(self, action: #selector(reducineTheFontSize), for: .touchUpInside)
    }
    
    
    func registerForKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    
    @objc func keyboardWillShow(_ notification: Notification) {
        
        let userInfo = notification.userInfo
        keyboardFrameSize = (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        
        let contentShiftUp = (window.frame.height - (popUpView.frame.height * 2) - (keyboardFrameSize?.height ?? 0))
        textNoteTextView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: contentShiftUp, right: 0)
        
        popUpViewFollowTheKeyboardWhenShow()
        
    }
    
    func popUpViewFollowTheKeyboardWhenShow() {
        let bottomEdge = window.frame.height - popUpView.frame.height
        let heightKeyboardAndPopUpView = (keyboardFrameSize?.minY ?? bottomEdge) - popUpView.frame.height
        popUpView.frame.origin.y = heightKeyboardAndPopUpView
    }

    @objc func keyboardWillHide() {
        popUpView.frame.origin.y = window.frame.height - popUpView.frame.height
    }
    
    func getTextForNote() {
        if isOldNote, indexPath != nil {
            let note = dataStoreManager.fetchResultController.object(at: indexPath!)
            textNoteTextView.attributedText = note.content
        } else {
            textNoteTextView.text = ""
            addAttributesInTextView()
        }
    }
    
    @IBAction func saveNote(_ sender: UIBarButtonItem) {
        let dateCreate = Date()
        noteData?(NSMutableAttributedString.init(attributedString: textNoteTextView.attributedText), dateCreate, indexPath)
        navigationController?.popViewController(animated: true)
    }

//    Нужен для выделения заголовка - им является первый параграф заметки
    private func getNoteTitle(text: String) -> String {
        var firstParagraph: String
        if let endIndexOfFirstParagraph = text.firstIndex(of: "\n") {
            firstParagraph = String(text[..<endIndexOfFirstParagraph])
        } else {
            firstParagraph = text
        }
        return firstParagraph
    }
    
//    Нужен для выделения содержания - им является текст после первого параграфа заметки
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
    
    func addAttributesInTextView() {
        
        let textStorage = textNoteTextView.textStorage
        
        let fontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body)
        let boldFontDescriptor = fontDescriptor.withSymbolicTraits(.traitBold)
        
        let boldFont = UIFont(descriptor: boldFontDescriptor!, size: 24)
        let normalFont = UIFont(descriptor: fontDescriptor, size: 20)
        
        //Нужно для определения длинны первого параграфа и остальных параграфов
        let firstParagraph = textStorage.mutableString.paragraphRange(for: NSRange(location: 0, length: 0))
        let otherParagraphs = NSString(string: getNoteContent(text: textNoteTextView.text))
        
        let titleNoteParagraphStyle = NSMutableParagraphStyle()
        let contentNoteParagraphsStyle = NSMutableParagraphStyle()
                
        //Атрибуты заголовка заметки (Первый абзац)
        textStorage.addAttribute(NSAttributedString.Key.paragraphStyle, value: titleNoteParagraphStyle, range: firstParagraph)
        textStorage.addAttribute(NSAttributedString.Key.font, value: boldFont, range: firstParagraph)
        
        //Атрибуты содержания заметки (Текст начиная со второго абзаца)
        if textNoteTextView.text.contains("\n") {
            textStorage.addAttribute(NSAttributedString.Key.paragraphStyle, value: contentNoteParagraphsStyle, range: NSRange(location: firstParagraph.length - 1, length: otherParagraphs.length + 1))
            textStorage.addAttribute(NSAttributedString.Key.font, value: normalFont, range: NSRange(location: firstParagraph.length - 1, length: otherParagraphs.length + 1))
        }
    }
    
    @objc func increaseTheFontSize() {
        
        if textNoteTextView != nil {
            
            isAnyButtonPressed = true
            
            let selectedRange = textNoteTextView.selectedRange
            guard NSLocationInRange(selectedRange.location, selectedRange) else { return }
            
            //Определение аттрибутов выделенного текста
            let attributesOfSelectedRange = textNoteTextView.textStorage.attributes(at: selectedRange.location, longestEffectiveRange: nil, in: selectedRange)
            guard let fontOfSelectedRange = attributesOfSelectedRange[NSAttributedString.Key.font] as? UIFont else { return }
            
            let plusOne = fontOfSelectedRange.pointSize + 1
            let increaseFontSize = fontOfSelectedRange.withSize(plusOne)
            
            textNoteTextView.textStorage.addAttribute(NSAttributedString.Key.font, value: increaseFontSize, range: NSRange(location: selectedRange.location, length: selectedRange.length))
        }
    }
    
    @objc func reducineTheFontSize() {
        
        if textNoteTextView != nil {
            
            isAnyButtonPressed = true
            
            let selectedRange = textNoteTextView.selectedRange
            guard NSLocationInRange(selectedRange.location, selectedRange) else { return }
            
            //Определение аттрибутов выделенного текста
            let attributesOfSelectedRange = textNoteTextView.textStorage.attributes(at: selectedRange.location, longestEffectiveRange: nil, in: selectedRange)
            guard let fontOfSelectedRange = attributesOfSelectedRange[NSAttributedString.Key.font] as? UIFont else { return }
            
            let minusOne = fontOfSelectedRange.pointSize - 1
            let increaseFontSize = fontOfSelectedRange.withSize(minusOne)
            
            textNoteTextView.textStorage.addAttribute(NSAttributedString.Key.font, value: increaseFontSize, range: NSRange(location: selectedRange.location, length: selectedRange.length))
        }
    }
    
    @objc func makesTheFontBold() {
        
        if textNoteTextView != nil {
            
            isAnyButtonPressed = true
            
            let selectedRange = textNoteTextView.selectedRange
            let fontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body)
            let boldFontDescriptor = fontDescriptor.withSymbolicTraits(.traitBold)!
            let italicFontDescriptor = fontDescriptor.withSymbolicTraits(.traitItalic)!
            let italicBoldFontDescriptor = fontDescriptor.withSymbolicTraits(UIFontDescriptor.SymbolicTraits(arrayLiteral: .traitBold, .traitItalic))
            
            guard NSLocationInRange(selectedRange.location, selectedRange) else { return }
            
            //Определение аттрибутов выделенного текста
            let attributesOfSelectedRange = textNoteTextView.textStorage.attributes(at: selectedRange.location, longestEffectiveRange: nil, in: selectedRange)
            guard let fontOfSelectedRange = attributesOfSelectedRange[NSAttributedString.Key.font] as? UIFont else { return }
            let pointOfSizeSelectedFont = fontOfSelectedRange.pointSize
            let symbolicTraitsOfSelectedFont = fontOfSelectedRange.fontDescriptor.symbolicTraits
            
            let normalFont = UIFont(descriptor: fontDescriptor, size: pointOfSizeSelectedFont)
            let boldFont = UIFont(descriptor: boldFontDescriptor, size: pointOfSizeSelectedFont)
            let italicFont = UIFont(descriptor: italicFontDescriptor, size: pointOfSizeSelectedFont)
            let italicBoldFont = UIFont(descriptor: italicBoldFontDescriptor!, size: pointOfSizeSelectedFont)
            
            textNoteTextView.textStorage.addAttribute(NSAttributedString.Key.font, value: boldFont, range: NSRange(location: selectedRange.location, length: selectedRange.length))
            
            if symbolicTraitsOfSelectedFont == UIFontDescriptor.SymbolicTraits(arrayLiteral: .traitBold, .traitItalic) {
                textNoteTextView.textStorage.addAttribute(NSAttributedString.Key.font, value: italicFont, range: NSRange(location: selectedRange.location, length: selectedRange.length))
                popUpView.italicButton.backgroundColor = #colorLiteral(red: 1, green: 0.8323456645, blue: 0.4732058644, alpha: 1)
                popUpView.boldButton.backgroundColor = .white
                
            } else if symbolicTraitsOfSelectedFont == .traitItalic {
                textNoteTextView.textStorage.addAttribute(NSAttributedString.Key.font, value: italicBoldFont, range: NSRange(location: selectedRange.location, length: selectedRange.length))
                popUpView.boldButton.backgroundColor = #colorLiteral(red: 1, green: 0.8323456645, blue: 0.4732058644, alpha: 1)
                popUpView.italicButton.backgroundColor = #colorLiteral(red: 1, green: 0.8323456645, blue: 0.4732058644, alpha: 1)
                
            } else if symbolicTraitsOfSelectedFont == .traitBold {
                textNoteTextView.textStorage.addAttribute(NSAttributedString.Key.font, value: normalFont, range: NSRange(location: selectedRange.location, length: selectedRange.length))
                popUpView.boldButton.backgroundColor = .white
                
            } else {
                textNoteTextView.textStorage.addAttribute(NSAttributedString.Key.font, value: boldFont, range: NSRange(location: selectedRange.location, length: selectedRange.length))
                popUpView.boldButton.backgroundColor = #colorLiteral(red: 1, green: 0.8323456645, blue: 0.4732058644, alpha: 1)
            }
        }
    }
    
    @objc func makesTheFontStrikethrough() {
        
        if textNoteTextView != nil {
            
            isAnyButtonPressed = true
            
            let selectedRange = textNoteTextView.selectedRange
            let strikethroughAttributes = NSAttributedString.Key.strikethroughStyle
            
            guard NSLocationInRange(selectedRange.location, selectedRange) else { return }
            let attributesOfSelectedRange = textNoteTextView.textStorage.attributes(at: selectedRange.location, longestEffectiveRange: nil, in: selectedRange)
            
            let valueSymbolicTraitsOfSelectedRange = attributesOfSelectedRange[NSAttributedString.Key.strikethroughStyle] as? Int ?? 0

            if valueSymbolicTraitsOfSelectedRange == 1 {
                textNoteTextView.textStorage.addAttribute(strikethroughAttributes, value: 0, range: NSRange(location: selectedRange.location, length: selectedRange.length))
                popUpView.strikethroughButton.backgroundColor = .white
            } else {
                textNoteTextView.textStorage.addAttribute(strikethroughAttributes, value: 1, range: NSRange(location: selectedRange.location, length: selectedRange.length))
                popUpView.strikethroughButton.backgroundColor =  #colorLiteral(red: 1, green: 0.8323456645, blue: 0.4732058644, alpha: 1)
            }
        }
    }
    
    
    @objc func makesTheFontItalic() {
        
        if textNoteTextView != nil {
            
            isAnyButtonPressed = true
            
            let selectedRange = textNoteTextView.selectedRange
            let fontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body)
            let boldFontDescriptor = fontDescriptor.withSymbolicTraits(.traitBold)!
            let italicFontDescriptor = fontDescriptor.withSymbolicTraits(.traitItalic)!
            let italicBoldFontDescriptor = fontDescriptor.withSymbolicTraits(UIFontDescriptor.SymbolicTraits(arrayLiteral: .traitBold, .traitItalic))
            
            guard NSLocationInRange(selectedRange.location, selectedRange) else { return }
            let attributesOfSelectedRange = textNoteTextView.textStorage.attributes(at: selectedRange.location, longestEffectiveRange: nil, in: selectedRange)
            guard let fontOfSelectedRange = attributesOfSelectedRange[NSAttributedString.Key.font] as? UIFont else { return }
            let pointOfSizeSelectedFont = fontOfSelectedRange.pointSize
            let symbolicTraitsOfSelectedFont = fontOfSelectedRange.fontDescriptor.symbolicTraits
            
            let normalFont = UIFont(descriptor: fontDescriptor, size: pointOfSizeSelectedFont)
            let boldFont = UIFont(descriptor: boldFontDescriptor, size: pointOfSizeSelectedFont)
            let italicFont = UIFont(descriptor: italicFontDescriptor, size: pointOfSizeSelectedFont)
            let italicBoldFont = UIFont(descriptor: italicBoldFontDescriptor!, size: pointOfSizeSelectedFont)
            
            if symbolicTraitsOfSelectedFont == UIFontDescriptor.SymbolicTraits(arrayLiteral: .traitBold, .traitItalic) {
                textNoteTextView.textStorage.addAttribute(NSAttributedString.Key.font, value: boldFont, range: NSRange(location: selectedRange.location, length: selectedRange.length))
                popUpView.boldButton.backgroundColor = #colorLiteral(red: 1, green: 0.8323456645, blue: 0.4732058644, alpha: 1)
                popUpView.italicButton.backgroundColor = .white
                
            } else if symbolicTraitsOfSelectedFont == .traitItalic {
                textNoteTextView.textStorage.addAttribute(NSAttributedString.Key.font, value: normalFont, range: NSRange(location: selectedRange.location, length: selectedRange.length))
                popUpView.italicButton.backgroundColor = .white
                
            } else if symbolicTraitsOfSelectedFont == .traitBold {
                textNoteTextView.textStorage.addAttribute(NSAttributedString.Key.font, value: italicBoldFont, range: NSRange(location: selectedRange.location, length: selectedRange.length))
                popUpView.boldButton.backgroundColor = #colorLiteral(red: 1, green: 0.8323456645, blue: 0.4732058644, alpha: 1)
                popUpView.italicButton.backgroundColor = #colorLiteral(red: 1, green: 0.8323456645, blue: 0.4732058644, alpha: 1)
                
            } else {
                textNoteTextView.textStorage.addAttribute(NSAttributedString.Key.font, value: italicFont, range: NSRange(location: selectedRange.location, length: selectedRange.length))
                popUpView.italicButton.backgroundColor =  #colorLiteral(red: 1, green: 0.8323456645, blue: 0.4732058644, alpha: 1)
            }
        }
    }
    
    @objc func makesTheFontUnderlined() {
        
        if textNoteTextView != nil {
            
            isAnyButtonPressed = true

            let selectedRange = textNoteTextView.selectedRange
            let underlineAttributes = NSAttributedString.Key.underlineStyle
            
            guard NSLocationInRange(selectedRange.location, selectedRange) else { return }
            let attributesOfSelectedRange = textNoteTextView.textStorage.attributes(at: selectedRange.location, longestEffectiveRange: nil, in: selectedRange)

            let valueSymbolicTraitsOfSelectedRange = attributesOfSelectedRange[NSAttributedString.Key.underlineStyle] as? Int ?? 0
           
            if valueSymbolicTraitsOfSelectedRange == 1 {
                textNoteTextView.textStorage.addAttribute(underlineAttributes, value: 0, range: NSRange(location: selectedRange.location, length: selectedRange.length))
                popUpView.underlineButton.backgroundColor = .white
                
            } else {
                textNoteTextView.textStorage.addAttribute(underlineAttributes, value: 1, range: NSRange(location: selectedRange.location, length: selectedRange.length))
                popUpView.underlineButton.backgroundColor = #colorLiteral(red: 1, green: 0.8323456645, blue: 0.4732058644, alpha: 1)
            }
        }
    }
    
    //MARK: - UITextViewDelegate

    func textViewDidChange(_ textView: UITextView) {
        if !isAnyButtonPressed {
            addAttributesInTextView()
        }
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        let selectedRange = textNoteTextView.selectedRange
        var attributesOfSelectedRange = [NSAttributedString.Key : Any]()
        var fontOfSelectedRange = UIFont()
                
        let rangeText = NSRange(location: 0, length: textView.textStorage.length)
        guard NSLocationInRange(selectedRange.location - 1, rangeText) else { return }
        
        //Без этого условия не корректно отображает атрибуты при перемещении указателя / выделении участка текста
        if selectedRange.length == 0 {
            attributesOfSelectedRange = textNoteTextView.textStorage.attributes(at: selectedRange.location - 1, longestEffectiveRange: nil, in: selectedRange)
        } else {
            attributesOfSelectedRange = textNoteTextView.textStorage.attributes(at: selectedRange.location, longestEffectiveRange: nil, in: selectedRange)
        }
        
        let underlineStyle = attributesOfSelectedRange[NSAttributedString.Key.underlineStyle] as? Int ?? 0
        
        if underlineStyle == 1 {
            popUpView.underlineButton.backgroundColor = #colorLiteral(red: 1, green: 0.8323456645, blue: 0.4732058644, alpha: 1)
        } else {
            popUpView.underlineButton.backgroundColor = .white
        }
        
        
        let strikethroughStyle = attributesOfSelectedRange[NSAttributedString.Key.strikethroughStyle] as? Int ?? 0
        
        if strikethroughStyle == 1 {
            popUpView.strikethroughButton.backgroundColor = #colorLiteral(red: 1, green: 0.8323456645, blue: 0.4732058644, alpha: 1)
        } else {
            popUpView.strikethroughButton.backgroundColor = .white
        }
        
        fontOfSelectedRange = attributesOfSelectedRange[NSAttributedString.Key.font] as! UIFont
        let symbolicTraitsOfSelectedFont = fontOfSelectedRange.fontDescriptor.symbolicTraits
        
        if symbolicTraitsOfSelectedFont == UIFontDescriptor.SymbolicTraits(arrayLiteral: .traitBold, .traitItalic) {
            popUpView.boldButton.backgroundColor = #colorLiteral(red: 1, green: 0.8323456645, blue: 0.4732058644, alpha: 1)
            popUpView.italicButton.backgroundColor = #colorLiteral(red: 1, green: 0.8323456645, blue: 0.4732058644, alpha: 1)
            
        } else if symbolicTraitsOfSelectedFont == .traitItalic {
            popUpView.italicButton.backgroundColor = #colorLiteral(red: 1, green: 0.8323456645, blue: 0.4732058644, alpha: 1)
            popUpView.boldButton.backgroundColor = .white
            
        } else if symbolicTraitsOfSelectedFont == .traitBold {
            popUpView.boldButton.backgroundColor = #colorLiteral(red: 1, green: 0.8323456645, blue: 0.4732058644, alpha: 1)
            popUpView.italicButton.backgroundColor = .white
            
        } else {
            popUpView.boldButton.backgroundColor = .white
            popUpView.italicButton.backgroundColor = .white
        }
    }
}

    


