<?php

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

include_once '../config/Database.php';
include_once "../Models/Products.php";

$method = $_SERVER["REQUEST_METHOD"];

$database = new Database();
$db = $database->getConnection();

$products = new Products($db);
$data = json_decode(file_get_contents("php://input"));



function handleUpdate($product) {
    global $data;
    if (
        !empty($data->inventoryID) &&
        !empty($data->product_name) &&
        !empty($data->product_quantity) &&
        !empty($data->category) 
       
    ) {
        $product->inventoryID = $data->inventoryID;
        $product->product_name = $data->product_name;
        $product->product_quantity = $data->product_quantity;
        $product->category = $data->category;
        $product->product_price = $data->product_price;
      

        if ($product->updateProduct()) {
            http_response_code(200);
            echo json_encode(array("message" => "Updated Successfully"));
        }
        else{
           
            echo json_encode(array("message" => "Update failed!"));
        }
    }
}

function handleDelete($product, $inventoryID) {
    if (!empty($inventoryID)) {
        if ($product->deleteProduct($inventoryID)) {
            http_response_code(200);
            echo json_encode(array("message" => "Product deleted successfully."));
        } else {
            http_response_code(503);
            echo json_encode(array("message" => "Unable to delete product."));
        }
    } else {
        http_response_code(400);
        echo json_encode(array("message" => "Invalid inventory ID."));
    }
}

function handleSearch($product,$keyword)
{
    $result = $product->searchProduct($keyword);
    $num = count($result);

    if($num > 0)
    {
        http_response_code(200);
        echo json_encode($result);
    } else {
        http_response_code(503);
        echo json_encode(array("message" => "No products found"));
    }
}


if ($method == "POST") 
{   if(strtoupper($data->Request) == "READ")
    {
        $products->getProducts();
    }
    if (isset($data->Request) && strtoupper($data->Request) == "DELETE") {
        handleDelete($products, $data->inventoryID);
    }
    else if(isset($data->Request) && strtoupper($data->Request) == "UPDATE")
    {
       $products->createUpdateProducts($data->transactionID, $data->product_name, $data->product_quantity,$data->product_price, $data->category, $data->inventoryID);
    }
    else if(isset($data->Request) && strtoupper($data->Request) == "SEARCH")
    {
       handleSearch($products,$data->inventoryID);
    }
    else {
    http_response_code(400);
    echo json_encode(array("message" => "Invalid request."));
    }
   
}

else
{
    http_response_code(400);
    echo json_encode(array("message" => "Method not Allowed"));
}

?>
