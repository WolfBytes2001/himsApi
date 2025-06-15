<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

include_once '../config/Database.php';
include_once "../models/StockingTransactions.php";
include_once "../models/Products.php";
include_once "../api/StockingTransactionsController.php";

$database = new Database();
$db = $database->getConnection();

$itemRecieve = new StockingTransactions($db);
$products = new Products($db);

$method = $_SERVER["REQUEST_METHOD"];
$data = json_decode(file_get_contents("php://input"));



if ($method == 'POST') {
   

    if (isset($data->Request) && strtoupper($data->Request) == "SEARCH" && !empty($data->transactionID)) {
        handleSearch($itemRecieve, $data->transactionID);
    } 
    else if (isset($data->Request) && strtoupper($data->Request) == "CREATE") {
        createStockingTransaction($itemRecieve, $products);
    }
    else if(isset($data->Request) && strtoupper($data->Request) == "UPDATE")
    {
        handleUpdate($itemRecieve);
    }
    else if(isset($data->Request) && strtoupper($data->Request) == "READ_ALL")
    {
         readAllStocking($itemRecieve);
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