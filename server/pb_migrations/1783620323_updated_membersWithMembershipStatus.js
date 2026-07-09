/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_1952861926")

  // update collection data
  unmarshal({
    "viewQuery": "SELECT m.id, m.name, mm.endDate AS membershipEndDate, IIF(mm.endDate IS NULL, 9999999999, strftime('%s', mm.endDate)) AS membershipSortOrder FROM members m LEFT JOIN memberMemberships mm ON mm.member = m.id WHERE m.isDeleted = false LIMIT 1"
  }, collection)

  // remove field
  collection.fields.removeById("_clone_CFtY")

  // remove field
  collection.fields.removeById("_clone_1Q8L")

  // remove field
  collection.fields.removeById("_clone_hKlx")

  // remove field
  collection.fields.removeById("_clone_oyk9")

  // remove field
  collection.fields.removeById("_clone_eVYO")

  // remove field
  collection.fields.removeById("_clone_y9Pl")

  // remove field
  collection.fields.removeById("_clone_tKL8")

  // remove field
  collection.fields.removeById("_clone_SLXU")

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

  // add field
  collection.fields.addAt(3, new Field({
    "help": "",
    "hidden": false,
    "id": "json2411108298",
    "maxSize": 1,
    "name": "membershipSortOrder",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "json"
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_1952861926")

  // update collection data
  unmarshal({
    "viewQuery": "SELECT m.id, m.name, m.mobileNumber, m.photo, mm.endDate AS membershipEndDate, mm.endDate AS membershipSortDate, mm.status AS membershipStatus, mm.branch AS membershipBranch, mm.membership AS membershipId FROM members m LEFT JOIN memberMemberships mm ON mm.member = m.id AND mm.id = (SELECT mm2.id FROM memberMemberships mm2 WHERE mm2.member = m.id ORDER BY mm2.endDate DESC LIMIT 1) WHERE m.isDeleted = false"
  }, collection)

  // add field
  collection.fields.addAt(1, new Field({
    "autogeneratePattern": "",
    "help": "",
    "hidden": false,
    "id": "_clone_CFtY",
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
    "id": "_clone_1Q8L",
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
    "id": "_clone_hKlx",
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
    "id": "_clone_oyk9",
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
    "id": "_clone_eVYO",
    "max": "",
    "min": "",
    "name": "membershipSortDate",
    "presentable": false,
    "required": true,
    "system": false,
    "type": "date"
  }))

  // add field
  collection.fields.addAt(6, new Field({
    "help": "",
    "hidden": false,
    "id": "_clone_y9Pl",
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
  collection.fields.addAt(7, new Field({
    "cascadeDelete": false,
    "collectionId": "pbc_2358601297",
    "help": "",
    "hidden": false,
    "id": "_clone_tKL8",
    "maxSelect": 1,
    "minSelect": 0,
    "name": "membershipBranch",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "relation"
  }))

  // add field
  collection.fields.addAt(8, new Field({
    "cascadeDelete": false,
    "collectionId": "pbc_memberships01",
    "help": "",
    "hidden": false,
    "id": "_clone_SLXU",
    "maxSelect": 1,
    "minSelect": 0,
    "name": "membershipId",
    "presentable": false,
    "required": true,
    "system": false,
    "type": "relation"
  }))

  // remove field
  collection.fields.removeById("_clone_08PA")

  // remove field
  collection.fields.removeById("_clone_4hCM")

  // remove field
  collection.fields.removeById("json2411108298")

  return app.save(collection)
})
