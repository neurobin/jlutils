
<html>
<head>

<style>
img{
    max-width: 100%;
    min-width: 80%;
    height: auto;
    background-size: contain;
}

</style>

</head>

<body>
<div style="width:100%;margin:10px 10px 10px;left:auto;right:auto;text-align:center">
<?php

$arr = glob('*');
$arr = preg_grep("/\.html$/i", $arr, PREG_GREP_INVERT);
natsort($arr);
//var_dump($arr);
foreach($arr as $f){
    echo "<img src='$f'><br>";
}
?>
</div>
</body>
</html>
