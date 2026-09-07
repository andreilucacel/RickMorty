//
//  FilterViewController.swift
//  InterProj
//
//  Created by Andrei Lucacel on 12/07/2026.
//

import UIKit

final class FilterViewController: UIViewController {
    
    private let statusOptions: [(title: String, value: String)] = [
        ("Alive", "alive"),
        ("Dead", "dead"),
        ("Unknown", "unknown")
    ]
    
    private let genderOptions: [(title: String, value: String)] = [
        ("Male", "male"),
        ("Female", "female"),
        ("Genderless", "genderless"),
        ("Unknown", "unknown")
    ]
    
    private var filter: CharacterFilter
    
    var onFilterChanged: ((CharacterFilter) -> Void)
    
    private var statusButtons: [UIButton] = []
    private var genderButtons: [UIButton] = []
    
    init(filter: CharacterFilter, onFilterChanged: @escaping ((CharacterFilter) -> Void)) {
        self.filter = filter
        self.onFilterChanged = onFilterChanged
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Filter"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Reset",
            style: .plain,
            target: self,
            action: #selector(resetTapped)
        )
        
        setupLayout()
        updateSelection()
    }
    
    private func setupLayout() {
        let statusHeader = makeSectionLabel("STATUS")
        let statusRow = makeChipRow(options: statusOptions, into: &statusButtons)
        
        let genderHeader = makeSectionLabel("GENDER")
        let genderRow = makeChipRow(options: genderOptions, into: &genderButtons)
        
        let stack = UIStackView(arrangedSubviews: [
            statusHeader, statusRow, genderHeader, genderRow
        ])
        stack.axis = .vertical
        stack.spacing = 12
        stack.setCustomSpacing(24, after: statusRow)
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func makeSectionLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .secondaryLabel
        return label
    }
    
    private func makeChipRow(options: [(title: String, value: String)],
                             into store: inout [UIButton]) -> UIView {
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 10
        container.alignment = .leading
        
        var currentRow = makeHorizontalRow()
        container.addArrangedSubview(currentRow)
        var itemsInRow = 0
        let maxPerRow = 3
        
        for option in options {
            let button = makeChip(title: option.title, value: option.value)
            store.append(button)
            
            if itemsInRow == maxPerRow {
                currentRow = makeHorizontalRow()
                container.addArrangedSubview(currentRow)
                itemsInRow = 0
            }
            currentRow.addArrangedSubview(button)
            itemsInRow += 1
        }
        return container
    }
    
    private func makeHorizontalRow() -> UIStackView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 10
        row.alignment = .leading
        return row
    }
    
    private func makeChip(title: String, value: String) -> UIButton {
        var config = UIButton.Configuration.bordered()
        config.title = title
        config.cornerStyle = .capsule
        config.baseForegroundColor = .label
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
        
        let button = UIButton(configuration: config)
        button.accessibilityIdentifier = value
        button.addTarget(self, action: #selector(chipTapped(_:)), for: .touchUpInside)
        return button
    }
    
    @objc private func chipTapped(_ sender: UIButton) {
        guard let value = sender.accessibilityIdentifier else { return }
        
        if statusButtons.contains(sender) {
            filter.status = (filter.status == value) ? nil : value
        } else if genderButtons.contains(sender) {
            filter.gender = (filter.gender == value) ? nil : value
        }
        
        updateSelection()
        onFilterChanged(filter)
    }
    
    @objc private func resetTapped() {
        let alert = UIAlertController(
            title: "Reset Filters",
            message: "This will remove all applied filters. Do you want to continue?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Reset", style: .destructive) { [weak self] _ in
            guard let self else { return }
            self.filter = CharacterFilter()
            self.updateSelection()
            self.onFilterChanged(self.filter)
        })
        present(alert, animated: true)
    }
    
    private func updateSelection() {
        for button in statusButtons {
            applyStyle(button, selected: button.accessibilityIdentifier == filter.status)
        }
        for button in genderButtons {
            applyStyle(button, selected: button.accessibilityIdentifier == filter.gender)
        }
    }
    
    private func applyStyle(_ button: UIButton, selected: Bool) {
        var config = button.configuration
        config?.baseBackgroundColor = selected ? .systemBlue : .secondarySystemBackground
        config?.baseForegroundColor = selected ? .white : .label
        button.configuration = config
    }
}
