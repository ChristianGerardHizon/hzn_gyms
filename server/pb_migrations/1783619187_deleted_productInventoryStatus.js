/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_919946851");

  return app.delete(collection);
}, (app) => {
  const collection = new Collection({
    "createRule": null,
    "deleteRule": null,
    "fields": [
      {
        "autogeneratePattern": "",
        "help": "",
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
        "cascadeDelete": false,
        "collectionId": "pbc_4092854851",
        "help": "",
        "hidden": false,
        "id": "relation3544843437",
        "maxSelect": 1,
        "minSelect": 0,
        "name": "product",
        "presentable": false,
        "required": false,
        "system": false,
        "type": "relation"
      },
      {
        "autogeneratePattern": "",
        "help": "",
        "hidden": false,
        "id": "_clone_bIcz",
        "max": 0,
        "min": 0,
        "name": "productName",
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
        "id": "json3872470127",
        "maxSize": 1,
        "name": "totalQuantity",
        "presentable": false,
        "required": false,
        "system": false,
        "type": "json"
      },
      {
        "help": "",
        "hidden": false,
        "id": "json3889500226",
        "maxSize": 1,
        "name": "totalExpired",
        "presentable": false,
        "required": false,
        "system": false,
        "type": "json"
      },
      {
        "help": "",
        "hidden": false,
        "id": "_clone_xBEX",
        "max": null,
        "min": null,
        "name": "stockThreshold",
        "onlyInt": false,
        "presentable": false,
        "required": false,
        "system": false,
        "type": "number"
      },
      {
        "help": "",
        "hidden": false,
        "id": "json2063623452",
        "maxSize": 1,
        "name": "status",
        "presentable": false,
        "required": false,
        "system": false,
        "type": "json"
      },
      {
        "help": "",
        "hidden": false,
        "id": "_clone_Cp1T",
        "name": "forSale",
        "presentable": false,
        "required": false,
        "system": false,
        "type": "bool"
      },
      {
        "help": "",
        "hidden": false,
        "id": "_clone_bWaX",
        "name": "isDeleted",
        "presentable": false,
        "required": false,
        "system": false,
        "type": "bool"
      },
      {
        "hidden": false,
        "id": "_clone_veOk",
        "name": "created",
        "onCreate": true,
        "onUpdate": false,
        "presentable": false,
        "system": false,
        "type": "autodate"
      },
      {
        "hidden": false,
        "id": "_clone_iM4P",
        "name": "updated",
        "onCreate": true,
        "onUpdate": true,
        "presentable": false,
        "system": false,
        "type": "autodate"
      }
    ],
    "id": "pbc_919946851",
    "indexes": [],
    "listRule": "",
    "name": "productInventoryStatus",
    "system": false,
    "type": "view",
    "updateRule": null,
    "viewQuery": "SELECT\n  p.id,\n  p.id AS product,\n  p.name AS productName,\n\n  ( -- totalQuantity\n    CASE\n      WHEN p.trackByLot = 0 THEN COALESCE(p.quantity, 0)\n      ELSE COALESCE(\n        SUM(\n          CASE \n            WHEN ps.isDeleted = 0 THEN ps.quantity \n            ELSE 0 \n          END\n        ), \n        0\n      )\n    END\n  ) AS totalQuantity,\n\n  ( -- totalExpired\n    CASE\n      WHEN p.trackByLot = 0 THEN\n        CASE \n          WHEN p.expiration IS NOT NULL \n           AND p.expiration <= CURRENT_DATE \n          THEN p.quantity \n          ELSE 0 \n        END\n      ELSE COALESCE(\n        SUM(\n          CASE \n            WHEN ps.isDeleted = 0 \n             AND ps.expiration IS NOT NULL \n             AND ps.expiration <= CURRENT_DATE \n            THEN ps.quantity \n            ELSE 0 \n          END\n        ), \n        0\n      )\n    END\n  ) AS totalExpired,\n\n  p.stockThreshold,\n\n  ( -- status (excluding expired lots/products)\n    CASE\n      WHEN p.stockThreshold IS NULL \n        OR p.stockThreshold = 0\n      THEN 'noThreshold'\n\n      WHEN (\n        CASE\n          WHEN p.trackByLot = 0 THEN\n            -- only count non-expired single-lot products\n            CASE \n              WHEN p.expiration IS NULL \n                OR p.expiration > CURRENT_DATE \n              THEN COALESCE(p.quantity, 0)\n              ELSE 0\n            END\n\n          ELSE\n            COALESCE(\n              SUM(\n                CASE \n                  WHEN ps.isDeleted = 0\n                   AND ps.isDisposed = 0\n                   AND (\n                     ps.expiration IS NULL \n                     OR ps.expiration > CURRENT_DATE\n                   )\n                  THEN ps.quantity \n                  ELSE 0 \n                END\n              ), \n              0\n            )\n        END\n      ) = 0\n      THEN 'outOfStock'\n\n      WHEN (\n        CASE\n          WHEN p.trackByLot = 0 THEN\n            CASE \n              WHEN p.expiration IS NULL \n                OR p.expiration > CURRENT_DATE \n              THEN COALESCE(p.quantity, 0)\n              ELSE 0\n            END\n\n          ELSE\n            COALESCE(\n              SUM(\n                CASE \n                  WHEN ps.isDeleted = 0\n                   AND ps.isDisposed = 0\n                   AND (\n                     ps.expiration IS NULL \n                     OR ps.expiration > CURRENT_DATE\n                   )\n                  THEN ps.quantity \n                  ELSE 0 \n                END\n              ), \n              0\n            )\n        END\n      ) < p.stockThreshold\n      THEN 'lowStock'\n\n      ELSE 'inStock'\n    END\n  ) AS status,\n\n  p.`forSale`,\n  p.isDeleted,\n  p.created,\n  p.updated\n\nFROM products p\nLEFT JOIN productStocks ps \n  ON ps.product = p.id\nGROUP BY p.id;\n",
    "viewRule": ""
  });

  return app.save(collection);
})
