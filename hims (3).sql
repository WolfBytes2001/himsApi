-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: May 31, 2024 at 10:15 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `hims`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `customerPurchase_CreateRecord` (IN `orderID` INT(50), IN `withdrawalID` INT(50), IN `customerName` VARCHAR(50))   INSERT INTO costumer_purchase(
    costumer_purchase.orderID,
    costumer_purchase.withdrawalID,
    costumer_purchase.customerName
)
VALUES(
    orderID,
    withdrawalID,
    customerName
)
ON DUPLICATE KEY UPDATE
   
    costumer_purchase.customerName = VALUES(customerName)$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `customerPurchase_Delete` (IN `orderID` INT)   UPDATE costumer_purchase SET costumer_purchase.isDeleted = 1
WHERE costumer_purchase.orderID = orderID$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `customerPurchase_ReadAllOrderRecords` ()   SELECT * FROM costumer_purchase
WHERE costumer_purchase.isDeleted = 0$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `customerPurchase_search` (IN `keyword` VARCHAR(50))   SELECT * FROM costumer_purchase WHERE costumer_purchase.orderID LIKE keyword AND costumer_purchase.isDeleted = 0$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `customerPurchase_updateRecord` (IN `id` INT(50), IN `customerName` VARCHAR(50))   UPDATE costumer_purchase SET
	costumer_purchase.customerName = customerName
WHERE costumer_purchase.orderID = id$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getAllProducts` ()   SELECT * FROM products$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `insertTransactions` (IN `delivered_by` VARCHAR(50), IN `recorded_at` VARCHAR(50), IN `recieved_by` VARCHAR(50), IN `purchase_details` VARCHAR(100))   INSERT INTO stocking_transaction(stocking_transactions.delivered_by,stocking_transactions.recorded_at,stocking_transactions.recieved_by,stocking_transactions.purchase_details)
VALUES(delivered_by,recorded_at,recieved_by,purchase_details)$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `products_DeleteProduct` (IN `inventoryID` INT(50))   UPDATE products SET products.isDeleted = 1
WHERE products.inventoryID = inventoryID$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `products_SearchProduct` (IN `keyword` INT(50))   SELECT * FROM products 
    WHERE products.inventoryID LIKE keyword AND products.isDeleted = 0$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `products_updateProduct` (IN `inventoryID` INT(50), IN `product_name` VARCHAR(50), IN `product_quantity` INT(50), IN `category` VARCHAR(50), IN `price` DOUBLE)   UPDATE products
SET
	products.product_name = product_name,
    products.product_quantity = product_quantity,
    products.category = category,
    products.price = price,
    products.transferID = transferID
WHERE
	products.inventoryID = inventoryID$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `products_ViewAllProducts` ()   SELECT * FROM products
WHERE products.isDeleted =0$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `product_Transfer` (IN `inventoryID` INT, IN `transferID` INT)   UPDATE products SET products.transferID = transferID
WHERE products.inventoryID = inventoryID$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `product_Withdrawal` (IN `inventoryID` INT(50), IN `quantity` INT(50))   UPDATE products 
SET
	products.product_quantity = (products.product_quantity - quantity)
WHERE
	products.inventoryID = inventoryID$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `readItemReceived` ()   SELECT * FROM stocking_transactions$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `report_itemReceivingAndStocking` ()   BEGIN
	#Routine body goes here...
	SELECT
    stocking_transactions.transactionID, 
    stocking_transactions.recorded_at AS date_received, 
    stocking_transactions.purchase_order, 
    stocking_transactions.delivered_by, 
    stocking_transactions.recieved_by, 
    products.inventoryID, 
    products.product_name, 
    products.product_quantity AS quantity_received, 
    products.price AS unit_cost, 
    (products.product_quantity * products.price) AS total_cost
FROM
    stocking_transactions
INNER JOIN
    products ON stocking_transactions.transactionID = products.transactionID;


END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `report_Return` ()   BEGIN
	#Routine body goes here...
SELECT
    return_transaction.returnID, 
    costumer_purchase.orderID, 
    return_transaction.handled_by, 
    costumer_purchase.customerName, 
    return_transaction.approval_status, 
    return_transaction.status AS return_status, 
    return_transaction.recorded_at AS return_recorded_at, 
    costumer_purchase.recorded_at AS purchase_recorded_at
FROM
    return_transaction
INNER JOIN
    costumer_purchase ON return_transaction.orderID = costumer_purchase.orderID;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `report_slowFast` ()   BEGIN
	#Routine body goes here...
SELECT
    products.product_name, 
    COUNT(costumer_purchase.orderID) AS times_sold, 
    SUM(products.price) AS total_sales_value,
    MIN(products.added_at) AS first_added_at,
    MAX(costumer_purchase.recorded_at) AS last_sold_at,
    DATEDIFF(MAX(costumer_purchase.recorded_at), MIN(products.added_at)) AS days_on_sale
FROM
    products
INNER JOIN
    withdrawal_transaction
    ON products.inventoryID = withdrawal_transaction.inventoryID
INNER JOIN
    costumer_purchase
    ON costumer_purchase.withdrawalID = withdrawal_transaction.withdrawalID
GROUP BY
    products.product_name
HAVING
    COUNT(costumer_purchase.orderID) <= 5
ORDER BY
    times_sold ASC, days_on_sale DESC;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `report_stockAging` ()   BEGIN
	#Routine body goes here...
SELECT
    products.inventoryID, 
    products.product_name, 
    products.product_quantity, 
    products.price, 
    withdrawal_transaction.quantity AS withdrawal_quantity, 
    costumer_purchase.recorded_at AS last_sale_date, 
    stocking_transactions.recorded_at AS receipt_date,
    CASE
        WHEN DATEDIFF(CURDATE(), stocking_transactions.recorded_at) <= 30 THEN '0-30 days'
        WHEN DATEDIFF(CURDATE(), stocking_transactions.recorded_at) BETWEEN 31 AND 60 THEN '31-60 days'
        WHEN DATEDIFF(CURDATE(), stocking_transactions.recorded_at) BETWEEN 61 AND 90 THEN '61-90 days'
        ELSE '91+ days'
    END AS aging_bucket
FROM
    products
INNER JOIN
    withdrawal_transaction ON products.inventoryID = withdrawal_transaction.inventoryID
INNER JOIN
    costumer_purchase ON withdrawal_transaction.withdrawalID = costumer_purchase.withdrawalID
INNER JOIN
    stocking_transactions ON products.transactionID = stocking_transactions.transactionID;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `report_Transfer` ()   BEGIN
	#Routine body goes here...
SELECT
    inventory_transfer.transferID, 
    inventory_transfer.inventoryID, 
    products.product_name, 
    inventory_transfer.storage, 
    inventory_transfer.initiated_at, 
    inventory_transfer.handled_by
FROM
    inventory_transfer
INNER JOIN
    products ON inventory_transfer.transferID = products.transferID;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `report_Withdrawal` ()   BEGIN
	#Routine body goes here...
SELECT
    withdrawal_transaction.withdrawalID, 
    withdrawal_transaction.inventoryID, 
    products.product_name, 
    products.product_quantity AS current_quantity, 
    products.price AS unit_price, 
    withdrawal_transaction.quantity AS quantity_withdrawn, 
    (withdrawal_transaction.quantity * products.price) AS total_cost,
    withdrawal_transaction.purpose, 
    withdrawal_transaction.withdrawnBy, 
    withdrawal_transaction.recorded_at AS withdrawal_date, 
    costumer_purchase.orderID, 
    costumer_purchase.customerName, 
    costumer_purchase.recorded_at AS purchase_date
FROM
    withdrawal_transaction
INNER JOIN
    products ON withdrawal_transaction.inventoryID = products.inventoryID
LEFT JOIN
    costumer_purchase ON withdrawal_transaction.withdrawalID = costumer_purchase.withdrawalID;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `return_adminApprovalList` ()   SELECT * FROM return_transaction
WHERE return_transaction.approval_status = 0 AND 
return_transaction.isDeleted = 0$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `return_adminViewApprovedList` ()   SELECT * FROM return_transaction
WHERE return_transaction.approval_status = 1 and return_transaction.isDeleted = 0$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `return_ApproveReturn` (IN `id` INT)   UPDATE return_transaction SET
return_transaction.approval_status = 1
WHERE return_transaction.returnID = id$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `return_CreateRecord` (IN `id` INT(50), IN `orderID` INT(50), IN `handled_by` VARCHAR(50))   INSERT INTO return_transaction(
    return_transaction.returnID,
    return_transaction.orderID ,
    return_transaction.handled_by
)
VALUES(id, orderID, handled_by)
ON DUPLICATE KEY UPDATE
return_transaction.orderID = VALUES(orderID),
return_transaction.handled_by = VALUES(handled_by)$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `return_ReadAllRecords` ()   SELECT * FROM return_transaction
WHERE return_transaction.isDeleted = 0$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `return_search` (IN `id` INT)   SELECT * FROM return_transaction
WHERE return_transaction.returnID = id
And return_transaction.isDeleted = 0$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `return_SoftDeletion` (IN `id` INT)   UPDATE return_transaction SET
	return_transaction.isDeleted = 1
WHERE return_transaction.returnID = id$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `stocking_DeleteTransaction` (IN `id` INT(50))   DELETE  FROM stocking_transactions 
WHERE
	stocking_transactions.transactionID = id$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `stocking_recordItemRecieved` (IN `id` INT(50), IN `delivered_by` VARCHAR(50), IN `recieved_by` VARCHAR(50), IN `purchase_order` INT(50))   INSERT INTO stocking_transactions(
    stocking_transactions.transactionID,
    stocking_transactions.delivered_by,
    stocking_transactions.recieved_by,
    stocking_transactions.purchase_order
)
VALUES(
    id,
    delivered_by,
    recieved_by,
    purchase_order
)
ON DUPLICATE KEY UPDATE
   stocking_transactions.delivered_by = VALUES(delivered_by),
   stocking_transactions.recieved_by = VALUES(recieved_by),
   stocking_transactions.purchase_order = VALUES(purchase_order)$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `stocking_recordProducts` (IN `transactionID` INT(50), IN `product_name` VARCHAR(50), IN `product_quantity` INT(50), IN `product_price` INT, IN `category` VARCHAR(100))   INSERT INTO products(
    products.transactionID,
    products.product_name,
    products.product_quantity,
    products.price,
    products.category
    )
VALUES(
    transactionID,
    product_name,
    product_quantity,
    product_price,
    category
    )$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `stocking_SearchTransaction` (IN `keyword` VARCHAR(50))   BEGIN
    SELECT * FROM stocking_transactions 
    WHERE transactionID LIKE CONCAT( keyword) 
      ;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `stocking_UpdateRecord` (IN `id` INT(50), IN `delivered_by` VARCHAR(50), IN `recieved_by` VARCHAR(50), IN `purchase_order` INT(50))   UPDATE stocking_transactions SET
	stocking_transactions.delivered_by = delivered_by,
    stocking_transactions.recieved_by = recieved_by,
    stocking_transactions.purchase_order = purchase_order
    
WHERE stocking_transactions.transactionID = id$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `transfer_CreateRecord` (IN `transferID` INT(50), IN `inventoryID` INT(50), IN `storage` VARCHAR(50), IN `handled_by` VARCHAR(50))   INSERT INTO inventory_transfer(
    inventory_transfer.transferID,
    inventory_transfer.inventoryID,
    inventory_transfer.storage,
    inventory_transfer.handled_by)
VALUES(
    transferID,
    inventoryID,
    storage,
    handled_by
    )
ON DUPLICATE KEY UPDATE
 inventory_transfer.inventoryID = VALUES(inventoryID),
  inventory_transfer.storage = VALUES(storage),
   inventory_transfer.handled_by =  VALUES(handled_by)$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `transfer_ReadAll` ()   SELECT * FROM inventory_transfer
WHERE inventory_transfer.isDeleted = 0$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `transfer_Search` (IN `id` INT)   SELECT * FROM inventory_transfer
WHERE inventory_transfer.transferID = id
AND inventory_transfer.isDeleted = 0$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `transfer_SoftDelete` (IN `transferID` INT)   UPDATE inventory_transfer SET
inventory_transfer.isDeleted = 1
WHERE inventory_transfer.transferID = transferID$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `transfer_update` (IN `transferID` INT(50), IN `inventoryID` INT(50), IN `storage` VARCHAR(50), IN `handled_by` VARCHAR(50))   UPDATE inventory_transfer SET
inventory_transfer.inventoryID = inventoryID,
inventory_transfer.storage = storage,
inventory_transfer.handled_by = handled_by

WHERE inventory_transfer.transferID = transferID$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `transfer_ViewAllRecords` ()   SELECT * FROM inventory_transfer
WHERE inventory_transfer.isDeleted = 0$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `withdrawal_Create` (IN `withdrawalID` INT(50), IN `inventoryID` INT(50), IN `purpose` VARCHAR(50), IN `withdrawnBy` VARCHAR(100), IN `quantity` INT(50))   INSERT INTO withdrawal_transaction(
    withdrawal_transaction.withdrawalID,
    withdrawal_transaction.inventoryID,
    withdrawal_transaction.purpose,
    withdrawal_transaction.withdrawnBy,
    withdrawal_transaction.quantity
    )
VALUES(
    withdrawalID,
    inventoryID,
    purpose,
    withdrawnBy,
    quantity
    )
ON DUPLICATE KEY UPDATE
    withdrawal_transaction.inventoryID = VALUES(inventoryID),
    withdrawal_transaction.purpose = VALUES(purpose),
    withdrawal_transaction.withdrawnBy = VALUES(withdrawnBy),
    withdrawal_transaction.quantity = VALUES(quantity)$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `withdrawal_ReadAll` ()   SELECT * FROM withdrawal_transaction
WHERE withdrawal_transaction.isDeleted = 0$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `withdrawal_SearchRecord` (IN `id` INT(50))   SELECT * FROM withdrawal_transaction
WHERE withdrawal_transaction.isDeleted = 0 AND withdrawal_transaction.sequence_id = id$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `withdrawal_softDelete` (IN `sequence_id` INT)   UPDATE withdrawal_transaction SET withdrawal_transaction.isDeleted = 1
WHERE withdrawal_transaction.sequence_id = sequence_id$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `withdrawal_update` (IN `withdrawalID` INT(50), IN `inventoryID` INT(50), IN `purpose` VARCHAR(50), IN `withdrawnBy` VARCHAR(50))   UPDATE withdrawal_transaction SET 
withdrawal_transaction.inventoryID = inventoryID,
withdrawal_transaction.purpose = purpose,
withdrawal_transaction.withdrawnBy = withdrawnBy

WHERE withdrawal_transaction.withdrawalID = withdrawalID$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `costumer_purchase`
--

CREATE TABLE `costumer_purchase` (
  `orderID` int(11) NOT NULL,
  `withdrawalID` int(11) DEFAULT NULL,
  `customerName` varchar(50) DEFAULT NULL,
  `recorded_at` datetime NOT NULL DEFAULT current_timestamp(),
  `isDeleted` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC;

--
-- Dumping data for table `costumer_purchase`
--

INSERT INTO `costumer_purchase` (`orderID`, `withdrawalID`, `customerName`, `recorded_at`, `isDeleted`) VALUES
(1, 1, 'Jay Ann Salazar', '2024-05-24 11:50:14', 1),
(2, 2, 'DRAKe ', '2024-05-25 22:46:44', 0),
(3, 3, 'Mae', '2024-05-25 22:47:59', 0),
(4, 4, 'Mae', '2024-05-25 22:50:41', 0),
(5, 5, 'Mae', '2024-05-26 16:07:16', 0),
(6, 6, 'Mae', '2024-05-26 16:07:49', 0),
(7, 7, 'Mae', '2024-05-26 16:09:23', 0),
(8, 8, 'Mae', '2024-05-26 16:11:53', 0),
(9, 9, 'Mae', '2024-05-26 16:13:37', 0),
(10, 10, 'Mae', '2024-05-26 16:15:25', 0),
(11, 11, 'Mae', '2024-05-26 16:16:35', 0),
(12, 12, 'Mae', '2024-05-26 16:18:54', 0),
(13, 13, 'Mae', '2024-05-26 16:21:36', 0),
(14, 14, 'Rasmus Lerdurf', '2024-05-26 16:54:55', 1),
(15, 15, 'DRAK ', '2024-05-30 13:04:41', 1),
(16, 16, 'Rasmus Lerdurf', '2024-05-26 17:02:41', 0),
(17, 17, 'Rasmus Lerdurf', '2024-05-26 17:06:41', 0),
(18, 18, 'Rasmus Lerdurf', '2024-05-26 17:11:19', 0),
(19, 19, 'Hanna ', '2024-05-26 17:13:34', 0),
(20, 20, 'Hanna ', '2024-05-26 17:18:42', 0),
(21, 21, 'Hanna ', '2024-05-26 17:20:58', 0),
(22, 22, 'Gideon Santiago ', '2024-05-27 12:41:01', 0),
(23, 23, 'Gideon Santiago ', '2024-05-29 19:29:35', 0),
(24, 24, 'Rivia ', '2024-05-29 20:00:57', 0),
(25, 25, 'DRAKe ', '2024-05-31 10:39:50', 1),
(111, 111, 'aa', '2024-05-31 10:37:26', 0);

-- --------------------------------------------------------

--
-- Table structure for table `inventory_transfer`
--

CREATE TABLE `inventory_transfer` (
  `transferID` int(11) NOT NULL,
  `inventoryID` int(11) DEFAULT NULL,
  `storage` varchar(50) NOT NULL,
  `initiated_at` datetime DEFAULT current_timestamp(),
  `handled_by` varchar(50) DEFAULT NULL,
  `isDeleted` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC;

--
-- Dumping data for table `inventory_transfer`
--

INSERT INTO `inventory_transfer` (`transferID`, `inventoryID`, `storage`, `initiated_at`, `handled_by`, `isDeleted`) VALUES
(1, 7, 'storage 1', '2024-05-28 09:15:50', 'Jay ann Gahi', 1),
(2, 7, 'inventory room 2', '2024-05-28 09:58:41', 'Triss Merigold', 1),
(3, 17, 'equipment storage', '2024-05-28 09:59:25', 'Tomira', 1),
(4, 37, 'stock room 5', '2024-05-30 08:23:16', 'Roach', 0),
(5, 7, 'storage 1', '2024-05-30 13:30:39', 'Renz Santiago', 1),
(6, 29, 'stock room 101222', '2024-05-31 13:57:42', 'Roach', 0);

-- --------------------------------------------------------

--
-- Table structure for table `products`
--

CREATE TABLE `products` (
  `inventoryID` int(11) NOT NULL,
  `transactionID` int(11) DEFAULT NULL,
  `product_name` varchar(50) DEFAULT NULL,
  `product_quantity` int(11) DEFAULT NULL,
  `price` double NOT NULL,
  `added_at` datetime DEFAULT current_timestamp(),
  `transferID` int(11) DEFAULT NULL,
  `category` varchar(255) DEFAULT NULL,
  `isDeleted` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC;

--
-- Dumping data for table `products`
--

INSERT INTO `products` (`inventoryID`, `transactionID`, `product_name`, `product_quantity`, `price`, `added_at`, `transferID`, `category`, `isDeleted`) VALUES
(7, 5, 'Vulca', 20, 150.9, '2024-05-16 12:34:56', 3, 'Roof Sealant', 1),
(8, 5, 'Vulca Seal', 20, 150.9, '2024-05-16 12:34:56', NULL, 'Roof Sealant', 1),
(17, 23, 'Bosny Spray PAint', 237, 150, '2024-05-22 09:57:41', NULL, 'Paint', 0),
(18, 23, 'Water Pump', 10, 4999.99, '2024-05-22 09:57:41', NULL, 'Machine', 0),
(19, 25, 'Mighty Bond', 20, 150.9, '2024-05-22 12:11:42', NULL, 'BASTA', 0),
(20, 25, 'Plywood 2 inches thick', 39, 575.5, '2024-05-22 12:11:42', NULL, 'Construction Materials', 0),
(21, 26, 'Jack Hammer', 5, 0, '2024-05-29 17:51:57', NULL, '50000', 0),
(22, 26, 'Air Blower 600 watts', 10, 0, '2024-05-29 17:51:57', NULL, '589.99', 0),
(23, 27, 'Jack Hammer', 5, 0, '2024-05-29 18:00:03', NULL, '50000', 1),
(29, 27, 'Steel Brush Size 1', 150, 25.5, '2024-05-29 18:05:04', 5, 'brush', 0),
(30, 28, 'Jack Hammer', 5, 0, '2024-05-29 18:10:02', NULL, '50000', 0),
(31, 28, 'Air Blower 600 watts', 10, 0, '2024-05-29 18:10:02', NULL, '589.99', 0),
(32, 29, 'Jack Hammer', 5, 0, '2024-05-29 18:13:06', NULL, '50000', 0),
(33, 29, 'Air Blower 600 watts', 10, 0, '2024-05-29 18:13:06', NULL, '589.99', 0),
(34, 30, 'Jack Hammer', 5, 0, '2024-05-29 18:15:02', NULL, '50000', 0),
(35, 30, 'Air Blower 600 watts', 10, 0, '2024-05-29 18:15:02', NULL, '589.99', 0),
(36, 31, 'Jack Hammer', 5, 0, '2024-05-29 18:17:58', NULL, '50000', 0),
(37, 31, 'Air Blower 600 watts', 10, 0, '2024-05-29 18:17:58', 4, '589.99', 1),
(38, 32, 'Jack Hammer', 5, 50000, '2024-05-29 18:19:28', NULL, 'Power Tools', 0),
(39, 32, 'Air Blower 600 watts', 10, 590, '2024-05-29 18:19:28', NULL, 'Power Tools', 0),
(40, 33, 'Jack Hammer', 5, 50000, '2024-05-30 12:17:30', NULL, 'Power Tools', 0),
(41, 33, 'Air Blower 600 watts', 10, 590, '2024-05-30 12:17:30', NULL, 'Power Tools', 0);

-- --------------------------------------------------------

--
-- Table structure for table `return_transaction`
--

CREATE TABLE `return_transaction` (
  `returnID` int(11) NOT NULL,
  `orderID` int(11) DEFAULT NULL,
  `handled_by` varchar(100) DEFAULT NULL,
  `approval_status` int(11) NOT NULL DEFAULT 0,
  `status` int(11) NOT NULL DEFAULT 0,
  `recorded_at` datetime NOT NULL DEFAULT current_timestamp(),
  `isDeleted` int(11) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC;

--
-- Dumping data for table `return_transaction`
--

INSERT INTO `return_transaction` (`returnID`, `orderID`, `handled_by`, `approval_status`, `status`, `recorded_at`, `isDeleted`) VALUES
(1, 2, 'Jay ann Remorosa', 1, 1, '2024-05-27 15:09:04', 0),
(2, 1, 'Jay ann Gahi', 1, 0, '2024-05-27 15:13:08', 1),
(3, 3, 'Staff 2', 0, 0, '2024-05-27 17:01:12', 1),
(4, 4, 'Yennefer of Veghenberg', 0, 0, '2024-05-28 08:24:26', 0),
(5, 6, 'Trisss Merigold', 1, 1, '2024-05-29 22:13:19', 0),
(6, 111, 'Anonymous', 1, 1, '2024-05-30 13:22:30', 1),
(7, 24, 'Anonymoooussss', 1, 0, '2024-05-31 13:25:06', 1);

-- --------------------------------------------------------

--
-- Table structure for table `stocking_transactions`
--

CREATE TABLE `stocking_transactions` (
  `transactionID` int(11) NOT NULL,
  `delivered_by` varchar(50) DEFAULT NULL,
  `recorded_at` datetime DEFAULT current_timestamp(),
  `recieved_by` varchar(50) DEFAULT NULL,
  `purchase_order` varchar(200) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC;

--
-- Dumping data for table `stocking_transactions`
--

INSERT INTO `stocking_transactions` (`transactionID`, `delivered_by`, `recorded_at`, `recieved_by`, `purchase_order`) VALUES
(1, 'JNT express', '2024-05-16 12:34:56', 'Staff 9', '36'),
(2, 'John Doe', '2024-05-16 12:34:56', 'Jane Smith', 'Order #12345'),
(3, 'John Doe', '2024-05-16 12:34:56', 'Jane Smith', 'Order #12345'),
(4, 'John Doe', '2024-05-16 12:34:56', 'Jane Smith', 'Order #12345'),
(5, 'John Doe', '2024-05-16 12:34:56', 'Jane Smith', 'Order #12345'),
(7, 'John Doess', '2024-05-16 12:34:56', 'Jane Does', 'PO 2121'),
(23, 'Jay ann', '2024-05-22 09:57:41', 'Triss', '222'),
(25, 'Albert Einstein', '2024-05-22 12:11:42', 'Jay ann Salazar', '12345'),
(26, 'FLASH EXPRESS', '2024-05-29 17:51:57', 'Keira Mitz', '26'),
(27, 'JNT', '2024-05-29 18:00:03', 'Yennefer', '27'),
(28, 'JNT', '2024-05-29 18:10:02', 'Yennefer', '27'),
(29, 'JNT', '2024-05-29 18:13:06', 'Yennefer', '27'),
(30, 'JNT', '2024-05-29 18:15:02', 'Yennefer', '27'),
(31, 'JNT', '2024-05-29 18:17:58', 'Yennefer', '27'),
(32, 'JNT', '2024-05-29 18:19:28', 'Yennefer', '27'),
(33, 'LBCS', '2024-05-30 12:17:30', 'Staff 3', '33'),
(34, 'LBCSS', '2024-05-31 09:50:07', 'Staff 9', '35'),
(35, 'LBCSS', '2024-05-31 10:00:23', 'Staff 9', '36'),
(99, 'John Doess', '2024-05-16 12:34:56', 'Jane Does', '12312'),
(100, 'lbc', '2024-05-22 11:06:58', 'jay ann', '1001'),
(101, 'flash', '2024-05-31 15:38:27', 'Staff 10', '36'),
(1234, 'John Doe', '2024-05-16 12:34:56', 'Jane Smith', 'Order #12345'),
(1235, 'LBCS', '2024-05-31 09:47:14', 'Staff 3', '33');

-- --------------------------------------------------------

--
-- Table structure for table `withdrawal_transaction`
--

CREATE TABLE `withdrawal_transaction` (
  `sequence_id` int(11) NOT NULL,
  `withdrawalID` int(11) NOT NULL,
  `inventoryID` int(11) DEFAULT NULL,
  `purpose` varchar(50) DEFAULT NULL,
  `withdrawnBy` varchar(50) DEFAULT NULL,
  `quantity` int(11) NOT NULL,
  `recorded_at` datetime NOT NULL DEFAULT current_timestamp(),
  `isDeleted` int(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC;

--
-- Dumping data for table `withdrawal_transaction`
--

INSERT INTO `withdrawal_transaction` (`sequence_id`, `withdrawalID`, `inventoryID`, `purpose`, `withdrawnBy`, `quantity`, `recorded_at`, `isDeleted`) VALUES
(3, 10, 8, 'purchase', 'Pepe', 0, '2024-05-26 16:58:53', 1),
(4, 14, 20, 'purchase', 'ANONONO', 0, '2024-05-26 16:58:53', 1),
(5, 16, 18, 'purchase', 'Pepe', 1, '2024-05-26 17:02:41', 1),
(6, 17, 18, 'purchase', 'Pepe', 1, '2024-05-26 17:06:41', 0),
(7, 18, 18, 'purchase', 'Pepe', 1, '2024-05-26 17:11:19', 0),
(8, 19, 20, 'purchase', 'Pepe', 1, '2024-05-26 17:13:34', 0),
(9, 21, 19, 'purchase', 'Pepe', 1, '2024-05-26 17:20:58', 0),
(13, 23, 29, 'purchase', 'Geralt', 50, '2024-05-29 19:29:35', 0),
(14, 23, 17, 'purchase', 'Geralt', 11, '2024-05-29 19:29:35', 0),
(15, 24, 7, 'purchase', 'Geralt', 1, '2024-05-29 20:00:57', 0),
(16, 24, 17, 'purchase', 'Geralt', 1, '2024-05-29 20:00:57', 0),
(17, 14, 20, 'purchase', 'ANONONO', 10, '2024-05-29 22:01:21', 0),
(18, 15, 7, 'purchase', 'FRED', 1, '2024-05-30 13:04:41', 0),
(19, 15, 17, 'purchase', 'FRED', 1, '2024-05-30 13:04:41', 0),
(20, 99999, 7, 'purchase', 'adaw', 1, '2024-05-31 12:18:01', 0),
(21, 20, 17, 'purchase', 'wabalo', 10, '2024-05-31 12:19:23', 0),
(22, 20, 17, 'purchase', 'wabalo', 10, '2024-05-31 12:20:03', 0),
(23, 20, 17, 'purchase', 'wabalos', 10, '2024-05-31 12:21:31', 0);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `costumer_purchase`
--
ALTER TABLE `costumer_purchase`
  ADD PRIMARY KEY (`orderID`) USING BTREE,
  ADD UNIQUE KEY `withdrawalID_2` (`withdrawalID`),
  ADD KEY `withdrawalID` (`withdrawalID`) USING BTREE;

--
-- Indexes for table `inventory_transfer`
--
ALTER TABLE `inventory_transfer`
  ADD PRIMARY KEY (`transferID`) USING BTREE,
  ADD KEY `inventoryID` (`inventoryID`) USING BTREE;

--
-- Indexes for table `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`inventoryID`) USING BTREE,
  ADD KEY `transactionID` (`transactionID`) USING BTREE;

--
-- Indexes for table `return_transaction`
--
ALTER TABLE `return_transaction`
  ADD PRIMARY KEY (`returnID`) USING BTREE,
  ADD UNIQUE KEY `orderID` (`orderID`);

--
-- Indexes for table `stocking_transactions`
--
ALTER TABLE `stocking_transactions`
  ADD PRIMARY KEY (`transactionID`) USING BTREE;

--
-- Indexes for table `withdrawal_transaction`
--
ALTER TABLE `withdrawal_transaction`
  ADD PRIMARY KEY (`sequence_id`),
  ADD KEY `inventoryID` (`inventoryID`) USING BTREE;

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `costumer_purchase`
--
ALTER TABLE `costumer_purchase`
  MODIFY `orderID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=112;

--
-- AUTO_INCREMENT for table `inventory_transfer`
--
ALTER TABLE `inventory_transfer`
  MODIFY `transferID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `products`
--
ALTER TABLE `products`
  MODIFY `inventoryID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=42;

--
-- AUTO_INCREMENT for table `return_transaction`
--
ALTER TABLE `return_transaction`
  MODIFY `returnID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `stocking_transactions`
--
ALTER TABLE `stocking_transactions`
  MODIFY `transactionID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1236;

--
-- AUTO_INCREMENT for table `withdrawal_transaction`
--
ALTER TABLE `withdrawal_transaction`
  MODIFY `sequence_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=24;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `inventory_transfer`
--
ALTER TABLE `inventory_transfer`
  ADD CONSTRAINT `inventory_transfer_ibfk_1` FOREIGN KEY (`inventoryID`) REFERENCES `products` (`inventoryID`);

--
-- Constraints for table `products`
--
ALTER TABLE `products`
  ADD CONSTRAINT `products_ibfk_1` FOREIGN KEY (`transactionID`) REFERENCES `stocking_transactions` (`transactionID`);

--
-- Constraints for table `return_transaction`
--
ALTER TABLE `return_transaction`
  ADD CONSTRAINT `orderID` FOREIGN KEY (`orderID`) REFERENCES `costumer_purchase` (`orderID`);

--
-- Constraints for table `withdrawal_transaction`
--
ALTER TABLE `withdrawal_transaction`
  ADD CONSTRAINT `withdrawal_transaction_ibfk_1` FOREIGN KEY (`inventoryID`) REFERENCES `products` (`inventoryID`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
