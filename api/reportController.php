<?php

header("Content-Type: application/json; charset=UTF-8");


include_once "../config/Database.php";
include_once "../models/Reports.php";


$method = $_SERVER["REQUEST_METHOD"];
$data = json_decode(file_get_contents("php://input"));

$database = new Database();
$db = $database->getConnection();

$report = new Reports($db);



if($method == "POST")
{
    if(strtoupper($data->Request) == "SLOW_FAST")
    {
        $report->GetSlowAndFastMovingItemsReport();
    }
    if(strtoupper($data->Request) == "AGING")
    {
        $report->GetStockAgingReport();
    }
    if(strtoupper($data->Request) == "STOCKING")
    {
        $report->GetStocking();
    }
    if(strtoupper($data->Request) == "WITHDRAWAL")
    {
        $report->GetWithdrawal();
    }
    if(strtoupper($data->Request) == "TRANSFER")
    {
        $report->GetTransfer();
    }
    if(strtoupper($data->Request) == "RETURN")
    {
        $report->GetReturn();
    }
}
else
{
    echo json_encode(array("message" => "method not allowed!"));
}
