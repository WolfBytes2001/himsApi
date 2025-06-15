<?php
class Products{
    private $conn;

    public function __construct($db)
    {
        $this->conn = $db;
    }

    public function createUpdateProducts($transactionID, $product_name, $product_quantity, $product_price, $category, $inventoryID)
    {
        $query = "CALL stocking_recordProducts(:transactionID, :product_name, :product_quantity, :product_price, :category, :inventoryID)";
        $stmt = $this->conn->prepare($query);

        if($stmt === false)
        {
            die("Failed to process the request!");
        }

        $stmt->bindParam(':transactionID', $transactionID);
        $stmt->bindParam(':product_name', $product_name);
        $stmt->bindParam(':product_quantity', $product_quantity);
        $stmt->bindParam(':product_price', $product_price);
        $stmt->bindParam(':category', $category);
        $stmt->bindParam(':inventoryID', $inventoryID);

        if($stmt->execute())
        {
            echo json_encode(array("message"=>"Request processed successfully"));
        }
    }

    public function getProducts()
    {
        $query = "CALL products_ViewAllProducts()";
        $stmt = $this->conn->prepare($query);
        $stmt->execute();
        
        $num = $stmt->rowCount();

        if ($num > 0) {
            $product_array = array();
            while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
                extract($row);
                $product_items = array(
                    "inventory_id" => $inventoryID,
                    "transactionID" => $transactionID,
                    "product_name" => $product_name,
                    "category" => $category,
                    "product_quantity" => $product_quantity,
                    "price" =>$price,
                    "added_at" => $added_at,
                    "transfer_id" => $transferID,
                    "isDeleted" => $isDeleted
                );
                array_push($product_array, $product_items);
            }
            http_response_code(200);
            echo json_encode($product_array);
        } else {
            http_response_code(404);
            echo json_encode(array("message" => "no product records"));
        }
    }

    

    public function deleteProduct($inventoryID) {
        $query = "CALL products_DeleteProduct(:inventoryID)";
        $stmt = $this->conn->prepare($query);

        if ($stmt == false) {
            die("Execution error: " . $stmt->errorInfo()[2]);
        }

        $stmt->bindParam(":inventoryID", $inventoryID, PDO::PARAM_STR);
        return $stmt->execute();
    }

    public function searchProduct($keyword)
    {
        $query = "CALL products_SearchProduct(:keyword)" ;
        $stmt = $this->conn->prepare($query);
        if($stmt == false)
        {
            die("Query Error". $stmt->errorInfo()[2]);
        }
       
        $stmt->bindParam(":keyword", $keyword, PDO::PARAM_STR);

        if (!$stmt->execute()) {
            die("Execute error: " . $stmt->errorInfo()[2]);
        }
    
        $result = $stmt->fetchAll(PDO::FETCH_ASSOC);
        return $result;
    }

    public function updateProductQuantity($quantitySold, $inventoryID)
    {
        try {
            $query = "CALL product_Withdrawal(:id, :quantity)";
            $stmt = $this->conn->prepare($query);

            if($stmt == false)
            {
                throw new Exception("Updating stock quantity for product with inventory id:" . $inventoryID . "failed!");
                
            }

            $stmt->bindParam(":quantity", $quantitySold);
            $stmt->bindParam(":id", $inventoryID);
            $stmt->execute();
            return $stmt;
        } catch (\Throwable $th) {
            error_log("Error updating stock quantity: " . $th->getMessage());
            return false; 
        }
    }
    
    public function updateTransferID($inventoryID, $transferID)
    {
        $query = "CALL product_Transfer(:inventoryID, :transferID)";
        $stmt = $this->conn->prepare($query);
        if($stmt == false)
        {
            die("Failed to update transfer id of target product! " . $stmt->errorInfo());
        }
        $stmt->bindParam(":inventoryID", $inventoryID);
        $stmt->bindParam(":transferID", $transferID);
        $stmt->execute();
        return $stmt;
    }
    
}
?>
