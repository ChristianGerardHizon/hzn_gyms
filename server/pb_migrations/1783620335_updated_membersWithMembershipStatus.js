/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_1952861926")

  // update collection data
  unmarshal({
    "viewQuery": "SELECT m.id, m.name, m.mobileNumber, m.photo, mm.endDate AS membershipEndDate, mm.status AS membershipStatus, mm.branch AS membershipBranch, mm.membership AS membershipId, IIF(mm.endDate IS NULL, 9999999999, IIF(mm.endDate < datetime('now'), strftime('%s', 'now') + 1000000000 + (strftime('%s', 'now') - strftime('%s', mm.endDate)), strftime('%s', mm.endDate))) AS membershipSortOrder FROM members m LEFT JOIN memberMemberships mm ON mm.member = m.id AND mm.id = (SELECT mm2.id FROM memberMemberships mm2 WHERE mm2.member = m.id ORDER BY mm2.endDate DESC LIMIT 1) WHERE m.isDeleted = false"
  }, collection)

  // remove field
  collection.fields.removeById("_clone_08PA")

  // remove field
  collection.fields.removeById("_clone_4hCM")

  // add field
  collection.fields.addAt(1, new Field({
    "autogeneratePattern": "",
    "help": "",
    "hidden": false,
    "id": "_clone_B8vN",
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
    "id": "_clone_3CRQ",
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
    "id": "_clone_pstb",
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
    "id": "_clone_eYfc",
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
    "id": "_clone_w2Qq",
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
    "id": "_clone_1opf",
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
    "id": "_clone_3fbY",
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
    "viewQuery": "SELECT m.id, m.name, mm.endDate AS membershipEndDate, IIF(mm.endDate IS NULL, 9999999999, strftime('%s', mm.endDate)) AS membershipSortOrder FROM members m LEFT JOIN memberMemberships mm ON mm.member = m.id WHERE m.isDeleted = false LIMIT 1"
  }, collection)

  // add field
  collection.fields.addAt(1, new Field({
    "autogeneratePattern": "",
    "help": "",
    "hidden": false,
    "id": "_clone_08PA",
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
    "help": "",
    "hidden": false,
    "id": "_clone_4hCM",
    "max": "",
    "min": "",
    "name": "membershipEndDate",
    "presentable": false,
    "required": true,
    "system": false,
    "type": "date"
  }))

  // remove field
  collection.fields.removeById("_clone_B8vN")

  // remove field
  collection.fields.removeById("_clone_3CRQ")

  // remove field
  collection.fields.removeById("_clone_pstb")

  // remove field
  collection.fields.removeById("_clone_eYfc")

  // remove field
  collection.fields.removeById("_clone_w2Qq")

  // remove field
  collection.fields.removeById("_clone_1opf")

  // remove field
  collection.fields.removeById("_clone_3fbY")

  return app.save(collection)
})
