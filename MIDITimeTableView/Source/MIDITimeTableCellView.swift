//
//  MIDITimeTableCellView.swift
//  MIDITimeTableView
//
//  Created by Cem Olcay on 16.10.2017.
//  Copyright © 2017 cemolcay. All rights reserved.
//

import UIKit
import ALKit

/// Delegate functions to inform about editing or deleting cell.
public protocol MIDITimeTableCellViewDelegate: class {
  /// Informs about moving the cell with the pan gesture.
  ///
  /// - Parameters:
  ///   - midiTimeTableCellView: Cell that moving around.
  ///   - pan: Pan gesture that moves the cell.
  func midiTimeTableCellViewDidMove(_ midiTimeTableCellView: MIDITimeTableCellView, pan: UIPanGestureRecognizer)

  /// Informs about resizing the cell with the pan gesture.
  ///
  /// - Parameters:
  ///   - midiTimeTableCellView: Cell that resizing.
  ///   - pan: Pan gesture that resizes the cell.
  func midiTimeTableCellViewDidResize(_ midiTimeTableCellView: MIDITimeTableCellView, pan: UIPanGestureRecognizer)

  /// Informs about the cell is about to delete.
  ///
  /// - Parameter midiTimeTableCellView: Cell is going to delete.
  func midiTimeTableCellViewDidDelete(_ midiTimeTableCellView: MIDITimeTableCellView)
}

/// Base cell view that shows on `MIDITimeTableView`. Has abilitiy to move, resize and delete.
open class MIDITimeTableCellView: UIView {
  /// View that holds the pan gesture on right most side in the view to use in resizing cell.
  private var resizeView = UIView()
  /// Width constraint of resize view to be able to change its width ratio later.
  private var resizeViewWidthConstraint: NSLayoutConstraint?
  /// Inset from the rightmost side on the cell to capture resize gesture.
  public var resizePanThreshold: CGFloat = 10
  /// Delegate that informs about editing cell.
  public weak var delegate: MIDITimeTableCellViewDelegate?

  open override var canBecomeFirstResponder: Bool {
    return true
  }

  public override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }

  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonInit()
  }

  private func commonInit() {
    addSubview(resizeView)
    resizeView.translatesAutoresizingMaskIntoConstraints = false
    resizeView.pinRight(to: self)
    resizeView.fillVertical(to: self)
    resizeViewWidthConstraint = NSLayoutConstraint(
      item: resizeView,
      attribute: .width,
      relatedBy: .equal,
      toItem: nil,
      attribute: .notAnAttribute,
      multiplier: 1,
      constant: resizePanThreshold)
    resizeView.addConstraint(resizeViewWidthConstraint!)

    let moveGesture = UIPanGestureRecognizer(target: self, action: #selector(didMove(pan:)))
    addGestureRecognizer(moveGesture)

    let resizeGesture = UIPanGestureRecognizer(target: self, action: #selector(didResize(pan:)))
    resizeView.addGestureRecognizer(resizeGesture)

    let longPressGesure = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(longPress:)))
    addGestureRecognizer(longPressGesure)
  }

  open override func layoutSubviews() {
    super.layoutSubviews()
    resizeViewWidthConstraint?.constant = resizePanThreshold
  }

  @objc public func didMove(pan: UIPanGestureRecognizer) {
    delegate?.midiTimeTableCellViewDidMove(self, pan: pan)
  }

  @objc public func didResize(pan: UIPanGestureRecognizer) {
    delegate?.midiTimeTableCellViewDidResize(self, pan: pan)
  }

  @objc public func didLongPress(longPress: UILongPressGestureRecognizer) {
    guard let superview = superview else { return }
    becomeFirstResponder()

    let menu = UIMenuController.shared
    menu.menuItems = [
      UIMenuItem(
        title: NSLocalizedString("Delete", comment: "Delete button"),
        action: #selector(didPressDeleteButton))
    ]
    menu.arrowDirection = .up
    menu.setTargetRect(frame, in: superview)
    menu.setMenuVisible(true, animated: true)
  }

  @objc public func didPressDeleteButton() {
    UIMenuController.shared.setMenuVisible(false, animated: true)
    delegate?.midiTimeTableCellViewDidDelete(self)
  }
}
