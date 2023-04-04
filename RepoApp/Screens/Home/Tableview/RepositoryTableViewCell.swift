import UIKit

class RepositoryTableViewCell: UITableViewCell {

    static let reuseIdentifier = "Cell"

    private let nameLabel = UILabel()
    private let favoriteButton = UIButton(type: .system)

    private let viewModel = RepositoryListViewModel()

    private var isFavorited = false {
        didSet {
            if #available(iOS 13.0, *) {
                let image = isFavorited ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")
                favoriteButton.setImage(image, for: .normal)
            } else {
                // Fallback on earlier versions
                let image = isFavorited ? UIImage(named: "heart_fill") : UIImage(named: "heart")
                favoriteButton.setImage(image, for: .normal)
            }

        }
    }

    var repository: Repository?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameLabel)
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
        ])

        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(favoriteButton)
        NSLayoutConstraint.activate([
            favoriteButton.widthAnchor.constraint(equalToConstant: 24),
            favoriteButton.heightAnchor.constraint(equalToConstant: 24),
            favoriteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            favoriteButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: favoriteButton.leadingAnchor, constant: -8)
        ])

        favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with repository: Repository) {
        self.repository = repository
        nameLabel.text = repository.name

        viewModel.getFavorites { result in
            switch result {
                case .success(let favorites):
                    let isFavorited = favorites.contains(where: { $0.name == repository.name && $0.is_favorited })
                    self.isFavorited = isFavorited
                case .failure(let error):
                    print("Failed to fetch favorites: \(error.localizedDescription)")
                    self.isFavorited = false
            }
        }

    }


    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        isFavorited = false
    }

    @objc private func favoriteButtonTapped() {
        guard let repository = repository else { return }
        isFavorited.toggle()
        if isFavorited {
            viewModel.addFavorite(repository: repository)
        } else {
            viewModel.removeFavorite(repository: repository)
        }
    }

}
