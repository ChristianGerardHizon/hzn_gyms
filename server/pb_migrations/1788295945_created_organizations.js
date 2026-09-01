/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = new Collection({
    "createRule": "@request.auth.role.permissions ?~ \"organizations.manage\"",
    "deleteRule": "@request.auth.role.permissions ?~ \"organizations.manage\"",
    "fields": [
      {
        "autogeneratePattern": "[a-z0-9]{15}",
        "help": "",
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
        "autogeneratePattern": "",
        "help": "",
        "hidden": false,
        "id": "text1579384326",
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
        "help": "",
        "hidden": false,
        "id": "text2560465762",
        "max": 63,
        "min": 1,
        "name": "slug",
        "pattern": "^[a-z0-9-]+$",
        "presentable": true,
        "primaryKey": false,
        "required": true,
        "system": false,
        "type": "text"
      },
      {
        "autogeneratePattern": "",
        "help": "",
        "hidden": false,
        "id": "text1731158936",
        "max": 0,
        "min": 0,
        "name": "displayName",
        "pattern": "",
        "presentable": false,
        "primaryKey": false,
        "required": false,
        "system": false,
        "type": "text"
      },
      {
        "autogeneratePattern": "",
        "help": "",
        "hidden": false,
        "id": "text2624781215",
        "max": 9,
        "min": 0,
        "name": "seedColor",
        "pattern": "^#[0-9A-Fa-f]{6,8}$",
        "presentable": false,
        "primaryKey": false,
        "required": false,
        "system": false,
        "type": "text"
      },
      {
        "help": "",
        "hidden": false,
        "id": "file2397019907",
        "maxSelect": 1,
        "maxSize": 5242880,
        "mimeTypes": [
          "image/png",
          "image/jpeg",
          "image/webp",
          "image/svg+xml"
        ],
        "name": "logoLight",
        "presentable": false,
        "protected": false,
        "required": false,
        "system": false,
        "thumbs": null,
        "type": "file"
      },
      {
        "help": "",
        "hidden": false,
        "id": "file3329830007",
        "maxSelect": 1,
        "maxSize": 5242880,
        "mimeTypes": [
          "image/png",
          "image/webp",
          "image/svg+xml"
        ],
        "name": "logoTransparent",
        "presentable": false,
        "protected": false,
        "required": false,
        "system": false,
        "thumbs": null,
        "type": "file"
      },
      {
        "autogeneratePattern": "",
        "help": "",
        "hidden": false,
        "id": "text2139300606",
        "max": 9,
        "min": 0,
        "name": "splashBackgroundColor",
        "pattern": "^#[0-9A-Fa-f]{6,8}$",
        "presentable": false,
        "primaryKey": false,
        "required": false,
        "system": false,
        "type": "text"
      },
      {
        "autogeneratePattern": "",
        "help": "",
        "hidden": false,
        "id": "text3252000302",
        "max": 255,
        "min": 0,
        "name": "subdomain",
        "pattern": "",
        "presentable": false,
        "primaryKey": false,
        "required": false,
        "system": false,
        "type": "text"
      },
      {
        "help": "",
        "hidden": false,
        "id": "select839482800",
        "maxSelect": 1,
        "name": "dnsStatus",
        "presentable": false,
        "required": false,
        "system": false,
        "type": "select",
        "values": [
          "pending",
          "created",
          "failed"
        ]
      },
      {
        "autogeneratePattern": "",
        "help": "",
        "hidden": false,
        "id": "text1031953815",
        "max": 0,
        "min": 0,
        "name": "dnsError",
        "pattern": "",
        "presentable": false,
        "primaryKey": false,
        "required": false,
        "system": false,
        "type": "text"
      },
      {
        "help": "",
        "hidden": false,
        "id": "date2859834503",
        "max": "",
        "min": "",
        "name": "dnsLastAttempt",
        "presentable": false,
        "required": false,
        "system": false,
        "type": "date"
      },
      {
        "help": "",
        "hidden": false,
        "id": "bool2382110195",
        "name": "isDeleted",
        "presentable": false,
        "required": false,
        "system": false,
        "type": "bool"
      },
      {
        "hidden": false,
        "id": "autodate2990389176",
        "name": "created",
        "onCreate": true,
        "onUpdate": false,
        "presentable": false,
        "system": false,
        "type": "autodate"
      },
      {
        "hidden": false,
        "id": "autodate3332085495",
        "name": "updated",
        "onCreate": true,
        "onUpdate": true,
        "presentable": false,
        "system": false,
        "type": "autodate"
      }
    ],
    "id": "pbc_2873630990",
    "indexes": [
      "CREATE UNIQUE INDEX `idx_slug_organizations` ON `organizations` (`slug`)",
      "CREATE UNIQUE INDEX `idx_subdomain_organizations` ON `organizations` (`subdomain`) WHERE `subdomain` != ''"
    ],
    "listRule": "@request.auth.role.permissions ?~ \"organizations.manage\"",
    "name": "organizations",
    "system": false,
    "type": "base",
    "updateRule": "@request.auth.role.permissions ?~ \"organizations.manage\"",
    "viewRule": ""
  });

  return app.save(collection);
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_2873630990");

  return app.delete(collection);
})
