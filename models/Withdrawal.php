<?php
class Withdrawal_Transaction
{
    private $conn;

    public $withdrawalID;
    public $inventoryID;
    public $purpose;
    public $withdrawnBy;
    public $quantity;

    public function __construct($db)
    {
        $this->conn = $db;
    }

    public function createUpdateWithdrawalRecord($withdrawalID, $inventoryID, $purpose, $withdrawnBy, $quantity)
    {
        $query = "CALL withdrawal_Create(:id, :invID, :purpose, :withBy, :quantity)";
        $stmt = $this->conn->prepare($query);
        if ($stmt == false) {
            die("Failed to process request! " . $stmt->errorInfo());
        }
        $stmt->bindParam(":id", $withdrawalID);
        $stmt->bindParam(":invID", $inventoryID);
        $stmt->bindParam(":purpose", $purpose);
        $stmt->bindParam(":withBy", $withdrawnBy);
        $stmt->bindParam(":quantity", $quantity);

        if( $stmt->execute())
        {
            echo json_encode(array("message"=>"Request processed successfully"));
        }
    }

    public function readAllWithdrawalRecords()
    {
        $query = "CALL withdrawal_ReadAll()";
        $stmt =$this->conn->prepare($query);
        $stmt->execute();
     
        $num = $stmt->rowCount();

        if($num > 0)
        {
            $withdrawal_array = array();
            while($row = $stmt->fetch(PDO::FETCH_ASSOC))
            {
                extract($row);

                $withdrawal_item = array
                (   
                    "sequence_id" => $sequence_id,
                    "withdrawalID" => $withdrawalID,
                    "inventoryID" => $inventoryID,
                    "purpose" => $purpose,
                    "withdrawnBy" =>$withdrawnBy,
                    "quantity" => $quantity
                );
                array_push($withdrawal_array, $withdrawal_item);
            
            }
            echo json_encode($withdrawal_array);
        }
        else
        {
           
            echo json_encode(array("message" => "No transactions found."));
        }
    }

    public function searchWithdrawalRecord($id)
    {
        $query = "CALL withdrawal_SearchRecord(:id)";
        $stmt = $this->conn->prepare($query);

        if($stmt == false)
        {
            die("Failed to execute search withdrawalRecords". $stmt->errorInfo());
        }
        $stmt->bindParam(":id", $id);
        $stmt->execute();
        $result = $stmt->fetchAll(PDO:: FETCH_ASSOC);
        
        $num = count($result);
        if($num > 0)
        {
            echo json_encode($result);
        }
        else
        {
            http_response_code(404);
            echo json_encode(array("message" => "No transactions found."));
        }

    }

    public function deleteWithdrawalRecord($id)
    {
        $query = "CALL withdrawal_softDelete(:id) ";
        $stmt = $this->conn->prepare($query);

        if($stmt == false)
        {
            die("Failed to execute delete withdrawal Records". $stmt->errorInfo());
        }
        $stmt->bindParam(":id", $id);
        $stmt->execute();
        return $stmt;
    }

    public function updateWithdrawal()
    {
        $query = "CALL withdrawal_update(:withdrawalID, :inventoryID, :purpose, :withdrawnBy)";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(":withdrawalID", $this->withdrawalID);
        $stmt->bindParam(":inventoryID", $this->inventoryID);
        $stmt->bindParam(":purpose", $this->purpose);
        $stmt->bindParam(":withdrawnBy", $this->withdrawnBy);
 

        $stmt->execute();
        return $stmt;
    }
}
