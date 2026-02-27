/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = new Collection({
    "createRule": null,
    "deleteRule": null,
    "fields": [
      {
        "autogeneratePattern": "",
        "hidden": false,
        "id": "text3208210256",
        "max": 0,
        "min": 0,
        "name": "id",
        "pattern": "^[a-z0-9]+$",
        "presentable": false,
        "primaryKey": true,
        "required": true,
        "system": true,
        "type": "text"
      },
      {
        "autogeneratePattern": "",
        "hidden": false,
        "id": "_clone_As4g",
        "max": 0,
        "min": 0,
        "name": "name",
        "pattern": "",
        "presentable": true,
        "primaryKey": false,
        "required": true,
        "system": false,
        "type": "text"
      },
      {
        "autogeneratePattern": "",
        "hidden": false,
        "id": "_clone_vVWZ",
        "max": 0,
        "min": 0,
        "name": "mobileNumber",
        "pattern": "",
        "presentable": false,
        "primaryKey": false,
        "required": false,
        "system": false,
        "type": "text"
      },
      {
        "hidden": false,
        "id": "_clone_ZUwy",
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
      },
      {
        "hidden": false,
        "id": "_clone_QtbV",
        "max": "",
        "min": "",
        "name": "membershipEndDate",
        "presentable": false,
        "required": false,
        "system": false,
        "type": "date"
      },
      {
        "hidden": false,
        "id": "_clone_6BPX",
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
      },
      {
        "cascadeDelete": false,
        "collectionId": "pbc_2358601297",
        "hidden": false,
        "id": "_clone_NRTf",
        "maxSelect": 1,
        "minSelect": 0,
        "name": "membershipBranch",
        "presentable": false,
        "required": false,
        "system": false,
        "type": "relation"
      },
      {
        "cascadeDelete": false,
        "collectionId": "pbc_memberships01",
        "hidden": false,
        "id": "_clone_T3bC",
        "maxSelect": 1,
        "minSelect": 0,
        "name": "membershipId",
        "presentable": false,
        "required": false,
        "system": false,
        "type": "relation"
      }
    ],
    "id": "pbc_1952861926",
    "indexes": [],
    "listRule": "",
    "name": "membersWithMembershipStatus",
    "system": false,
    "type": "view",
    "updateRule": null,
    "viewQuery": "SELECT m.id, m.name, m.mobileNumber, m.photo, mm.endDate AS membershipEndDate, mm.status AS membershipStatus, mm.branch AS membershipBranch, mm.membership AS membershipId FROM members m LEFT JOIN memberMemberships mm ON mm.member = m.id AND mm.id = (SELECT mm2.id FROM memberMemberships mm2 WHERE mm2.member = m.id ORDER BY mm2.endDate DESC LIMIT 1) WHERE m.isDeleted = false",
    "viewRule": ""
  });

  return app.save(collection);
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_1952861926");

  return app.delete(collection);
})
