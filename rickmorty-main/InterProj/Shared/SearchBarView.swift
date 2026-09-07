//
//  SearchBarView.swift
//  InterProj
//
//  Created by Andrei Lucacel on 12/07/2026.
//

import UIKit

final class SearchBarView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var onTextChange: ((String) -> Void)?
    
    var placeholder: String? {
        didSet { searchBar?.placeholder = placeholder }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("SearchBarView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Search..."
        searchBar.autocapitalizationType = .none
        searchBar.autocorrectionType = .no
    }
}

extension SearchBarView: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        onTextChange?(searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
