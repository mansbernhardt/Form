//
//  SectionResusable.swift
//  Example
//
//  Created by Måns Bernhardt on 2019-03-01.
//  Copyright © 2018 iZettle. All rights reserved.
//

import UIKit
import Flow
import Form

extension UIViewController {
    func presentTableUsingKitAndSectionReusable(style: DynamicTableViewFormStyle) -> Disposable {
        displayableTitle = "TableKit and SectionReusable"
        let bag = DisposeBag()

        let tableKit = TableKit(table: table, style: style, bag: bag)
        bag += self.install(tableKit.view)

        bag += self.navigationItem.addItem(UIBarButtonItem(title: "Swap"), position: .right).onValue {
            swap(&table, &swapTable)
            tableKit.set(table)
        }

        return bag
    }

    func presentUsingCollectionKitAndSectionReusable() -> Disposable {
        displayableTitle = "CollectionKit and SectionReusable"
        let bag = DisposeBag()

        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: 100, height: 50)
        flowLayout.headerReferenceSize = CGSize(width: 200, height: 30)
        flowLayout.footerReferenceSize = CGSize(width: 200, height: 30)

        let collectionKit = CollectionKit(table: table, layout: flowLayout, bag: bag)
        collectionKit.view.backgroundColor = .white
        bag += self.install(collectionKit.view)

        bag += self.navigationItem.addItem(UIBarButtonItem(title: "Swap"), position: .right).onValue {
            swap(&table, &swapTable)
            collectionKit.set(table)
        }

        return bag
    }
}

struct Section: SectionReusable, Hashable {
    var header: String
    var footer: String
}

private var table = Table(sections: [(Section(header: "Header 1", footer: "Footer 1"), 0..<5), (Section(header: "Header 2", footer: "Footer 2"), 5..<10)])
private var swapTable = Table(sections: [(Section(header: "Header 1", footer: "Footer 1"), 0..<2), (Section(header: "Header 1b", footer: "Footer 1b"), 3..<7), (Section(header: "Header 2", footer: "Footer 2"), 7..<10)])

/// New additions to Form? Add to CollectionKit as well?

public protocol SectionReusable {
    associatedtype Header: Reusable
    associatedtype Footer: Reusable
    var header: Header { get }
    var footer: Footer { get }
}

public extension TableKit where Row: Reusable, Row.ReuseType: ViewRepresentable, Section: SectionReusable, Section.Header.ReuseType: ViewRepresentable, Section.Footer.ReuseType: ViewRepresentable {
    convenience init(table: Table = Table(), style: DynamicTableViewFormStyle = .default, view: UITableView? = nil, bag: DisposeBag) {
        self.init(table: table, style: style, view: view, bag: bag, headerForSection: { table, section in
            table.dequeueHeaderFooterView(forItem: section.header, style: style.header, formStyle: style.form)
        }, footerForSection: { table, section in
            table.dequeueHeaderFooterView(forItem: section.footer, style: style.footer, formStyle: style.form)
        }, cellForRow: { table, row in
            table.dequeueCell(forItem: row, style: style)
        })
    }
}

public extension CollectionKit where Row: Reusable, Row.ReuseType: ViewRepresentable, Section: SectionReusable, Section.Header.ReuseType: ViewRepresentable, Section.Footer.ReuseType: ViewRepresentable {
    convenience init(table: Table = Table(), layout: UICollectionViewLayout, bag: DisposeBag) {
        self.init(table: table, layout: layout, bag: bag) { collection, cell, index in
            return collection.dequeueCell(forItem: cell, at: IndexPath(row: index.row, section: index.section))
        }

        bag += self.dataSource.supplementaryElement(for: UICollectionElementKindSectionHeader).set { index in
            let section = self.table.sections[index.section].value
            return self.view.dequeueSupplementaryView(forItem: section.header, at: IndexPath(row: index.row, section: index.section))
        }

        bag += self.dataSource.supplementaryElement(for: UICollectionElementKindSectionFooter).set { index in
            let section = self.table.sections[index.section].value
            return self.view.dequeueSupplementaryView(forItem: section.footer, at: IndexPath(row: index.row, section: index.section))
        }
    }
}
