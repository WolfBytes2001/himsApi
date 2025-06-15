<?php


header("Content-Type: application/json; charset=UTF-8");


include_once "../config/Database.php";
include_once "../models/inventoryTransfer.php";


$database = new Database();
$db = $database->getConnection();

$transfer = new InventoryTransfer($db);


$method = $_SERVER["REQUEST_METHOD"];
$data = json_decode( file_get_contents("php://input"));



if($method == "POST")
{
    if(strtoupper($data->Request) == "UPDATE")
    {
        $transfer->createUpdateTransferRecord($data->transferID, $data->inventoryID, $data->storage, $data->handled_by);
    }
    else if(strtoupper($data->Request) == "READ")
    {
        $transfer->readAllTransferRecord();
    }
    
    else if(strtoupper($data->Request) == "DELETE")
    {
        $transfer->deleteTransferRecord($data->transferID);
    }

    else if(strtoupper($data->Request) == "SEARCH")
    {
        $transfer->searchTransferRecord($data->transferID);
    }
}