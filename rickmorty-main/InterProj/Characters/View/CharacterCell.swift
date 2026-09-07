//
//  CustomCell.swift
//  InterProj
//
//  Created by Andrei Lucacel on 25/06/2026.
//
import UIKit
import SwiftUI

class CharacterCell: UICollectionViewCell {
    
    let characterImage = UIImageView()
    static let identifier = "cell"
    let nameLabel = UILabel()
    let statusLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(characterImage)
        contentView.addSubview(nameLabel)
        contentView.addSubview(statusLabel)
        
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true
        
        characterImage.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        
        nameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        NSLayoutConstraint.activate([
            characterImage.topAnchor.constraint(equalTo: topAnchor),
            characterImage.leadingAnchor.constraint(equalTo: leadingAnchor),
            characterImage.trailingAnchor.constraint(equalTo: trailingAnchor),
            characterImage.heightAnchor.constraint(equalToConstant: 150),
            
            nameLabel.topAnchor.constraint(equalTo: characterImage.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: statusLabel.leadingAnchor, constant: -8),
            
            statusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            statusLabel.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor)
            
        ])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(character: Character) {
        self.nameLabel.text = character.name
        self.statusLabel.text = character.status
        self.characterImage.image = nil
        
        Task { [weak self] in
            guard let self else { return }
            let image = await ImageService.shared.getImage(urlString: character.image)
            await MainActor.run { [weak self] in
                guard let self else { return }
                self.characterImage.image = image
            }
        }
    }
}

#Preview {
    let cell = CharacterCell(frame: CGRect(x: 0, y: 0, width: 180, height: 100))
    cell.setup(character: Character(
        id: 1,
        name: "Rick Sanchez asdasdasdas ",
        status: "Alive dasdsadasda",
        species: "Human",
        type: nil,
        gender: "Male",
        origin: LocationRef(name: "Earth (C-137)", url: ""),
        location: LocationRef(name: "Citadel of Ricks", url: ""),
        image: "https://rickandmortyapi.com/api/character/avatar/1.jpeg",
        episode: []
    ))
    return cell
}
