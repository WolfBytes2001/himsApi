<?php

class Reports
{
    private $conn;



    public function __construct($db)
    {
        $this->conn = $db;
    }

    public function GetSlowAndFastMovingItemsReport()
    {
        $query = "CALL report_slowFast()";
        $stmt = $this->conn->prepare($query);

        $stmt->execute();

       
        $num = $stmt->rowCount();

        if($num > 0)
        {
            $report_array = array();
            while($row = $stmt->fetch(PDO::FETCH_ASSOC))
            {
                extract($row);
                $report_item = array(
                    "product_name" => $product_name,
                    "times_sold" => $times_sold,
                    "total_sales_value" => $total_sales_value,
                    "added_at" => $first_added_at,
                    "last_sold_at" => $last_sold_at,
                    "days_on_sale" => $days_on_sale
    
                );
    
                array_push($report_array, $report_item);
               
            }
            echo json_encode($report_array);
    
        }
       

    }
    public function GetStockAgingReport()
    {
        $query = "CALL report_stockAging()";
        $stmt = $this->conn->prepare($query);

        $stmt->execute();
        $num = $stmt->rowCount();
        if($num > 0)
        {
            $report_array = array();
            while($row = $stmt->fetch(PDO:: FETCH_ASSOC))
            {
                extract($row);
                $report_item = array
                (
                    "inventoryID"=>$inventoryID,
                    "product_name"=>$product_name,
                    "product_quantity"=>$product_quantity,
                    "price" => $price,
                    "withdrawal_quantity" => $withdrawal_quantity,
                    "last_sold" =>$last_sale_date,
                    "stocked_on" =>$receipt_date,
                    "aging_bucket" => $aging_bucket
                );
                array_push($report_array,$report_item);
            }
            echo json_encode($report_array);
        }
        else
        {
            echo json_encode(array("message"=> "No reports found"));
        }
       
    }
    public function GetStocking()
    {
        $query = "CALL report_itemReceivingAndStocking()";
        $stmt = $this->conn->prepare($query);

        $stmt->execute();

        $num = $stmt->rowCount();
        if($num > 0)
        {
            $report_array = array();
            while($row = $stmt->fetch(PDO:: FETCH_ASSOC))
            {
                extract($row);
                $report_item = array
                (
                    "transactionID"=>$transactionID,
                    "date_received"=>$date_received,
                    "purchase_order"=>$purchase_order,
                    "delivered_by" => $delivered_by,
                    "recieved_by" => $recieved_by,
                    "inventoryID" =>$inventoryID,
                    "product_name" =>$product_name,
                    "quantity_received" => $quantity_received,
                    "unit_cost" =>$unit_cost,
                    "total_cost" => $total_cost
                    
                );
                array_push($report_array,$report_item);
            }
            echo json_encode($report_array);
        }
        else
        {
            echo json_encode(array("message"=> "No reports found"));
        }
       
    }

    public function GetWithdrawal()
    {
        $query = "CALL report_Withdrawal()";
        $stmt = $this->conn->prepare($query);

        $stmt->execute();

        $num = $stmt->rowCount();
        if($num > 0)
        {
            $report_array = array();
            while($row = $stmt->fetch(PDO:: FETCH_ASSOC))
            {
                extract($row);
                $report_item = array
                (
                    "withdrawalID"=>$withdrawalID,
                    "inventoryID"=>$inventoryID,
                    "product_name"=>$product_name,
                    "current_quantity" => $current_quantity,
                    "quantity_withdrawn" => $quantity_withdrawn,
                    "total_cost" =>$total_cost,
                    "purpose" =>$purpose,
                    "withdrawnBy" => $withdrawnBy,
                    "withdrawal_date" =>$withdrawal_date,
                    "orderID" => $orderID,
                    "customerName" =>$customerName,
                    "purchase_date" =>$purchase_date,
                    
                    
                );
                array_push($report_array,$report_item);
            }
            echo json_encode($report_array);
        }
        else
        {
            echo json_encode(array("message"=> "No reports found"));
        }
       
    }

    public function GetTransfer()
    {
        $query = "CALL report_Transfer()";
        $stmt = $this->conn->prepare($query);

        $stmt->execute();

        $num = $stmt->rowCount();
        if($num > 0)
        {
            $report_array = array();
            while($row = $stmt->fetch(PDO:: FETCH_ASSOC))
            {
                extract($row);
                $report_item = array
                (
                    "transferID"=>$transferID,
                    "inventoryID"=>$inventoryID,
                    "product_name"=>$product_name,
                    "storage" => $storage,
                    "initiated_at" => $initiated_at,
                    "handled_by" =>$handled_by,
                    
                );
                array_push($report_array,$report_item);
            }
            echo json_encode($report_array);
        }
        else
        {
            echo json_encode(array("message"=> "No reports found"));
        }
        
        }
    public function GetReturn()
    {
        $query = "CALL report_Return()";
        $stmt = $this->conn->prepare($query);

        $stmt->execute();
        $num = $stmt->rowCount();
        if($num > 0)
        {
            $report_array = array();
            while($row = $stmt->fetch(PDO:: FETCH_ASSOC))
            {
                extract($row);
                $report_item = array
                (
                    "returnID"=>$returnID,
                    "orderID"=>$orderID,
                    "handled_by"=>$handled_by,
                    "customerName" => $customerName,
                    "approval_status" => $approval_status,
                    "return_status" =>$return_status,
                    "return_recorded_at" =>$return_recorded_at,
                    "purchase_recorded_at" =>$purchase_recorded_at,
                );
                array_push($report_array,$report_item);
            }
            echo json_encode($report_array);
        }
        else
        {
            echo json_encode(array("message"=> "No reports found"));
        }
       
    }
}