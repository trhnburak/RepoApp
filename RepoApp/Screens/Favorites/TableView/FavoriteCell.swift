//
//  FavoriteCell.swift
//  RepoApp
//
//  Created by Burak Turhan on 4.04.2023.
//

import UIKit

class FavoriteCell: UITableViewCell {

    // MARK: - Properties
    static let identifier = "FavoriteCell"

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let favoriteButton: UIButton = {
        let button = UIButton()

        if #available(iOS 13.0, *) {
            button.setImage(UIImage(systemName: "heart"), for: .normal)
        } else {
            // Fallback on earlier versions
            button.setImage(UIImage(named: "heart"), for: .normal)
        }

        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    var isFavorited: Bool = false {
        didSet {
            let imageName = isFavorited ? "heart.fill" : "heart"
            if #available(iOS 13.0, *) {
                let image = UIImage(systemName: imageName)
                favoriteButton.setImage(image, for: .normal)

            } else {
                let image = UIImage(named: imageName)
                favoriteButton.setImage(image, for: .normal)

            }

        }
    }

    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameLabel)
        contentView.addSubview(favoriteButton)

        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            favoriteButton.widthAnchor.constraint(equalToConstant: 24),
            favoriteButton.heightAnchor.constraint(equalToConstant: 24),
            favoriteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            favoriteButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: favoriteButton.leadingAnchor, constant: -8)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Actions
    func configure(with favorite: Favorite) {
        nameLabel.text = favorite.name
        isFavorited = favorite.is_favorited
    }
}
