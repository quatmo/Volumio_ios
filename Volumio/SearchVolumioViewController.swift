//
//  SearchVolumioViewController.swift
//  Volumio
//
//  Created by Federico Sintucci on 18/10/16.
//  Copyright © 2016 Federico Sintucci. All rights reserved.
//

import UIKit

class SearchVolumioViewController: UIViewController, NetServiceBrowserDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var searchResultTable: UITableView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textLabel: UILabel!
    
    let browser = NetServiceBrowser()
    var services : [NetService] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        localize()
        
        let logo = UIImage(named: "logo")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        SocketIOManager.sharedInstance.closeConnection()

        searchResultTable.delegate = self
        searchResultTable.dataSource = self
        searchResultTable.tableFooterView = UIView(frame: CGRect.zero)

        browser.delegate = self
        browserStartSearch()
    }

    @IBAction func refreshBrowser(_ sender: UIBarButtonItem) {
        browser.stop()
        browserStartSearch()
    }
    
    func tableView(_ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return services.count
    }
    
    func tableView(_ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "service", for: indexPath) as! SelectPlayerTableViewCell
        let service = services[indexPath.row]
        
        cell.playerName.text = service.name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        browser.stop()
        
        let selectedPlayer = services[indexPath.row]
        UserDefaults.standard.set(selectedPlayer.name, forKey: "selectedPlayer")
        
        SocketIOManager.sharedInstance.changeServer(server: selectedPlayer.name)
        if let top = UIApplication.shared.keyWindow?.rootViewController {
            top.dismiss(animated: true, completion: nil)
        }
    }
    
    func browserStartSearch() {
        services.removeAll()
        browser.searchForServices(ofType: "_Volumio._tcp", inDomain: "local.")
    }
    
    func netServiceBrowserWillSearch(_ browser: NetServiceBrowser) {
    }
    
    func netServiceBrowserDidStopSearch(_ browser: NetServiceBrowser) {
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser,
        didNotSearch errorDict: [String : NSNumber]
    ) {
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser,
        didFind service: NetService,
        moreComing: Bool
    ) {
        if !moreComing {
            services.removeAll()
        }
        services.append(service)
        DispatchQueue.main.async {
            self.searchResultTable.reloadData()
        }
    }
    
    @IBAction func closeButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Localization

extension SearchVolumioViewController {
    
    fileprivate func localize() {
        titleLabel.text = NSLocalizedString("SEARCH_VOLUMIO_TITLE",
            comment: "search volumio view title"
        )
        textLabel.text = NSLocalizedString("SEARCH_VOLUMIO_TEXT",
            comment: "search volumio view text"
        )
    }
    
}
