/// PocketBase collection names used throughout the application.
///
/// Centralizes collection name constants to avoid typos and
/// make refactoring easier.
abstract class PocketBaseCollections {
  // Authentication
  static const String users = 'users';
  static const String userRoles = 'userRoles';

  // Organization
  static const String branches = 'branches';
  static const String printerConfigs = 'printerConfigs';

  // Products
  static const String products = 'products';
  static const String productCategories = 'productCategories';
  static const String productStocks = 'productStocks';
  static const String productLots = 'productLots';
  static const String productAdjustments = 'productAdjustments';

  // Quantity Units
  static const String quantityUnits = 'quantityUnits';

  // Carts
  static const String carts = 'carts';
  static const String cartItems = 'cartItems';

  // Members
  static const String members = 'members';
  static const String memberCards = 'memberCards';

  // Memberships
  static const String memberships = 'memberships';
  static const String memberMemberships = 'memberMemberships';
  static const String membershipAddOns = 'membershipAddOns';
  static const String memberMembershipAddOns = 'memberMembershipAddOns';

  // Check-ins
  static const String checkIns = 'checkIns';

  // Sales
  static const String sales = 'sales';
  static const String saleItems = 'saleItems';
  static const String payments = 'payments';

  // POS Groups
  static const String posGroups = 'posGroups';
  static const String posGroupItems = 'posGroupItems';

  // View Collections (SQL Views for optimized queries)
  static const String activityLogs = 'activityLogs';
  static const String vwInventoryStatus = 'vw_inventory_status';
  static const String vwSalesDailySummary = 'vw_sales_daily_summary';
  static const String vwTopSellingProducts = 'vw_top_selling_products';
  static const String vwTodaysSales = 'vw_todays_sales';
  static const String vwLotQuantityTotals = 'vw_lot_quantity_totals';
  static const String vwLowStockProducts = 'vw_low_stock_products';
  static const String vwLowStockLotProducts = 'vw_low_stock_lot_products';
  static const String vwExpiredLots = 'vw_expired_lots';
  static const String vwNearExpirationLots = 'vw_near_expiration_lots';
  static const String vwPosSearchItems = 'vw_pos_search_items';
  static const String membersWithMembershipStatus =
      'membersWithMembershipStatus';
  static const String vwRevenueByItemType = 'vw_revenue_by_item_type';
  static const String vwCheckinsDailySummary = 'vw_checkins_daily_summary';

  // Period-bucketed report views
  static const String vwSalesWeeklySummary = 'vw_sales_weekly_summary';
  static const String vwSalesMonthlySummary = 'vw_sales_monthly_summary';
  static const String vwSalesYearlySummary = 'vw_sales_yearly_summary';
  static const String vwRevenueByItemTypeWeekly =
      'vw_revenue_by_item_type_weekly';
  static const String vwRevenueByItemTypeMonthly =
      'vw_revenue_by_item_type_monthly';
  static const String vwRevenueByItemTypeYearly =
      'vw_revenue_by_item_type_yearly';
  static const String vwTopSellingProductsMonthly =
      'vw_top_selling_products_monthly';
  static const String vwTopSellingProductsYearly =
      'vw_top_selling_products_yearly';
  static const String vwCheckinsWeeklySummary = 'vw_checkins_weekly_summary';
  static const String vwCheckinsMonthlySummary = 'vw_checkins_monthly_summary';
  static const String vwCheckinsYearlySummary = 'vw_checkins_yearly_summary';
}
