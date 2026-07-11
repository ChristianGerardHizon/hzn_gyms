/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_1952861926")

  // update collection data
  unmarshal({
    "viewQuery": "SELECT m.id, m.name, m.mobileNumber, m.photo, mm.endDate AS membershipEndDate, mm.status AS membershipStatus, mm.branch AS membershipBranch, mm.membership AS membershipId, IIF(mm.endDate IS NULL, 2, IIF(date(mm.endDate) < date('now'), 1, 0)) AS membershipSortTier, IIF(mm.endDate IS NULL, 0, IIF(date(mm.endDate) < date('now'), 9999999999 - strftime('%s', mm.endDate), strftime('%s', mm.endDate))) AS membershipSortOrder FROM members m LEFT JOIN memberMemberships mm ON mm.member = m.id AND mm.id = (SELECT mm2.id FROM memberMemberships mm2 WHERE mm2.member = m.id ORDER BY mm2.endDate DESC LIMIT 1) WHERE m.isDeleted = false"
  }, collection)

  // remove field
  collection.fields.removeById("_clone_oi5o")

  // remove field
  collection.fields.removeById("_clone_s8Wt")

  // remove field
  collection.fields.removeById("_clone_jDUn")

  // remove field
  collection.fields.removeById("_clone_UZf5")

  // remove field
  collection.fields.removeById("_clone_mIdt")

  // remove field
  collection.fields.removeById("_clone_qN4h")

  // remove field
  collection.fields.removeById("_clone_Tfkm")

  // add field
  collection.fields.addAt(1, new Field({
    "autogeneratePattern": "",
    "help": "",
    "hidden": false,
    "id": "_clone_bwNi",
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
    "id": "_clone_C0iU",
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
    "id": "_clone_Cknh",
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
    "id": "_clone_tQNb",
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
    "id": "_clone_96oz",
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
    "id": "_clone_IoPG",
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
    "id": "_clone_6eTT",
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
    "viewQuery": "SELECT m.id, m.name, m.mobileNumber, m.photo, mm.endDate AS membershipEndDate, mm.status AS membershipStatus, mm.branch AS membershipBranch, mm.membership AS membershipId, IIF(mm.endDate IS NULL, 2, IIF(mm.endDate < datetime('now'), 1, 0)) AS membershipSortTier, IIF(mm.endDate IS NULL, 0, IIF(mm.endDate < datetime('now'), 9999999999 - strftime('%s', mm.endDate), strftime('%s', mm.endDate))) AS membershipSortOrder FROM members m LEFT JOIN memberMemberships mm ON mm.member = m.id AND mm.id = (SELECT mm2.id FROM memberMemberships mm2 WHERE mm2.member = m.id ORDER BY mm2.endDate DESC LIMIT 1) WHERE m.isDeleted = false"
  }, collection)

  // add field
  collection.fields.addAt(1, new Field({
    "autogeneratePattern": "",
    "help": "",
    "hidden": false,
    "id": "_clone_oi5o",
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
    "id": "_clone_s8Wt",
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
    "id": "_clone_jDUn",
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
    "id": "_clone_UZf5",
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
    "id": "_clone_mIdt",
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
    "id": "_clone_qN4h",
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
    "id": "_clone_Tfkm",
    "maxSelect": 1,
    "minSelect": 0,
    "name": "membershipId",
    "presentable": false,
    "required": true,
    "system": false,
    "type": "relation"
  }))

  // remove field
  collection.fields.removeById("_clone_bwNi")

  // remove field
  collection.fields.removeById("_clone_C0iU")

  // remove field
  collection.fields.removeById("_clone_Cknh")

  // remove field
  collection.fields.removeById("_clone_tQNb")

  // remove field
  collection.fields.removeById("_clone_96oz")

  // remove field
  collection.fields.removeById("_clone_IoPG")

  // remove field
  collection.fields.removeById("_clone_6eTT")

  return app.save(collection)
})
