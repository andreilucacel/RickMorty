//
//  TabBar.swift
//  InterProj
//
//  Created by Andrei Lucacel on 23/06/2026.
//

import UIKit

final class TabBar: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
    }
    
    private func setupTabs() {
        let charactersVC = CharactersViewController()
        charactersVC.title = "Characters"
        let charactersNav = UINavigationController(rootViewController: charactersVC)
        charactersNav.navigationBar.prefersLargeTitles = true
        charactersNav.tabBarItem = UITabBarItem(
            title: "Characters",
            image: UIImage(systemName: "person.circle"),
            selectedImage: UIImage(systemName: "person.circle.fill")
        )
        
        let episodesVC = EpisodesViewController()
        episodesVC.title = "Episodes"
        let episodesNav = UINavigationController(rootViewController: episodesVC)
        episodesNav.navigationBar.prefersLargeTitles = true
        episodesNav.tabBarItem = UITabBarItem(
            title: "Episodes",
            image: UIImage(systemName: "tv"),
            selectedImage: UIImage(systemName: "tv.fill")
        )
        
        viewControllers = [charactersNav, episodesNav]
    }
}
