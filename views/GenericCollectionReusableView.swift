//
//  GenericCollectionReusableView.swift
//  ComposableDataSource
//
//  Created by Chrishon Wyllie on 7/8/20.
//

import UIKit

// This class is the superclass for other UICollectionReusableViews
// Just cast the `item` to the necessary ViewModel
protocol GenericCollectionReusableViewProtocol: ConfigurableReusableSupplementaryView {
    var containerView: UIView { get set }
    func setContentViewPadding(padding: UIEdgeInsets)
    func setupUIElements()
}
class GenericCollectionReusableView: UICollectionReusableView, GenericCollectionReusableViewProtocol {
    typealias T = GenericSupplementaryModel
    func configure(with item: GenericSupplementaryModel, at indexPath: IndexPath) {}
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUIElements()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    public var containerView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    public func setContentViewPadding(padding: UIEdgeInsets) {
        containerView.removeAllConstraints()
        containerView.anchor(leading:     leadingAnchor,
                             top:         topAnchor,
                             trailing:    trailingAnchor,
                             bottom:      bottomAnchor,
                             centerX:     nil,
                             centerY:     nil,
                             padding:     padding,
                             size:        .zero)
    }
    
    open func setupUIElements() {
        addSubview(containerView)
        containerView.anchor(to: self)
    }
}












// MARK: - UIView
// Creates common functions to handle NSLayoutConstraints easier as well as some shadowing/gradients

extension UIView {
    
    func anchor(to view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    func anchorWithSafeLayouts(to view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
    
    // provide default values if none passed in
    func anchor(leading: NSLayoutXAxisAnchor?, top: NSLayoutYAxisAnchor?, trailing: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, centerX: NSLayoutXAxisAnchor?, centerY: NSLayoutYAxisAnchor?, padding: UIEdgeInsets = .zero, size: CGSize = .zero) {
        
//        self.removeAllConstraints()
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let leading = leading {
            leadingAnchor.constraint(equalTo: leading, constant: padding.left).isActive = true
        }
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: padding.top).isActive = true
        }
        if let trailing = trailing {
            trailingAnchor.constraint(equalTo: trailing, constant: -padding.right).isActive = true
        }
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -padding.bottom).isActive = true
        }
        if let centerX = centerX {
            centerXAnchor.constraint(equalTo: centerX).isActive = true
        }
        if let centerY = centerY {
            centerYAnchor.constraint(equalTo: centerY).isActive = true
        }
        
        if size.width != 0 {
            widthAnchor.constraint(equalToConstant: size.width).isActive = true
        }
        
        if size.height != 0 {
            heightAnchor.constraint(equalToConstant: size.height).isActive = true
        }
        
    }
    
    func addConstraintsWithFormat(_ format: String, views: UIView...) {
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            view.translatesAutoresizingMaskIntoConstraints = false
            viewsDictionary[key] = view
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: viewsDictionary))
    }
    
    func removeAllConstraints() {
        guard let superview = self.superview else { return }
        for constraint: NSLayoutConstraint in superview.constraints {
            if constraint.firstItem as? UIView == self || constraint.secondItem as? UIView == self {
                superview.removeConstraint(constraint)
            }
        }
        
        translatesAutoresizingMaskIntoConstraints = true
    }
}
