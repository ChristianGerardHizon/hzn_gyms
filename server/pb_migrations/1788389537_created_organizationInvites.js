/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = new Collection({
    "createRule": null,
    "deleteRule": null,
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
        "exceptDomains": null,
        "help": "",
        "hidden": false,
        "id": "email3885137012",
        "name": "email",
        "onlyDomains": null,
        "presentable": false,
        "required": true,
        "system": false,
        "type": "email"
      },
      {
        "cascadeDelete": false,
        "collectionId": "pbc_2873630990",
        "help": "",
        "hidden": false,
        "id": "relation3253625724",
        "maxSelect": 1,
        "minSelect": 0,
        "name": "organization",
        "presentable": false,
        "required": true,
        "system": false,
        "type": "relation"
      },
      {
        "cascadeDelete": false,
        "collectionId": "pbc_2105053228",
        "help": "",
        "hidden": false,
        "id": "relation1466534506",
        "maxSelect": 1,
        "minSelect": 0,
        "name": "role",
        "presentable": false,
        "required": true,
        "system": false,
        "type": "relation"
      },
      {
        "autogeneratePattern": "[a-zA-Z0-9]{32}",
        "help": "",
        "hidden": true,
        "id": "text1597481275",
        "max": 32,
        "min": 32,
        "name": "token",
        "pattern": "",
        "presentable": false,
        "primaryKey": false,
        "required": true,
        "system": false,
        "type": "text"
      },
      {
        "help": "",
        "hidden": false,
        "id": "select2063623452",
        "maxSelect": 1,
        "name": "status",
        "presentable": false,
        "required": true,
        "system": false,
        "type": "select",
        "values": [
          "pending",
          "accepted",
          "expired",
          "revoked"
        ]
      },
      {
        "cascadeDelete": false,
        "collectionId": "pbc_3841632486",
        "help": "",
        "hidden": false,
        "id": "relation3607751814",
        "maxSelect": 1,
        "minSelect": 0,
        "name": "invitedBy",
        "presentable": false,
        "required": true,
        "system": false,
        "type": "relation"
      },
      {
        "cascadeDelete": false,
        "collectionId": "pbc_3841632486",
        "help": "",
        "hidden": false,
        "id": "relation2422977887",
        "maxSelect": 1,
        "minSelect": 0,
        "name": "acceptedBy",
        "presentable": false,
        "required": false,
        "system": false,
        "type": "relation"
      },
      {
        "help": "",
        "hidden": false,
        "id": "date730627375",
        "max": "",
        "min": "",
        "name": "expiresAt",
        "presentable": false,
        "required": true,
        "system": false,
        "type": "date"
      }
    ],
    "id": "pbc_5182934182",
    "indexes": [
      "CREATE UNIQUE INDEX idx_token_organizationInvites ON organizationInvites (token)"
    ],
    "listRule": "@request.auth.id != \"\" && (invitedBy = @request.auth.id || email = @request.auth.email || organization.organizationMemberships_via_organization.user ?= @request.auth.id)",
    "name": "organizationInvites",
    "system": false,
    "type": "base",
    "updateRule": null,
    "viewRule": "@request.auth.id != \"\" && (invitedBy = @request.auth.id || email = @request.auth.email || organization.organizationMemberships_via_organization.user ?= @request.auth.id)"
  });

  return app.save(collection);
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_5182934182");

  return app.delete(collection);
})
