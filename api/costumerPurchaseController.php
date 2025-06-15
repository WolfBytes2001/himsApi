<?php
header("Content-Type: application/json; charset=UTF-8");

include_once '../config/Database.php';
include_once "../models/CostumerPurchase.php";

$database = new Database();
$db = $database->getConnection();
$purchase = new CostumerPurchase($db);

$method = $_SERVER["REQUEST_METHOD"];
$data = json_decode(file_get_contents("php://input"));


if ($method == "POST") {
    if (isset($data->Request) && strtoupper($data->Request) == "READ") 
    {
        $purchase->readAllOrderRecords();
    }
    else if (isset($data->Request)) 
    {
        if (strtoupper($data->Request) == "UPDATE")
        {

          $purchase->createUpdateCostumerPurchase($data->orderID, $data->withdrawalID, $data->customerName);
          
        }
        elseif (strtoupper($data->Request) == "SEARCH") 
        {
            $purchase->searchPurchase($data->orderID);
        } 
        
        elseif (strtoupper($data->Request) == "DELETE") 
        {
            $purchase->deletePurchase($data->orderID);
        }
       
    }
} 
else 
{
    echo json_encode(array("message" => "Method not allowed"));
}
