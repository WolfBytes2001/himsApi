<?php

header("Content-Type: application/json; charset=UTF-8");


include_once "../models/Withdrawal.php";
include_once "../config/Database.php";
include_once "../models/Products.php";

$database = new Database();
$db = $database->getConnection();
$withdraw = new Withdrawal_Transaction($db);

$method = $_SERVER["REQUEST_METHOD"];
$data = json_decode(file_get_contents("php://input"));



if($method == "POST")
{   
    if(strtoupper($data->Request)== "SEARCH")
    {
        $withdraw->searchWithdrawalRecord($data->sequenceID);
    }
    if(strtoupper($data->Request)== "READ")
    {
        $withdraw->readAllWithdrawalRecords();
    }
    if(strtoupper($data->Request)== "DELETE")
    {
        $withdraw->deleteWithdrawalRecord($data->sequenceID);
    }
    if(strtoupper($data->Request)== "UPDATE")
    {
       $withdraw->createUpdateWithdrawalRecord($data->withdrawalID, $data->inventoryID, $data->purpose, $data->withdrawnBy, $data->quantity);
    }
}
else
{
    echo json_encode(array("message"=>"Method not allowed"));
}



