<?php
class StockingTransactions
{
    private $conn;
   
    
    public function __construct($db)
    {
        $this->conn = $db;
    }

    public function getAllItemRecieveTransactions()
    {
        $query = "CALL readItemReceived()";
        $stmt = $this->conn->prepare($query);
        $stmt->execute();

        $num = $stmt->rowCount();

        if($num > 0)
        {
            $itemRecieve_array = array();
            while($row = $stmt->fetch(PDO::FETCH_ASSOC))
            {
                extract($row);
                $itemRecieve_item = array(
                    "transactionID" => $transactionID,
                    "delivered_by" => $delivered_by,
                    "recieved_by" => $recieved_by,
                    "purchase_order" => $purchase_order,
                    "recorded_at" => $recorded_at
                );
                array_push($itemRecieve_array, $itemRecieve_item);
            }
            http_response_code(200);
            echo json_encode($itemRecieve_array);
        }
        else
        {
           
            echo json_encode(array("message" => "No transactions found!"));
        }
        return json_encode($itemRecieve_array);
    }


    public function createAndUpdateStocking($transactionID, $delivered_by, $recieved_by, $purchase_order)
    {
        $query = "CALL stocking_recordItemRecieved(:transactionID, :delivered_by, :recieved_by, :purchase_order)";
        $stmt = $this->conn->prepare($query);
        if($stmt == false)
        {
            die("Creating Record Failed!". $stmt->errorInfo()[2]);
        }
        $stmt->bindParam(':transactionID', $transactionID);
        $stmt->bindParam(':delivered_by', $delivered_by);
        $stmt->bindParam(':recieved_by', $recieved_by);
        $stmt->bindParam(':purchase_order', $purchase_order);

        if( $stmt->execute())
        {
            echo json_encode(array("message"=> "Request processed successfully!"));
        }
      

    }

    public function searchItemRecieveTransactions($keyword)
    {
        $query = "CALL stocking_SearchTransaction(:keyword)";
        $stmt = $this->conn->prepare($query);
        if ($stmt === false) {
            die("Prepare error: " . $this->conn->errorInfo()[2]);
        }
    
        $likeTerm = "{$keyword}";
        $stmt->bindParam(":keyword", $likeTerm, PDO::PARAM_STR);
    
        if (!$stmt->execute()) {
            die("Execute error: " . $stmt->errorInfo()[2]);
        }
    
        $result = $stmt->fetchAll(PDO::FETCH_ASSOC);
        echo json_encode($result);
        
    }





    
}




?>
