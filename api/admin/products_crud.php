<?php
include '../config.php';

$action = $_POST['action'] ?? $_GET['action'] ?? '';

switch($action){

  case "read":
    $q = mysqli_query($conn,"SELECT * FROM products");
    $data = [];
    while ($r = mysqli_fetch_assoc($q)) $data[]=$r;
    echo json_encode(["status"=>"success","data"=>$data]);
  break;

  case "add":
    $name  = $_POST['name'];
    $price = $_POST['price'];
    $image = $_POST['image'];
    $desc  = $_POST['description'];

    mysqli_query($conn,"INSERT INTO products (name,price,image,description)
    VALUES ('$name','$price','$image','$desc')");

    echo json_encode(["status"=>"success","message"=>"Produk ditambahkan"]);
  break;

  case "update":
    $id    = $_POST['id'];
    $name  = $_POST['name'];
    $price = $_POST['price'];
    $image = $_POST['image'];
    $desc  = $_POST['description'];

    mysqli_query($conn,"UPDATE products SET
      name='$name',
      price='$price',
      image='$image',
      description='$desc'
    WHERE id='$id'");

    echo json_encode(["status"=>"success","message"=>"Produk diupdate"]);
  break;

  case "delete":
    $id = $_POST['id'];
    mysqli_query($conn,"DELETE FROM products WHERE id='$id'");
    echo json_encode(["status"=>"success","message"=>"Produk dihapus"]);
  break;

  default:
    echo json_encode(["status"=>"error","message"=>"Action tidak valid"]);
}
