/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  // Check if collection already exists
  try {
    const existing = app.findCollectionByNameOrId("memberCards")
    if (existing) {
      // Collection already exists, skip creation
      return
    }
  } catch (e) {
    // Collection doesn't exist, proceed with creation
  }

  const collection = new Collection({
    "id": "pbc_memberCards",
    "name": "memberCards",
    "type": "base",
    "system": false,
    "fields": [
      {
        "autogeneratePattern": "[a-z0-9]{15}",
        "hidden": false,
        "id": "text3208210256",
        "max": 15,
        "min": 15,
        "name": "id",
        "pattern": "^[a-z0-9]+$",
        "presentable": false,
        "primaryKey": true,
        "required": true,
        "system": true,
        "type": "text"
      },
      {
        "cascadeDelete": true,
        "collectionId": "pbc_members001",
        "hidden": false,
        "id": "relation_member",
        "maxSelect": 1,
        "minSelect": 1,
        "name": "member",
        "presentable": false,
        "required": true,
        "system": false,
        "type": "relation"
      },
      {
        "autogeneratePattern": "",
        "hidden": false,
        "id": "text_cardvalue",
        "max": 0,
        "min": 1,
        "name": "cardValue",
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
        "id": "text_label",
        "max": 0,
        "min": 0,
        "name": "label",
        "pattern": "",
        "presentable": false,
        "primaryKey": false,
        "required": false,
        "system": false,
        "type": "text"
      },
      {
        "hidden": false,
        "id": "select_status",
        "maxSelect": 1,
        "name": "status",
        "presentable": false,
        "required": true,
        "system": false,
        "type": "select",
        "values": ["active", "lost", "deactivated"]
      },
      {
        "hidden": false,
        "id": "date_deactivatedat",
        "max": "",
        "min": "",
        "name": "deactivatedAt",
        "presentable": false,
        "required": false,
        "system": false,
        "type": "date"
      },
      {
        "autogeneratePattern": "",
        "hidden": false,
        "id": "text_notes",
        "max": 0,
        "min": 0,
        "name": "notes",
        "pattern": "",
        "presentable": false,
        "primaryKey": false,
        "required": false,
        "system": false,
        "type": "text"
      },
      {
        "hidden": false,
        "id": "autodate2990389176",
        "name": "created",
        "onCreate": { "enabled": true },
        "onUpdate": { "enabled": false },
        "presentable": false,
        "system": false,
        "type": "autodate"
      },
      {
        "hidden": false,
        "id": "autodate3332085495",
        "name": "updated",
        "onCreate": { "enabled": true },
        "onUpdate": { "enabled": true },
        "presentable": false,
        "system": false,
        "type": "autodate"
      }
    ],
    "indexes": [
      "CREATE UNIQUE INDEX `idx_memberCards_cardValue` ON `memberCards` (`cardValue`)",
      "CREATE INDEX `idx_memberCards_member` ON `memberCards` (`member`)"
    ],
    "listRule": "@request.auth.id != ''",
    "viewRule": "@request.auth.id != ''",
    "createRule": "@request.auth.id != ''",
    "updateRule": "@request.auth.id != ''",
    "deleteRule": "@request.auth.id != ''"
  })

  return app.save(collection)
}, (app) => {
  try {
    const collection = app.findCollectionByNameOrId("pbc_memberCards")
    return app.delete(collection)
  } catch (e) {
    // Collection doesn't exist, nothing to delete
  }
})
