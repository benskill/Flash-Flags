//
//  GameVCTableExt.swift
//  CountryTrainer
//
//  Created by Ben Sullivan on 12/09/2016.
//  Copyright © 2016 Ben Sullivan. All rights reserved.
//

import UIKit

extension GameVC: UITableViewDelegate, UITableViewDataSource {
  
  // MARK: - TABLE VIEW
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    if indexPath.section == 0 {
      let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! GameCell
      
      cell.delegate = self
      cell.configureCell((game?.tracker.remainingCountries[(indexPath as NSIndexPath).row])!)
      
      return cell
      
    }
    let cell = tableView.dequeueReusableCell(withIdentifier: "gamePlaceholderCell", for: indexPath)
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    
    if let selectedIndex = tableView.indexPathForSelectedRow, selectedIndex == indexPath as IndexPath {
      
      if let cell = tableView.cellForRow(at: indexPath) as? GameCell {
        DispatchQueue.main.async {
          
          tableView.beginUpdates()
          tableView.deselectRow(at: indexPath as IndexPath, animated: true)
          cell.changeCellStatus(selected: false)
          tableView.endUpdates()
        }
      }
      
      return nil
    }
    
    return indexPath
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    if indexPath.section == 0 {
      selectedRow = indexPath
      let cell = tableView.cellForRow(at: indexPath) as! GameCell
      
      DispatchQueue.main.async {
        
        cell.changeCellStatus(selected: true)
        tableView.beginUpdates()
        tableView.endUpdates()
      }
    }
  }
  
  func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    
    if let cell = tableView.cellForRow(at: indexPath as IndexPath) as? GameCell {
      
      DispatchQueue.main.async {
        
        cell.changeCellStatus(selected: false)
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
        
      }
    }
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    if section == 0 {
      guard let game = game else { return 0 }
      
      return game.tracker.remainingCells.count
    }
    return 1
  }
  
}
