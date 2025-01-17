//
//  NewsDetailViewController.swift
//  DailyFeed
//
//

import UIKit
import SafariServices
import RealmSwift

class NewsDetailViewController: UIViewController, SFSafariViewControllerDelegate, UIViewControllerTransitioningDelegate {
    
    // MARK: - Variable declaration
    
    var receivedNewsItem: DailyFeedRealmModel?
    
    var receivedNewsSource: String?
    
    var articleStringURL: String?
    
    var receivedItemNumber: Int?
    
    var isLanguageRightToLeftDetailView: Bool = false
    
    // MARK: - IBOutlets
    @IBOutlet weak var newsImageView: TSImageView! {
        didSet {
            newsImageView.layer.masksToBounds = true
            guard let imageURL = receivedNewsItem?.urlToImage else { return }
            newsImageView.downloadedFromLink(imageURL)
        }
    }
    
    @IBOutlet weak var newsTitleLabel: UILabel! {
        didSet {
            newsTitleLabel.text = receivedNewsItem?.title
            newsTitleLabel.alpha = 0.0
            if isLanguageRightToLeftDetailView {
                newsTitleLabel.textAlignment = .right
            } else {
                newsTitleLabel.textAlignment = .left
            }
        }
    }
    
    @IBOutlet weak var contentTextView: UITextView! {
        didSet {
            contentTextView.text = receivedNewsItem?.articleDescription
            contentTextView.alpha = 0.0
            contentTextView.font = UIFont.preferredFont(forTextStyle: .subheadline)
            contentTextView.sizeToFit()
            if isLanguageRightToLeftDetailView {
                contentTextView.textAlignment = .right
            } else {
                contentTextView.textAlignment = .left
            }
        }
    }
    
    @IBOutlet weak var newsAuthorLabel: UILabel! {
        didSet {
            newsAuthorLabel.text = receivedNewsItem?.author
            newsAuthorLabel.alpha = 0.0
            if isLanguageRightToLeftDetailView {
                newsAuthorLabel.textAlignment = .right
            } else {
                newsAuthorLabel.textAlignment = .left
            }
        }
    }
    
    @IBOutlet weak var backButton: UIButton! {
        didSet {
            backButton.layer.shadowColor = UIColor.black.cgColor
            backButton.layer.shadowRadius = 2.0
            backButton.layer.shadowOpacity = 1.0
            backButton.layer.shadowOffset = CGSize(width: 0, height: 1)
        }
    }
    
    @IBOutlet weak var shareButton: UIButton! {
        didSet {
            shareButton.layer.shadowColor = UIColor.black.cgColor
            shareButton.layer.shadowRadius = 2.0
            shareButton.layer.shadowOpacity = 1.0
            shareButton.layer.shadowOffset = CGSize(width: 0, height: 1)
        }
    }
    
    @IBOutlet weak var swipeLeftButton: UIButton! {
        didSet {
            swipeLeftButton.layer.cornerRadius = 10.0
            swipeLeftButton.setTitle("Open full text", for: .normal)
            switch Reach().connectionStatus() {
            case .unknown, .offline:
                swipeLeftButton.isEnabled = false
                swipeLeftButton.backgroundColor = .lightGray
                
            case .online(_):
                swipeLeftButton.isEnabled = true
            }
        }
    }
    
    @IBOutlet weak var newsSourceLabel: UILabel! {
        didSet {
            newsSourceLabel.text = receivedNewsSource
        }
    }
    
    @IBOutlet weak var newsItemNumberLabel: UILabel! {
        didSet {
            guard let newsItemNumber = receivedItemNumber else { return }
            newsItemNumberLabel.text = String(newsItemNumber)
            newsItemNumberLabel.alpha = 1.0
            newsItemNumberLabel.clipsToBounds = true
            newsItemNumberLabel.layer.cornerRadius = 5.0
        }
    }
    
    
    // MARK: - View Controller Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        //Hide Nav bar
        navigationController?.setNavigationBarHidden(true, animated: true)
        // Setting the newsImageView gradient
        newsImageView.addGradient([UIColor(white: 0, alpha: 0.6).cgColor, UIColor.clear.cgColor,
                                   UIColor(white: 0, alpha: 0.6).cgColor],
                                  locations: [0.0, 0.05, 0.85])
        
        //Setting articleStringURL for state restoration
        articleStringURL = receivedNewsItem?.url
        
        if #available(iOS 11.0, *) {
            let dragInteraction = UIDragInteraction(delegate: self)
            dragInteraction.isEnabled = true
            newsImageView.addInteraction(dragInteraction)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        newsTitleLabel.center.y += 20
        newsAuthorLabel.center.y += 20
        contentTextView.center.y += 20
        
        UIView.animate(withDuration: 0.07, delay: 0.0, options: .curveEaseIn, animations: {
            self.newsTitleLabel.alpha = 1.0
            self.newsTitleLabel.center.y -= 20
            self.newsAuthorLabel.alpha = 1.0
            self.newsAuthorLabel.center.y -= 20
            self.newsItemNumberLabel.alpha = 1.0
        })
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseIn, animations: {
            self.contentTextView.center.y -= 20
            self.contentTextView.alpha = 1.0
        })
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
    }
    
    // MARK: - Status Bar Color
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - Back Button Dismiss action
    @IBAction func dismissButtonTapped() {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Back dismiss swipe
    @IBAction func swipeToDismiss(_ sender: UISwipeGestureRecognizer) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - share article
    @IBAction func shareArticle(_ sender: UIButton) {
        let delay = DispatchTime.now() + 0.11
        DispatchQueue.main.asyncAfter(deadline: delay) {
            guard let articleToBookmarkData = self.receivedNewsItem else {return}
            let realm = try! Realm()
            try! realm.write {
                realm.add(articleToBookmarkData, update: .all)
                self.showErrorWithDelay("Added to Favourites Successfully!")
            }
            
        }
    }
    
    
    @IBAction func openArticleInSafari(_ sender: UIButton) {
        openInSafari()
    }
    
    // Helper method to open articles in Safari
    func openInSafari() {
        guard let articleString = articleStringURL, let url = URL(string: articleString) else { return }
        let svc = DFSafariViewController(url: url)
        svc.delegate = self
        self.present(svc, animated: true, completion: nil)
    }
}

@available(iOS 11.0, *)
extension NewsDetailViewController: UIDragInteractionDelegate {
    
    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        guard let image = newsImageView.image else { return [] }
        let provider = NSItemProvider(object: image)
        let item = UIDragItem(itemProvider: provider)
        return [item]
    }
    
}
