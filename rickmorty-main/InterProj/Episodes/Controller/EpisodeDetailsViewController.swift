//
//  EpisodeDetailsViewController.swift
//  InterProj
//
//  Created by Andrei Lucacel on 12/07/2026.
//

import UIKit

final class EpisodeDetailsViewController: UIViewController {
    
    private let episode: Episode
    private let characterService = CharacterService()
    private var characters: [Character] = []
    
    private let spinner = UIActivityIndicatorView(style: .large)
    private var collectionView: UICollectionView!
    
    init(episode: Episode) {
        self.episode = episode
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = episode.episode
        navigationItem.largeTitleDisplayMode = .never
        
        setupCollectionView()
        loadCharacters()
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        layout.headerReferenceSize = CGSize(width: view.bounds.width, height: 180)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(CharacterCell.self, forCellWithReuseIdentifier: CharacterCell.identifier)
        collectionView.register(
            EpisodeDetailHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: EpisodeDetailHeaderView.identifier
        )
        view.addSubview(collectionView)
        
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true
        view.addSubview(spinner)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func loadCharacters() {
        let ids = APIHelpers.ids(from: episode.characters)
        guard !ids.isEmpty else { return }
        
        spinner.startAnimating()
        Task { [weak self] in
            guard let self else { return }
            do {
                self.characters = try await characterService.getCharacters(ids: ids)
            } catch {
                self.characters = []
            }
            self.spinner.stopAnimating()
            self.collectionView.reloadData()
        }
    }
}

extension EpisodeDetailsViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return characters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CharacterCell.identifier,
            for: indexPath
        ) as! CharacterCell
        cell.setup(character: characters[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: EpisodeDetailHeaderView.identifier,
            for: indexPath
        ) as! EpisodeDetailHeaderView
        header.configure(with: episode)
        return header
    }
}

extension EpisodeDetailsViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let character = characters[indexPath.item]
        let detailVC = CharacterDetailsViewController(character: character)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

extension EpisodeDetailsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing: CGFloat = 12
        let insets: CGFloat = 12 * 2
        let width = (collectionView.bounds.width - insets - spacing) / 2
        return CGSize(width: floor(width), height: floor(width) + 70)
    }
}

private final class EpisodeDetailHeaderView: UICollectionReusableView {
    
    static let identifier = "EpisodeDetailHeaderView"
    
    private let codeLabel = UILabel()
    private let codeContainer = UIView()
    private let nameLabel = UILabel()
    private let dateLabel = UILabel()
    private let charactersHeader = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        codeContainer.backgroundColor = .secondarySystemBackground
        codeContainer.layer.cornerRadius = 6
        codeContainer.translatesAutoresizingMaskIntoConstraints = false
        
        codeLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        codeLabel.textColor = .systemBlue
        codeLabel.translatesAutoresizingMaskIntoConstraints = false
        codeContainer.addSubview(codeLabel)
        
        let codeRow = UIStackView(arrangedSubviews: [codeContainer, UIView()])
        codeRow.axis = .horizontal
        
        nameLabel.font = .systemFont(ofSize: 26, weight: .bold)
        nameLabel.numberOfLines = 0
        
        dateLabel.font = .systemFont(ofSize: 15)
        dateLabel.textColor = .secondaryLabel
        
        charactersHeader.text = "CHARACTERS"
        charactersHeader.font = .systemFont(ofSize: 13, weight: .semibold)
        charactersHeader.textColor = .secondaryLabel
        
        let stack = UIStackView(arrangedSubviews: [codeRow, nameLabel, dateLabel, charactersHeader])
        stack.axis = .vertical
        stack.spacing = 8
        stack.setCustomSpacing(20, after: dateLabel)
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        
        NSLayoutConstraint.activate([
            codeLabel.topAnchor.constraint(equalTo: codeContainer.topAnchor, constant: 4),
            codeLabel.bottomAnchor.constraint(equalTo: codeContainer.bottomAnchor, constant: -4),
            codeLabel.leadingAnchor.constraint(equalTo: codeContainer.leadingAnchor, constant: 8),
            codeLabel.trailingAnchor.constraint(equalTo: codeContainer.trailingAnchor, constant: -8),
            
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -8)
        ])
    }
    
    func configure(with episode: Episode) {
        codeLabel.text = episode.episode
        nameLabel.text = episode.name
        dateLabel.text = episode.airDate
    }
}
