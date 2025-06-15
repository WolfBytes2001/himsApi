<?php

header("Content-Type: application/json; charset=UTF-8");


include_once '../config/Database.php';
include_once "../models/StockingTransactions.php";


$database = new Database();
$db = $database->getConnection();
$itemRecieve = new StockingTransactions($db);


$method = $_SERVER["REQUEST_METHOD"];
$data = json_decode(file_get_contents("php://input"));



if ($method == 'POST') {
   

    if (isset($data->Request) && strtoupper($data->Request) == "SEARCH" && !empty($data->transactionID)) {
        $itemRecieve->searchItemRecieveTransactions($data->transactionID);
    } 
    else if (isset($data->Request) && strtoupper($data->Request) == "UPDATE") {
        $itemRecieve->createAndUpdateStocking($data->transactionID, $data->delivered_by, $data->recieved_by,$data->purchase_order);
    }
    
    else if(isset($data->Request) && strtoupper($data->Request) == "READ")
    {
        $itemRecieve->getAllItemRecieveTransactions();
    }
    else {
        http_response_code(400);
        echo json_encode(array("message" => "Invalid request."));
    }
} 

else {
    http_response_code(405);
    echo json_encode(array("message" => "Method not allowed."));
}

?>
