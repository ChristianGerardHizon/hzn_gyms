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
        "cascadeDelete": false,
        "collectionId": "pbc_3841632486",
        "help": "",
        "hidden": false,
        "id": "relation2375276105",
        "maxSelect": 1,
        "minSelect": 0,
        "name": "user",
        "presentable": false,
        "required": true,
        "system": false,
        "type": "relation"
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
          "active",
          "suspended"
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
        "required": false,
        "system": false,
        "type": "relation"
      },
      {
        "help": "",
        "hidden": false,
        "id": "date2904712964",
        "max": "",
        "min": "",
        "name": "joinedAt",
        "presentable": false,
        "required": true,
        "system": false,
        "type": "date"
      }
    ],
    "id": "pbc_5182934071",
    "indexes": [
      "CREATE UNIQUE INDEX idx_user_organization_organizationMemberships ON organizationMemberships (user, organization)"
    ],
    "listRule": "@request.auth.id != \"\" && (user = @request.auth.id || organization.organizationMemberships_via_organization.user ?= @request.auth.id)",
    "name": "organizationMemberships",
    "system": false,
    "type": "base",
    "updateRule": null,
    "viewRule": "@request.auth.id != \"\" && (user = @request.auth.id || organization.organizationMemberships_via_organization.user ?= @request.auth.id)"
  });

  return app.save(collection);
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_5182934071");

  return app.delete(collection);
})
