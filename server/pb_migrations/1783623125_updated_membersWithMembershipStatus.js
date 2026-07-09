/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_1952861926")

  // update collection data
  unmarshal({
    "viewQuery": "SELECT m.id, m.name, m.mobileNumber, m.photo, mm.endDate AS expirationDate, mm.status AS membershipStatus, mm.branch AS membershipBranch, mm.membership AS membershipId, IIF(mm.endDate IS NULL, 2, IIF(date(mm.endDate, '+8 hours') < date('now', '+8 hours'), 1, 0)) AS membershipSortTier, IIF(mm.endDate IS NULL, 9999999999, IIF(date(mm.endDate, '+8 hours') < date('now', '+8 hours'), 9999999999 - strftime('%s', date(mm.endDate, '+8 hours')), strftime('%s', date(mm.endDate, '+8 hours')))) AS membershipSortOrder FROM members m LEFT JOIN memberMemberships mm ON mm.member = m.id AND mm.id = (SELECT mm2.id FROM memberMemberships mm2 WHERE mm2.member = m.id ORDER BY CASE WHEN mm2.status = 'active' THEN 0 ELSE 1 END, mm2.endDate DESC LIMIT 1) WHERE m.isDeleted = false"
  }, collection)

  // remove field
  collection.fields.removeById("_clone_F19B")

  // remove field
  collection.fields.removeById("_clone_sXys")

  // remove field
  collection.fields.removeById("_clone_mWoc")

  // remove field
  collection.fields.removeById("_clone_R3CP")

  // remove field
  collection.fields.removeById("_clone_NprD")

  // remove field
  collection.fields.removeById("_clone_oS0Q")

  // remove field
  collection.fields.removeById("_clone_ukS1")

  // add field
  collection.fields.addAt(1, new Field({
    "autogeneratePattern": "",
    "help": "",
    "hidden": false,
    "id": "_clone_j22r",
    "max": 0,
    "min": 0,
    "name": "name",
    "pattern": "",
    "presentable": true,
    "primaryKey": false,
    "required": true,
    "system": false,
    "type": "text"
  }))

  // add field
  collection.fields.addAt(2, new Field({
    "autogeneratePattern": "",
    "help": "",
    "hidden": false,
    "id": "_clone_mwDi",
    "max": 0,
    "min": 0,
    "name": "mobileNumber",
    "pattern": "",
    "presentable": false,
    "primaryKey": false,
    "required": false,
    "system": false,
    "type": "text"
  }))

  // add field
  collection.fields.addAt(3, new Field({
    "help": "",
    "hidden": false,
    "id": "_clone_erBc",
    "maxSelect": 1,
    "maxSize": 0,
    "mimeTypes": [],
    "name": "photo",
    "presentable": false,
    "protected": false,
    "required": false,
    "system": false,
    "thumbs": [
      "100x100f",
      "200x200f"
    ],
    "type": "file"
  }))

  // add field
  collection.fields.addAt(4, new Field({
    "help": "",
    "hidden": false,
    "id": "_clone_wjOI",
    "max": "",
    "min": "",
    "name": "expirationDate",
    "presentable": false,
    "required": true,
    "system": false,
    "type": "date"
  }))

  // add field
  collection.fields.addAt(5, new Field({
    "help": "",
    "hidden": false,
    "id": "_clone_hB1y",
    "maxSelect": 1,
    "name": "membershipStatus",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "select",
    "values": [
      "active",
      "expired",
      "cancelled",
      "voided"
    ]
  }))

  // add field
  collection.fields.addAt(6, new Field({
    "cascadeDelete": false,
    "collectionId": "pbc_2358601297",
    "help": "",
    "hidden": false,
    "id": "_clone_l3CX",
    "maxSelect": 1,
    "minSelect": 0,
    "name": "membershipBranch",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "relation"
  }))

  // add field
  collection.fields.addAt(7, new Field({
    "cascadeDelete": false,
    "collectionId": "pbc_memberships01",
    "help": "",
    "hidden": false,
    "id": "_clone_DOLp",
    "maxSelect": 1,
    "minSelect": 0,
    "name": "membershipId",
    "presentable": false,
    "required": true,
    "system": false,
    "type": "relation"
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_1952861926")

  // update collection data
  unmarshal({
    "viewQuery": "SELECT m.id, m.name, m.mobileNumber, m.photo, mm.endDate AS expirationDate, mm.status AS membershipStatus, mm.branch AS membershipBranch, mm.membership AS membershipId, IIF(mm.endDate IS NULL, 2, IIF(date(mm.endDate, '+8 hours') < date('now', '+8 hours'), 1, 0)) AS membershipSortTier, IIF(mm.endDate IS NULL, 9999999999, strftime('%s', date(mm.endDate, '+8 hours'))) AS membershipSortOrder FROM members m LEFT JOIN memberMemberships mm ON mm.member = m.id AND mm.id = (SELECT mm2.id FROM memberMemberships mm2 WHERE mm2.member = m.id ORDER BY CASE WHEN mm2.status = 'active' THEN 0 ELSE 1 END, mm2.endDate DESC LIMIT 1) WHERE m.isDeleted = false"
  }, collection)

  // add field
  collection.fields.addAt(1, new Field({
    "autogeneratePattern": "",
    "help": "",
    "hidden": false,
    "id": "_clone_F19B",
    "max": 0,
    "min": 0,
    "name": "name",
    "pattern": "",
    "presentable": true,
    "primaryKey": false,
    "required": true,
    "system": false,
    "type": "text"
  }))

  // add field
  collection.fields.addAt(2, new Field({
    "autogeneratePattern": "",
    "help": "",
    "hidden": false,
    "id": "_clone_sXys",
    "max": 0,
    "min": 0,
    "name": "mobileNumber",
    "pattern": "",
    "presentable": false,
    "primaryKey": false,
    "required": false,
    "system": false,
    "type": "text"
  }))

  // add field
  collection.fields.addAt(3, new Field({
    "help": "",
    "hidden": false,
    "id": "_clone_mWoc",
    "maxSelect": 1,
    "maxSize": 0,
    "mimeTypes": [],
    "name": "photo",
    "presentable": false,
    "protected": false,
    "required": false,
    "system": false,
    "thumbs": [
      "100x100f",
      "200x200f"
    ],
    "type": "file"
  }))

  // add field
  collection.fields.addAt(4, new Field({
    "help": "",
    "hidden": false,
    "id": "_clone_R3CP",
    "max": "",
    "min": "",
    "name": "expirationDate",
    "presentable": false,
    "required": true,
    "system": false,
    "type": "date"
  }))

  // add field
  collection.fields.addAt(5, new Field({
    "help": "",
    "hidden": false,
    "id": "_clone_NprD",
    "maxSelect": 1,
    "name": "membershipStatus",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "select",
    "values": [
      "active",
      "expired",
      "cancelled",
      "voided"
    ]
  }))

  // add field
  collection.fields.addAt(6, new Field({
    "cascadeDelete": false,
    "collectionId": "pbc_2358601297",
    "help": "",
    "hidden": false,
    "id": "_clone_oS0Q",
    "maxSelect": 1,
    "minSelect": 0,
    "name": "membershipBranch",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "relation"
  }))

  // add field
  collection.fields.addAt(7, new Field({
    "cascadeDelete": false,
    "collectionId": "pbc_memberships01",
    "help": "",
    "hidden": false,
    "id": "_clone_ukS1",
    "maxSelect": 1,
    "minSelect": 0,
    "name": "membershipId",
    "presentable": false,
    "required": true,
    "system": false,
    "type": "relation"
  }))

  // remove field
  collection.fields.removeById("_clone_j22r")

  // remove field
  collection.fields.removeById("_clone_mwDi")

  // remove field
  collection.fields.removeById("_clone_erBc")

  // remove field
  collection.fields.removeById("_clone_wjOI")

  // remove field
  collection.fields.removeById("_clone_hB1y")

  // remove field
  collection.fields.removeById("_clone_l3CX")

  // remove field
  collection.fields.removeById("_clone_DOLp")

  return app.save(collection)
})
