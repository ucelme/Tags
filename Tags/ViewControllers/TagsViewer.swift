//
//  ExampleUsingStoryboard.swift
//  Hashtags
//
//  Created by gottingoscar@gmail.com on 06/08/2018.
//  Copyright (c) 2018 gottingoscar@gmail.com. All rights reserved.
//

import UIKit
import Hashtags
import ScrollingContentViewController

fileprivate extension Selector {
    static let onEditingChanged = #selector(TagsViewer.editingChanged(_:))
}

class TagsViewer: ScrollingContentViewController {
    
    var tags = [String]()
    var favorites = [String]()
        
    struct Constants {
        static let minCharsForInput = 3
        static let maxCharsForInput = 30
    }

    @IBOutlet var count: UILabel!
    @IBOutlet weak var input: UITextField!
    @IBOutlet weak var hashtags: HashtagView!
    @IBOutlet weak var addButton: AddButton!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!

    @IBOutlet var copyTags: RoundButton!
    @IBOutlet var pasteTags: RoundButton!
    @IBOutlet var addToFavorites: RoundButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hashtags.delegate = self
        self.input.delegate = self
        self.input.addTarget(self, action: Selector.onEditingChanged, for: .editingChanged)
        self.addButton.setClickable(false)
                
        let hashTagArray = tags.map { HashTag(word: $0) }
        
        self.hashtags.addTags(tags: hashTagArray)
                
        count.text = "\(tags.count) / 30"
        
        if tags.count > 30 {
            count.textColor = .red
        } else {
            count.textColor = .black
        }

        copyTags.layer.cornerRadius = 30
        copyTags.setTitleColor(.black, for: .normal)
        copyTags.titleLabel!.font = UIFont(name: Fonts.circeBold, size: 22)
        copyTags.titleLabel!.textAlignment = .center
        copyTags.backgroundColor = .white
        copyTags.setShadowOpacity(0.14)
        copyTags.setShadowColor(.gray)
        copyTags.setShadowRadius(12)

        pasteTags.layer.cornerRadius = 30
        pasteTags.setTitleColor(.black, for: .normal)
        pasteTags.titleLabel!.font = UIFont(name: Fonts.circeBold, size: 22)
        pasteTags.titleLabel!.textAlignment = .center
        pasteTags.backgroundColor = .white
        pasteTags.setShadowOpacity(0.14)
        pasteTags.setShadowColor(.gray)
        pasteTags.setShadowRadius(12)

        addToFavorites.layer.cornerRadius = 30
        addToFavorites.setTitleColor(.black, for: .normal)
        addToFavorites.titleLabel!.font = UIFont(name: Fonts.circeBold, size: 22)
        addToFavorites.titleLabel!.textAlignment = .center
        addToFavorites.backgroundColor = .white
        addToFavorites.setShadowOpacity(0.14)
        addToFavorites.setShadowColor(.gray)
        addToFavorites.setShadowRadius(12)
        
    }

    @IBAction func copyTags(_ sender: Any) {

        if !UserDefaults.standard.bool(forKey: "purchased") {
                  let storyboard = UIStoryboard(name: "Main", bundle: nil)
                  let controller = storyboard.instantiateViewController(withIdentifier: "Upgrade")
                self.navigationController?.pushViewController(controller, animated: true)
        } else {
        let temp = tags.map { "#" + $0 }
            UIPasteboard.general.string = temp.joined(separator:" ")
                    let alert = UIAlertController(title: "Copied!", message: "These tags are now on your clipboard!", preferredStyle: .alert)
                    let gotIt = UIAlertAction(title: "Got it", style: .default, handler: nil)
                    let openInstagram = UIAlertAction(title: "Open Instagram", style: UIAlertActionStyle.default) { action in
                        self.openInstagram()
                    }
                    alert.addAction(openInstagram)
                    alert.addAction(gotIt)
                    present(alert, animated: true, completion: nil)
        }
    }

    @IBAction func pasteTags(_ sender: Any) {
        let paste = UIPasteboard.general.string
            let replaced = paste!.replacingOccurrences(of: "#", with: "")
            let result = replaced.components(separatedBy: " ")
            let hashTagArray = result.map { HashTag(word: $0) }
            self.hashtags.addTags(tags: hashTagArray)
            tags += result
            print(tags)
            count.text = "\(tags.count) / 30"
            saveChecklistItems()

            if tags.count > 30 {
                count.textColor = .red
            } else {
                count.textColor = .black
            }

    }

    @IBAction func addToFavorites(_ sender: Any) {
        let temp = tags.map { "#" + $0 }
        favorites.append(temp.joined(separator:" "))
        saveChecklistItems()
        showMessage("Added to Favorites")

    }


    override func viewWillAppear(_ animated: Bool) {
        loadChecklistItems()
    }
    

    @objc func openInstagram() {
        if let instagramURL = URL(string: "instagram://app") {
            UIApplication.shared.open(instagramURL)
        }
    }

    
    @IBAction func onAddHashtag(_ sender: Any) {
        guard let text = self.input.text else {
            return
        }
        let hashtag = HashTag(word: text, isRemovable: true)
        self.hashtags.addTag(tag: hashtag)
        tags.append(text)
        count.text = "\(tags.count) / 30"
        
        self.input.text = ""
        self.addButton.setClickable(false)
                
        if tags.count > 30 {
            count.textColor = .red
        } else {
            count.textColor = .black
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

extension TagsViewer: HashtagViewDelegate {
    
    func hashtagRemoved(hashtag: HashTag) {
        print(hashtag.text + " Removed!")
        hashtag.text.remove(at: hashtag.text.startIndex)
        tags.removeAll { $0 == hashtag.text }
        count.text = "\(tags.count) / 30"
        
        if tags.count > 30 {
            count.textColor = .red
        } else {
            count.textColor = .black
        }

    }
    
    func viewShouldResizeTo(size: CGSize) {
        self.heightConstraint.constant = size.height
        
        UIView.animate(withDuration: 0.4) {
            self.view.layoutIfNeeded()
        }
    }
}

extension TagsViewer: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text else {
            return false
        }
        if text.count >= Constants.minCharsForInput {
            onAddHashtag(textField)
            return true
        }
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentCharacterCount = textField.text?.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + string.count - range.length
        return newLength <= Constants.maxCharsForInput
    }
    
    @objc
    func editingChanged(_ textField: UITextField) {
        guard let text = textField.text else {
            return
        }
        if text.count >= Constants.minCharsForInput {
            self.addButton.setClickable(true)
        } else {
            self.addButton.setClickable(false)
        }
    }
}

extension TagsViewer {
    
    private func showMessage(_ message: String) {
        let label = UILabel()
        label.text = message
        label.sizeToFit()
        label.font = UIFont(name: "AvenirNext-DemiBold", size: 20)
        label.frame.size = CGSize(width: label.frame.width + 100, height: 70)
        label.backgroundColor = .black
        label.textColor = .white
        label.textAlignment = .center
        label.center = self.view.center
        view.addSubview(label)
        label.alpha = 0
        label.clipsToBounds = true
        label.layer.cornerRadius = label.frame.height/2
        UIView.animate(withDuration: 0.2, animations: { label.alpha = 1 }) { _ in
            UIView.animate(withDuration: 0.2, delay: 1.0, options: [], animations: { label.alpha = 0 }) { _ in
                label.removeFromSuperview()
            }
        }
    }
}
