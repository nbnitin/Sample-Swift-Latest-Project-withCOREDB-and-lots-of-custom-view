//
//  MenuTableViewCell.swift
//  Aliyah Media
//
//  Created by Nitin Bhatia on 12/04/18.
//  Copyright © 2018 Nitin Bhatia. All rights reserved.
//

import UIKit

protocol subMenuCellDelegate {
    func cellSelected(row:Int)
}

class MenuTableViewCell: UITableViewCell,UITableViewDataSource,UITableViewDelegate {
    
    var dataArr:[String] = ["HOME","Hazard Tree","Cycle Trim","User Guide","About Us","Log Out"] //"Work Order"
    var imageArr:[String] = ["home","download","trim","guide","icon","logout-1"] //"work_order",
    var subMenuTable:UITableView?
    var delegate : subMenuCellDelegate!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style , reuseIdentifier: reuseIdentifier)
        
        setUpTable()
    }
    
   
    required init(coder aDecoder: NSCoder) {
       // fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)!
        setUpTable()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setUpTable()
    }
    
    func setUpTable(){
        subMenuTable = UITableView(frame: CGRect.zero, style:UITableView.Style.plain)
        subMenuTable?.delegate = self
        subMenuTable?.dataSource = self
        subMenuTable?.separatorColor = UIColor.white
        subMenuTable?.backgroundColor = UIColor.white
        subMenuTable?.tableFooterView = UIView()
        self.addSubview(subMenuTable!)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        subMenuTable?.frame = CGRect(x:0.2, y:0.3, width:self.bounds.size.width-5, height:self.bounds.size.height-5)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "cell")
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "cellID")
        }
        
        cell?.textLabel?.text = dataArr[indexPath.row]
        cell?.imageView?.image = UIImage(named: imageArr[indexPath.row])
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
        cell.textLabel?.textColor = UIColor.darkGray
        cell.selectionStyle = .none
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate.cellSelected(row: indexPath.row)
    }

}
