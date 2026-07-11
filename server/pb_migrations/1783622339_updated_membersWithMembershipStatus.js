/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_1952861926")

  // update collection data
  unmarshal({
    "viewQuery": "SELECT m.id, m.name, m.mobileNumber, m.photo, mm.endDate AS membershipEndDate, mm.status AS membershipStatus, mm.branch AS membershipBranch, mm.membership AS membershipId, IIF(mm.endDate IS NULL, 2, IIF(date(mm.endDate, '+8 hours') < date('now', '+8 hours'), 1, 0)) AS membershipSortTier, IIF(mm.endDate IS NULL, 9999999999, ABS(strftime('%s', date(mm.endDate, '+8 hours')) - strftime('%s', date('now', '+8 hours')))) AS membershipSortOrder FROM members m LEFT JOIN memberMemberships mm ON mm.member = m.id AND mm.id = (SELECT mm2.id FROM memberMemberships mm2 WHERE mm2.member = m.id ORDER BY mm2.endDate DESC LIMIT 1) WHERE m.isDeleted = false"
  }, collection)

  // remove field
  collection.fields.removeById("_clone_mFGP")

  // remove field
  collection.fields.removeById("_clone_fkDu")

  // remove field
  collection.fields.removeById("_clone_joPQ")

  // remove field
  collection.fields.removeById("_clone_95ml")

  // remove field
  collection.fields.removeById("_clone_HFBM")

  // remove field
  collection.fields.removeById("_clone_nAHB")

  // remove field
  collection.fields.removeById("_clone_Ktbl")

  // add field
  collection.fields.addAt(1, new Field({
    "autogeneratePattern": "",
    "help": "",
    "hidden": false,
    "id": "_clone_UjKo",
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
    "id": "_clone_vZuj",
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
    "id": "_clone_ifmx",
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
    "id": "_clone_WpxM",
    "max": "",
    "min": "",
    "name": "membershipEndDate",
    "presentable": false,
    "required": true,
    "system": false,
    "type": "date"
  }))

  // add field
  collection.fields.addAt(5, new Field({
    "help": "",
    "hidden": false,
    "id": "_clone_q8J6",
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
    "id": "_clone_p3fh",
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
    "id": "_clone_BMAo",
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
    "viewQuery": "SELECT m.id, m.name, m.mobileNumber, m.photo, mm.endDate AS membershipEndDate, mm.status AS membershipStatus, mm.branch AS membershipBranch, mm.membership AS membershipId, IIF(mm.endDate IS NULL, 2, IIF(date(mm.endDate) < date('now'), 1, 0)) AS membershipSortTier, IIF(mm.endDate IS NULL, 9999999999, ABS(strftime('%s', date(mm.endDate)) - strftime('%s', date('now')))) AS membershipSortOrder FROM members m LEFT JOIN memberMemberships mm ON mm.member = m.id AND mm.id = (SELECT mm2.id FROM memberMemberships mm2 WHERE mm2.member = m.id ORDER BY mm2.endDate DESC LIMIT 1) WHERE m.isDeleted = false"
  }, collection)

  // add field
  collection.fields.addAt(1, new Field({
    "autogeneratePattern": "",
    "help": "",
    "hidden": false,
    "id": "_clone_mFGP",
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
    "id": "_clone_fkDu",
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
    "id": "_clone_joPQ",
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
    "id": "_clone_95ml",
    "max": "",
    "min": "",
    "name": "membershipEndDate",
    "presentable": false,
    "required": true,
    "system": false,
    "type": "date"
  }))

  // add field
  collection.fields.addAt(5, new Field({
    "help": "",
    "hidden": false,
    "id": "_clone_HFBM",
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
    "id": "_clone_nAHB",
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
    "id": "_clone_Ktbl",
    "maxSelect": 1,
    "minSelect": 0,
    "name": "membershipId",
    "presentable": false,
    "required": true,
    "system": false,
    "type": "relation"
  }))

  // remove field
  collection.fields.removeById("_clone_UjKo")

  // remove field
  collection.fields.removeById("_clone_vZuj")

  // remove field
  collection.fields.removeById("_clone_ifmx")

  // remove field
  collection.fields.removeById("_clone_WpxM")

  // remove field
  collection.fields.removeById("_clone_q8J6")

  // remove field
  collection.fields.removeById("_clone_p3fh")

  // remove field
  collection.fields.removeById("_clone_BMAo")

  return app.save(collection)
})
