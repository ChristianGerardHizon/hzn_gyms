/// Helpers for receipt dialog behavior after checkout vs reprint from sales.
bool shouldAutoPrintReceipt({required bool isReprint}) => !isReprint;

/// Headline shown in the receipt dialog body.
String receiptDialogHeadline({required bool isReprint}) =>
    isReprint ? 'Reprint Receipt' : 'Sale Complete!';

/// App bar / dialog title for the receipt surface.
String receiptDialogTitle({required bool isReprint}) =>
    isReprint ? 'Print Receipt' : 'Receipt';

/// Primary dismiss action label.
String receiptDialogDismissLabel({required bool isReprint}) =>
    isReprint ? 'Close' : 'Done';
