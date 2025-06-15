<?php

class InventoryTransfer
{
    private $conn;
    public $transferID;
    public $inventoryID;
    public $storage;
    public $handled_by;


    public function __construct($db)
    {
        $this->conn = $db;
    }

    public function createUpdateTransferRecord($transferID, $inventoryID, $storage, $handled_by)
    {
        $query = "CALL transfer_CreateRecord(:transferID, :inventoryID, :storage, :handled_by)";
        $stmt = $this->conn->prepare($query);
        if($stmt == false)
        {
            die("Failed to process request! ". $stmt->errorInfo());
        }
        $stmt->bindParam("transferID", $transferID);
        $stmt->bindParam("inventoryID", $inventoryID);
        $stmt->bindParam("storage", $storage);
        $stmt->bindParam("handled_by", $handled_by);

        if($stmt->execute())
        {
            echo json_encode(array("message"=>"Request processed successfully"));
        }
       
    }

    public function readAllTransferRecord()
    {
        $query = "CALL transfer_ViewAllRecords()";
        $stmt = $this->conn->prepare($query);
        $stmt->execute();
        $num = $stmt->rowCount();

   
        if($num > 0)
        {
            $transfer_array = array();
            while($row = $stmt->fetch(PDO:: FETCH_ASSOC))
            {
                extract($row);
                $transfer_item = array(
                    "transferID" => $transferID,
                    "inventoryID"=>$inventoryID,
                    "storage"=> $storage,
                    "initiated_at"=>$initiated_at,
                    "handled_by"=>$handled_by,
                    "isDeleted"=>$isDeleted

                );
                array_push($transfer_array, $transfer_item);
            }
        
            echo json_encode($transfer_array);
        }
        else
        {
            echo json_encode(array("message"=>"No transfer records found!"));
        }
        }

   

    public function deleteTransferRecord($transferID)
    {
        $query = "CALL transfer_SoftDelete(:transferID)";
        $stmt = $this->conn->prepare($query);
        if($stmt == false)
        {
            die("Failed to delete a transfer record!");
        }

        $stmt->bindParam(":transferID", $transferID);
        if($stmt->execute())
        {
            echo json_encode(array("message"=>"Request Processed Successfully!"));
        }
        
    }

    public function searchTransferRecord($transferID)
    {
        $query = "CALL transfer_Search(:id)";
        $stmt= $this->conn->prepare($query);
        if($stmt == false)
        {
            die("Failed to process search ". $stmt->errorInfo());
        }
        $stmt->bindParam(":id", $transferID);
        $stmt->execute();
        $row = $stmt->fetchAll(PDO::FETCH_ASSOC);
        $num = count($row);
        if($num > 0)
        {
            echo json_encode($row);
        }
        else
        {
            http_response_code(404);
            echo json_encode(array("message" => "No transactions found."));
        }
    }
}
