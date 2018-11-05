
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
if(!empty($argv[1])){
    $startIdx = $argv[1];
} else {
    $startIdx = "";
};
if(!empty($argv[2])){
    $endIdx = $argv[2];
} else {
    $endIdx = "";
}
$arr = glob('*');
natsort($arr);
//var_dump($arr);
foreach($arr as $f){
    if(is_dir($f)){
        if(!preg_match("/$startIdx/", $f) && empty($started)) continue;
        $started = true;
        echo "<br><h1>$f</h1><br>";
        $imgarr = glob("$f/*");
        natsort($imgarr);
        foreach($imgarr as $img){
            echo "<img src='$img'><br>";
        }
        if(!empty($endIdx) && preg_match("/$endIdx/", $f)) break;
    }
}
?>
</div>
</body>
</html>
