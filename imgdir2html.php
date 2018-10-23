
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
natsort($arr);
//var_dump($arr);
foreach($arr as $f){
    if(is_dir($f)){
        echo "<br><h1>$f</h1><br>";
        $imgarr = glob("$f/*");
        natsort($imgarr);
        foreach($imgarr as $img){
            echo "<img src='$img'><br>";
        }
    }
}
?>
</div>
</body>
</html>
