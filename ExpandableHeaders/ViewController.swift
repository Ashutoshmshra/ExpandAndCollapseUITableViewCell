
import UIKit
//import SwiftyJSON

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let kHeaderSectionTag: Int = 6900;

    @IBOutlet weak var tableView: UITableView!
    
    var expandedSectionHeaderNumber: Int = -1
    var expandedSectionHeader: UITableViewHeaderFooterView!
    var sectionItems: Array<Any> = []
     var sectionItemsFromAPI: Array<Any> = []
    var sectionNames: Array<Any> = []
    var sectionNamesFromApi: Array<String> = []
    var cellTitleFromApi = [String]()
    var cellDescriptionFromApi = [String]()
    var jsonData:Ornament?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView!.tableFooterView = UIView()
        tableView.register(UINib(nibName: "DetailTableViewCell", bundle: nil), forCellReuseIdentifier: "DetailTableViewCell")
        
       self.loadJson()
        
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Call json response

        func loadJson()  {
            guard let path = Bundle.main.path(forResource: "JSONFileData", ofType: "json") else { return }
            let url = URL(fileURLWithPath: path)
            
            do {
                let data = try Data(contentsOf: url)
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                print(json)
                
                guard let array = json as? [Any] else { return }
                
                for user in array {
                    guard let userDict = user as? [String: Any] else { return }
                    guard let userSubCategories = userDict["sub_category"] as? [Any] else { print("not an Array"); return }
                    
                    for user1 in userSubCategories {
                     guard let userSubDict = user1 as? [String: Any] else { return }
                        guard let userSubCategoriesTitle = userSubDict["name"] as? String else { print("not an String"); return }
                        
                        guard let userSubCategoriesDesc = userSubDict["display_name"] as? String else { print("not an String"); return }
                        cellDescriptionFromApi.append(userSubCategoriesDesc)
                        cellTitleFromApi.append(userSubCategoriesTitle)
                    }
                    
                    guard let name = userDict["name"] as? String else { return }
                    sectionItemsFromAPI.append(userSubCategories)
                    self.sectionNamesFromApi.append(name)
                    print("subCategory data is:--\(userSubCategories)")
                     print(" ")
                    print(name)
//                    print(companyName)
                    print(" ")
                  
                }
            }
            catch {
                print(error)
            }
            
            self.tableView.reloadData()
            
              print("Section name is :\(sectionNamesFromApi)")
              print("title name is :\(cellTitleFromApi)")
              print("Desc name is :\(cellDescriptionFromApi)")
        }


    // MARK: - Tableview Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if (sectionNamesFromApi.count) > 0 {
            tableView.backgroundView = nil
            return (sectionNamesFromApi.count)
        }
        
        else {
            let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height))
            messageLabel.text = "Retrieving data.\nPlease wait."
            messageLabel.numberOfLines = 0;
            messageLabel.textAlignment = .center;
            messageLabel.font = UIFont(name: "HelveticaNeue", size: 20.0)!
            messageLabel.sizeToFit()
            self.tableView.backgroundView = messageLabel;
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.expandedSectionHeaderNumber == section) {
            let arrayOfItems = self.sectionItemsFromAPI[section] as! NSArray
            return arrayOfItems.count;
        } else {
            return 0;
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (self.sectionNamesFromApi.count != 0) {
            return self.sectionNamesFromApi[section] as? String
        }
        return ""
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0;
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat{
        return 0;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableView.automaticDimension
        return 100
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        //recast your view as a UITableViewHeaderFooterView
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.contentView.backgroundColor = UIColor.colorWithHexString(hexStr: "#0075d4")
        header.textLabel?.textColor = UIColor.white
        
        if let viewWithTag = self.view.viewWithTag(kHeaderSectionTag + section) {
            viewWithTag.removeFromSuperview()
        }
        let headerFrame = self.view.frame.size
        let theImageView = UIImageView(frame: CGRect(x: headerFrame.width - 32, y: 13, width: 18, height: 18));
        theImageView.image = UIImage(named: "Chevron-Dn-Wht")
        theImageView.tag = kHeaderSectionTag + section
        header.addSubview(theImageView)
        
        // make headers touchable
        header.tag = section
        let headerTapGesture = UITapGestureRecognizer()
        headerTapGesture.addTarget(self, action: #selector(ViewController.sectionHeaderWasTouched(_:)))
        header.addGestureRecognizer(headerTapGesture)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetailTableViewCell", for: indexPath) as! DetailTableViewCell
        let section = self.sectionItemsFromAPI[indexPath.section] as! NSArray
        let nameDict = section[indexPath.row] as? NSDictionary
        if let nameData = nameDict?["name"], let DescData = nameDict?["display_name"]{
            cell.titleLabel?.text = nameData as? String
            cell.descriptionLabel?.text = DescData as? String
        }
        cell.textLabel?.textColor = UIColor.black
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Expand / Collapse Methods
    
    @objc func sectionHeaderWasTouched(_ sender: UITapGestureRecognizer) {
        let headerView = sender.view as! UITableViewHeaderFooterView
        let section    = headerView.tag
        let eImageView = headerView.viewWithTag(kHeaderSectionTag + section) as? UIImageView
        
        if (self.expandedSectionHeaderNumber == -1) {
            self.expandedSectionHeaderNumber = section
            tableViewExpandSection(section, imageView: eImageView!)
        } else {
            if (self.expandedSectionHeaderNumber == section) {
                tableViewCollapeSection(section, imageView: eImageView!)
            } else {
                let cImageView = self.view.viewWithTag(kHeaderSectionTag + self.expandedSectionHeaderNumber) as? UIImageView
                tableViewCollapeSection(self.expandedSectionHeaderNumber, imageView: cImageView!)
                tableViewExpandSection(section, imageView: eImageView!)
            }
        }
    }
    
    func tableViewCollapeSection(_ section: Int, imageView: UIImageView) {
        let sectionData = self.sectionItemsFromAPI[section] as! NSArray
        
        self.expandedSectionHeaderNumber = -1;
        if (sectionData.count == 0) {
            return;
        } else {
            UIView.animate(withDuration: 0.4, animations: {
                imageView.transform = CGAffineTransform(rotationAngle: (0.0 * CGFloat(Double.pi)) / 180.0)
            })
            var indexesPath = [IndexPath]()
            for i in 0 ..< sectionData.count {
                let index = IndexPath(row: i, section: section)
                indexesPath.append(index)
            }
            self.tableView!.beginUpdates()
            self.tableView!.deleteRows(at: indexesPath, with: UITableView.RowAnimation.fade)
            self.tableView!.endUpdates()
        }
    }
    
    func tableViewExpandSection(_ section: Int, imageView: UIImageView) {
        let sectionData = self.sectionItemsFromAPI[section] as! NSArray
        
        if (sectionData.count == 0) {
            self.expandedSectionHeaderNumber = -1;
            return;
        } else {
            UIView.animate(withDuration: 0.4, animations: {
                imageView.transform = CGAffineTransform(rotationAngle: (180.0 * CGFloat(Double.pi)) / 180.0)
            })
            var indexesPath = [IndexPath]()
            for i in 0 ..< sectionData.count {
                let index = IndexPath(row: i, section: section)
                indexesPath.append(index)
            }
            self.expandedSectionHeaderNumber = section
            self.tableView!.beginUpdates()
            self.tableView!.insertRows(at: indexesPath, with: UITableView.RowAnimation.fade)
            self.tableView!.endUpdates()
        }
    }

}
