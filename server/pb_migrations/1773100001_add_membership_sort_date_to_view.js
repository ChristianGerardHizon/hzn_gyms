/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("membersWithMembershipStatus");

  collection.viewQuery = `
    SELECT
      m.id,
      m.name,
      m.mobileNumber,
      m.photo,
      mm.endDate AS membershipEndDate,
      mm.status AS membershipStatus,
      mm.branch AS membershipBranch,
      mm.membership AS membershipId,
      CASE
        WHEN mm.endDate IS NULL THEN '9999-12-31'
        WHEN mm.endDate < datetime('now') THEN
          datetime('now', '+' || CAST(ROUND(julianday('now') - julianday(mm.endDate)) AS INTEGER) || ' days')
        ELSE mm.endDate
      END AS membershipSortDate
    FROM members m
    LEFT JOIN memberMemberships mm ON mm.member = m.id
      AND mm.id = (
        SELECT mm2.id
        FROM memberMemberships mm2
        WHERE mm2.member = m.id
        ORDER BY mm2.endDate DESC
        LIMIT 1
      )
    WHERE m.isDeleted = false
  `;

  collection.fields.addAt(collection.fields.length, new Field({
    "hidden": false,
    "id": "_clone_sortDate",
    "max": "",
    "min": "",
    "name": "membershipSortDate",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "date",
  }));

  return app.save(collection);
}, (app) => {
  const collection = app.findCollectionByNameOrId("membersWithMembershipStatus");

  collection.viewQuery = `
    SELECT
      m.id,
      m.name,
      m.mobileNumber,
      m.photo,
      mm.endDate AS membershipEndDate,
      mm.status AS membershipStatus,
      mm.branch AS membershipBranch,
      mm.membership AS membershipId
    FROM members m
    LEFT JOIN memberMemberships mm ON mm.member = m.id
      AND mm.id = (
        SELECT mm2.id
        FROM memberMemberships mm2
        WHERE mm2.member = m.id
        ORDER BY mm2.endDate DESC
        LIMIT 1
      )
    WHERE m.isDeleted = false
  `;

  collection.fields.removeById("_clone_sortDate");

  return app.save(collection);
});
