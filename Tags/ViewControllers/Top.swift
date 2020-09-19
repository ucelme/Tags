//
//  TagResultsViewController.swift
//  H#
//
//  Created by Dzmitry Veliaskevich on 12.03.20.
//  Copyright © 2020 Dzmitry Veliaskevich. All rights reserved.
//

import UIKit
import Alamofire
import Kanna

class Top: UIViewController {
    
    @IBOutlet weak var resultsTableView: UITableView!
    var instagramButton: UIBarButtonItem!
    
    public var unsafeTag: String?
    public var shouldShowBullets: Bool!
    
    private var tags: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrapeHTML()
    }
    
    @objc func openInstagram() {
        if let instagramURL = URL(string: "instagram://app") {
            UIApplication.shared.open(instagramURL)
        }
    }
    
    private func scrapeHTML() {
        let path = "https://top-hashtags.com/instagram/"
        if let url = URL(string: path) {
            Alamofire.request(url).responseString() { response in
                guard
                    response.result.isSuccess,
                    let html = response.result.value
                    else {
                        print("Failed to scrape HTML")
                        return
                }
                
                print("Scraped HTML Successfully")
                
                self.parse(html)
            }
        }
    }
    
    private func parse(_ html: String) {
        guard let doc = try? Kanna.HTML(html: html, encoding: .utf8) else {
            print("Failed to parse HTML")
            return
        }
        
//        print(html)
        
        for link in doc.css("div[class^='i-tag']") {
            let tagsString = (link.text?.trimmingCharacters(in: .whitespacesAndNewlines))!
            tags.append(tagsString)
            if tags.isEmpty {
                let alert = UIAlertController(title: "That didn't work", message: "Looks like the website didn't like that one. Please try later.", preferredStyle: .alert)
                let okay = UIAlertAction(title: "Okay", style: .destructive, handler: { action in
                    self.navigationController?.popToRootViewController(animated: true)
                })
                alert.addAction(okay)
                present(alert, animated: true, completion: nil)
            } else {
                resultsTableView.reloadData()
            }
        }
    }
    
}

extension Top: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tags.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.numberOfLines = 0
        let tagCollection = tags[indexPath.row]
        cell.textLabel?.text = tagCollection
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // MARK: - Add tags to clipboard
//        let tagCollection = tags[indexPath.row]
//        print(tagCollection)
//        let bullets = "\n.\n.\n.\n"
//        UIPasteboard.general.string = shouldShowBullets ? bullets + tagCollection : tagCollection
//        let alert = UIAlertController(title: "Copied!", message: "These tags are now on your clipboard!", preferredStyle: .alert)
//        let gotIt = UIAlertAction(title: "Got it", style: .default, handler: nil)
//        let openInstagram = UIAlertAction(title: "Open Instagram", style: UIAlertActionStyle.default) { action in
//            self.openInstagram()
//        }
//        alert.addAction(openInstagram)
//        alert.addAction(gotIt)
//        present(alert, animated: true, completion: nil)
        
        let cell: UITableViewCell = tableView.cellForRow(at: indexPath)!
        performSegue(withIdentifier: "ShowTags", sender: cell)
    }
    
       override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

       if segue.identifier == "ShowTags" {
       let controller = segue.destination as! TagResultsViewController
       if let indexPath = resultsTableView.indexPath(for: sender as! UITableViewCell) {
//       let replaced = tags[indexPath.row].replacingOccurrences(of: "#", with: "")
//       let result = replaced.components(separatedBy: " ")
       controller.unsafeTag = tags[indexPath.row].replacingOccurrences(of: "#", with: "")
       controller.shouldShowBullets = false
           }
       }
    }

}
