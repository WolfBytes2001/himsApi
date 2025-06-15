<?php

header("Content-Type: application/json; charset=UTF-8");


include_once "../models/returnTransactions.php";
include_once "../config/Database.php";

$database = new Database();
$db = $database->getConnection();

$return = new ReturnTransactions($db);

$method = $_SERVER["REQUEST_METHOD"];
$data = json_decode(file_get_contents("php://input"));


if($method == "POST")
{
    if(strtoupper($data->Request)== "UPDATE")
    {
        $return->createUpdateReturnTransaction($data->returnID, $data->orderID, $data->handled_by);
    }
    else if(strtoupper($data->Request) == "UNAPPROVED")
    {
        $return->viewUnApprovedRequest();
    }
    else if(strtoupper($data->Request) == "APPROVED")
    {
       $return->viewApprovedRequest();
    }
    else if(strtoupper($data->Request)== "READ")
    {
        $return->viewAllReturnRecords();
    }
    else if(strtoupper($data->Request)== "APPROVE_RETURN")
    {
       
        $return->approveReturnRequest($data->returnID);
    }
    
    else if(strtoupper($data->Request)== "DELETE")
    {
        $return->softDeletionReturn($data->returnID);
    }
    else if(strtoupper($data->Request)== "SEARCH")
    {
        $return->searchReturnRecord($data->returnID);
    }

    else
    {
        echo json_encode(array("message" => "Invalid request!"));
    }

}

else
{
    echo json_encode(array("message"=>"method not allowed"));
    
}