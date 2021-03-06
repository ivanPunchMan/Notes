//
//  PopUpView.swift
//  Notes
//
//  Created by Admin on 14.02.2022.
//


import UIKit

class PopUpView: UIView {
        
    override init(frame: CGRect) {
        super.init(frame: frame)
            
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = UIColor(red: 209/255, green: 212/255, blue: 214/255, alpha: 1)
                
        setupViews()
        setupConstraints()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Configuring and setup UI elements
    
    let flexibleSpaceBar: UIBarButtonItem = {
        let flexibleSpaceBar = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        return flexibleSpaceBar
    }()
    
    let plusFontSizeButton: UIButton = {
        let button = UIButton(type: .system)
        button.frame = .zero
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("", for: UIControl.State.normal)
        button.setImage(UIImage(named: "plus"), for: UIControl.State.normal)
        button.tintColor = .black
        button.backgroundColor = .white
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.clipsToBounds = true
        let borderColor: UIColor = .systemGray2
        button.layer.borderColor = borderColor.cgColor
        
        return button
    }()
    
    
    let minusFontSizeButton: UIButton = {
        let button = UIButton(type: .system)
        button.frame = .zero
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("", for: UIControl.State.normal)
        button.setImage(UIImage(named: "minus"), for: UIControl.State.normal)
        button.tintColor = .black
        button.backgroundColor = .white
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.clipsToBounds = true
        let borderColor: UIColor = .systemGray2
        button.layer.borderColor = borderColor.cgColor
        
        return button
    }()
    
    
    let boldButton: UIButton = {
        let button = UIButton(type: .system)
        button.frame = CGRect.zero
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("", for: UIControl.State.normal)
        button.setImage(UIImage(named: "bold"), for: UIControl.State.normal)
        button.tintColor = .black
        button.backgroundColor = .white
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.clipsToBounds = true
        let borderColor: UIColor = .systemGray2
        button.layer.borderColor = borderColor.cgColor
        
        return button
    }()
    
    let italicButton: UIButton = {
        let button = UIButton(type: .system)
        button.frame = CGRect.zero
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("", for: UIControl.State.normal)
        button.setImage(UIImage(named: "italic"), for: UIControl.State.normal)
        button.tintColor = .black
        button.backgroundColor = .white
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.clipsToBounds = true
        let borderColor: UIColor = .systemGray2
        button.layer.borderColor = borderColor.cgColor
        
        return button
    }()
    
    
    let underlineButton: UIButton = {
        let button = UIButton(type: .system)
        button.frame = CGRect.zero
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("", for: UIControl.State.normal)
        button.setImage(UIImage(named: "underline"), for: UIControl.State.normal)
        button.tintColor = .black
        button.backgroundColor = .white
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.clipsToBounds = true
        let borderColor: UIColor = .systemGray2
        button.layer.borderColor = borderColor.cgColor
        
        return button
    }()
    
    let strikethroughButton: UIButton = {
        let button = UIButton(type: .system)
        button.frame = CGRect.zero
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("", for: UIControl.State.normal)
        button.setImage(UIImage(named: "strikethrough"), for: UIControl.State.normal)
        button.tintColor = .black
        button.backgroundColor = .white
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.clipsToBounds = true
        let borderColor: UIColor = .systemGray2
        button.layer.borderColor = borderColor.cgColor
        
        return button
    }()
    
   
    
    //MARK: - Setup UI elements
    
    lazy var stackViewForFormattingText: UIStackView = {
        
        let stackView = UIStackView(arrangedSubviews: [boldButton, italicButton, underlineButton, strikethroughButton, plusFontSizeButton, minusFontSizeButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fill
        stackView.alignment = .fill
        
        return stackView
    }()
    
    func setupViews() {
        self.addSubview(stackViewForFormattingText)
    }
    
    
    //MARK: - Setup Constraints
    
    func setupConstraints() {
        setupConstraintsButtonsInStackViewFormattingText()
        setupConstraintsForStackViewFormatingText()
    }
    
    func setupConstraintsButtonsInStackViewFormattingText() {
        for button in stackViewForFormattingText.arrangedSubviews {
            button.widthAnchor.constraint(equalTo: boldButton.widthAnchor).isActive = true
            button.heightAnchor.constraint(equalToConstant: 35).isActive = true
        }
    }
    
    
    func setupConstraintsForStackViewFormatingText() {
        stackViewForFormattingText.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20).isActive = true
        stackViewForFormattingText.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -20).isActive = true
        stackViewForFormattingText.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -15).isActive = true
        stackViewForFormattingText.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
    }
    
    func setupConstraintsPopUpView() {
        
        guard let superview = superview else { return }
        
        self.centerXAnchor.constraint(equalTo: superview.centerXAnchor).isActive = true
        self.leftAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.leftAnchor).isActive = true
        self.rightAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.rightAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
    }
}
