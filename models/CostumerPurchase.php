<?php
class CostumerPurchase
{
    private $conn;

    public $orderID;
    public $withdrawalID;
    public $customerName;
    public $total_amount;

    public function __construct($db)
    {
        $this->conn = $db;
        
    }
    public function createUpdateCostumerPurchase($orderID, $withdrawalID, $customerName)
    {
        $query = "CALL customerPurchase_CreateRecord(:orderID, :withdrawalID, :customerName)";
        $stmt = $this->conn->prepare($query);
        if($stmt == false)
        {
            die("Creating Record Failed!". $stmt->errorInfo());
        }
        $stmt->bindParam(":orderID", $orderID);
        $stmt->bindParam(":withdrawalID", $withdrawalID);
        $stmt->bindParam(":customerName", $customerName);
      
        if( $stmt->execute())
        {
            echo json_encode(array("message"=> "Request processed successfully!"));
        }
        
    }

    public function readAllOrderRecords()
    {
        $query = "CALL customerPurchase_ReadAllOrderRecords()";
        $stmt = $this->conn->prepare($query);

        $stmt->execute();
        $result = $stmt->rowCount();
     
        if ($result  > 0) {
            $order_array = array();
            while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
                extract($row);
                $order_item = array(
                    "orderID" => $orderID,
                    "withdrawalID" => $withdrawalID,
                    "customerName" => $customerName,    
                    "recorded_at" => $recorded_at
                );
                array_push($order_array, $order_item);
            }
            http_response_code(200);
            echo json_encode($order_array);
        } else {
            http_response_code(400);
            echo json_encode(array("message" => "No transactions found!"));
        }
    }

  

    public function searchPurchase($keyword)
    {
        $query = "CALL customerPurchase_search(:keyword)";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(":keyword",$keyword );
        $stmt->execute();
        $result = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        $num = count($result);

        if ($num > 0) {
            echo json_encode($result);
        } else {
            http_response_code(404);
            echo json_encode(array("message" => "No records found!"));
        }   
      
    }

    public function deletePurchase($orderID)
    {
        $query = "CALL customerPurchase_Delete(:id)";
        $stmt = $this->conn->prepare($query);
        if($stmt == false)
        {
            die("Failed to delete purchase order");
        }
        $stmt->bindParam(":id", $orderID);
        if($stmt->execute())
        {
            echo json_encode(array("message" => "Deleted Successfully!"));
        }
           
    }
}