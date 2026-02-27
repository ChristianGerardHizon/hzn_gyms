/// Generated migration: Update sales status values to include awaitingPayment and paid.
/// Also migrates existing 'completed' records to 'paid' and updates PB views.

migrate((app) => {
  const collection = app.findCollectionByNameOrId("sales")

  // Update the status field with new values
  const statusField = collection.fields.find((f) => f.name === "status")
  if (statusField) {
    statusField.values = ["pending", "awaitingPayment", "paid", "completed", "refunded", "voided"]
  }

  app.save(collection)

  // Migrate existing 'completed' records to 'paid'
  const records = app.findRecordsByFilter("sales", "status = 'completed'", "", 0, 0)
  for (const record of records) {
    record.set("status", "paid")
    app.save(record)
  }

  // Update view queries to include 'paid' status alongside 'completed'

  // vw_sales_daily_summary
  const dailySummary = app.findCollectionByNameOrId("vw_sales_daily_summary")
  dailySummary.viewQuery = `
    SELECT
      (ROW_NUMBER() OVER()) AS id,
      DATE(s.created) AS sale_date,
      p.paymentMethod,
      s.branch,
      COUNT(DISTINCT s.id) AS transaction_count,
      SUM(p.amount) AS total_revenue,
      AVG(p.amount) AS avg_transaction_value
    FROM sales s
    LEFT JOIN payments p ON s.id = p.sale
    WHERE (s.isDeleted = false OR s.isDeleted IS NULL)
      AND s.status IN ('completed', 'paid')
    GROUP BY DATE(s.created), p.paymentMethod, s.branch
    ORDER BY sale_date DESC
  `
  app.save(dailySummary)

  // vw_todays_sales
  const todaysSales = app.findCollectionByNameOrId("vw_todays_sales")
  todaysSales.viewQuery = `
    SELECT
      (ROW_NUMBER() OVER()) AS id,
      s.branch,
      COUNT(*) AS transaction_count,
      COALESCE(SUM(s.totalAmount), 0) AS total_revenue
    FROM sales s
    WHERE DATE(s.created) = DATE('now')
      AND s.status IN ('completed', 'paid')
      AND (s.isDeleted = false OR s.isDeleted IS NULL)
    GROUP BY s.branch
  `
  app.save(todaysSales)

  // vw_top_selling_products
  const topSelling = app.findCollectionByNameOrId("vw_top_selling_products")
  topSelling.viewQuery = `
    SELECT
      (ROW_NUMBER() OVER()) AS id,
      si.productName,
      si.product AS product_id,
      s.branch,
      DATE(s.created) AS sale_date,
      SUM(si.quantity) AS total_quantity_sold,
      SUM(si.subtotal) AS total_revenue,
      COUNT(DISTINCT s.id) AS transaction_count
    FROM saleItems si
    JOIN sales s ON si.sale = s.id
    WHERE (s.isDeleted = false OR s.isDeleted IS NULL)
      AND s.status IN ('completed', 'paid')
    GROUP BY si.productName, si.product, s.branch, DATE(s.created)
    ORDER BY total_revenue DESC
  `
  app.save(topSelling)
}, (app) => {
  // Revert: migrate 'paid' records back to 'completed'
  const records = app.findRecordsByFilter("sales", "status = 'paid'", "", 0, 0)
  for (const record of records) {
    record.set("status", "completed")
    app.save(record)
  }

  const collection = app.findCollectionByNameOrId("sales")
  const statusField = collection.fields.find((f) => f.name === "status")
  if (statusField) {
    statusField.values = ["completed", "refunded", "voided", "pending"]
  }
  app.save(collection)

  // Revert view queries
  const dailySummary = app.findCollectionByNameOrId("vw_sales_daily_summary")
  dailySummary.viewQuery = `
    SELECT
      (ROW_NUMBER() OVER()) AS id,
      DATE(s.created) AS sale_date,
      p.paymentMethod,
      s.branch,
      COUNT(DISTINCT s.id) AS transaction_count,
      SUM(p.amount) AS total_revenue,
      AVG(p.amount) AS avg_transaction_value
    FROM sales s
    LEFT JOIN payments p ON s.id = p.sale
    WHERE (s.isDeleted = false OR s.isDeleted IS NULL)
      AND s.status = 'completed'
    GROUP BY DATE(s.created), p.paymentMethod, s.branch
    ORDER BY sale_date DESC
  `
  app.save(dailySummary)

  const todaysSales = app.findCollectionByNameOrId("vw_todays_sales")
  todaysSales.viewQuery = `
    SELECT
      (ROW_NUMBER() OVER()) AS id,
      s.branch,
      COUNT(*) AS transaction_count,
      COALESCE(SUM(s.totalAmount), 0) AS total_revenue
    FROM sales s
    WHERE DATE(s.created) = DATE('now')
      AND s.status = 'completed'
      AND (s.isDeleted = false OR s.isDeleted IS NULL)
    GROUP BY s.branch
  `
  app.save(todaysSales)

  const topSelling = app.findCollectionByNameOrId("vw_top_selling_products")
  topSelling.viewQuery = `
    SELECT
      (ROW_NUMBER() OVER()) AS id,
      si.productName,
      si.product AS product_id,
      s.branch,
      DATE(s.created) AS sale_date,
      SUM(si.quantity) AS total_quantity_sold,
      SUM(si.subtotal) AS total_revenue,
      COUNT(DISTINCT s.id) AS transaction_count
    FROM saleItems si
    JOIN sales s ON si.sale = s.id
    WHERE (s.isDeleted = false OR s.isDeleted IS NULL)
      AND s.status = 'completed'
    GROUP BY si.productName, si.product, s.branch, DATE(s.created)
    ORDER BY total_revenue DESC
  `
  app.save(topSelling)
})
