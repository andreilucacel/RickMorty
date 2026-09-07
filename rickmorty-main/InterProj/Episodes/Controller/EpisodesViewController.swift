//
//  EpisodesViewController.swift
//  InterProj
//
//  Created by Andrei Lucacel on 12/07/2026.
//

import UIKit

final class EpisodesViewController: UIViewController {
    
    private var episodes: [Episode] = []
    private let episodeService = EpisodeService()
    private var nextPageURL: String?
    private var isLoading = false
    
    private var searchText: String = ""
    private var searchWorkItem: DispatchWorkItem?
    
    private let searchBarView = SearchBarView()
    private let tableView = UITableView()
    private let spinner = UIActivityIndicatorView(style: .medium)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupSearchBar()
        setupTableView()
        
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
    
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 72
        tableView.keyboardDismissMode = .onDrag
        tableView.register(EpisodeCell.self, forCellReuseIdentifier: EpisodeCell.identifier)
        
        spinner.hidesWhenStopped = true
        tableView.tableFooterView = spinner
        spinner.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 44)
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            searchBarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchBarView.heightAnchor.constraint(equalToConstant: 56),
            
            tableView.topAnchor.constraint(equalTo: searchBarView.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
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
                let response = try await episodeService.getEpisodes(name: searchText)
                self.episodes = response.results
                self.nextPageURL = response.info.next
            } catch {
                self.episodes = []
                self.nextPageURL = nil
            }
            self.tableView.reloadData()
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
                let response = try await episodeService.getEpisodes(urlString: nextPageURL)
                self.nextPageURL = response.info.next
                self.episodes.append(contentsOf: response.results)
                self.tableView.reloadData()
            } catch {
                print(error.localizedDescription)
            }
            self.spinner.stopAnimating()
            self.isLoading = false
        }
    }
}

extension EpisodesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: EpisodeCell.identifier,
            for: indexPath
        ) as! EpisodeCell
        cell.setup(episode: episodes[indexPath.row])
        return cell
    }
}


extension EpisodesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let episode = episodes[indexPath.row]
        let detailVC = EpisodeDetailsViewController(episode: episode)
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
