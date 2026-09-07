//
//  EpisodeCell.swift
//  InterProj
//
//  Created by Andrei Lucacel on 12/07/2026.
//

import UIKit
import SwiftUI

final class EpisodeCell: UITableViewCell {
    
    static let identifier = "EpisodeCell"
    
    private let codeLabel: UILabel = {
        let codeLabel = UILabel()
        codeLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        codeLabel.textColor = .systemBlue
        codeLabel.translatesAutoresizingMaskIntoConstraints = false
        return codeLabel
    }()
    private let nameLabel = UILabel()
    private let dateLabel = UILabel()
    private let codeContainer = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        accessoryType = .disclosureIndicator
        
        codeContainer.backgroundColor = .secondarySystemBackground
        codeContainer.layer.cornerRadius = 6
        codeContainer.translatesAutoresizingMaskIntoConstraints = false
        
      
        codeContainer.addSubview(codeLabel)
        
        nameLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        nameLabel.numberOfLines = 0
        
        dateLabel.font = .systemFont(ofSize: 14)
        dateLabel.textColor = .secondaryLabel
        
        let textStack = UIStackView(arrangedSubviews: [nameLabel, dateLabel])
        textStack.axis = .vertical
        textStack.spacing = 2
        
        let mainStack = UIStackView(arrangedSubviews: [codeContainer, textStack])
        mainStack.axis = .horizontal
        mainStack.spacing = 12
        mainStack.alignment = .center
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            codeLabel.topAnchor.constraint(equalTo: codeContainer.topAnchor, constant: 4),
            codeLabel.bottomAnchor.constraint(equalTo: codeContainer.bottomAnchor, constant: -4),
//            codeLabel.leadingAnchor.constraint(equalTo: codeContainer.leadingAnchor, constant: 8),
//            codeLabel.trailingAnchor.constraint(equalTo: codeContainer.trailingAnchor, constant: -8),
            codeContainer.widthAnchor.constraint(equalToConstant: 60),
            codeLabel.centerXAnchor.constraint(equalTo: codeContainer.centerXAnchor),
            codeContainer.topAnchor.constraint(equalTo: textStack.topAnchor, constant: 4),
            codeContainer.bottomAnchor.constraint(equalTo: textStack.bottomAnchor , constant: -4),
            //            codeContainer.centerYAnchor.constraint(equalTo: text)
            
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
        

    }
    
    func setup(episode: Episode) {
        codeLabel.text = episode.episode
        nameLabel.text = episode.name
        dateLabel.text = episode.airDate
    }
}


#Preview {
    let episodeCell = EpisodeCell(style: .default, reuseIdentifier: "2")
    episodeCell.setup(episode: Episode(id: 2, name: "3", airDate: "air_date", episode: "S012", characters: ["Rick", "Morthy"]))
    return episodeCell
}
