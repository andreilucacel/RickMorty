//
//  ViewController.swift
//  InterProj
//
//  Created by Andrei Lucacel on 17/06/2026.
//

import UIKit
import SwiftUI
final class CharactersViewController: UIViewController {
    
    private var characters: [Character] = []
    private let characterService = CharacterService()
    private let spinner = UIActivityIndicatorView(style: .large)
    private var nextPageURL: String?
    private var isLoading = false
    
    private var filter = CharacterFilter()
    private var searchText: String = ""
    private var searchWorkItem: DispatchWorkItem?
    
    private let searchBarView = SearchBarView()
    private var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupSearchBar()
        setupCollectionView()
        setupFilterButton()
        
        loadFirstPage()
    }
        
    private func setupSearchBar() {
        searchBarView.placeholder = "Search..."
        searchBarView.translatesAutoresizingMaskIntoConstraints = false
        searchBarView.onTextChange = { [weak self] text in
            self?.handleSearch(text)
        }
        view.addSubview(searchBarView)
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .onDrag
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(CharacterCell.self, forCellWithReuseIdentifier: CharacterCell.identifier)
        view.addSubview(collectionView)
        
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true
        view.addSubview(spinner)
        
        NSLayoutConstraint.activate([
            searchBarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchBarView.heightAnchor.constraint(equalToConstant: 56),
            
            collectionView.topAnchor.constraint(equalTo: searchBarView.bottomAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupFilterButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "slider.horizontal.3"),
            style: .plain,
            target: self,
            action: #selector(filterTapped)
        )
    }
        
    @objc private func filterTapped() {
        let filterVC = FilterViewController(filter: filter) { [weak self] newFilter in
            self?.filter = newFilter
            self?.loadFirstPage()
        }
//        filterVC.onFilterChanged = { [weak self] newFilter in
//            guard let self else { return }
//            self.filter = newFilter
//            self.loadFirstPage()
//        }
        
        let nav = UINavigationController(rootViewController: filterVC)
        nav.modalPresentationStyle = .pageSheet
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        present(nav, animated: true)
    }
    
    private func handleSearch(_ text: String) {
        searchText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        searchWorkItem?.cancel()
        let work = DispatchWorkItem { [weak self] in
            self?.loadFirstPage()
        }
        searchWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: work)
    }
        
    private func loadFirstPage() {
        isLoading = true
        Task { [weak self] in
            guard let self else { return }
            do {
                let response = try await characterService.getCharacters(
                    status: filter.status,
                    gender: filter.gender,
                    name: searchText
                )
                self.characters = response.results
                self.nextPageURL = response.info.next
            } catch {
                self.characters = []
                self.nextPageURL = nil
            }
            self.collectionView.reloadData()
            self.collectionView.setContentOffset(.zero, animated: false)
            self.isLoading = false
        }
    }
    
    private func loadNextPage() {
        guard let nextPageURL, !isLoading else { return }
        
        isLoading = true
        spinner.startAnimating()
        
        Task { [weak self] in
            guard let self else { return }
            do {
                let response = try await characterService.getCharacters(urlString: nextPageURL)
                self.nextPageURL = response.info.next
                self.characters.append(contentsOf: response.results)
                self.collectionView.reloadData()
            } catch {
                print(error.localizedDescription)
            }
            self.spinner.stopAnimating()
            self.isLoading = false
        }
    }
}

extension CharactersViewController: UICollectionViewDataSource {
    
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
}

extension CharactersViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let character = characters[indexPath.item]
        let detailVC = CharacterDetailsViewController(character: character)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        let threshold = scrollView.contentSize.height - scrollView.frame.size.height - 100
        if position > threshold {
            loadNextPage()
        }
    }
}


extension CharactersViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing: CGFloat = 12
        let insets: CGFloat = 12 * 2
        let width = (collectionView.bounds.width - insets - spacing) / 2
        return CGSize(width: floor(width), height: floor(width) + 70)
    }
}

#Preview {
    
}
