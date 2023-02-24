-- mushthaq_sa_2023.customers definition

CREATE TABLE `customers` (
  `customer_id` int NOT NULL AUTO_INCREMENT,
  `first_name` varchar(50) NOT NULL,
  `last_name` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `phone` varchar(20) NOT NULL,
  `address` varchar(200) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`customer_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- mushthaq_sa_2023.items definition

CREATE TABLE `items` (
  `item_id` int NOT NULL AUTO_INCREMENT,
  `item_name` varchar(100) NOT NULL,
  `item_description` varchar(255) DEFAULT NULL,
  `item_image` varchar(255) DEFAULT NULL,
  `price` decimal(10,2) NOT NULL,
  `description` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`item_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- mushthaq_sa_2023.orders definition

CREATE TABLE `orders` (
  `order_id` int NOT NULL AUTO_INCREMENT,
  `customer_id` int NOT NULL,
  `order_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `total_amount` decimal(10,2) NOT NULL,
  `payment_status` enum('pending','paid','cancelled') DEFAULT 'pending',
  `delivery_status` enum('pending','in_progress','delivered','cancelled') DEFAULT 'pending',
  PRIMARY KEY (`order_id`),
  KEY `customer_id` (`customer_id`),
  CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- mushthaq_sa_2023.stock definition

CREATE TABLE `stock` (
  `stock_id` int NOT NULL AUTO_INCREMENT,
  `item_id` int NOT NULL,
  `quantity` int NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `includes` varchar(100) NOT NULL,
  `color` varchar(100) NOT NULL,
  `material` varchar(100) NOT NULL,
  `intended_for` varchar(100) NOT NULL,
  `received_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`stock_id`),
  KEY `item_id` (`item_id`),
  CONSTRAINT `stock_ibfk_1` FOREIGN KEY (`item_id`) REFERENCES `items` (`item_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- mushthaq_sa_2023.subscribers definition

CREATE TABLE `subscribers` (
  `sub_id` int NOT NULL AUTO_INCREMENT,
  `item_id` int NOT NULL,
  `sub_email` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`sub_id`),
  KEY `item_id` (`item_id`),
  CONSTRAINT `subscribers_ibfk_1` FOREIGN KEY (`item_id`) REFERENCES `items` (`item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- mushthaq_sa_2023.order_items definition

CREATE TABLE `order_items` (
  `order_item_id` int NOT NULL AUTO_INCREMENT,
  `order_id` int NOT NULL,
  `item_id` int NOT NULL,
  `quantity` int NOT NULL,
  `price` decimal(10,2) NOT NULL,
  PRIMARY KEY (`order_item_id`),
  KEY `order_id` (`order_id`),
  KEY `item_id` (`item_id`),
  CONSTRAINT `order_items_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`),
  CONSTRAINT `order_items_ibfk_2` FOREIGN KEY (`item_id`) REFERENCES `items` (`item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


INSERT INTO mushthaq_sa_2023.customers
(first_name, last_name, email, phone, address, created_at)
VALUES('', '', '', '', '', CURRENT_TIMESTAMP);
INSERT INTO mushthaq_sa_2023.items
(item_name, item_description, item_image, price, description, created_at)
VALUES('', '', '', 0, '', CURRENT_TIMESTAMP);
INSERT INTO mushthaq_sa_2023.order_items
(order_id, item_id, quantity, price)
VALUES(0, 0, 0, 0);
INSERT INTO mushthaq_sa_2023.orders
(customer_id, order_date, total_amount, payment_status, delivery_status)
VALUES(0, CURRENT_TIMESTAMP, 0, 'pending', 'pending');
INSERT INTO mushthaq_sa_2023.stock
(item_id, quantity, price, includes, color, material, intended_for, received_at)
VALUES(0, 0, 0, '', '', '', '', CURRENT_TIMESTAMP);
INSERT INTO mushthaq_sa_2023.subscribers
(item_id, sub_email)
VALUES(0, '');

