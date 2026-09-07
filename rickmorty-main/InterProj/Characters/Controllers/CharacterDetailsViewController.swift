//
//  CharacterDetailsViewController.swift
//  InterProj
//
//  Created by Andrei Lucacel on 12/07/2026.
//

import UIKit

final class CharacterDetailsViewController: UIViewController {
    
    private let character: Character
    private let episodeService = EpisodeService()
    private var episodes: [Episode] = []
    
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let episodesStack = UIStackView()
    private let episodesSpinner = UIActivityIndicatorView(style: .medium)
    
    init(character: Character) {
        self.character = character
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = character.name
        navigationItem.largeTitleDisplayMode = .never
        
        setupLayout()
        loadImage()
        loadEpisodes()
    }
        
    private func setupLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
        
        contentStack.addArrangedSubview(imageView)
        imageView.heightAnchor.constraint(equalToConstant: 260).isActive = true
        
        let nameLabel = UILabel()
        nameLabel.text = character.name
        nameLabel.font = .systemFont(ofSize: 28, weight: .bold)
        nameLabel.numberOfLines = 0
        contentStack.addArrangedSubview(wrapInHorizontalInset(nameLabel))
        
        let infoStack = UIStackView(arrangedSubviews: [
            makeInfoRow(title: "Species", value: character.species),
            makeSeparator(),
            makeInfoRow(title: "Gender", value: character.gender),
            makeSeparator(),
            makeInfoRow(title: "Origin", value: character.origin.name),
            makeSeparator(),
            makeInfoRow(title: "Location", value: character.location.name)
        ])
        infoStack.axis = .vertical
        infoStack.spacing = 12
        contentStack.addArrangedSubview(wrapInHorizontalInset(infoStack))
        
        let episodesHeader = UILabel()
        episodesHeader.text = "EPISODES"
        episodesHeader.font = .systemFont(ofSize: 13, weight: .semibold)
        episodesHeader.textColor = .secondaryLabel
        contentStack.addArrangedSubview(wrapInHorizontalInset(episodesHeader))
        
        let episodesScroll = UIScrollView()
        episodesScroll.showsHorizontalScrollIndicator = false
        episodesScroll.translatesAutoresizingMaskIntoConstraints = false
        
        episodesStack.axis = .horizontal
        episodesStack.spacing = 10
        episodesStack.translatesAutoresizingMaskIntoConstraints = false
        episodesScroll.addSubview(episodesStack)
        episodesScroll.addSubview(episodesSpinner)
        episodesSpinner.translatesAutoresizingMaskIntoConstraints = false
        
        contentStack.addArrangedSubview(episodesScroll)
        episodesScroll.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        NSLayoutConstraint.activate([
            episodesStack.topAnchor.constraint(equalTo: episodesScroll.contentLayoutGuide.topAnchor),
            episodesStack.bottomAnchor.constraint(equalTo: episodesScroll.contentLayoutGuide.bottomAnchor),
            episodesStack.leadingAnchor.constraint(equalTo: episodesScroll.contentLayoutGuide.leadingAnchor, constant: 16),
            episodesStack.trailingAnchor.constraint(equalTo: episodesScroll.contentLayoutGuide.trailingAnchor, constant: -16),
            episodesStack.heightAnchor.constraint(equalTo: episodesScroll.frameLayoutGuide.heightAnchor),
            
            episodesSpinner.leadingAnchor.constraint(equalTo: episodesScroll.frameLayoutGuide.leadingAnchor, constant: 16),
            episodesSpinner.centerYAnchor.constraint(equalTo: episodesScroll.frameLayoutGuide.centerYAnchor)
        ])
    }
    
    private var imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .secondarySystemBackground
        return iv
    }()
    
    private func wrapInHorizontalInset(_ view: UIView) -> UIView {
        let container = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: container.topAnchor),
            view.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            view.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16)
        ])
        return container
    }
    
    private func makeInfoRow(title: String, value: String) -> UIView {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 16)
        titleLabel.textColor = .secondaryLabel
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 16, weight: .medium)
        valueLabel.textColor = .label
        valueLabel.textAlignment = .right
        valueLabel.numberOfLines = 0
        
        let row = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        row.axis = .horizontal
        row.spacing = 12
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)
        return row
    }
    
    private func makeSeparator() -> UIView {
        let separator = UIView()
        separator.backgroundColor = .separator
        separator.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale).isActive = true
        return separator
    }
        
    private func loadImage() {
        Task { [weak self] in
            guard let self else { return }
            let image = await ImageService.shared.getImage(urlString: character.image)
            self.imageView.image = image
        }
    }
    
    private func loadEpisodes() {
        let ids = APIHelpers.ids(from: character.episode)
        guard !ids.isEmpty else { return }
        
        episodesSpinner.startAnimating()
        Task { [weak self] in
            guard let self else { return }
            do {
                self.episodes = try await episodeService.getEpisodes(ids: ids)
            } catch {
                self.episodes = []
            }
            self.episodesSpinner.stopAnimating()
            self.renderEpisodeChips()
        }
    }
    
    private func renderEpisodeChips() {
        for (index, episode) in episodes.enumerated() {
            let button = makeEpisodeChip(title: episode.episode, tag: index)
            episodesStack.addArrangedSubview(button)
        }
    }
    
    private func makeEpisodeChip(title: String, tag: Int) -> UIButton {
        var config = UIButton.Configuration.tinted()
        config.title = title
        config.cornerStyle = .medium
        config.baseForegroundColor = .systemBlue
        config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12)
        
        let button = UIButton(configuration: config)
        button.tag = tag
        button.addTarget(self, action: #selector(episodeChipTapped(_:)), for: .touchUpInside)
        return button
    }
    
    @objc private func episodeChipTapped(_ sender: UIButton) {
        guard episodes.indices.contains(sender.tag) else { return }
        let episode = episodes[sender.tag]
        let detailVC = EpisodeDetailsViewController(episode: episode)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
