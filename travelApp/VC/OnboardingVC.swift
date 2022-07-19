//
//  OnboardingViewController.swift
//  travelAppiOS
//
//  Created by Андрей Степанов on 03.07.2022.
//

import UIKit

class OnboardingVC: UIViewController {
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var onboardingCollectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var nextButton: UIButton!
    
    let titleArray = Config.OnboardingText.onboardingTitles
    let subtitleArray = Config.OnboardingText.onboardingSubtitles
    let imageArray = Config.OnboardingImages.imageArray
    override func viewDidLoad() {
        super.viewDidLoad()
        onboardingCollectionView.delegate = self
        onboardingCollectionView.dataSource = self
        setupUI()
    }
}

// MARK: IBActions
extension OnboardingVC {
    @IBAction func nextTapped(_ sender: UIButton) {
        if pageControl.page == 2 {
            performSegue(withIdentifier: Config.Segues.initialSettings, sender: self)
        } else {
            let nextPage = pageControl.page + 1
            showItem(at: nextPage)
        }
    }
    
    @IBAction func skipTapped(_ sender: UIButton) {
        showItem(at: 2)
    }
    
    @IBAction func pageChanged(_ sender: UIPageControl) {
        showItem(at: pageControl.currentPage)
    }
}

// MARK: Private functions

extension OnboardingVC {
    private func setupUI() {
        nextButton.layer.cornerRadius = Config.UIConstants.buttonCornerRadius
        self.navigationItem.hidesBackButton = true
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal

        onboardingCollectionView.collectionViewLayout = layout
    }
    
    private func hideSkip(_ bool: Bool) {
        UIView.animate(withDuration: 0.3) {
            self.skipButton.isHidden = bool
            self.skipButton.alpha = bool ? 0 : 1
            
            if bool {
                self.nextButton.setTitle("Let's get started!", for: .normal)
            } else {
                self.nextButton.setTitle("Next", for: .normal)                }
        }
    }
    private func showItem(at index: Int) {
        pageControl.page = index
        self.onboardingCollectionView.isPagingEnabled = false
        let indexPath = IndexPath(item: index, section: 0)
        onboardingCollectionView.scrollToItem(at: indexPath, at: [.centeredHorizontally, .centeredVertically], animated: true)
        self.onboardingCollectionView.isPagingEnabled = true
        hideSkip(index == 2)
    }
    private func normalize(input: CGFloat) -> CGFloat {
        let scale = UIScreen.main.bounds.width / 375.0
        return input * scale
    }
}

// MARK: DataSource

extension OnboardingVC: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return titleArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = onboardingCollectionView.dequeueReusableCell(withReuseIdentifier: "onboardingCell", for: indexPath) as! OnboardingCell
        cell.onboardingImageWidth.constant = normalize(input: 250)
        cell.onboardingImage.image = imageArray[indexPath.row]
        cell.titleLabel.text = titleArray[indexPath.row]
        cell.subtitleLabel.text = subtitleArray[indexPath.row]

        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: onboardingCollectionView.frame.width, height: onboardingCollectionView.frame.height)
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.size.width
        let page = Int(scrollView.contentOffset.x / pageWidth)
        pageControl.page = page
        hideSkip(page == 2)
    }
}
