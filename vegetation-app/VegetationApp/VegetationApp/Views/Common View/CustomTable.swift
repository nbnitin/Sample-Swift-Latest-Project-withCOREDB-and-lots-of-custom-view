//
//  CustomTable.swift
//  VegetationApp
//
//  Created by Nitin Bhatia on 17/05/19.
//  Copyright © 2019 Nitin Bhatia. All rights reserved.
//

import UIKit
import SDWebImage

protocol CustomTableProtocol {
    func valueSelected(obj:PopUpPickers)
}

class CustomTable:UIView,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate {
    
    //variable
    var data : [[String:Any]] = [[:]]
    var isApiSet : Bool = false
    var selectedIndex : Int = -1
    var filterData : [[String:Any]] = [[:]]
    var selectedId : Int = -1
    var selectedTextBoxObj : PopUpPickers!
    var oldSelectedIndexInStarting : IndexPath!
    var customTableDelegate : CustomTableProtocol!
    
    //outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var navigationView: Navigation!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    
    @IBInspectable
    //newValue is default setter property defined in swift...
    var EntityName: String = "" {
        didSet{
            let mcd = MasterDataController()
            data = mcd.getData(entityName: EntityName)
            filterData = data
            tableView.reloadData()
            selectedId = selectedTextBoxObj.selectedId
           
            if ( filterData.count > 0 && selectedId > -1 ) {
                guard  let indexFound = filterData.firstIndex(where: {$0["id"] as! Int == selectedId}) else {return}
                let indexPathToScroll = IndexPath(row:indexFound , section: 0)
                tableView.scrollToRow(at: indexPathToScroll, at: .top, animated: true)
            }
        }
    }
    
    func getData()->Any{
        
        return ""
    }
    
   
    
    @objc func btnRightAction(_ sender:UIButton){
        
        if ( selectedIndex > -1 ) {
            selectedTextBoxObj.selectedId = filterData[selectedIndex]["id"] as? Int
            selectedTextBoxObj.selectedName = filterData[selectedIndex]["name"] as? String
            selectedTextBoxObj.text = filterData[selectedIndex]["name"] as? String
        }
        self.customTableDelegate.valueSelected(obj: self.selectedTextBoxObj)
        self.removeFromSuperview()
    }
    
    @objc func btnLeftAction(_ sender:UIButton){
        self.removeFromSuperview()
    }
    
   
    
    //tableView delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
       
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
       
        
        if let image = filterData[indexPath.row]["image"] as? String {
            let img = UIImageView(frame: CGRect(x:20,y:9,width:50,height:50))
            img.sd_setImage(with: URL(string:image), completed: nil)
            img.layer.borderWidth = 1.0
            img.layer.masksToBounds = false
            img.layer.borderColor = UIColor.white.cgColor
            img.layer.cornerRadius = img.frame.size.width / 2
            img.clipsToBounds = true
            cell.contentView.addSubview(img)
            let label = UILabel(frame:CGRect(x:20 + 8 + 50,y:50/2,width:cell.frame.width - 28,height:21))
            label.text = filterData[indexPath.row]["name"] as? String ?? ""
            cell.contentView.addSubview(label)
            
        } else {
            cell.textLabel!.text = filterData[indexPath.row]["name"] as? String ?? ""
        }
        
        
        if ( filterData[indexPath.row]["id"] as! Int == selectedId  ) {
            self.selectedIndex = indexPath.row
            cell.accessoryType = .checkmark
            oldSelectedIndexInStarting = indexPath
        } else {
            cell.accessoryType = .none
            self.selectedIndex = -1
        }
        
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if ( oldSelectedIndexInStarting != nil ) {
            tableView.cellForRow(at: oldSelectedIndexInStarting)?.accessoryType = .none
        }
        
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        self.selectedIndex = indexPath.row
        navigationView.btnRight.isEnabled = true
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
        selectedIndex = -1
        navigationView.btnRight.isEnabled = false
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let image = filterData[indexPath.row]["image"] as? String {
            return 70.0
        }
        return UITableView.automaticDimension
    }
    
    //Mark:- searchbar delegates
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if ( searchText != "" ) {
            filterData = data.filter({($0["name"] as! String).contains(searchText)})
        } else {
            filterData = data
        }
        tableView.reloadData()
        
    }
    
    
    private func commonInit(){
        let view = Bundle.main.loadNibNamed("CustomTable", owner: self, options: nil)?[0] as! UIView
        addSubview(view)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight,.flexibleWidth,.flexibleTopMargin]
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        navigationView.btnMenu.setImage(UIImage(named:"ico"), for: .normal)
        navigationView.btnRight.setTitle("Done", for: .normal)
        navigationView.btnRight.addTarget(self, action: #selector(btnRightAction(_:)), for: .touchUpInside)
        navigationView.btnMenu.addTarget(self, action: #selector(btnLeftAction(_:)), for: .touchUpInside)
        tableView.tableFooterView = UIView()
        navigationView.btnRight.isEnabled = false
        
        
    }

}
