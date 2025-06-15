<?php

class ReturnTransactions
{
    private $conn;
    public $returnID;
    public $orderID;
    public $handled_by;
    public $approval_status;
    public $status;
    public $isDeleted;
   

    public function __construct($db)
    {
        $this->conn = $db;
    }

    public function createUpdateReturnTransaction($returnID, $orderID, $handled_by)
    {
        $query = "CALL return_CreateRecord(:id,:orderID, :handled_by)";
        $stmt = $this->conn->prepare($query);
        if($stmt == false)
        {
            die("Failed to process request!");
        }
        $stmt->bindParam(":id", $returnID);
        $stmt->bindParam(":orderID", $orderID);
        $stmt->bindParam(":handled_by", $handled_by);
        
       if( $stmt->execute())
       {
            echo json_encode(array("message"=>"Request process successfully!"));
       }
        
    }

    public function viewUnApprovedRequest()
    {
        $query = "CALL return_adminApprovalList()";
        $stmt = $this->conn->prepare($query);
        $stmt->execute();
      
        $num = $stmt->rowCount();
    
        if($num > 0)
        {
            $return_array = array();
            while($row = $stmt->fetch(PDO::FETCH_ASSOC))
            {
                extract($row);
                $return_item = array(
                    "returnID" => $returnID,
                    "orderID " => $orderID,
                    "approval_status" => $approval_status,
                    "handled_by" => $handled_by,
                    "recorded_at" => $recorded_at
                );
                array_push($return_array, $return_item);
                
            }
            echo json_encode($return_array);
        }
        else
        {
            echo json_encode(array("message"=> "No unapproved records found!"));
        }
    }
    public function viewApprovedRequest()
    {
        $query = "CALL return_adminViewApprovedList()";
        $stmt = $this->conn->prepare($query);
        $stmt->execute();
      
        
        $num = $stmt->rowCount();
        
        if($num > 0)
        {
            $return_array = array();
            while($row = $stmt->fetch(PDO::FETCH_ASSOC))
            {
                extract($row);
                $return_item = array(
                    "returnID" => $returnID,
                    "orderID " => $orderID,
                    "approval_status" => $approval_status,
                    "handled_by" => $handled_by,
                    "recorded_at" => $recorded_at
                );
                array_push($return_array, $return_item);
                
            }
            echo json_encode($return_array);
        }
        else
        {
            echo json_encode(array("message"=> "No unapproved records found!"));
        }
    }

    public function viewAllReturnRecords()
    {
        $query = "CALL return_ReadAllRecords()";
        $stmt = $this->conn->prepare($query);
        $stmt->execute();
        $num = $stmt->rowCount();

        if($num > 0)
        {
            $return_array = array();
            while($row = $stmt->fetch(PDO::FETCH_ASSOC))
            {
                extract($row);
                $return_item = array(
                    "returnID" => $returnID,
                    "orderID" => $orderID,
                    "approval_status"=> $approval_status,
                    "status" => $status,
                    "handled_by" => $handled_by,
                    "recorded_at" => $recorded_at
                );
                array_push($return_array, $return_item);
                
            }
            echo json_encode($return_array);
        }
        else
        {
            echo json_encode(array("message"=>"No return records found!"));
        }
    }

    public function approveReturnRequest($id)
    {
        $query = "CALL return_ApproveReturn(:id)";
        $stmt = $this->conn->prepare($query);
        if($stmt == false)
        {
            die("Failed approving a return request");
        }
        $stmt->bindParam(":id", $id);
        
        if( $stmt->execute())
        {
            echo json_encode(array("message"=>"Return request:" . $id . " approved!"));
           }
           else
           {
            echo json_encode(array("message"=>"Return request:" . $id . " failed!"));
           }
       
    }

    public function softDeletionReturn($id)
    {
        $query = "CALL return_SoftDeletion(:id)";
        $stmt = $this->conn->prepare($query);
        if($stmt == false)
        {
            die("Failed to finish return transaction". $stmt->errorInfo());
        }
        $stmt->bindParam("id", $id);
       
        if($stmt->execute())
        {
            echo json_encode(array("message"=>"Return transaction deleted!"));
        }
    
        else
        {
            echo json_encode(array("message" => "Return transaction failed to delete"));
        }
    }

    public function searchReturnRecord($keyword)
    {
        $query = "CALL return_search(:id)";
        $stmt = $this->conn->prepare($query);
        if($stmt == false)
        {
            die("Failed to finish return transaction". $stmt->errorInfo());
        }
        $stmt->bindParam("id", $keyword);
        $stmt->execute();

        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
        echo json_encode($rows);
    }
}