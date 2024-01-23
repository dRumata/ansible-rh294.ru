<?php
$servername = "localhost";
$username = "user1";
$password = "pass";

// Create connection
$conn = mysqli_connect($servername, $username, $password);

// Check connection
if (!$conn) {
  http_response_code(500); 
} else {
  http_response_code(200); 
}
