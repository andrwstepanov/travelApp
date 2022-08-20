//
//  Cell.swift
//  TablePlayground
//
//  Created by Андрей Степанов on 17.05.2022.
//

import UIKit

class PacklistCell: UITableViewCell {
    @IBOutlet weak var cellLabel: UILabel!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var dotsButton: UIButton!
    @IBOutlet weak var cellBackground: UIView!
    @IBOutlet weak var quantityLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        cellBackground.layer.cornerRadius = 15
        self.dotsButton.menu = cellMenu
        self.dotsButton.showsMenuAsPrimaryAction = true
        let checkImage = UIImage(systemName: "checkmark.square.fill")?.withTintColor(Config.Colors.darkGreen).withRenderingMode(.alwaysOriginal)
        checkButton.setImage(checkImage, for: .selected)
    }
    let cellMenu = UIMenu(title: "", children: [
        UIAction(title: "Edit", image: UIImage(systemName: "square.and.pencil")) {_ in },
        UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) {_ in }
    ])
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
