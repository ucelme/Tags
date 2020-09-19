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
import StoreKit

class Favorites: UIViewController {
    
    @IBOutlet weak var resultsTableView: UITableView!
    var instagramButton: UIBarButtonItem!
    
    var unsafeTag: String?
    var shouldShowBullets: Bool!
    
    var tags: [String] = []
    var favorites = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let tag = unsafeTag {
            scrapeHTML(from: tag)
            title = "#" + tag
        }
        
//        print(tags[0])
        
        resultsTableView.dragInteractionEnabled = true
        resultsTableView.dragDelegate = self
        resultsTableView.dropDelegate = self
        
        UserDefaults.standard.set(1, forKey: "countRating")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadChecklistItems()
        resultsTableView.reloadData()
        
        let countRating = UserDefaults.standard.integer(forKey: "countRating")
        if countRating % 10 == 0 {
            UserDefaults.standard.set(1, forKey: "countRating")
            if #available(iOS 10.3, *) {
                SKStoreReviewController.requestReview()
            } else {
                // Fallback on earlier versions
            }
        } else {
            UserDefaults.standard.set(countRating + 1, forKey: "countRating")
        }

//        if !UserDefaults.standard.bool(forKey: "purchased") {
//              let refreshAlert = UIAlertController(title: "Favorites", message: "Upgrade to Premium to get acess to favorites.", preferredStyle: UIAlertController.Style.alert)
//              refreshAlert.addAction(UIAlertAction(title: "Upgrade", style: .default, handler: { (action: UIAlertAction!) in
//                  let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                  let controller = storyboard.instantiateViewController(withIdentifier: "Upgrade")
//                self.navigationController?.pushViewController(controller, animated: true)
//                self.view.endEditing(true)
//
//              }))
//              refreshAlert.addAction(UIAlertAction(title: "No, thanks", style: .cancel, handler: { (action: UIAlertAction!) in
//                  let buy = self.storyboard!.instantiateViewController(withIdentifier: "Main") as! UITabBarController
//                  self.present(buy, animated:true, completion:nil)
//              }))
//              present(refreshAlert, animated: true, completion: nil)
//          }

    }
    
    @objc func openInstagram() {
        if let instagramURL = URL(string: "instagram://app") {
            UIApplication.shared.open(instagramURL)
        }
    }
    
    private func scrapeHTML(from tag: String) {
        let path = "https://top-hashtags.com/hashtag/\(tag)/"
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
        
        for i in 1...20 {
            for tagCollection in doc.css("#clip-tags-\(i)") {
                guard
                    let tagsString = tagCollection.text?.trimmingCharacters(in: .whitespacesAndNewlines)
                    else {
                        print("Could not trim characters or tagsString is Nil")
                        return
                }
                
                tags.append(tagsString)
            }
        }
        if tags.isEmpty {
            let alert = UIAlertController(title: "That didn't work", message: "Looks like the website didn't like that one. Please try a different tag.", preferredStyle: .alert)
            let okay = UIAlertAction(title: "Okay", style: .destructive, handler: { action in
                self.navigationController?.popToRootViewController(animated: true)
            })
            alert.addAction(okay)
            present(alert, animated: true, completion: nil)
        } else {
            resultsTableView.reloadData()
        }
    }
    
    // MARK: - Save and Load

    func documentsDirectory() -> URL {
      let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
      return paths[0]
    }
    
    func dataFilePath() -> URL {
      return documentsDirectory().appendingPathComponent("Favorites.plist")
    }
    
    func saveChecklistItems() {
      let encoder = PropertyListEncoder()
      do {
        let data = try encoder.encode(favorites)
        try data.write(to: dataFilePath(), options: Data.WritingOptions.atomic)
      } catch {
        print("Error encoding item array!")
      }
    }
    
    func loadChecklistItems() {
      let path = dataFilePath()
      if let data = try? Data(contentsOf: path) {
        let decoder = PropertyListDecoder()
        do {
          favorites = try decoder.decode([String].self, from: data)
        } catch {
          print("Error decoding item array!")
        }
      }
    }
}

extension Favorites: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favorites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.numberOfLines = 0
        let tagCollection = favorites[indexPath.row]
        cell.textLabel?.text = tagCollection
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            
            favorites.remove(at: indexPath.row)
            let indexPaths = [indexPath]
            tableView.deleteRows(at: indexPaths, with: .automatic)
            saveChecklistItems()
        }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        let movedObject = favorites[sourceIndexPath.row]
        favorites.remove(at: sourceIndexPath.row)
        favorites.insert(movedObject, at: destinationIndexPath.row)
        saveChecklistItems()
        tableView.reloadData()
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
        performSegue(withIdentifier: "Viewer", sender: cell)
    }
    
       override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

       if segue.identifier == "Viewer" {
       let controller = segue.destination as! TagsViewer
       if let indexPath = resultsTableView.indexPath(for: sender as! UITableViewCell) {
       let replaced = favorites[indexPath.row].replacingOccurrences(of: "#", with: "")
       let result = replaced.components(separatedBy: " ")
        print(result)
       controller.tags = result
           }
       }
    }

}

extension Favorites: UITableViewDragDelegate {
func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return [UIDragItem(itemProvider: NSItemProvider())]
    }
}

extension Favorites: UITableViewDropDelegate {
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {

        if session.localDragSession != nil {
            return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }

        return UITableViewDropProposal(operation: .cancel, intent: .unspecified)
    }

    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
    }
}
